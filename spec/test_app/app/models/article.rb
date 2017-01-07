class Article < StaticRecord::Base
  table       :articles
  path        Rails.root.join('app', 'models', 'articles', '**', '*.rb')
  primary_key :name

  def self.default_author
    'Default author'
  end

  def self.default_rank
    3
  end

  def self.override_cover(cover)
    unless cover.to_s.include?('/')
      folder = Rails.root.join('public', 'articles', 'cover').itself
      return folder + cover
    end
    cover
  end

  columns     name:       :string,
              author:     :string,
              rank:       :integer,
              important:  :boolean,
              cover:      :string
end
