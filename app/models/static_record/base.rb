module StaticRecord
  # Class that immutable model instances can inherit from
  class Base #< ActiveRecord::Base
    # Subclasses must implement this class method
    # It should return its own files path pattern
    # Example: Rails.root.join('static_records', 'my_class', '**', '*.rb')
    def self.path_pattern
      raise NotImplementedError
    end

    # Subclasses must implement this class method
    # It should return the subclass name
    # Example: 'my_class'
    def self.store
      raise NotImplementedError
    end

    def self.all
      records = []
      Dir.glob(path_pattern) do |filepath|
        klass = get_class_from_file(filepath)
        if klass
          records << klass.constantize
        end
      end
      records
    end

    def self.where(query = nil)
      return self.all unless query

      results = []
      begin
        dbname = Rails.root.join('db', "static_#{store}.sqlite3").to_s
        db = SQLite3::Database.open(dbname)
        sqlized = query.keys.map { |k| "#{k.to_s} = '#{query[k]}'" }.join(' AND ')
        sql = "SELECT * FROM #{store} WHERE #{sqlized}"
        statement = db.prepare(sql)
        result_set = statement.execute
        results = result_set.map { |row| row[1].constantize }
      rescue SQLite3::Exception => e 
        puts "Exception occurred"
        puts e
      ensure
        statement.close if statement
        db.close if db
      end
      results
    end

    def self.index(columns)
      begin
        dbname = Rails.root.join('db', "static_#{store}.sqlite3").to_s
        SQLite3::Database.new(dbname)
        db = SQLite3::Database.open(dbname)
        db.execute("DROP TABLE IF EXISTS #{store}")
        db.execute("CREATE TABLE #{store}(id INTEGER PRIMARY KEY, klass TEXT, #{columns.map{|c| c.to_s + ' TEXT'}.join(', ')})")
        self.load_records(path_pattern).each_with_index do |record, index|
          attributes = record.constantize.class_variable_get(:@@attributes)
          sqlized = ["#{index}", "'#{record}'"] + columns.map { |c| "'#{attributes[c]}'" }
          db.execute("INSERT INTO #{store} VALUES(#{sqlized.join(', ')})")
        end
      rescue SQLite3::Exception => e 
        puts "Exception occurred"
        puts e
      ensure
        db.close if db
      end
    end

    private

    def self.load_records(path_pattern)
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

    def self.get_class_from_file(filepath)
      klass = nil
      File.open(filepath) do |file|
        match = file.grep(/class\s+([a-zA-Z0-9_]+)/)
        klass = match.first.chomp.gsub(/class\s+/, '') if match
      end
      klass
    end
  end
end
