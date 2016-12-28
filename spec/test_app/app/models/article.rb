class Article < StaticRecord::Base
  table       :articles
  path        Rails.root.join('app', 'models', 'articles', '**', '*.rb')
  primary_key :name

  columns     name:   :string,
              author: :string,
              rank:   :integer
end
