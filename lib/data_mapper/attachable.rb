require 'erb'

module DataMapper
  
  module Attachable
    
    attr_accessor :attached_binding
    
    def attach_view(view)

      self.attached_binding = get_binding
      view_file = get_file(view)
      template  = ERB.new(view_file)
      output   = template.result self.attached_binding
      
    end
    
    def attach_footer
      view = "admin/attachables/footer.erb"
      self.attach_view(view)
    end
        
    def ban_user
      @user = find_user_model
      view = "admin/attachables/bannable.erb"
      self.attach_view(view)
    end

    def update_status
      view = "admin/attachables/statusable.erb"
      self.attach_view(view)
    end
    
    def update_property(prop)
      @prop = prop
      view = "admin/attachables/selectable.erb"
      self.attach_view(view)
    end
    
    def update_checkbox(prop)
      @prop = prop
      view = "admin/attachables/checkable.erb"
      self.attach_view(view)
    end
    
    def update_radio(prop)
      @prop = prop
      view = "admin/attachables/radioable.erb"
      self.attach_view(view)
    end
    
    def get_binding
      binding
    end

    private
    
    def get_file(file)
      path = File.join(File.expand_path(File.join(File.dirname(__FILE__))), '..', 'views', file)
      if File.exists?(path)
        File.read(path)
      else
        # is read file
        file
      end
    end
    
    def find_user_model
      if self.class.to_s == 'User'
        return self
      elsif self.class.associations.include?('user')
        return self.user 
      else
        raise StandardError, "Too confusing to find user model :("
      end
    end
    
  end
  
end

DataMapper::Model.append_inclusions DataMapper::Attachable