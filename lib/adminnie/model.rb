class UnknownClassError < StandardError
  def initialize
      super("Model not found" )
  end
end

module Adminnie

  class Model
    
    attr_accessor :model_name, :action, :display_name, :display_plural, :klass, :link, :params
    
    def initialize(model_name, action=nil)
      self.update(model_name, action)
    end
    
    def views
      File.join(File.expand_path(File.join(File.dirname(__FILE__))), '..', 'views')
    end
        
    def update(model_name, action=nil)
      return if model_name == 'admin' or model_name == 'canvas'
      
      self.model_name = Extlib::Inflection.singular(Extlib::Inflection.camelize(model_name))
      self.model_name.gsub!(/\.(.+)/,'') # Get rid of .csv 
      raise UnknownClassError unless DataMapper::Model.descendants.include?(get_klass)
      
      self.display_name = Extlib::Inflection.humanize(self.model_name)
      self.display_plural = Extlib::Inflection.plural(self.display_name)
      self.klass = get_klass
      self.link = model_name
      self.params = Extlib::Inflection.singular(model_name)
      self.action = action
      
    end
    
    def get_klass
      Kernel.const_get(self.model_name)
    rescue NameError => e
      puts e.to_s
      nil
    end
      
  end
  
end