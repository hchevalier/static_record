module StaticRecord
  # Reads ruby files whose path matches path pattern and store them
  # as records in an SQLite3 database
  module SqliteStoringConcern
    extend ActiveSupport::Concern

    module ClassMethods # :nodoc:
      def create_store
        cols = class_variable_get(:@@_columns)
        begin
          dbname = Rails.root.join('db', "static_#{store}.sqlite3").to_s
          SQLite3::Database.new(dbname)
          db = SQLite3::Database.open(dbname)
          db.execute("DROP TABLE IF EXISTS #{store}")
          create_table(db, cols)
          load_records.each_with_index do |record, index|
            insert_into_database(db, record, index, cols)
          end
        rescue SQLite3::Exception => e
          puts 'Exception occurred', e
        ensure
          db.close if db
        end
      end

      private

      def create_table(db, cols)
        attr_list = []
        cols.each do |c, v|
          attr_list << c.to_s + column_type_to_sql(v)
        end
        str_attr = attr_list.join(', ')
        sql = "CREATE TABLE #{store}(id INTEGER PRIMARY KEY, klass TEXT, #{str_attr})"
        db.execute(sql)
      end

      def column_type_to_sql(ctype)
        case ctype.to_s
        when 'string'
          ' TEXT'
        else
          " #{ctype.to_s.upcase}"
        end
      end

      def insert_into_database(db, record, index, cols)
        # TODO: get attributes without instantiating the record
        # that currently forces to declare base file (ex: badge.rb) columns
        # at the end of file, without what Badge instance methods are not defined
        # yet during BadgeOne#initialize
        attrs = record.constantize.new.attributes
        # id, klass
        sqlized = [index.to_s, "'#{record}'"]
        # model's attributes
        sqlized += cols.map do |name, ctype|
          ctype == :integer ? attrs[name].to_s : "'#{attrs[name]}'"
        end

        db.execute("INSERT INTO #{store} VALUES(#{sqlized.join(', ')})")
      end

      def load_records
        records = []
        Dir.glob(path_pattern) do |filepath|
          klass = get_class_from_file(filepath)
          if klass
            require filepath
            records << klass
          end
        end
        records
      end

      def get_class_from_file(filepath)
        klass = nil
        File.open(filepath) do |file|
          match = file.grep(/class\s+([a-zA-Z0-9_]+)/)
          klass = match.first.chomp.gsub(/class\s+/, '').split(' ')[0] if match
        end
        klass
      end
    end
  end
end
