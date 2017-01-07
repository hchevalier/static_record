class ArticleFour < Article
  attribute :name, 'Article Four'
  attribute :author, 'Me'
  attribute :rank, 3
  attribute :important, false
  attribute :cover, Rails.root.join('public', 'articles', 'cover', 'article_four.jpg')
end
