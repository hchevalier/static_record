class Article < StaticRecord::Base
  private

  def self.store
    'articles'
  end

  def self.path_pattern
    Rails.root.join('app', 'models', 'articles', '**', '*.rb')
  end

  self.index([:name, :author])
end
