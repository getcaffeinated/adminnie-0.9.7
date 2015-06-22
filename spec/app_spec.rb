require 'spec_helper'
require 'ftools'

describe 'The Adminnie App' do
  include Rack::Test::Methods
  
  it "gets the root of the application" do
    get '/admin'
    last_response.should be_ok
    puts confit.admin.inspect
    
  end
  
end