require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Querying, :type => :model do
  it 'delegates requests to StaticRecord::Relation' do
    expect(Article.where(author: 'The author')).to be_a(StaticRecord::Relation)
  end

  it 'returns a new StaticRecord::Relation for each method chaining node' do
    first_node = Article.where(author: 'The author')
    expect(first_node).to be_a(StaticRecord::Relation)
    second_node = first_node.where(rank: 3)
    expect(second_node).to be_a(StaticRecord::Relation)
    expect(second_node).not_to eql(first_node)
  end
end
