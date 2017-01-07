require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Base, :type => :module do
  it 'calls default_<column> method when attribute is not defined' do
    article = Article.find('Article Five')
    expect(article.author).to eql(Article.default_author)
    expect(article.rank).to eql(Article.default_rank)
  end

  it 'calls override_<column> method to override attribute when available' do
    article = Article.find('Article Five')
    expect(article.cover).to eql(Rails.root.join('public', 'articles', 'cover', 'article_five.jpg'))
  end

  it 'raises an error when attribute is not defined and no default method exists' do
    err = "You must define attribute 'description' for BadgeOne"
    expect { Badge.find('Badge One') }.to raise_error(StaticRecord::MissingAttribute, err)
  end
end
