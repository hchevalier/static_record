class Badge < StaticRecord::Base
  table     :badges
  path      Rails.root.join('app', 'models', 'badges', '**', '*.rb')
  columns   name:         :string,
            description:  :string
end
