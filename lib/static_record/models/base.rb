module StaticRecord
  # Class that immutable model instances can inherit from
  class Base
    include StaticRecord::Querying
    include StaticRecord::SqliteStoringConcern

    RESERVED_ATTRIBUTES = [
      :@@_columns,
      :@@_primary_key,
      :@@_path_pattern,
      :@@_store
    ].freeze

    KNOWN_TYPES = [
      :string,
      :boolean,
      :integer,
      :float
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

    def self.primary_key(name)
      err = RESERVED_ATTRIBUTES.include?("@@#{name}".to_sym)
      raise StaticRecord::ReservedAttributeName, "#{name} is a reserved name" if err
      class_variable_set('@@_primary_key', name)
    end

    def self.pkey
      class_variable_defined?(:@@_primary_key) ? class_variable_get('@@_primary_key') : nil
    end

    def self.table(store)
      class_variable_set('@@_store', store.to_s)
    end

    def self.store
      class_variable_get('@@_store')
    end

    def self.path(path)
      class_variable_set('@@_path_pattern', path)
    end

    def self.path_pattern
      class_variable_get('@@_path_pattern')
    end

    def attributes
      attrs = {}
      klass = self.class
      klass.class_variables.each do |var|
        next if RESERVED_ATTRIBUTES.include?(var)
        attrs[var.to_s.sub(/@@/, '').to_sym] = klass.class_variable_get(var)
      end
      attrs
    end

    def self.columns(cols)
      class_variable_set('@@_columns', cols)
      create_store
    end

    def self.get_column_type(column)
      class_variable_get(:@@_columns)[column]
    end
  end
end
