class Role < StaticRecord::Base
  table     :roles
  path      Rails.root.join('app', 'models', 'roles', '**', '*.rb')
  columns   name:         :string,
            description:  :string
end
