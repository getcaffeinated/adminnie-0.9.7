require File.join('.', 'config', 'env.rb')

map '/' do
  run App
end

map '/admin' do
  run Adminnie::Admin
end

map '/_valibot' do
  run Valibot::App
end