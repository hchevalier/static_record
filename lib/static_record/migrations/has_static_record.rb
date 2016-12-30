module StaticRecord
  # Provides has_static_record when included
  module HasStaticRecord
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods # :nodoc:
      def has_static_record(table_name, options = nil)
        options ||= {}
        class_eval do
          define_setter(table_name, options)
          define_getter(table_name, options)
        end
      end

      private

      def define_setter(table_name, options)
        define_method("#{table_name}=") do |static_record|
          unless static_record.class.pkey
            err = "No primary key has been defined for #{static_record.class}"
            raise NoPrimaryKey, err
          end

          table = __method__.to_s.delete('=')
          options[:class_name] ||= table.camelize
          superklass = static_record.class.superclass
          unless superklass.to_s == options[:class_name]
            err = "Record must be an instance of #{options[:class_name]}"
            raise ClassError, err
          end

          send(:"#{table}_static_record_type=", static_record.class.name)
        end
      end

      def define_getter(table_name, options)
        define_method(table_name) do
          table = __method__.to_s
          record_type = send(:"#{table}_static_record_type")
          return nil unless record_type

          options[:class_name] ||= table.camelize
          # eager loading may be disabled, initialize parent class
          superklass = options[:class_name].constantize
          superklass.find_by(klass: record_type)
        end
      end
    end
  end
end
