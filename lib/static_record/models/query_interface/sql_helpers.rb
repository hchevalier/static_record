module StaticRecord
  # Contains ActiveRecord-like query interface methods
  module QueryInterface
    # Contains SQL helpers
    module SqlHelpers
      private

      def to_sql
        build_query
      end

      def see_sql_of
        @only_sql = true
        self
      end

      def no_sql
        @only_sql = false
        self
      end
    end
  end
end
