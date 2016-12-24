require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Base, :type => :model do
  it 'allows to store primary key' do
    Article.primary_key :author
    expect(Article.pkey).to eql(:author)
    Article.primary_key :name # restoring primary key for other tests
  end
end
