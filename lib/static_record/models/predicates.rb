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
      unless value.is_a?(Array)
        @result_type = :record
        @sql_limit = 1
      end
      add_subclause(q: { :"#{@primary_key}" => value })
      res = to_a

      unless @only_sql
        case @result_type
        when :array
          if res.size != value.size
            err = "Couldn't find all #{@store.singularize.capitalize} "\
            "with '#{@primary_key}' IN #{value}"
            raise StaticRecord::RecordNotFound, err
          end
        when :record
          if res.nil?
            err = "Couldn't find #{@store.singularize.capitalize} "\
            "with '#{@primary_key}'=#{value}"
            raise StaticRecord::RecordNotFound, err
          end
        end
      end

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
