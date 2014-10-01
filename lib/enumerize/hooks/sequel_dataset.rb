module Enumerize
  module Hooks
    module SequelDataset
      def self.included(klass)
        klass.alias_method_chain :literal_append, :enumerize
      end

      def literal_append_with_enumerize(sql, v)
        if v.is_a?(Enumerize::Value)
          literal_append(sql, v.value)
        else
          literal_append_without_enumerize(sql, v)
        end
      end
    end
  end
end

::Sequel::Dataset.send :include, Enumerize::Hooks::SequelDataset
