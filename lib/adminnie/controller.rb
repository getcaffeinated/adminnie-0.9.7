module Adminnie
  
  class Controller
    
    include Sinatra::MessagesHelper
    include Adminnie::Helpers
    include Sinatra::Templates
    
    attr_accessor :renderer, :results, :page, :sort, :target, :page_title, :method, :id, :template_cache, :flash, :direction, :env, :format, :layout_template, :views, :path
    cattr_accessor :templates, :views
    
    def self.default_encoding
      ""
    end
    
    def settings
      self.class.settings
    end
    
    def self.settings
      self
    end
    
    def initialize(renderer, env, opts={})
      
      self.format = (opts[:format]||'erb')
      self.flash = env['x-rack.flash']
      self.env = env
      self.method = self.env["REQUEST_METHOD"]
      self.class.views = renderer.views
      self.class.templates = {}
      self.template_cache = Tilt::Cache.new
      self.renderer = renderer
      self.sort = (opts[:sort]||'created_at')
      self.direction = (opts[:direction]||'asc')
      self.layout_template = (opts[:layout_template]||adminnie_admin_layout)
      self.views=(opts[:views]||self.renderer.views)
      self.path = self.get_path(env)
      
    end
    
    def get_path(env)
      if env[:path]
        env[:path] =~ /^\/([^\/]+)/
        $1
      else
        "admin"
      end
    end
    
    # Show one record
    def get_item(id, params)
      self.renderer.action = 'show'
      self.id = id
      control(params){ self.results = self.renderer.klass.first(:id => self.id) }
      templatize(:"admin/templates/show", false)
    end
    
    # Get list for ajax pagination
    def get_items(params, conditions = {})
      self.page = (params[:page] || 1)
      self.sort = 'created_at' if self.sort == 'created'
      self.direction = 'desc' if self.sort == 'created_at'
      
      self.results = self.renderer.klass.page(self.page, {:order => self.sort.to_sym.send(self.direction), :per_page => (confit.admin.entries_per_page)}.merge!(conditions))
      templatize(:"admin/templates/_items", false)
      
    rescue ArgumentError => e
      #error e.to_s
      self.sort = 'created'
      order = [:id.desc]
      order.unshift :created_at.desc if renderer.klass.properties.include? :created_at
      self.results = self.renderer.klass.page(self.page, {:unique => true, :order => order, :per_page => (confit.admin.entries_per_page)}.merge!(conditions))
      templatize(:"admin/templates/_items", false)
    end
      
    # Edit or new
    def get_edit_or_new(action, params)
      self.renderer.action = action

      if self.renderer.action == 'edit'
        self.target = "update"
      elsif self.renderer.action == 'new'
        self.target = "create"
      end

      control(params){ do_get(params) }
    end
    
    # Create or update
    def post_create_or_update(params)
      do_post(params)
      ("admin/#{@renderer.link}")
    end
    
    # Update one property in a model instance
    def post_update_property(id, property, property_id)
      self.id = id
      self.results = self.renderer.klass.first(:id => id)
      self.results.send("#{property}=", property_id)
      self.results.save
      'Updated!'
    end
    
    # Update boolean in a model instance
    def post_update_boolean(id, property, bool)
      self.id = id
      self.results = self.renderer.klass.first(:id => id)
      self.results.toggle_boolean(bool)
      self.results.save
      'Updated!'
    end
    
    # List
    def get_list(params)
      self.renderer.action = 'index'
      templatize(:"admin/#{self.renderer.link}/#{self.renderer.action}", self.layout_template)
    end
    
    # Delete record
    def delete_item(id, params)
      self.renderer.action = 'destroy'
      self.id = id
      do_delete(params)
      ("admin/#{@renderer.link}")
    end
    
    def get_csv
      require 'csv'
      items = self.renderer.klass.all
      begin
        data = CSV.generate do |csv|
          props = self.renderer.klass.list_attributes
          csv << props
          items.each do |item|
            csv << props.collect { |p| item.send p }
          end
        end
      rescue Exception => e
        raise "CSV generation requires Ruby 1.9.2!"
      end
    end
    
    private
    
    def control(params)
      yield
      templatize(:"admin/#{self.renderer.link}/#{self.renderer.action}", self.layout_template)
    #rescue NoMethodError => e
    #  err "Probably no record(s) #{e.inspect}"
    #  templatize(:"admin/templates/_error", self.layout_template)
    end

    def go_to_default
      #return adminnie_redirect(url_for "/#{self.path}")
    end

    def do_get(params)
      act(params)
    end

    def do_post(params)
      act(params)
      self.flash = {} if self.flash.nil?
      if self.results.valid?
        self.flash[:notice] = "Successfully #{self.renderer.action}d #{self.renderer.display_name}"
      else
        self.flash[:error] = "There was an error with your submission #{self.results.errors_for}"
      end
      info self.flash.inspect
    end

    def do_delete(params)
      self.results = self.renderer.klass.first_or_new(:id => self.id)
      self.results.destroy
      self.flash[:notice] = "Successfully deleted #{self.renderer.display_name}"  
    end

    def act(params)

      self.page_title = "#{self.path.capitalize}: #{self.renderer.display_name}"

      if params[self.renderer.params] # has form params
        
        if params[self.renderer.params][:id] and not params[self.renderer.params][:id].empty? # has an id

          self.results = self.renderer.klass.first_or_new(:id => params[self.renderer.params][:id])

          if not self.renderer.action or self.renderer.action.empty?
            if self.results.new?
              self.renderer.action = "create"
            else
              self.renderer.action = "update"
            end
          end
          
          self.results.send(self.renderer.action, params[self.renderer.params]) if self.method == 'POST'
          self.results.save_amazon_photos if params[self.renderer.params]["amazon_file"]

        else # doesn't have an id
          self.renderer.action = "create" if not self.renderer.action
            
          params[self.renderer.params].delete "id"
          info "NO ID self.results = #{self.renderer.klass}.send(#{self.renderer.action}, params[#{self.renderer.params}])"
          self.results = self.renderer.klass.send(self.renderer.action, params[self.renderer.params])
          self.results.save_amazon_photos if params[self.renderer.params]["amazon_file"]

        end
      else # doesn't have form params
        info "No form params(params[#{self.renderer.params}] #{params[self.renderer.params]})"
        self.results = self.renderer.klass.send(self.renderer.action)
      end

    end

    def templatize(template, layout_template=adminnie_admin_layout)
      
      if self.format == 'json'
        if self.results
          return self.results.jsonify 
        else
          err "No results #{self.results.inspect}"
          return Yajl.dump []
        end
      end
      
      @controller = self
      erb template, :layout => layout_template, :views => self.views
      
    rescue Errno::ENOENT => e
      template = :"admin/templates/#{self.renderer.action}"
      erb template, :layout => layout_template, :views => self.views
    #rescue NoMethodError => e
    #  error "No results"
    #  Yajl.dump {}
    end
    
  end
  
end
