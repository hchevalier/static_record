require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Querying, :type => :model do
  it 'delegates requests to StaticRecord::Relation' do
    expect(Article.where(author: 'The author')).to be_a(StaticRecord::Relation)
  end
end
