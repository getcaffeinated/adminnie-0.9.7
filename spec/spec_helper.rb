# You need to checkout enterprise and do a bundle install for autotest to work!

ENV['RACK_ENV'] = 'test'
raise 'Forget it.' if ENV['RACK_ENV'] == 'production'
TEST_APP_ROOT = File.join(File.dirname(__FILE__)), '..', '..', 'enterprise'
APP_ROOT = File.join(File.dirname(__FILE__)), '..'

TESTING_UID = '655764281'
# Get one from the console after loading /admin!
TESTING_SIGNED_REQUEST = 'znJ0ONHzPYFooGlelWEZnk3Z0TabduBkUUcI4WO7Dqc.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDc2NjA0MDAsImlzc3VlZF9hdCI6MTMwNzY1NjE2NSwib2F1dGhfdG9rZW4iOiIxMzg3NDQ0MzYxNzA3OTF8Mi5BUUNrSGR1TzVGdFZBSTRNLjM2MDAuMTMwNzY2MDQwMC4xLTEwMDAwMDk4MTU0NTQ3MXxlU0poOFdnWm9qb0FWbVp4MFg3V1h3WlpycTAiLCJ1c2VyIjp7ImNvdW50cnkiOiJ1cyIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwMDk4MTU0NTQ3MSJ9'

# Test from enterprise
def link_gemfile
  # Need this for bundler
  File.symlink(File.join(TEST_APP_ROOT, 'Gemfile'), File.join(APP_ROOT, 'Gemfile'))
rescue Errno::EEXIST => e
  
end

link_gemfile
require File.join(TEST_APP_ROOT, 'config', 'env.rb')
require 'rack/test'

DataMapper.auto_migrate!
DataMapper.auto_upgrade!
DataMapper::Model.descendants.each do |klass|
  klass.bootstrap! if klass.respond_to?('bootstrap!')
  klass.fixtures! if klass.respond_to?('fixtures!')
end
 
RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

# This needs to be periodically updated with a fresh signed_request :(
def signed_request
  "signed_request=#{TESTING_SIGNED_REQUEST}"
end

def app
  App
end

def user
  User.first(:uid=>TESTING_UID)
end

def create_quiz
  r = Result.create(:user=>user)
  Question.all.each do |q|
    selected = q.answers.pick
    Rejoinder.create(:answer => selected, :result=>r)
  end
  
  r
end

def create_user
  User.create(:uid=>TESTING_UID, :first_name => 'Abraham', :last_name => 'Lincoln')
end

create_user