module Adminnie 
  
  class Admin < Adminnie::Crudite
    
    before do
      
      if confit.admin.ssl and request.referer !~ /^https/ #request.env['HTTP_X_FORWARDED_PROTO'] == 'https'
        info "Should be ssl: #{request.referer} || #{request.path} || #{adminnie_url_for(request.path, :ssl=>true)}"
        info request.inspect
        halt redirect adminnie_url_for(request.path, :ssl=>true)
      end
      
      session[:sort] = params[:sort] if params[:sort]
      session[:direction] = params[:direction] if params[:direction]
      opts = {
        :sort => session[:sort],
        :direction => session[:direction],
        :format => 'erb'
      }
      if request.path =~ /^(?:\/canvas)?\/admin\/?$/ or request.path =~ /^(?:\/canvas)?\/admin\/reports\/?$/
        @renderer = Adminnie::Render.new('dashboards')
      else
        request.path =~ /^(?:\/canvas)?\/admin\/([^\/]+)/
        begin
          @renderer = Adminnie::Render.new($1)
        rescue UnknownClassError => e
          err "Class not found #{e.to_s}"
          halt not_found
        end
      end
      @controller = Adminnie::Controller.new(@renderer, request.env.merge!({:path=>request.path}), opts)
      
      adminnie_authorized?
      adminnie_output_info
    end

    get '/?' do
      erb :"admin/index", :layout => adminnie_admin_layout, :views => @renderer.views
    end

    post '/ban_user/:uid' do
      @user = User.get(params[:uid])
      @user.banned = true
      @user.save
      'Banned user!'
    end

    post '/unban_user/:uid' do
      @user = User.get(params[:uid])
      @user.banned = false
      @user.save
      'Unbanned user!'
    end
    
  end
  
end
