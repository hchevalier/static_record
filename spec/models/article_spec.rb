require 'spec_helper'
require 'rails_helper'

RSpec.describe Article, :type => :model do
  it 'lists static records' do
    expect(Article.all.size).to eql(2)
    expect(Article.all).to eql([ArticleOne, ArticleTwo])
  end

  it 'conditionnaly lists static records' do
    expect(Article.where(name: 'Article One').size).to eql(1)
    expect(Article.where(name: 'Article One')).to eql([ArticleOne])
  end
end
