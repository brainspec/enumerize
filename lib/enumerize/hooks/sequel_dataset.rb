module Enumerize
  module Hooks
    module SequelDataset
      def literal_append(sql, v)
        if v.is_a?(Enumerize::Value)
          super(sql, v.value)
        else
          super(sql, v)
        end
      end
    end
  end
end

::Sequel::Dataset.send :prepend, Enumerize::Hooks::SequelDataset
