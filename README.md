# Enumerize [![TravisCI](https://secure.travis-ci.org/brainspec/enumerize.png?branch=master)](http://travis-ci.org/brainspec/enumerize) [![Gemnasium](https://gemnasium.com/brainspec/enumerize.png)](https://gemnasium.com/brainspec/enumerize)

Enumerated attributes with I18n and ActiveRecord/Mongoid/MongoMapper support

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
  extend Enumerize

  enumerize :sex, in: [:male, :female]
end
```

ActiveRecord:

```ruby
class User < ActiveRecord::Base
  extend Enumerize

  enumerize :sex, in: [:male, :female], default: lambda { |user| SexIdentifier.sex_for_name(user.name).to_sym }

  enumerize :role, in: [:user, :admin], default: :user
end
```

Mongoid:

```ruby
class User
  include Mongoid::Document
  extend Enumerize

  field :role
  enumerize :role, in: [:user, :admin], default: :user
end
```

MongoMapper:

```ruby
class User
  include MongoMapper::Document
  extend Enumerize

  key :role
  enumerize :role, in: [:user, :admin], default: :user
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

Note that if you want to use I18n feature with plain Ruby object don't forget to extend it with `ActiveModel::Naming`:

```ruby
class User
  extend Enumerize
  extend ActiveModel::Naming
end
```

get attribute value:

```ruby
@user.sex_text # or @user.sex.text
```

get all values for enumerized attribute:

```ruby
User.sex.values # or User.enumerized_attributes[:sex].values
```

use it with forms (it supports `:only` and `:except` options):

```erb
<%= form_for @user do |f| %>
  <%= f.select :sex, User.sex.options %>
<% end %>
```

Boolean methods:

```ruby
user.sex = :male
user.sex.male? #=> true
user.sex.female? #=> false
```

Predicate methods:

```ruby
class User
  extend Enumerize

  enumerize :sex, in: %w(male female), predicates: true
end

user = User.new

user.male?   # => false
user.female? # => false

user.sex = 'male'

user.male?   # => true
user.female? # => false
```

Using prefix:

```ruby
class User
  extend Enumerize

  enumerize :sex, in: %w(male female), predicates: { prefix: true }
end

user = User.new
user.sex = 'female'
user.sex_female? # => true
```
Use `:only` and `:except` options to specify what values create predicate methods for.

To make some attributes shared across different classes it's possible to define them in a separate module and then include it into classes:

```ruby
module PersonEnumerations
  extend Enumerize

  enumerize :sex, in: %w[male female]
end

class Person
  include PersonEnumerations
end

class User
  include PersonEnumerations
end
```

It's also possible to store enumerized attribute value using custom values (e.g. integers). You can pass a hash as `:in` option to achieve this:

```ruby
class User < ActiveRecord::Base
  extend Enumerize

  enumerize :role, in: {:user => 1, :admin => 2}
end

user = User.new
user.role = :user
user.role #=> 'user'
user.role_value #=> 1
```

ActiveRecord scopes:

```ruby
class User < ActiveRecord::Base
  extend Enumerize
  enumerize :sex, :in => [:male, :female], scope: true
  enumerize :status, :in => { active: 1, blocked: 2 }, scope: :having_status
end

User.with_sex(:female)
# SELECT "users".* FROM "users" WHERE "users"."sex" IN ('female')

User.without_sex(:male)
# SELECT "users".* FROM "users" WHERE "users"."sex" NOT IN ('male')

User.having_status(:blocked).with_sex(:male, :female)
# SELECT "users".* FROM "users" WHERE "users"."status" IN (2) AND "users"."sex" IN ('male', 'female')
```

Array-like attributes with plain ruby objects:

```ruby
class User
  extend Enumerize

  enumerize :interests, in: [:music, :sports], multiple: true
end

user = User.new
user.interests << :music
user.interests << :sports
```

and with ActiveRecord:

```ruby
class User < ActiveRecord::Base
  extend Enumerize

  serialize :interests, Array
  enumerize :interests, in: [:music, :sports], multiple: true
end
```

### SimpleForm

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

### Formtastic

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

### RSpec

Also you can use builtin RSpec matcher:

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], default: :male
end

describe User do
  it { should enumerize(:sex).in(:male, :female) }
  it { should enumerize(:sex).in(:male, :female).with_default(:male) }
end
```

### Other Integrations

Enumerize integrates with the following automatically:

* [RailsAdmin](https://github.com/sferik/rails_admin/)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
