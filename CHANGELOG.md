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
