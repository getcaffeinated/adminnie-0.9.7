class App < Sinatra::Base
  before do
    puts params.inspect if settings.environment.to_s =~ /dev/ && !settings.in_testing?
    init_open_graph unless ['/page'].include? request.path
  end

  get '/page' do
    erb :page
  end
  
  get '/?' do
    erb :page
  end
  
end
