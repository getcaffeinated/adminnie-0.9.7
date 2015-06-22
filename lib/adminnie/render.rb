class Dashboard
  
  include DataMapper::Resource
  property :id, Serial, :index => true
  
  def self.listable?
    false
  end
  
end

module Adminnie
  
  class Render < Model
        
    def property_type(klass)
      return nil if klass.to_s == 'NilClass'
      
      klass.to_s =~ /(String|Text|Boolean|Integer|Date)$/
      if $1
        $1.downcase
      else
        "string"
      end
    end

    def render_value(value)
      if confit.admin.extra_secure
        h value
      else
        value
      end
    end
    
    def render_association(key, value)
      puts "render_association(#{key}, #{value}) -- #{self.params}[#{key}]"
      ass_string = %{<select name="#{self.params}[#{key}_id]">}
      ass_string += Kernel.const_get(key.capitalize).select_for(name="to_s", Kernel.const_get(key.capitalize).all, "", render_value(value))
      ass_string += %{</select>}
      ass_string
    end

    def render_input_date(key, value)
      %{<input type="text" name="#{self.params}[#{key}]" value="#{render_value(value)}">}
    end

    def render_input_text(key, value)
      %{<textarea name="#{self.params}[#{key}]">#{render_value(value)}</textarea>}
    end
    
    def render_input_string(key, value)
      if key == 'amazon_filename'
        if value
          amazon_url = "https://s3.amazonaws.com/#{BUCKET}/#{self.klass.to_s}/main/#{value}"
          %{<input type="file" name="#{self.params}[amazon_file]"> <a href="#{amazon_url}">#{value}</a>}                    
        else
          %{<input type="file" name="#{self.params}[amazon_file]">}          
        end
      else 
        %{<input type="text" name="#{self.params}[#{key}]" value="#{render_value(value)}">}
      end
    end
    
    def render_input_boolean(key, value)
      %{<select name="#{self.params}[#{key}]"><option value="1" #{"selected" if value}>True</option><option value="0" #{"selected" if not value}>False</option></select>}
    end
    
    def render_input_integer(key, value)
      render_input_string(key, value)
    end
    
    def render_input_(key, value); end
    
  end

end