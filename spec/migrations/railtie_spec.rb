require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Railtie, :type => :module do
  it 'extends ActiveRecord::Base' do
    expect{ActiveRecord::Base.has_static_record(:test)}.not_to raise_error
  end
end
