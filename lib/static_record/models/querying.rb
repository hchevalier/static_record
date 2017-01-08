module StaticRecord
  module Querying # :nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods # :nodoc:
      def method_missing(method_sym, *arguments, &block)
        params = relation_params
        if Relation.new(nil, params).respond_to?(method_sym, true)
          Relation.new(nil, params).send(method_sym, *arguments, &block)
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        if Relation.new(nil, relation_params).respond_to?(method_sym, true)
          true
        else
          super
        end
      end

      def respond_to_missing?(method_sym, include_private = false)
        if Relation.new(nil, relation_params).respond_to_missing?(method_sym, true)
          true
        else
          super
        end
      end

      private

      def relation_params
        {
          klass: name,
          store: store,
          primary_key: pkey
        }
      end
    end
  end
end
