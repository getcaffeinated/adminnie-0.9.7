module DataMapper
  module Utils
    
    def falsify_other_booleans(bool)
      self.class.all(bool.to_sym => true).each do |truth|
        truth.send("#{bool}=", false)
        truth.save
      end
    end
    
    def toggle_boolean(bool)
      self.send("#{bool}=", !(self.send(bool)))
      self.save
    end
    
    def next(conditions={}, id=nil)
      id = (id.nil? ? self.id : id)
      maybe_next_id = id+1
      if maybe_next_id <= self.class.count and self.class.all(conditions).map(&:id).include?(maybe_next_id)
        return self.class.get(maybe_next_id)
      else
        if id > self.class.count
          return self.class.first(conditions)
        else
          return self.next(conditions, maybe_next_id)
        end
      end
    end

    def previous(conditions={}, id=nil)
      id = (id.nil? ? self.id : id)
      maybe_previous_id = id-1
      if maybe_previous_id > 0 and self.class.all(conditions).map(&:id).include?(maybe_previous_id)
        return self.class.get(maybe_previous_id)
      else
        if id < 1
          return self.class.last(conditions)
        else
          return self.previous(conditions, maybe_previous_id)
        end
        
      end
    end
    
    def amazon_file
      if self.class.included_modules.include?(DataMapper::AmazonImage::Resource)
        @amazon_file
      end
    end
    
    def amazon_file=(image)
      if self.class.included_modules.include?(DataMapper::AmazonImage::Resource)
        @amazon_file = image
      end
    end
    
    def to_s
      if self.class.included_modules.include?(DataMapper::AmazonImage::Resource)
        self.photo
      elsif self.respond_to?('name')
        self.name
      else
        "#{self.class.to_s} \##{self.id}"
      end
    end
    
    def photo
      if self.class.included_modules.include?(DataMapper::AmazonImage::Resource)
        "<img src='#{self.amazon_public_url(:thumb)}' class='photo'>"
      end
    end
    
    def created
      self.formatted_created_at
    end
    
    def updated
      self.formatted_updated_at
    end
    
    def formatted_created_at
      created_at.strftime(fmt='%m/%d/%Y') if self.respond_to?("created_at")
    end
    
    def formatted_updated_at
      updated_at.strftime(fmt='%m/%d/%Y') if self.respond_to?("updated_at")
    end
    
    def errors_for
      "Please correct the following errors:\n<br/>#{self.errors.map{|error| error}.join("\n<br/>")}"
    end
    
    def jsonify
      hashy = Hash.new
      attributes = self.class.properties.map do |i| 
        unless (i.name.to_s =~ /_id$/)
          hashy[i.name.to_s] = self.send(i.name.to_s)
        end
      end
      self.class.associations.each do |ass|
        hashy[ass.to_s] = self.send(ass).jsonify
      end
      
      Yajl.dump hashy
    end
       
  end
  
end

DataMapper::Model.append_inclusions DataMapper::Utils