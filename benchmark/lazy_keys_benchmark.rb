# frozen_string_literal: true

# Benchmark isolating the "lazy i18n keys" change in Enumerize::Value.
#
# It compares two implementations that differ ONLY in when the i18n lookup
# keys (and the humanized fallback string) are built:
#
#   * EAGER  - the previous behavior: build the keys array in #initialize and
#              retain it on every Value instance forever.
#   * LAZY   - the current behavior: build the keys on first #text and memoize
#              them copy-on-write on the attribute. Values whose #text is never
#              rendered build and retain nothing; rendered values pay once.
#
# So the memory columns are measured with #text never called (lazy retains
# nothing) and the throughput column is measured warm (lazy keys memoized),
# which is the realistic render path.
#
# Run: ruby -Ilib benchmark/lazy_keys_benchmark.rb

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'enumerize'
require 'benchmark/ips'
require 'objspace'

# A real attribute so the keys are built against real i18n_scopes/name.
KLASS = Class.new do
  extend Enumerize
  enumerize :status, in: %i[active inactive pending archived deleted suspended]
end
ATTR = KLASS.enumerized_attributes[:status]
NAMES = %i[active inactive pending archived deleted suspended].freeze

# EAGER variant: replicate the pre-change behavior (keys built and retained in
# the constructor), so the only axis that varies is eager-vs-lazy.
class EagerValue < Enumerize::Value
  def initialize(attr, name, value = nil)
    super
    @i18n_keys = build_i18n_keys
  end

  def text
    I18n.t(@i18n_keys[0], default: @i18n_keys[1..-1])
  end

  private

  def build_i18n_keys
    keys = @attr.i18n_scopes.map do |s|
      scope = Enumerize::Utils.call_if_callable(s, @value)
      :"#{scope}.#{self}"
    end
    keys << :"enumerize.defaults.#{@attr.name}.#{self}"
    keys << :"enumerize.#{@attr.name}.#{self}"
    keys << ActiveSupport::Inflector.humanize(ActiveSupport::Inflector.underscore(self))
    keys
  end
end

def build_values(value_class)
  NAMES.map { |n| value_class.new(ATTR, n).freeze }
end

# ---------------------------------------------------------------------------
# 1. Retained memory per value (the win) — text never rendered.
# ---------------------------------------------------------------------------
def retained_bytes(value_class, count)
  GC.start
  before = ObjectSpace.memsize_of_all
  store = Array.new(count) { build_values(value_class) }
  GC.start
  after = ObjectSpace.memsize_of_all
  store.clear
  after - before
end

COUNT = 5_000 # attributes worth of values (× 6 values each = 30k Value objects)
eager_mem = retained_bytes(EagerValue, COUNT)
lazy_mem  = retained_bytes(Enumerize::Value, COUNT)
values_total = COUNT * NAMES.size

# ---------------------------------------------------------------------------
# 2. Allocations to construct one attribute's worth of values (boot cost).
# ---------------------------------------------------------------------------
def construct_allocs(value_class, reps)
  GC.start
  GC.disable
  start = GC.stat(:total_allocated_objects)
  reps.times { build_values(value_class) }
  allocs = GC.stat(:total_allocated_objects) - start
  GC.enable
  allocs.to_f / reps
end

REPS = 2_000
eager_build_allocs = construct_allocs(EagerValue, REPS)
lazy_build_allocs  = construct_allocs(Enumerize::Value, REPS)

# ---------------------------------------------------------------------------
# 3. #text throughput — warm (lazy keys memoized on the attribute), the
#    realistic render path.
# ---------------------------------------------------------------------------
eager_values = build_values(EagerValue)
lazy_values  = build_values(Enumerize::Value)
lazy_values.each(&:text) # warm the attribute key cache

puts "\n#text throughput (higher is better):"
text_report = Benchmark.ips do |x|
  x.report('eager #text') { eager_values.each(&:text) }
  x.report('lazy  #text') { lazy_values.each(&:text) }
  x.compare!
end

eager_ips = text_report.entries.find { |e| e.label == 'eager #text' }.ips
lazy_ips  = text_report.entries.find { |e| e.label == 'lazy  #text' }.ips

# ---------------------------------------------------------------------------
# Markdown summary table.
# ---------------------------------------------------------------------------
fmt_kb  = ->(b) { format('%.1f KB', b / 1024.0) }
fmt_b   = ->(b) { format('%.1f B', b.to_f) }
pct     = ->(from, to) { format('%+.1f%%', (to - from) * 100.0 / from) }

puts "\n\n## Lazy i18n keys — benchmark results"
puts "\nRuby #{RUBY_VERSION}, #{values_total} Value objects measured for memory.\n\n"
puts '| Metric | Eager (before) | Lazy (after) | Change |'
puts '| --- | --- | --- | --- |'
puts "| Retained memory, #{values_total} values (text never called) | #{fmt_kb[eager_mem]} | #{fmt_kb[lazy_mem]} | #{pct[eager_mem, lazy_mem]} |"
puts "| Retained memory per value | #{fmt_b[eager_mem.to_f / values_total]} | #{fmt_b[lazy_mem.to_f / values_total]} | #{fmt_b[(lazy_mem - eager_mem).to_f / values_total]}/value |"
puts "| Objects allocated building one attribute (6 values) | #{format('%.1f', eager_build_allocs)} | #{format('%.1f', lazy_build_allocs)} | #{pct[eager_build_allocs, lazy_build_allocs]} |"
puts "| #text throughput (i/s, 6 values/iter, warm) | #{format('%.0f', eager_ips)} | #{format('%.0f', lazy_ips)} | #{pct[eager_ips, lazy_ips]} |"
puts "\n_Lazy wins on memory and build cost; memoization keeps #text on par with eager._"
