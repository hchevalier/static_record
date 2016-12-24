require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Base, :type => :model do
  it 'must be inherited from' do
    expect { StaticRecord::Base.all }.to raise_error(NotImplementedError)
  end
end
