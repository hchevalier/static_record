class ArticleThree < Article
  attribute :name, 'Article Three'
  attribute :author, 'Another author'
  attribute :rank, 1
  attribute :important, true
  attribute :cover, Rails.root.join('public', 'articles', 'cover', 'article_three.jpg')
end
