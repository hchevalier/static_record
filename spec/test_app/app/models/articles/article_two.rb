class ArticleTwo < Article
  attribute :name, 'Article Two'
  attribute :author, 'The author'
  attribute :rank, 3
  attribute :important, true
  attribute :cover, Rails.root.join('public', 'articles', 'cover', 'article_two.jpg')
end
