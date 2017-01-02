require 'static_record/engine'
require 'static_record/exceptions'

require 'static_record/concerns/query_building_concern'
require 'static_record/concerns/sqlite_storing_concern'

require 'static_record/models/query_interface/conditioners'
require 'static_record/models/query_interface/retrievers'
require 'static_record/models/query_interface/search_modifiers'
require 'static_record/models/query_interface/sql_helpers'
require 'static_record/models/query_interface'

require 'static_record/models/querying'
require 'static_record/models/relation'
require 'static_record/models/base'

require 'static_record/migrations/has_static_record'

# This ClassMethods module will be extended by ActiveRecord
module StaticRecord
  module ClassMethods # :nodoc:
    def has_static_record(name, options = nil)
      HasStaticRecord.define_on(self, name, options || {})
    end
  end
end

require 'static_record/migrations/schema'
require 'static_record/migrations/railtie'
