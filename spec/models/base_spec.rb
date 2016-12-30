require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Base, :type => :model do
  it 'allows to store primary key' do
    Article.primary_key :author
    expect(Article.pkey).to eql(:author)
    Article.primary_key :name # restoring primary key for other tests
  end

  it "allows to access attributes defined with 'attribute'" do
    article = Article.find('Article One')
    expect(article.name).to eql('Article One')
    expect(article.author).to eql('The author')
    expect(article.rank).to eql(2)
  end
end
