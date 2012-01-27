# Enumerize [![TravisCI](https://secure.travis-ci.org/twinslash/enumerize.png?branch=master)](http://travis-ci.org/twinslash/enumerize)

Enumerated attributes with I18n and ActiveRecord support

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

I18n:

```ruby
en:
  enumerize:
    user:
      sex:
        male: "Male"
        female: "Female"
```

or if you use `sex` attribute across several models you can use this:

```ruby
en:
  enumerize:
    sex:
      male: "Male"
      female: "Female"
```

get attribute value:

```ruby
  @user.sex_text # or @user.sex.text
```

use it with forms:

```ruby
<%= form_for @user do |f| %>
  <%= f.select :sex, User.sex.options %>
<% end %>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
