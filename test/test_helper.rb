require 'minitest/autorun'
require 'minitest/spec'

$VERBOSE=true
YAML::ENGINE.yamler = ENV['YAMLER'] if ENV['YAMLER']

require 'enumerize'
