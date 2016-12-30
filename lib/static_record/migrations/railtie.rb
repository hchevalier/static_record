module StaticRecord
  class Railtie < Rails::Railtie # :nodoc:
    initializer 'static_record.insert_into_active_record' do |_app|
      ActiveSupport.on_load :active_record do
        StaticRecord::Railtie.insert
      end
    end

    def self.insert
      if defined?(ActiveRecord)
        ActiveRecord::Base.send(:include, StaticRecord::Schema)
        ActiveRecord::Base.send(:include, StaticRecord::HasStaticRecord)
      end
    end
  end
end
