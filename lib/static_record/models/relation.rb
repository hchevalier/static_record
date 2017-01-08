module StaticRecord
  class Relation # :nodoc:
    attr_reader :columns,
                :sql_limit,
                :sql_offset,
                :where_clauses,
                :joins_clauses,
                :chain,
                :result_type,
                :order_by,
                :only_sql

    include StaticRecord::QueryInterface::Interface
    include StaticRecord::QueryBuildingConcern
    include StaticRecord::RequestExecutionConcern

    def initialize(previous_node, params)
      @store = params[:store]
      @table = params[:store]
      @klass = params[:klass]
      @primary_key = params[:primary_key]

      @columns = '*'
      @sql_limit = nil
      @sql_offset = nil
      @where_clauses = []
      @joins_clauses = []
      @chain = :and
      @result_type = :array
      @order_by = []
      @only_sql = false

      chained_from(previous_node) if previous_node
    end

    def method_missing(method_sym, *arguments, &block)
      if respond_to?(method_sym, true)
        params = {
          klass: @klass,
          store: @store,
          primary_key: @primary_key
        }
        Relation.new(self, params).send(method_sym, *arguments, &block)
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
      @joins_clauses = relation.joins_clauses.deep_dup
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
  end
end
