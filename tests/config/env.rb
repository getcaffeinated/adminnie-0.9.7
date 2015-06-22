# Try not to change this.. use config.rb if you have a choice.

ENV['RACK_ENV'] ||= ENV['RAILS_ENV'] # hack for passenger
RUBY_VERSION[0..2] == '1.9' ? Encoding.default_internal = 'UTF-8' : $KCODE = "u"
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require :default
require 'pp'
require 'yajl/json_gem'

module Sinatra
  class Base
    def self.development?; (environment.to_s =~ /dev/ ? true : false); end
  end
end

Sinatra::Base.root = File.join File.expand_path(File.join(File.dirname(__FILE__))), '..'

Dir.glob(File.join(Sinatra::Base.root, 'lib', '**/*.rb')).each { |f| require f }
Dir.glob(File.join(Sinatra::Base.root, 'models', '**/*.rb')).each { |f| require f }
require File.join(Sinatra::Base.root, 'config', 'config')

DataMapper.finalize

Sinatra::Base.use Rack::Modernizr if defined?(Rack::Modernizr)
Sinatra::Base.use Rack::CommonLogger
Sinatra::Base.use Rack::RestBook
Sinatra::Base.use Rack::PerformanceLog if Sinatra::Base.production?
Sinatra::Base.use Rack::Session::Cookie, :key => 'app.session',
                                         :path => '/',
                                         :expire_after => 2592000, # In seconds
                                         :secret => 'Oej2yrKTI4Lv3jRXnpAx5NPj3xG'

Sinatra::Base.mime_type :ttf, 'font/ttf'
Sinatra::Base.mime_type :woff, 'application/octet-stream'
Sinatra::Base.use Rack::CookieMonster

Sinatra::Base.set :in_testing?, false
Sinatra::Base.set :root, Sinatra::Base.root
Sinatra::Base.set :public, File.join(Sinatra::Base.root, 'public')
Sinatra::Base.set :static, true
Sinatra::Base.set :raise_errors, true
Sinatra::Base.register Sinatra::MessagesHelper
confit File.join(Sinatra::Base.root, 'config', 'facebook.yml'), Sinatra::Base.environment

Sinatra::Base.not_found do
  erb :not_found, :layout => false
end

require File.join(Sinatra::Base.root, 'app')

confit(File.join(Sinatra::Base.root, 'config', 'facebook.yml'), ENV['RACK_ENV'])
confit(File.join(Sinatra::Base.root, 'config', 'admin.yml'))

Sinatra::Base.helpers Adminnie::Helpers

Sinatra::Base.use Rack::Flash

if Sinatra::Base.production?
  #DataMapper::Schema.setup_database_for_schema ENV['APP_NAME'].gsub('-', '_'), ENV['DATABASE_URL']
  DataMapper.setup :default, ENV['DATABASE_URL']
elsif File.exists? File.join(Sinatra::Base.root, 'config', 'database.yml')
  DataMapper::Logger.new STDOUT, :debug if Sinatra::Base.development?
  DataMapper.setup :default, YAML.load_file(File.join(Sinatra::Base.root, 'config', 'database.yml'))[Sinatra::Base.environment.to_s]
end

if Sinatra::Base.production?
  Sinatra::Messages.suppress = true
  Sinatra::Base.set :cache_buster, Time.now.to_i
end

require File.join(Sinatra::Base.root, '..', 'lib', 'adminnie')

TIMEZONE='-7'
ENV['TZ'] = TIMEZONE

puts "Started in #{Sinatra::Base.environment} mode #{Time.now} (#{TIMEZONE})"
