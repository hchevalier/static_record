module StaticRecord
  module Querying # :nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods # :nodoc:
      def method_missing(method_sym, *arguments, &block)
        if Relation.new(nil, store: store).respond_to?(method_sym, true)
          Relation.new(nil, store: store, primary_key: pkey).send(method_sym, *arguments, &block)
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        if Relation.new(nil, store: store).respond_to?(method_sym, true)
          true
        else
          super
        end
      end

      def respond_to_missing?(method_sym, include_private = false)
        if Relation.new(nil, store: store).respond_to_missing?(method_sym, true)
          true
        else
          super
        end
      end
    end
  end
end
