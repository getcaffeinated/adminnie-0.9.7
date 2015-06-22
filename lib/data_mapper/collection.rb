module DataMapper
  class Collection
    
    def jsonify
      arr = Array.new
      self.each{|item| arr << item.jsonify}
      "[#{arr.join ","}]"
    end
    
  end
end