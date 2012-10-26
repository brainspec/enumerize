require 'active_support/concern'
require 'enumerize/version'

module Enumerize
  autoload :Attribute,    'enumerize/attribute'
  autoload :AttributeMap, 'enumerize/attribute_map'
  autoload :Value,        'enumerize/value'
  autoload :Set,          'enumerize/set'
  autoload :Base,         'enumerize/base'
  autoload :ActiveRecord, 'enumerize/activerecord'
  autoload :Predicates,   'enumerize/predicates'
  autoload :ModuleAttributes, 'enumerize/module_attributes'

  def self.included(base)
    ActiveSupport::Deprecation.warn '`include Enumerize` was deprecated. Please use `extend Enumerize`.', caller
    extended(base)
  end

  def self.extended(base)
    base.send :include, Enumerize::Base
    base.extend Enumerize::Predicates

    if defined?(::ActiveRecord::Base) && base < ::ActiveRecord::Base
      base.extend Enumerize::ActiveRecord
    end

    if Module === base
      base.extend Enumerize::Base::ClassMethods
      base.extend Enumerize::ModuleAttributes
    end

    super
  end

  begin
    require 'simple_form'
    require 'enumerize/hooks/simple_form'
    require 'enumerize/form_helper'
  rescue LoadError
  end

  begin
    require 'formtastic'
    require 'enumerize/hooks/formtastic'
  rescue LoadError
  end
end
