module StaticRecord
  # Class that immutable model instances can inherit from
  class Base
    include StaticRecord::GettersSettersConcern
    include StaticRecord::Querying
    include StaticRecord::SqliteStoringConcern

    RESERVED_ATTRIBUTES = [
      :@@_columns,
      :@@_primary_key,
      :@@_path_pattern,
      :@@_store,
      :@@_bound_static_tables
    ].freeze

    KNOWN_TYPES = [
      :string,
      :boolean,
      :integer,
      :float,
      :static_record
    ].freeze

    def initialize
      attributes.each do |attr, value|
        instance_variable_set "@#{attr}", value
        self.class.class_eval do
          attr_accessor :"#{attr}"
        end
      end
      super
    end

    def self.attribute(name, value)
      err = RESERVED_ATTRIBUTES.include?("@@#{name}".to_sym)
      raise StaticRecord::ReservedAttributeName, "#{name} is a reserved name" if err
      class_variable_set("@@#{name}", value)
    end

    def self.reference(name, value)
      attribute(name, value)
      unless value.class < StaticRecord::Base
        err = 'Reference only accepts StaticRecords'
        raise StaticRecord::ClassError, err
      end
      tables = superclass.bound_static_tables
      tables[value.class.store.to_sym] = name
      superclass.bound_static_tables = tables
    end

    def attributes
      attrs = {}
      klass = self.class
      klass.class_variables.each do |var|
        next if RESERVED_ATTRIBUTES.include?(var)
        attrs[var.to_s.sub(/@@/, '').to_sym] = klass.class_variable_get(var)
      end
      default_attributes(attrs)
    end

    def self.columns(cols)
      class_variable_set('@@_columns', cols)
      create_store
    end

    def self.get_column_type(column)
      class_variable_get(:@@_columns)[column]
    end

    private

    def default_attributes(attrs)
      klass = self.class
      klass.class_variable_get(:@@_columns).each do |column, _ctype|
        column_defined = attrs.key?(column)
        unless column_defined || default?(column)
          err = "You must define attribute '#{column}' for #{klass.name}"
          raise StaticRecord::MissingAttribute, err
        end

        v = column_defined ? attrs[column] : klass.send(:"default_#{column}")
        v = klass.send(:"override_#{column}", v) if override?(column)
        attrs[column] = v
      end
      attrs
    end

    def default?(column)
      self.class.respond_to?("default_#{column}")
    end

    def override?(column)
      self.class.respond_to?("override_#{column}")
    end
  end
end
