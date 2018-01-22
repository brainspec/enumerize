# Enumerize [![TravisCI](https://secure.travis-ci.org/brainspec/enumerize.svg?branch=master)](http://travis-ci.org/brainspec/enumerize) [![Gemnasium](https://gemnasium.com/brainspec/enumerize.svg)](https://gemnasium.com/brainspec/enumerize)

Enumerated attributes with I18n and ActiveRecord/Mongoid/MongoMapper/Sequel support

## Installation

Add this line to your application's Gemfile:

    gem 'enumerize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install enumerize

## Supported Versions
- Ruby 2.2+
- Rails 4.2+

## Usage

Basic:

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female]
end
```

Note that enumerized values are just identificators so if you want to use multi-word, etc. values you should use `I18n` feature.


ActiveRecord:

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :sex
      t.string :role

      t.timestamps
    end
  end
end

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

or if you use `sex` attribute across several models you can use `defaults` scope:

```ruby
en:
  enumerize:
    defaults:
      sex:
        male: "Male"
        female: "Female"
```

You can also pass `i18n_scope` option to specify scope (or array of scopes) storing the translations.


```ruby
class Person
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :sex, in: %w[male female], i18n_scope: "sex"
  enumerize :color, in: %w[black white], i18n_scope: ["various.colors", "colors"]
end

# localization file
en:
  sex:
    male: "Male"
    female: "Female"
  various:
    colors:
      black: "Black"
  colors:
    white: "White"
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
:warning: If `enumerize` is used with Mongoid, it's not recommended to use `"writer"` as a field value since `writer?` is defined by Mongoid. [See more](https://github.com/brainspec/enumerize/issues/235). :warning:

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

User.role.find_value(:user).value #=> 1
User.role.find_value(:admin).value #=> 2
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

:warning: It is not possible to define a scope when using the `:multiple` option. :warning:

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

get an array of all text values:

```ruby
@user.interests.texts # shortcut for @user.interests.map(&:text)
```

Also, the reader method can be overridden, referencing the enumerized attribute value using `super`:

```ruby
def sex
  if current_user.admin?
    "Super#{super}"
  else
    super
  end
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

Please note that Enumerize overwrites the I18n keys of SimpleForm collections. The enumerized keys are used instead of the SimpleForm ones for inputs concerning enumerized attributes. If you don't want this just pass `:collection` option to the `input` call.

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

  enumerize :sex, in: [:male, :female]
end

describe User do
  it { should enumerize(:sex) }

  # or with RSpec 3 expect syntax
  it { is_expected.to enumerize(:sex) }
end
```

#### Qualifiers

##### in

Use `in` to test usage of the `:in` option.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female]
end

describe User do
  it { should enumerize(:sex).in(:male, :female) }
end
```

You can test enumerized attribute value using custom values with the `in`
qualifier.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: { male: 0, female: 1 }
end

describe User do
  it { should enumerize(:sex).in(male: 0, female: 1) }
end
```

##### with_default

Use `with_default` to test usage of the `:default` option.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], default: :female
end

describe User do
  it { should enumerize(:sex).in(:male, :female).with_default(:female) }
end
```

##### with_i18n_scope

Use `with_i18n_scope` to test usage of the `:i18n_scope` option.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], i18n_scope: 'sex'
end

describe User do
  it { should enumerize(:sex).in(:male, :female).with_i18n_scope('sex') }
end
```

##### with_predicates

Use `with_predicates` to test usage of the `:predicates` option.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], predicates: true
end

describe User do
  it { should enumerize(:sex).in(:male, :female).with_predicates(true) }
end
```

You can text prefixed predicates with the `with_predicates` qualifiers.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], predicates: { prefix: true }
end

describe User do
  it { should enumerize(:sex).in(:male, :female).with_predicates(prefix: true) }
end
```

##### with_scope

Use `with_scope` to test usage of the `:scope` option.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], scope: true
end

describe User do
  it { should enumerize(:sex).in(:male, :female).with_scope(true) }
end
```

You can text custom scope with the `with_scope` qualifiers.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], scope: :having_sex
end

describe User do
  it { should enumerize(:sex).in(:male, :female).with_scope(scope: :having_sex) }
end
```

##### with_multiple

Use `with_multiple` to test usage of the `:multiple` option.

```ruby
class User
  extend Enumerize

  enumerize :sex, in: [:male, :female], multiple: true
end

describe User do
  it { should enumerize(:sex).in(:male, :female).with_multiple(true) }
end
```

### Minitest with Shoulda

You can use the RSpec matcher with shoulda in your tests by adding two lines in your `test_helper.rb` inside `class ActiveSupport::TestCase` definition:

```ruby
class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  require 'enumerize/integrations/rspec'
  extend Enumerize::Integrations::RSpec

  ...
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
