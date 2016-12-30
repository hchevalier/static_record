module StaticRecord
  # Helps building SQL queries
  module QueryBuildingConcern
    extend ActiveSupport::Concern

    def build_query
      sql = sql_select_from
      sql += sql_where unless @where_clauses.empty?
      sql += sql_order unless @order_by.empty?
      sql += sql_limit_offset if @sql_limit
      sql
    end

    private

    def sql_select_from
      "SELECT #{@columns} FROM #{@table}"
    end

    def sql_where
      " WHERE #{where_clause_builder}"
    end

    def sql_order
      return '' unless @primary_key

      ord_sql = ''
      @order_by.each do |ord|
        ord_sql += ord_sql.empty? ? ' ORDER BY' : ', '
        case ord.class.name
        when Hash.name
          ord_sql += ord.map { |k, v| " #{@table}.#{k} #{v.to_s.upcase}" }.join(',')
        when Array.name
          ord_sql += ord.map { |sym| " #{@table}.#{sym} ASC" }.join(',')
        when Symbol.name
          ord_sql += " #{@table}.#{ord} ASC"
        when String.name
          ord_sql += " #{ord}"
        end
      end
      ord_sql
    end

    def sql_limit_offset
      sql = " LIMIT #{@sql_limit}"
      sql += " OFFSET #{@sql_offset}" if @sql_offset
      sql
    end

    def where_clause_builder
      params = []
      @where_clauses.map do |clause|
        subquery = clause[:q]
        if subquery.is_a?(Hash)
          params << where_clause_from_hash(clause, subquery)
        elsif subquery.is_a?(String)
          params << where_clause_from_string(clause, subquery)
        end

        if params.size > 1
          joint = clause[:chain] == :or ? 'OR' : 'AND'
          params = [params.join(" #{joint} ")]
        end
      end

      params.first
    end

    def where_clause_from_hash(clause, subquery)
      parts = subquery.keys.map do |key|
        value = subquery[key]
        if value.is_a?(Array)
          # ex: where(name: ['John', 'Jack'])
          # use IN operator
          value.map! { |v| v =~ /^\d+$/ ? v : "\"#{v}\"" }
          inverse = 'NOT ' if clause[:operator] == :not_eq
          "#{key} #{inverse}IN (#{value.join(',')})"
        else
          # ex: where(name: 'John')
          # use = operator
          inverse = '!' if clause[:operator] == :not_eq
          "#{key} #{inverse}= '#{value}'"
        end
      end
      parts.join(' AND ')
    end

    def where_clause_from_string(clause, subquery)
      final_string = subquery
      if clause[:parameters].is_a?(Array)
        # Anon parameters
        # ex: where("name = ? OR name = ?", 'John', 'Jack')
        clause[:parameters].each do |param|
          final_string.sub!(/\?/, "\"#{param}\"")
        end
      elsif clause[:parameters].is_a?(Hash)
        # Named parameters (placeholder condition)
        # ex: where("name = :one OR name = :two", one: 'John', two: 'Smith')
        clause[:parameters].each do |key, value|
          final_string.sub!(":#{key}", "\"#{value}\"")
        end
      end
      final_string
    end
  end
end
