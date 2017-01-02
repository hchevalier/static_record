module StaticRecord
  # Provides has_static_record when included
  class HasStaticRecord
    def self.define_on(klass, name, options)
      new(klass, name, options).define
    end

    def initialize(klass, name, options)
      @klass = klass
      @name = name
      @options = options
    end

    def define
      define_getter
      define_setter
    end

    private

    def define_getter
      name = @name
      options = @options
      @klass.send :define_method, @name do
        record_type = send(:"#{name}_static_record_type")
        return nil unless record_type

        options[:class_name] ||= name.to_s.camelize
        # eager loading may be disabled, initialize parent class
        superklass = options[:class_name].constantize
        superklass.find_by(klass: record_type)
      end
    end

    def define_setter
      name = @name
      options = @options
      @klass.send :define_method, "#{@name}=" do |static_record|
        options[:class_name] ||= name.to_s.camelize
        superklass = static_record.class.superclass

        unless superklass.to_s == options[:class_name]
          err = "Record must be an instance of #{options[:class_name]}, got #{superklass}"
          raise ClassError, err
        end

        unless superklass.pkey
          err = "No primary key has been defined for #{superklass.class}"
          raise NoPrimaryKey, err
        end

        send(:"#{name}_static_record_type=", static_record.class.name)
      end
    end
  end
end
