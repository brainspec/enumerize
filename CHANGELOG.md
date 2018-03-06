## master

### enhancements

### bug fix

## 2.2.2 (March 6, 2018)

### bug fix

* Support non-ActiveModel objects in SimpleForm/Formtastic integration. (by [@nashby](https://github.com/nashby))

## 2.2.1 (February 15, 2018)

### bug fix

* Fix issue with SimpleForm/Formtastic forms without object. (by [@nashby](https://github.com/nashby))

## 2.2.0 (February 13, 2018)

### enhancements

* Add integration with active_interaction. (by [@runephilosof](https://github.com/runephilosof))
* Allow using `plugin :enumerize` with Sequel. (by [@jnylen](https://github.com/jnylen))
* Support ActiveModel::Attributes from Rails 5.2. (by [@troter](https://github.com/troter))
* Support Sequel 5.2.0. (by [@troter](https://github.com/troter))

### bug fix

* Fix RailsAdmin integration when enumerated field used on edit form and enumerated value wasn't set. (by [@nashby](https://github.com/nashby))
* Fallback to a raw passed value instead of nil if AR type can't find value in the attribute. (by [@nashby](https://github.com/nashby))

## 2.1.2 (May 18, 2017)

### bug fix

* Support YAML serialization for the custom AR type. (by [@lest](https://github.com/lest))

## 2.1.1 (May 1, 2017)

### enhancements

* Run tests with multiple DBs (SQLite and PostgreSQL). (by [tkawa](https://github.com/tkawa))

### bug fix

* Support deserialize and Rails 4.2 methods in the custom AR::Type class. (by [@lest](https://github.com/lest))
* Support dumping custom AR type to JSON. (by [@lest](https://github.com/lest))

## 2.1.0 (March 31, 2017)

### enhancements

* Support Active Record types serialization. (by [@lest](https://github.com/lest))

## 2.0.1 (October 18, 2016)

### bug fix

* Support enumerized attributes in #update_all on relation objects. (by [@lest](https://github.com/lest))

## 2.0.0 (August 10, 2016)

### enhancements

* Drop support for Ruby older than 2.2. Support only Ruby 2.2+. (by [@nashby](https://github.com/nashby))
* Drop support for Rails 4.0 and 4.1. Support only Rails 4.2 and newer. (by [@lest](https://github.com/lest))
* Support Rails 5.0. (by [@nashby](https://github.com/nashby) and [@lest](https://github.com/lest))
* Allow to pass enumerize values to `ActiveRecord#update_all` (by [@DmitryTsepelev](https://github.com/DmitryTsepelev) and [@ianwhite](https://github.com/ianwhite))

  ```ruby
  User.update_all(status: :blocked)
  ```

### bug fix

* Rescue MissingAttributeError on attribute writing. (by [@embs](https://github.com/embs))
* Fix presence validation for multiple attributes when the list contains a blank string. (by [@smoriwaki](https://github.com/smoriwaki))
* Replace deprecated alias_method_chain with Module#prepend. (by [@koenpunt](https://github.com/koenpunt) and [@akm](https://github.com/akm))
* Make it compatible with `globalize` gem. (by [@falm](https://github.com/falm))
* Prevent method getter from being called when no default_value is being set. (by [@arjan0307](https://github.com/arjan0307))

## 1.1.1 (January 25, 2016)

### bug fix

* Fix exception when using predicate methods and enumerized values have dash in it. (by [@nashby](https://github.com/nashby))

## 1.1.0 (November 15, 2015)

### enhancements
 * Add Sequel support. (by [@mrbrdo](https://github.com/mrbrdo))
 * Add qualifiers to RSpec matcher. (by [@maurogeorge](https://github.com/maurogeorge))
 * Support hash in the RSpec matcher. (by [@maurogeorge](https://github.com/maurogeorge))

### bug fix

## 1.0.0 (August 2, 2015)

### enhancements
 * Add `texts` method for getting an array of text values of the enumerized field with multiple type. (by [@huynhquancam](https://github.com/huynhquancam))
 * Drop Rails 3.2 support. (by [@nashby](https://github.com/nashby))

### bug fix

 * Fix conflicts when Active Record and Mongoid are used at the same time. (by [@matsu911](https://github.com/matsu911))

## 0.11.0 (March 29, 2015) ##

### enhancements
 * Add ability to set default value for enumerized field with multiple type. (by [@nashby](https://github.com/nashby))
 * Support Rails 4.2. (by [@lest](https://github.com/lest))

### bug fix
 * Use Mongoid's `:in` method for generated scopes, fix chained scopes. (by [@nashby](https://github.com/nashby))
 * Use `after_initialize` callback to set default value in Mongoid documents. (by [@nashby](https://github.com/nashby))

## 0.10.1 (March 4, 2015) ##

### bug fix

 * Use method_missing instead of defining singleton class methods to allow Marshal serialization (by [@lest](https://github.com/lest))

## 0.10.0 (February 17, 2015) ##

### enhancements

 * Add scopes support to mongoid documents (by [@nashby](https://github.com/nashby))
 * Use underscore.humanize in #text to make use of Inflector acronyms (by [@mintuhouse](https://github.com/mintuhouse))
 * Raise an exception when :scope option is used together with :multiple option (by [@maurogeorge](https://github.com/maurogeorge))
 * Use alias_method_chain instead of overriding Class#inherited (by [@yuroyoro](https://github.com/yuroyoro))
 * Shortcut methods to retrieve enumerize values (by [@CyborgMaster](https://github.com/CyborgMaster))
 * Extend equality operator to support comparing with symbols and custom values (e.g. integers) (by [@CyborgMaster](https://github.com/CyborgMaster))

## 0.9.0 (December 11, 2014) ##

### enhancements

  * Add :value_class option (by [@lest](https://github.com/lest))
  * Use 'defaults' scope in the localization file for the attributes that used across several models. This will help to avoid conflicting keys with model names and attribute names. Example:

  ```yml
    en:
      enumerize:
        defaults:
          sex:
            male: Male
            female: Female
  ```

  You still can use the old solution without "default" scope:

  ```yml
    en:
      enumerize:
        sex:
          male: Male
          female: Female
  ```
  (by [@nashby](https://github.com/nashby))

### bug fix
  * Store values for validation using string keys (by [@nagyt234](https://github.com/nagyt234))
  * Store custom values for multiple attributes (by [@lest](https://github.com/lest))
  * Support validations after using AR#becomes (by [@lest](https://github.com/lest))
  * Do not try to set attribute for not selected attributes (by [@dany1468](https://github.com/dany1468))

## 0.8.0 (March 4, 2014) ##

### enhancements
  * Integration with SimpleForm's `input_field` (by [@nashby](https://github.com/nashby))
  * Support multiple attributes in Active Record #becomes method (by [@lest](https://github.com/lest))
  * Add ability to specify localization scope with `i18n_scope` option (by [@dreamfall](https://github.com/dreamfall))

### bug fix
  * Fix Rails Admin integration when custom values are used (by [@brenes](https://github.com/brenes))
  * Fix RSpec integration using enumerize with Spring (by [@winston](https://github.com/winston))
  * Return proper RSpec failure message for enumerized attribute with default value (by [@nashby](https://github.com/nashby))
  * Return proper RSpec description for enumerized attribute without default value (by [@andreygerasimchuk](https://github.com/andreygerasimchuk))
  * Do not try to set default value for not selected attributes (by [@nashby](https://github.com/nashby))
  * Fix uniqueness validation with Active Record (by [@lest](https://github.com/lest))
  * Fix loading of attributes with multiple: true in mongoid (by [glebtv](https://github.com/glebtv))
  * Serialize value as scalar type (by [@ka8725](https://github.com/ka8725))

## 0.7.0 (August 21, 2013) ##

### enhancements
  * Give priority to model specific translation definition. See example [here](https://github.com/brainspec/enumerize/pull/96) (by [@labocho](https://github.com/labocho))
  * Allow lambda in default value (by [@adie](https://github.com/adie))
  * Add predicate methods to the multiple attributes (by [@nashby](https://github.com/nashby))
  * Add RSpec matcher (by [@nashby](https://github.com/nashby))
  * Add `*_value` method that returns actual value of the enumerized attribute (useful for attributes with custom values)
    (by [@tkyowa](https://github.com/tkyowa))

### bug fix
  * Make validation work when `write_attribute` is using for setting enumerized values (by [@nashby](https://github.com/nashby))
  * Validates enumerized values when enumeration is included via module
    (by [@nashby](https://github.com/nashby)) and (by [@lest](https://github.com/lest))

## 0.6.1 (May 20, 2013) ##

### bug fix
  * Don't raise error when enumerized attribute is already defined. (by [@lest](https://github.com/lest))

## 0.6.0 (May 16, 2013) ##

### enhancements
  * Use inclusion error message for invalid values (by [@lest](https://github.com/lest))
  * Add `:only` and `except` options to the `Attribute#options` method. (by [@thehappycoder](https://github.com/thehappycoder) and [@randoum](https://github.com/randoum))
  * ActiveRecord scopes. (by [@lest](https://github.com/lest), [@banyan](https://github.com/banyan) and [@nashby](https://github.com/nashby))
  * Support for RailsAdmin (by [@drewda](https://github.com/drewda))

### bug fix
  * Return correct default value for enumerized attribute using `default_scope` with generated scope [@nashby](https://github.com/nashby)
  * Allow either key or value as valid (by [aghull](https://github.com/aghull) and [@lest](https://github.com/lest))
  * Use default enum value from db column (by [@lest](https://github.com/lest))

## 0.5.1 (December 10, 2012) ##

### bug fix

  * Always return Enumerize::Set for multiple attributes (by [@nashby](https://github.com/nashby))

## 0.5.0 (October 31, 2012) ##

The previous method of adding enumerize to a class was deprecated. Please use
`extend Enumerize` instead of `include Enumerize`.

### enhancements
  * SimpleForm support for multiple attributes. (by [@nashby](https://github.com/nashby))
  * Formtastic support for multiple attributes. (by [@nashby](https://github.com/nashby))
  * Array-like multiple attributes. (by [@lest](https://github.com/lest))

## 0.4.0 (September 6, 2012) ##

Legacy support was dropped. The following versions are supported:

* Ruby 1.9.3+ (including JRuby and Rubinius)
* Rails 3.2+
* Formtastic 2.2+
* SimpleForm 2+
* Mongoid 3+

### enhancements
  * Ability to define predicate methods on enumerized object. (by [@lest](https://github.com/lest))

## 0.3.0 (July 9, 2012) ##

### enhancements
  * Accept a values hash to store an attribute using custom values (e.g. integers) (by [@lest](https://github.com/lest))

## 0.2.2 (May 22, 2012) ##

### bug fix
  * Correctly assign default value to handle mass assignment in Active Record (by [@lest](https://github.com/lest))

## 0.2.1 (May 21, 2012) ##

### bug fix
  * Call super in attribute accessors if available (by [@lest](https://github.com/lest))

## 0.2.0 (March 29, 2012) ##

### enhancements
  * Ability to enumerize attributes in a module and then include it into classes (by [@lest](https://github.com/lest))
  * Add error to a model when attribute value is not included in allowed list (by [@lest](https://github.com/lest))

### bug fix
  * Inheriting enumerized attributes (by [@cgunther](https://github.com/cgunther) and [@nashby](https://github.com/nashby))
  * Don't cast nil to string (by [@jimryan](https://github.com/jimryan))

## 0.1.1 (March 6, 2012) ##

### bug fix
  * I18n regression: Multiple calls to value #text return different results (by [@cgunther](https://github.com/cgunther) and [@lest](https://github.com/lest))

## 0.1.0 (March 5, 2012) ##

### enhancements
  * Return humanized value if there are no translations (by [@nashby](https://github.com/nashby))
  * Integration with SimpleForm (by [@nashby](https://github.com/nashby))
  * Integration with Formtastic (by [@lest](https://github.com/lest))

## 0.0.4 (February 8, 2012) ##

### bug fix
  * Make attribute accessors to work with ActiveRecord 3.1.x (by [@lest](https://github.com/lest))

## 0.0.3 (February 8, 2012) ##

### enhancements
  * Mongoid support (by [@lest](https://github.com/lest))
  * Boolean methods (by [@Dreamfa11](https://github.com/Dreamfa11))
