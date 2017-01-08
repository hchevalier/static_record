class Category < StaticRecord::Base
  table     :categories
  path      Rails.root.join('app', 'models', 'categories', '**', '*.rb')
  primary_key :name
  columns   name:         :string,
            description:  :string
end
