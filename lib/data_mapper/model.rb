module DataMapper
  module Model
    
    include Sinatra::MessagesHelper
    
    alias_method :list, :all
    alias_method :edit, :first
    alias_method :show, :get
    alias_method :index, :all
    
    def description
      ""
    end
    
    def reports
      {:total => self.all.count}
    end
    
    def truncate_list_words_at
      confit.admin.truncate_list_words_at
    end
    
    def associations
	    assoc = Array.new
	    self.relationships.each do |rarr|
	      #puts rarr.inspect
        # belongs_to relationship
        if rarr.child_model.to_s.downcase == self.to_s.downcase
          assoc << rarr.instance_variable_name[1,rarr.instance_variable_name.length]
        end
      end
      assoc
    end
	  
	  def is_association?(key_name)
	    if associations.include?(key_name)
	      true
	    else
	      false
	    end
	  end
	  
	  def get_attribute(key_name)
	    self.properties.each do |prop|
	      return prop if prop.name.to_s == key_name
	    end
	    
	    return nil
	    # should be an association if it gets here
	  end
	  
    def list_attributes
      list_props = self.properties.map{|i| i.name.to_s unless i.name.to_s =~ /_id$/}
      
      list_props.concat self.associations
      
      if list_props.include?('created_at')
        list_props.slice!(list_props.index('created_at'))
        list_props << 'created'
      end
      
      if list_props.include?('updated_at')
        list_props.slice!(list_props.index('updated_at'))
      end
      
      if list_props.include?('id')
        list_props.slice!(list_props.index('id'))
      end
      
      if self.included_modules.include?(DataMapper::AmazonImage::Resource)
        list_props.slice!(list_props.index('amazon_filename'))
        list_props.unshift('photo')
      end
      
      list_props.compact
    end
    
    def sort_attributes
      sort_props = list_attributes
    end
    
    def edit_attributes
      edit_props = self.properties.map{|i| i.name.to_s unless (i.name.to_s == 'id' or i.name.to_s =~ /_id$/)}
      
      edit_props.concat self.associations
      
      if edit_props.include?('created_at')
        edit_props.slice!(edit_props.index('created_at'))
      end
      
      if edit_props.include?('updated_at')
        edit_props.slice!(edit_props.index('updated_at'))
      end
      
      #if self.included_modules.include?(DataMapper::AmazonImage)
      #  edit_props.slice!(edit_props.index('amazon_filename'))
      #  edit_props.unshift('amazon_file')
      #end
      
      edit_props.compact
    end
    
    def select_for(name="name", collection=self.all, child_prefix="", selected_object=nil)

      prefix = ""
      selected = ""
      if collection.nil?
        collection = all
      end
       
      @options = collection.map{|obj|

        if selected_object and (selected_object == obj)
          selected = " selected"
        else
          selected = ""
        end
        
        if obj.respond_to?('selectable?')
          prefix = child_prefix
        end
        if obj.respond_to?('selectable?') and not obj.selectable?
          next
          #Took out parents value = "value='' disabled><strong>#{obj.send(name)}</strong>"
        else
          value = "value='#{obj.id}'#{selected}>#{prefix}#{obj.send(name)}"
        end
        "<option  #{value}</option>" 
        
      }.join
    end
    
    def readonly?
      true
    end
    
    def indestructible?
      false
    end
    
    def listable?
      true
    end
    
    def link_for
      Extlib::Inflection.plural(Extlib::Inflection.underscore(self.to_s).downcase)
    end
    
    def get_position(conditions={})
      (self.max(:id, conditions)||0)+1
    end
     
    def order_by(klass, prop, direction=:asc)
      order = DataMapper::Query::Direction.new(user.first_name, direction) 
      query = all.query # Access a blank query object for us to manipulate
      query.instance_variable_set("@order", [order])

      # Force the associated model to be joined into the query
      query.instance_variable_set("@links", [relationships['user']])

      all(query) # Create a new collection with the modified query
    end
    
    def footer
      self.new.attach_footer
    end
    
  end
end