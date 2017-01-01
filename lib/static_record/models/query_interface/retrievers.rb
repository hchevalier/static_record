module StaticRecord
  # Contains ActiveRecord-like query interface methods
  module QueryInterface
    # Contains retrievers
    module Retrievers
      private

      def to_a
        exec_request
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
        @order_by << { :"#{@primary_key}" => :asc } if @primary_key && @order_by.empty?
        take(amount)
      end

      def last(amount = 1)
        if !@primary_key && @order_by.empty?
          cnt = self.class.new(self, store: @store, primary_key: @primary_key).no_sql.send(:count)
          @sql_offset = [cnt - amount, 0].max
          res = take(amount)
        else
          @order_by << { :"#{@primary_key}" => :desc } if @order_by.empty?
          res = take(amount)
          res.reverse! if res.is_a?(Array)
        end
        res
      end
    end
  end
end
