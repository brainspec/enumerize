require 'active_support/concern'
require 'enumerize/version'

module Enumerize
  autoload :Attribute,    'enumerize/attribute'
  autoload :AttributeMap, 'enumerize/attribute_map'
  autoload :Value,        'enumerize/value'
  autoload :Base,         'enumerize/base'
  autoload :ActiveRecord, 'enumerize/activerecord'
  autoload :ModuleAttributes, 'enumerize/module_attributes'

  def self.included(base)
    base.send :include, Enumerize::Base
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
  rescue LoadError
  end

  begin
    require 'formtastic'
    require 'enumerize/hooks/formtastic'
  rescue LoadError
  end
end
