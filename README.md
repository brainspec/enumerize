# Enumerize

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'enumerize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install enumerize

## Usage

Basic:

```ruby
class User
  include Enumerize

  enumerize :sex, :in => [:male, :female]
end
```

ActiveRecord:

```ruby
class User < ActiveRecord::Base
  include Enumerize

  enumerize :sex, :in => [:male, :female]

  enumerize :role, :in => [:user, :admin], :default => :user
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
