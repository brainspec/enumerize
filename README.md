# Enumerize [![TravisCI](https://secure.travis-ci.org/twinslash/enumerize.png?branch=master)](http://travis-ci.org/twinslash/enumerize) [![Gemnasium](https://gemnasium.com/twinslash/enumerize.png)](https://gemnasium.com/twinslash/enumerize)

Enumerated attributes with I18n and ActiveRecord/Mongoid support

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

Mongoid:

```ruby
class User
  include Mongoid::Document
  include Enumerize

  field :role
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

get all values for enumerized attribute:

```ruby
User.sex.values # or User.enumerized_attributes[:sex].values
```

use it with forms:

```erb
<%= form_for @user do |f| %>
  <%= f.select :sex, User.sex.options %>
<% end %>
```

If you are using SimpleForm gem you don't need to specify input type (`:select` by default) and collection:

```erb
<%= simple_form_for @user do |f| %>
  <%= f.input :sex %>
<% end %>
```

and if you want it as radio buttons:

```erb
<%= simple_form_for @user do |f| %>
  <%= f.input :sex, :as => :radio_buttons %>
<% end %>
```

If you are using Formtastic gem you also don't need to specify input type (`:select` by default) and collection:

```erb
<%= semantic_form_for @user do |f| %>
  <%= f.input :sex %>
<% end %>
```

and if you want it as radio buttons:

```erb
<%= semantic_form_for @user do |f| %>
  <%= f.input :sex, :as => :radio %>
<% end %>
```

Boolean methods:

```ruby
user.sex = :male
user.sex.male? #=> true
user.sex.female? #=> false
```

To make some attributes shared across different classes it's possible to define them in a separate module and then include it into classes:

```ruby
module PersonEnumerations
  include Enumerize

  enumerize :sex, :in => %w[male female]
end

class Person
  include PersonEnumerations
end

class User
  include PersonEnumerations
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
