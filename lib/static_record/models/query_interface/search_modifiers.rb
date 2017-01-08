module StaticRecord
  # Contains ActiveRecord-like query interface methods
  module QueryInterface
    # Contains search modifiers
    module SearchModifiers
      private

      def joins(joint)
        joint = joint.store unless [String, Symbol].include?(joint.class)
        @joins_clauses << joint
        self
      end

      def limit(amount)
        @sql_limit = amount
        self
      end

      def offset(amount)
        @sql_offset = amount
        self
      end

      def order(ord)
        @order_by << ord
        self
      end

      def count
        @columns = 'COUNT(*)'
        exec_request(:integer)
      end
    end
  end
end
