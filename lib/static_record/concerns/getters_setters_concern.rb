module StaticRecord
  # Contains StaticRecord::Base getters and setters
  module GettersSettersConcern
    extend ActiveSupport::Concern

    module ClassMethods # :nodoc:
      def primary_key(name)
        err = StaticRecord::Base::RESERVED_ATTRIBUTES.include?("@@#{name}".to_sym)
        raise StaticRecord::ReservedAttributeName, "#{name} is a reserved name" if err
        class_variable_set('@@_primary_key', name)
      end

      def pkey
        class_variable_defined?(:@@_primary_key) ? class_variable_get('@@_primary_key') : nil
      end

      def bound_static_tables
        return {} unless class_variable_defined?(:@@_bound_static_tables)
        class_variable_get('@@_bound_static_tables')
      end

      def bound_static_tables=(value)
        class_variable_set('@@_bound_static_tables', value)
      end

      def table(store)
        class_variable_set('@@_store', store.to_s)
      end

      def store
        class_variable_get('@@_store')
      end

      def path(path)
        class_variable_set('@@_path_pattern', path)
      end

      def path_pattern
        class_variable_get('@@_path_pattern')
      end
    end
  end
end
