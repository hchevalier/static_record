module StaticRecord
  class Railtie < Rails::Railtie # :nodoc:
    initializer 'static_record.insert_into_active_record' do |_app|
      ActiveSupport.on_load :active_record do
        send(:extend, StaticRecord::ClassMethods)
        send(:include, StaticRecord::Schema)
        ActiveSupport.run_load_hooks(:static_record, StaticRecord::Base)
      end
    end
  end
end
