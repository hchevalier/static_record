module StaticRecord
  class RecordNotFound < RuntimeError; end
  class ReservedAttributeName < RuntimeError; end
  class MissingAttribute < RuntimeError; end
  class NoPrimaryKey < RuntimeError; end
  class UnkownType < RuntimeError; end
  class ClassError < RuntimeError; end
end
