module StaticRecord
  # Provides helper methods that can be used in migrations
  module Schema
    COLUMNS = {
      static_record_type: :string
    }.freeze

    def self.included(_base)
      ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Statements
      ActiveRecord::Migration::CommandRecorder.send :include, CommandRecorder
    end

    module Statements # :nodoc:
      def bind_static_record(table_name, *record_tables)
        raise ArgumentError, 'Please specify StaticRecord table in your bind_static_record call.' if record_tables.empty?

        options = record_tables.extract_options!
        record_tables.each do |record_table|
          COLUMNS.each_pair do |column_name, column_type|
            column_options = options.merge(options[column_name.to_sym] || {})
            add_column(table_name, "#{record_table}_#{column_name}", column_type, column_options)
          end
        end
      end

      def remove_static_record(table_name, *record_tables)
        raise ArgumentError, 'Please specify StaticRecord table in your remove_static_record call.' if record_tables.empty?

        record_tables.each do |record_table|
          COLUMNS.keys.each do |column_name|
            remove_column(table_name, "#{record_table}_#{column_name}")
          end
        end
      end
    end

    module CommandRecorder # :nodoc:
      def bind_static_record(*args)
        record(:bind_static_record, args)
      end

      private

      def invert_bind_static_record(args)
        [:remove_static_record, args]
      end
    end
  end
end
