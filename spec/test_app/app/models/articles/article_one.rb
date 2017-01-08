class ArticleOne < Article
  attribute :name, 'Article One'
  attribute :author, 'The author'
  attribute :rank, 2
  attribute :important, false
  attribute :cover, Rails.root.join('public', 'articles', 'cover', 'article_one.jpg')

  reference :category, Category.find('Category One')
end
