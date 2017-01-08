require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Base, :type => :module do
  it 'can query over a static record reference' do
    category = Category.find('Category One')
    article = Article.where(category: category)
    expect(article.first.category.class).to eql(category.class)
  end
end
