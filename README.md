# Enumerize [![Ruby](https://github.com/brainspec/enumerize/actions/workflows/ruby.yml/badge.svg)](https://github.com/brainspec/enumerize/actions/workflows/ruby.yml)

Enumerated attributes with I18n and ActiveRecord/Mongoid/MongoMapper/Sequel support

## Table of Contents

- [Installation](#installation)
- [Supported Versions](#supported-versions)
- [Usage](#usage)
- [Database support](#database-support)
  - [ActiveRecord](#activerecord)
  - [Mongoid](#mongoid)
  - [MongoMapper](#mongomapper)
- [I18n Support](#i18n-support)
  - [I18n Helper Methods](#i18n-helper-methods)
- [Boolean Helper Methods](#boolean-helper-methods)
  - [Basic](#basic)
  - [Predicate Methods](#predicate-methods)
- [Optimzations and Tips](#optimzations-and-tips)
  - [Extendable Module](#extendable-module)
  - [Customizing Enumerize Value](#customizing-enumerize-value)
  - [ActiveRecord scopes](#activerecord-scopes)
  - [Array-like Attributes](#array-like-attributes)
- [Forms](#forms)
  - [SimpleForm](#simpleform)
  - [Formtastic](#formtastic)
- [Testing](#testing)
  - [RSpec](#rspec)
  - [Minitest with Shoulda](#minitest-with-shoulda)
  - [Other Integrations](#other-integrations)
- [Contributing](#contributing)

## Installation

Add this line to your application's Gemfile:

    gem 'enumerize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install enumerize

## Supported Versions

- Ruby 2.7+
- Rails 5.2+

## Usage

Basic:

```ruby
class User
  extend Enumerize

  enumerize :role, in: [:user, :admin]
end
```

Note that enumerized values are just identificators so if you want to use multi-word, etc. values then you should use `I18n` feature.

---

## Database support

### ActiveRecord

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :status
      t.string :role

      t.timestamps
    end
  end
end

class User < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], default: lambda { |user| StatusIdentifier.status_for_age(user.age).to_sym }

  enumerize :role, in: [:user, :admin], default: :user
end
```

:warning: By default, `enumerize` adds `inclusion` validation to the model. You can skip validations by passing `skip_validations` option. :warning:

```ruby
class User < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], skip_validations: lambda { |user| user.new_record? }

  enumerize :role, in: [:user, :admin], skip_validations: true
end
```

### Mongoid

```ruby
class User
  include Mongoid::Document
  extend Enumerize

  field :role
  enumerize :role, in: [:user, :admin], default: :user
end
```

### MongoMapper

```ruby
class User
  include MongoMapper::Document
  extend Enumerize

  key :role
  enumerize :role, in: [:user, :admin], default: :user
end
```

---

## I18n Support

```ruby
en:
  enumerize:
    user:
      status:
        student: "Student"
        employed: "Employed"
        retired: "Retiree"
```

or if you use `status` attribute across several models you can use `defaults` scope:

```ruby
en:
  enumerize:
    defaults:
      status:
        student: "Student"
        employed: "Employed"
        retired: "Retiree"
```

You can also pass `i18n_scope` option to specify scope (or array of scopes) storing the translations.

```ruby
class Person
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :status, in: %w[student employed retired], i18n_scope: "status"
  enumerize :roles, in: %w[user admin], i18n_scope: ["user.roles", "roles"]
end

# localization file
en:
  status:
    student: "Student"
    employed: "Employed"
    retired: "Retiree"
  user:
    roles:
      user: "User"
  roles:
    admin: "Admin"
```

Note that if you want to use I18n feature with plain Ruby object don't forget to extend it with `ActiveModel::Naming`:

```ruby
class User
  extend Enumerize
  extend ActiveModel::Naming
end
```

### I18n Helper Methods

#### \*\_text / .text

Attribute's I18n text value:

```ruby
@user.status_text # or @user.status.text
```

#### values

List of possible values for an enumerized attribute:

```ruby
User.status.values # or User.enumerized_attributes[:status].values
# => ['student', 'employed', 'retired']
```

#### I18n text values

List of possible I18n text values for an enumerized attribute:

```ruby
User.status.values.collect(&:text)
# => ['Student', 'Employed', 'Retiree']
```

#### Form example

Use it with forms (it supports `:only` and `:except` options):

```erb
<%= form_for @user do |f| %>
  <%= f.select :status, User.status.options %>
<% end %>
```

---

## Boolean Helper Methods

### Basic

```ruby
user.status = :student
user.status.student? #=> true
user.status.retired? #=> false
```

### Predicate Methods

```ruby
class User
  extend Enumerize

  enumerize :status, in: %w(student employed retired), predicates: true
end

user = User.new

user.student?  # => false
user.employed? # => false

user.status = :student

user.student?  # => true
user.employed? # => false
```

:warning: If `enumerize` is used with Mongoid, it's not recommended to use `"writer"` as a field value since `writer?` is defined by Mongoid. [See more](https://github.com/brainspec/enumerize/issues/235). :warning:

#### Predicate Prefixes

```ruby
class User
  extend Enumerize

  enumerize :status, in: %w(student employed retired), predicates: { prefix: true }
end

user = User.new
user.status = 'student'
user.status_student? # => true
```

Use `:only` and `:except` options to specify what values create predicate methods for.

---

## Optimzations and Tips

### Extendable Module

To make some attributes shared across different classes it's possible to define them in a separate module and then include it into classes:

```ruby
module RoleEnumerations
  extend Enumerize

  enumerize :roles, in: %w[user admin]
end

class Buyer
  include RoleEnumerations
end

class Seller
  include RoleEnumerations
end
```

### Customizing Enumerize Value

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

### ActiveRecord scopes:

#### Basic

```ruby
class User < ActiveRecord::Base
  extend Enumerize
  enumerize :role, :in => [:user, :admin], scope: true
  enumerize :status, :in => { student: 1, employed: 2, retired: 3 }, scope: :having_status
end

User.with_role(:admin)
# SELECT "users".* FROM "users" WHERE "users"."role" IN ('admin')

User.without_role(:admin)
# SELECT "users".* FROM "users" WHERE "users"."role" NOT IN ('admin')

User.having_status(:employed).with_role(:user, :admin)
# SELECT "users".* FROM "users" WHERE "users"."status" IN (2) AND "users"."role" IN ('user', 'admin')
```

#### Shallow Scopes

Adds named scopes to the class directly.

```ruby
class User < ActiveRecord::Base
  extend Enumerize
  enumerize :status, :in => [:student, :employed, :retired], scope: :shallow
  enumerize :role, :in => { user: 1, admin: 2 }, scope: :shallow
end

User.student
# SELECT "users".* FROM "users" WHERE "users"."status" = 'student'

User.admin
# SELECT "users".* FROM "users" WHERE "users"."role" = 2
```

:warning: It is not possible to define a scope when using the `:multiple` option. :warning:

### Array-like Attributes

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
def status
  if current_user.admin?
    "Super #{super}"
  else
    super
  end
end
```

---

## Forms

### SimpleForm

If you are using SimpleForm gem you don't need to specify input type (`:select` by default) and collection:

```erb
<%= simple_form_for @user do |f| %>
  <%= f.input :status %>
<% end %>
```

and if you want it as radio buttons:

```erb
<%= simple_form_for @user do |f| %>
  <%= f.input :status, :as => :radio_buttons %>
<% end %>
```

Please note that Enumerize overwrites the I18n keys of SimpleForm collections. The enumerized keys are used instead of the SimpleForm ones for inputs concerning enumerized attributes. If you don't want this just pass `:collection` option to the `input` call.

### Formtastic

If you are using Formtastic gem you also don't need to specify input type (`:select` by default) and collection:

```erb
<%= semantic_form_for @user do |f| %>
  <%= f.input :status %>
<% end %>
```

and if you want it as radio buttons:

```erb
<%= semantic_form_for @user do |f| %>
  <%= f.input :status, :as => :radio %>
<% end %>
```

---

## Testing

### RSpec

Also you can use builtin RSpec matcher:

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired]
end

describe User do
  it { should enumerize(:status) }

  # or with RSpec 3 expect syntax
  it { is_expected.to enumerize(:status) }
end
```

#### Qualifiers

##### in

Use `in` to test usage of the `:in` option.

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired]
end

describe User do
  it { should enumerize(:status).in(:student, :employed, :retired) }
end
```

You can test enumerized attribute value using custom values with the `in`
qualifier.

```ruby
class User
  extend Enumerize

  enumerize :role, in: { user: 0, admin: 1 }
end

describe User do
  it { should enumerize(:role).in(user: 0, admin: 1) }
end
```

##### with_default

Use `with_default` to test usage of the `:default` option.

```ruby
class User
  extend Enumerize

  enumerize :role, in: [:user, :admin], default: :user
end

describe User do
  it { should enumerize(:user).in(:user, :admin).with_default(:user) }
end
```

##### with_i18n_scope

Use `with_i18n_scope` to test usage of the `:i18n_scope` option.

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], i18n_scope: 'status'
end

describe User do
  it { should enumerize(:status).in(:student, :employed, :retired).with_i18n_scope('status') }
end
```

##### with_predicates

Use `with_predicates` to test usage of the `:predicates` option.

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], predicates: true
end

describe User do
  it { should enumerize(:status).in(:student, :employed, :retired).with_predicates(true) }
end
```

You can text prefixed predicates with the `with_predicates` qualifiers.

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], predicates: { prefix: true }
end

describe User do
  it { should enumerize(:status).in(:student, :employed, :retired).with_predicates(prefix: true) }
end
```

##### with_scope

Use `with_scope` to test usage of the `:scope` option.

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], scope: true
end

describe User do
  it { should enumerize(:status).in(:student, :employed, :retired).with_scope(true) }
end
```

You can test a custom scope with the `with_scope` qualifiers.

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed], scope: :employable
end

describe User do
  it { should enumerize(:status).in(:student, :employed, :retired).with_scope(scope: :employable) }
end
```

##### with_multiple

Use `with_multiple` to test usage of the `:multiple` option.

```ruby
class User
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], multiple: true
end

describe User do
  it { should enumerize(:status).in(:student, :employed, :retired).with_multiple(true) }
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

- [RailsAdmin](https://github.com/sferik/rails_admin/)

---

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
