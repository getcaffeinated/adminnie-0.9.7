require 'sinatra'

module Adminnie
  
  module Helpers
    
    def adminnie_redirect(uri, *args)
      if confit.admin.always_skip_facebook
        return adminnie_admin_url_for uri
      else
        return %{<script type="text/javascript">top.location.href = "#{adminnie_admin_url_for uri}";</script>}
      end
    end
    
    def adminnie_url_for(path, opts={})
      path.sub!(/^\//, '')  
      if opts[:skip_facebook] or confit.admin.always_skip_facebook
        if (opts[:ssl] or confit.admin.ssl) and ENV['RACK_ENV'] !~ /dev/
          "#{confit.facebook.callback_url}/#{path}".gsub(/http\:/, 'https:')
        else
          "#{confit.facebook.callback_url}/#{path}"
        end
      else
        if (opts[:ssl] or confit.admin.ssl) and ENV['RACK_ENV'] !~ /dev/
          "https://apps.facebook.com/#{confit.facebook.canvas_page_name}/#{path}"
        else
          "http://apps.facebook.com/#{confit.facebook.canvas_page_name}/#{path}"
        end
      end
    end
    
    def adminnie_secure_url_for(path, opts={})
      adminnie_url_for(path, opts.merge!({:ssl=>true}))
    end
    
    module_function :adminnie_url_for
    module_function :adminnie_secure_url_for
    
    def adminnie_secure_url_for_page_tab; confit.facebook.page_tab_url.gsub(/http\:/, 'https:') end
    def adminnie_url_for_page_tab; confit.facebook.page_tab_url end
    def adminnie_secure_url_for_img(filename); adminnie_url_for "img/#{filename}", {:skip_facebook => true, :ssl => true} end
    def adminnie_url_for_img(filename); adminnie_url_for "img/#{filename}", :skip_facebook => true end
    
    def adminnie_output_info
      info "#{@controller.path} - #{request.env['REQUEST_METHOD']} (ajax? #{request.xhr?}) #{request.path} Name: #{@renderer.model_name} Action: #{@renderer.action} Class: #{@renderer.klass} Params: #{params.inspect}"
    end
    
    def adminnie_admin_layout
      :'admin/templates/layout'
    end
    
    def adminnie_authorized?

      if confit.admin.always_skip_facebook
        info "Skipping FB authentication"
        # add basic auth
        return true
      end
    
      if Sinatra::Base.included_modules.include?(Sinatra::OriginalGangster)
        init_open_graph if not facebook_session
        @uid = facebook_session.user_id
        adminnie_valid_user?
      else
        init_facebook
        adminnie_valid_user?
      end

    rescue NameError => e
      # Koala!
      init_facebook
      adminnie_valid_user?
    end
  
    def adminnie_valid_user?
      unless confit.admin.uid_whitelist.include?(@uid)
        error_msg = "User not authorized."
        flash[:error] = error_msg
        err error_msg
        halt redirect(confit.admin.default_url||(adminnie_url_for '/'))
      else
        true
      end
    end
    
    def adminnie_models
      mods = Array.new
      DataMapper::Model.descendants.each do |klass|
        mods << klass if klass.listable?
      end
      mods
    end
    
    def adminnie_reports_for_index
      reports_arr = Array.new
      x = 0
      adminnie_models.each do |model|
        model.reports.each_pair do |key,val|
          reports_arr[x] = [model,key,val]
          x+=1
        end
      end
      reports_arr
    end
    
    def adminnie_models_for_nav
      nav_models = adminnie_models
      this_mod = 0
      nav_models.each do |mod|
        plur = Extlib::Inflection.plural(mod.to_s)
        nav_models[this_mod] = Extlib::Inflection.underscore(plur)
        this_mod += 1
      end
      nav_models
    end
    
    def adminnie_humanize(klass)
      Extlib::Inflection.humanize(klass)
    end
  
    def adminnie_singular(klass)
      Extlib::Inflection.singular(klass).downcase
    end

    def adminnie_plural(klass)
      Extlib::Inflection.plural(klass).downcase
    end
  
    def adminnie_camelize(klass)
      Extlib::Inflection.camelize(klass).downcase
    end
  
    def adminnie_underscore(klass)
      Extlib::Inflection.underscore(klass).downcase
    end
  
    def adminnie_clientize(klass, plural=false)
      humane = plural.nil? ? klass : Extlib::Inflection.plural(klass)
      Extlib::Inflection.humanize(humane)
    end
  
    def adminnie_truncate_words(str, length = 30, end_string = ' ...')
      return str if str.nil? or str.class.to_s != 'String' or str.empty?
      words = str.split()
      words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
    end
  
    def adminnie_assocify(ass, value)
      @renderer.render_association(ass, value)
    end
  
    def adminnie_formulate(key, value)
      property = @renderer.klass.get_attribute(key)    
      if property
        @renderer.send "render_input_#{@renderer.property_type(property.class)}".to_sym, key, value
      else
        adminnie_assocify(key, value)
      end
    end
  
    def adminnie_admin_url_for(path, opts={})
      if confit.admin.ssl
        adminnie_secure_url_for(path, opts)
      else
        adminnie_url_for(path, opts)
      end
    end
    
    def adminnie_get_flash(kind)
      if @controller.flash
        @controller.flash[kind]
      else 
        ""
      end
    end
    
  end
  
end
