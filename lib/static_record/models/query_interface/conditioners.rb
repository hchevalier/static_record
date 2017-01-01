module StaticRecord
  # Contains ActiveRecord-like query interface methods
  module QueryInterface
    # Contains conditioners
    module Conditioners
      private

      def where(query = nil, *params)
        params = [params] unless params.is_a?(Array) || params.is_a?(Hash)
        params = params.first if params.size == 1 && params[0].is_a?(Hash)
        add_subclause({ q: query }, params) if query
        self
      end

      def not(query, *params)
        params = [params] unless params.is_a?(Array) || params.is_a?(Hash)
        params = params.first if params.size == 1 && params[0].is_a?(Hash)
        add_subclause({ q: query, operator: :not_eq }, params)
        self
      end

      def or
        @chain = :or
        self
      end
    end
  end
end
