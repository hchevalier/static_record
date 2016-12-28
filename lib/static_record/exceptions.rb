module StaticRecord
  class RecordNotFound < RuntimeError; end
  class ReservedAttributeName < RuntimeError; end
  class NoPrimaryKey < RuntimeError; end
  class UnkownType < RuntimeError; end
end
