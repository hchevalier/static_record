module StaticRecord
  class Relation # :nodoc:
    attr_reader :columns,
                :sql_limit,
                :sql_offset,
                :where_clauses,
                :chain,
                :result_type,
                :order_by,
                :only_sql

    include Predicates
    include StaticRecord::QueryBuildingConcern

    def initialize(previous_node, params)
      @store = params[:store]
      @table = params[:store]
      @primary_key = params[:primary_key]

      @columns = '*'
      @sql_limit = nil
      @sql_offset = nil
      @where_clauses = []
      @chain = :and
      @result_type = :array
      @order_by = []
      @only_sql = false

      chained_from(previous_node) if previous_node
    end

    def method_missing(method_sym, *arguments, &block)
      if respond_to?(method_sym, true)
        Relation.new(self, store: @store, primary_key: @primary_key).send(method_sym, *arguments, &block)
      elsif [].respond_to?(method_sym)
        to_a.send(method_sym)
      else
        super
      end
    end

    def respond_to?(method_sym, include_private = false)
      if !include_private && [].respond_to?(method_sym, include_private)
        true
      else
        super
      end
    end

    def respond_to_missing?(method_sym, include_private = false)
      include_private ? super : respond_to?(method_sym, true)
    end

    private

    def chained_from(relation)
      @columns = relation.columns
      @sql_limit = relation.sql_limit
      @sql_offset = relation.sql_offset
      @where_clauses = relation.where_clauses.deep_dup
      @chain = relation.chain
      @result_type = relation.result_type
      @order_by = relation.order_by.deep_dup
      @only_sql = relation.only_sql
    end

    def add_subclause(clause, params = nil)
      params ||= {}

      clause[:chain] = @chain unless clause[:chain].present?
      clause[:operator] = :eq unless clause[:operator].present?
      clause[:parameters] = params

      @where_clauses << clause
      @chain = :and
    end

    def exec_request(expectancy = :result_set)
      return build_query if @only_sql

      dbname = Rails.root.join('db', "static_#{@store}.sqlite3").to_s
      result = get_expected_result_from_database(dbname, expectancy)
      cast_result(expectancy, result)
    end

    def get_expected_result_from_database(dbname, expectancy)
      result = nil

      begin
        db = SQLite3::Database.open(dbname)
        if expectancy == :integer
          result = db.get_first_value(build_query)
        else
          statement = db.prepare(build_query)
          result_set = statement.execute
          result = result_set.map { |row| row[1].constantize.new }
        end
      rescue SQLite3::Exception => e
        error = e
      ensure
        statement.close if statement
        db.close if db
      end

      raise error if error

      result
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
