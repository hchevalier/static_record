module StaticRecord
  # Contains ActiveRecord-like query interface methods
  module QueryInterface
    module Interface # :nodoc:
      include StaticRecord::QueryInterface::Conditioners
      include StaticRecord::QueryInterface::Retrievers
      include StaticRecord::QueryInterface::SearchModifiers
      include StaticRecord::QueryInterface::SqlHelpers
    end
  end
end
