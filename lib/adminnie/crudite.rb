module DG
  module Sinatra
    class Base < ::Sinatra::Base
    end
  end
end

module Adminnie
  class Crudite < DG::Sinatra::Base
    before do
      
      session[:sort] = params[:sort] if params[:sort]
      session[:direction] = params[:direction] if params[:direction]
      opts = {
        :sort => session[:sort],
        :direction => session[:direction],
        :format => 'json'
      }
      base_path = 'crudite\/' if not confit.admin.base_path
      request.path =~ /#{confit.admin.base_path}([^\/]+)/
      if ($1)
        success "#{request.path} - #{$1}"
        @renderer = Adminnie::Render.new($1)
        @controller = Adminnie::Controller.new(@renderer, request.env.merge!({:path=>request.path}), opts)
        adminnie_output_info
      else
        err "Couldn't retrieve model!"
      end
      
    end
  
    # CSV dump of given model
    get %r{/(\w+)\.csv/?} do |model|
      content_type 'text/csv'
      @controller.renderer.update(model)
      @controller.get_csv
    end
    
    # Update association
    post %r{/(\w+)/(\d+)/(\w+)/(\d+)/?} do |model, model_id, property, property_id|
      @controller.post_update_property(model_id, property, property_id)
    end
    
    # Update boolean
    post %r{/(\w+)/(\d+)/(\w+)/(true|false)/?} do |model, model_id, property, bool|
      @controller.post_update_boolean(model_id, property, bool)
    end
    
    # Show one record
    get %r{/(\w+)/(\d+)/?} do |model, id|
      @controller.get_item(id, params)
    end

    # Get list for ajax pagination
    get %r{/(\w+)/items/?} do |model|
      session[:sort] = params[:sort] if params[:sort]
      @controller.get_items(params)
    end 
    
    # Delete record
    delete %r{/(\w+)/(\d+)/?} do |model, id|
      puts "deleting"
      adminnie_redirect @controller.delete_item(id, params)
    end

    # Edit or new
    get %r{/(\w+)/(edit|new)/?} do |model, action|
      puts "Edit or new #{action}"
      @controller.get_edit_or_new(action, params)
    end

    # Create or update
    post %r{/(\w+)/?} do |model|
      info "posting create or update"
      adminnie_redirect @controller.post_create_or_update(params)
    end
    
    # List
    get %r{/(\w+)/?(?:by)?/?(\w+)?/?} do |model, sort|
      puts "Listing #{sort}"
      session[:sort] = sort if sort
      @controller.get_list(params)
    end
    
  end
end
