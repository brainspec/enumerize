require 'active_support/concern'
require 'enumerize/version'

module Enumerize
  autoload :Attribute,    'enumerize/attribute'
  autoload :AttributeMap, 'enumerize/attribute_map'
  autoload :Value,        'enumerize/value'
  autoload :Set,          'enumerize/set'
  autoload :Base,         'enumerize/base'
  autoload :Module,       'enumerize/module'
  autoload :Predicates,   'enumerize/predicates'
  autoload :Predicatable, 'enumerize/predicatable'
  autoload :ModuleAttributes, 'enumerize/module_attributes'

  autoload :ActiveModelAttributesSupport, 'enumerize/activemodel'
  autoload :ActiveRecordSupport, 'enumerize/activerecord'
  autoload :SequelSupport, 'enumerize/sequel'
  autoload :MongoidSupport,      'enumerize/mongoid'

  module Scope
    autoload :ActiveRecord, 'enumerize/scope/activerecord'
    autoload :Sequel, 'enumerize/scope/sequel'
    autoload :Mongoid,      'enumerize/scope/mongoid'
  end

  def self.included(base)
    ActiveSupport::Deprecation.warn '`include Enumerize` was deprecated. Please use `extend Enumerize`.', caller
    extended(base)
  end

  def self.extended(base)
    base.send :include, Enumerize::Base
    base.extend Enumerize::Predicates

    if defined?(::ActiveModel::Attributes)
      base.extend Enumerize::ActiveModelAttributesSupport
    end

    if defined?(::ActiveRecord::Base)
      base.extend Enumerize::ActiveRecordSupport
      base.extend Enumerize::Scope::ActiveRecord
    end

    if defined?(::Mongoid::Document)
      base.extend Enumerize::MongoidSupport
      base.extend Enumerize::Scope::Mongoid
    end

    if defined?(::Sequel::Model)
      base.extend Enumerize::SequelSupport
      base.extend Enumerize::Scope::Sequel
    end

    if defined?(::RailsAdmin)
      require 'enumerize/integrations/rails_admin'
      base.extend Enumerize::Integrations::RailsAdmin
    end

    if ::Module === base
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

  begin
    require 'rspec/matchers'
  rescue LoadError
  else
    require 'enumerize/integrations/rspec'
  end
end
