module StaticRecord
  # Reads ruby files whose path matches path pattern and store them
  # as records in an SQLite3 database
  module SqliteStoringConcern
    extend ActiveSupport::Concern

    module ClassMethods # :nodoc:
      def create_store
        columns = class_variable_get(:@@_columns)
        begin
          dbname = Rails.root.join('db', "static_#{store}.sqlite3").to_s
          SQLite3::Database.new(dbname)
          db = SQLite3::Database.open(dbname)
          db.execute("DROP TABLE IF EXISTS #{store}")
          create_table(db, columns)
          load_records.each_with_index do |record, index|
            insert_into_database(db, record, index, columns)
          end
        rescue SQLite3::Exception => e
          puts 'Exception occurred', e
        ensure
          db.close if db
        end
      end

      private

      def create_table(db, columns)
        cols = columns.map { |c| c.to_s + ' TEXT' }.join(', ')
        sql = "CREATE TABLE #{store}(id INTEGER PRIMARY KEY, klass TEXT, #{cols})"
        db.execute(sql)
      end

      def insert_into_database(db, record, index, columns)
        attrs = record.constantize.new.attributes
        sqlized = [index.to_s, "'#{record}'"] # id, klass
        sqlized += columns.map { |c| "'#{attrs[c]}'" } # model's attributes
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
