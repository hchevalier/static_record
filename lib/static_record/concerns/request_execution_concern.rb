module StaticRecord
  module RequestExecutionConcern # :nodoc:
    extend ActiveSupport::Concern

    private

    def exec_request(expectancy = :result_set)
      return build_query if @only_sql

      dbname = Rails.root.join('db', 'static_records.sqlite3').to_s
      result = get_expected_result_from_database(dbname, expectancy)
      cast_result(expectancy, result)
    end

    def get_expected_result_from_database(dbname, expectancy)
      result = nil

      begin
        db = SQLite3::Database.open(dbname)
        query = build_query
        if expectancy == :integer
          result = db.get_first_value(query)
        else
          statement = db.prepare(query)
          result_set = statement.execute
          result = result_set.map { |row| row[1].constantize.new }
        end
      rescue SQLite3::Exception => e
        error, msg = handle_error(e, query)
      ensure
        statement.close if statement
        db.close if db
      end
      raise error, msg if error

      result
    end

    def handle_error(error, query)
      msg = query ? "#{error} in #{query}" : error
      [error, msg]
    end

    def cast_result(expectancy, result)
      if expectancy == :result_set
        case @result_type
        when :array
          result = [] if result.nil?
        when :record
          result = result.empty? ? nil : result.first
        end
      end

      result
    end
  end
end
