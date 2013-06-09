require 'enumerize'
require 'rspec'

class RSpecUser
  extend Enumerize

  enumerize :sex, in: [:male, :female], default: :male
end

describe RSpecUser do
  it { should enumerize(:sex).in(:male, :female) }
  it { should enumerize(:sex).in(:male, :female).with_default(:male) }
end
