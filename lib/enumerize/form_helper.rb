# backport of https://github.com/rails/rails/commit/3be9e8a0c2187744b6c9879ca2836cef5ebed693
if defined?(ActionView::Helpers::InstanceTag)
  ActionView::Helpers::InstanceTag.class_eval do
    def self.check_box_checked?(value, checked_value)
      case value
      when TrueClass, FalseClass
        value
      when NilClass
        false
      when Integer
        value != 0
      when String
        value == checked_value
      else
        if value.respond_to?(:include?)
          value.include?(checked_value)
        else
          value.to_i != 0
        end
      end
    end
  end
end
