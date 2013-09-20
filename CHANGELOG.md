## master ##

### enhancements
  * Integration with SimpleForm's `input_field` (by [@nashby](https://github.com/nashby))

### bug fix
  * Return proper RSpec failure message for enumerized attribute with default value (by [@nashby](https://github.com/nashby))
  * Return proper RSpec description for enumerized attribute without default value (by [@andreygerasimchuk](https://github.com/andreygerasimchuk))
  * Do not try to set default value for not selected attributes (by [@nashby](https://github.com/nashby))

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
