module StaticRecord
  # Contains ActiveRecord-like query predicates
  module Predicates
    private

    def where(query = nil, *params)
      params = [params] unless params.is_a?(Array) || params.is_a?(Hash)
      params = params.first if params.size == 1 && params[0].is_a?(Hash)
      add_subclause({ q: query }, params) if query
      self
    end

    def not(query, *params)
      params = [params] unless params.is_a?(Array) || params.is_a?(Hash)
      params = params.first if params.size == 1 && params[0].is_a?(Hash)
      add_subclause({ q: query, operator: :not_eq }, params)
      self
    end

    def or
      @chain = :or
      self
    end

    def all
      to_a
    end

    def find(value)
      raise StaticRecord::NoPrimaryKey, 'No primary key have been set' if @primary_key.nil?
      @result_type = :record unless value.is_a?(Array)
      add_subclause(q: { :"#{@primary_key}" => value })
      @sql_limit = 1 if @result_type == :record

      res = to_a
      return res if @only_sql

      raise StaticRecord::RecordNotFound, "Couldn't find all #{@store.singularize.capitalize} with '#{@primary_key.to_s}' IN #{value}" if @result_type == :array && res.size != value.size
      raise StaticRecord::RecordNotFound, "Couldn't find #{@store.singularize.capitalize} with '#{@primary_key.to_s}'=#{value}" if @result_type == :record && res.nil?

      res
    end

    def find_by(query)
      add_subclause(q: query)
      take(1)
    end

    def take(amount = 1)
      @sql_limit = amount
      @result_type = :record if amount == 1
      to_a
    end

    def first(amount = 1)
      @order_by << { :"#{@primary_key}" => :asc } if @order_by.empty?
      take(amount)
    end

    def last(amount = 1)
      @order_by << { :"#{@primary_key}" => :desc } if @order_by.empty?
      res = take(amount)
      res.reverse! if res.is_a?(Array)
      res
    end

    def limit(amount)
      @sql_limit = amount
      self
    end

    def offset(amount)
      @sql_offset = amount
      self
    end

    def order(ord)
      @order_by << ord
      self
    end

    def count
      @columns = 'COUNT(*)'
      exec_request(:integer)
    end

    def to_sql
      build_query
    end

    def see_sql_of
      @only_sql = true
      self
    end

    def to_a
      exec_request
    end
  end
end
