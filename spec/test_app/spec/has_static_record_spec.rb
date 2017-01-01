require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::HasStaticRecord, :type => :module do
  it 'adds a setter to ActiveRecord' do
    t = Test.new(name: 'Test')
    t.article = Article.find('Article One')
    expect(t.article_static_record_type).to eql('ArticleOne')
  end

  it 'adds a getter to ActiveRecord' do
    article = Article.find('Article One')
    Test.create(name: 'Test', article: article)
    t = Test.last
    expect(t.article.name).to eql(article.name)
  end

  it 'must assign correct instance' do
    expect { Test.new.article = Article.last }.not_to raise_error
    expect { Test.new.article = Role.last }.to raise_error(StaticRecord::ClassError)
  end

  it 'cannot add getter to ActiveRecord if no primary key is set' do
    Test.has_static_record :role
    expect { Test.new.role = Role.last }.to raise_error(StaticRecord::NoPrimaryKey)
  end
end
