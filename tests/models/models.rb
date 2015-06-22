# MODELS

# Individual apt listing
class Listing

    include DataMapper::Resource

    property :id,           Serial
    property :title,        String
    property :content,      Text
    property :address,      String
    property :price,        Integer
    property :posting_id,   Integer
    property :size,     String
    property :url, String
    property :listing_date, String
    property :created_at, DateTime

    belongs_to :zip_code, :required => false
    belongs_to :area, :required => false

end


# Geocoded zipcode
class ZipCode

  include DataMapper::Resource

  property :id, Serial
  property :zip_code, Integer
  property :lat, String
  property :lng, String
  property :created_at, DateTime
  
  has n, :listing
  
end

# Experimental class storing location strings -- might not be useful for anything
class Area

  include DataMapper::Resource

  property :id,           Serial
  property :zip_code,     String
  property :location,     String
  property :created_at,   DateTime

  has n, :listing

end

require 'md5'

class User
  include DataMapper::Resource
  
  property :id, Serial, :index             => true
  property :uid, String, :required         => true, :length => 15
  property :first_name, String, :required  => true, :length => 100
  property :last_name, String, :required   => true, :length => 100
  property :email, String, :required       => false, :unique => true, :length => 100
  property :banned, Boolean, :required     => true, :default => false
  property :created_at, DateTime, :index   => true
  property :updated_at, DateTime

  
  attr_accessor :facebook_session

  def self.readonly?
    true
  end
  
  def banned=(bool)
    if bool
      ban_or_unban('admin.unbanUsers')
    else
      ban_or_unban('admin.banUsers')
    end
    super
  end
  
  def self.list_attributes
    ["uid", "name", "email", "banned", "created"]
  end
  
  def self.jen
    User.first(:first_name=>'Dev Jen')
  end
    
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  #def to_s
  #  Rack::Utils.escape_html self.name
  #end
  
  def split_name(name)
    if name =~ /(.+)\s([^\s]+)/
      first_name = $1
      last_name = $2
    else
      first_name = name
      last_name = ""
    end
    
    [first_name, last_name]
  end
  
  def toggle_banned
    if self.banned
      self.banned = false
      ban_or_unban('admin.unbanUsers')
    else
      self.banned = true
      ban_or_unban('admin.banUsers')
    end  
    self.save
  end
  
  def display_name 
    "#{self.first_name} #{self.last_name[0..0]}."
  end

  def profile_pic_tag(type = :small, klass = '')
    "<img" + (klass.blank? ? "" : " class=\"#{klass}\"") +
    " src=\"https://" + Koala::Facebook::GRAPH_SERVER + "/#{self.uid}/picture?&type=#{type.to_s}\"/>"
  end
  
  def self.banned_users(domain, page_num=0)
    self.page(page_num, {:banned => 1, :domain => domain})
  end
  
  def self.hijack
    hijackers = [['100000981545471', "Dev Jen", "Oslislo"], ['100002098302692', "Eugene", "Pumpernickel"], ['100001661925784', 'Jax', 'Oslislo'], ['503381601', "Lindsey", "Kirkbride"]]
  
    User.all.each do |user|
      return if hijackers.size == 0
      if user.friends.count > 0 and user.photos.count > 0
        hijacker        = hijackers.pop
        user.uid        = hijacker[0]
        user.first_name = hijacker[1]
        user.last_name  = hijacker[2]
        user.save

      end
    end
    
  end
  
  private

  def ban_or_unban(method = 'admin.banUsers')
    args        = {
      'api_key' => confit.facebook.api_key,
      'uids'    => Yajl.dump([self.uid]),
      'method'  => method,
      'format'  => 'json'
      }
    args['sig'] = User.generate_sig(args)
    Koala::Facebook::RestAPI.new.rest_call(method, args)
  end
  
  def self.generate_sig(args = {}, secret = confit.facebook.secret_key)
    req_str = ''
    args.keys.sort.each {|k| req_str << k.to_s << '=' << args[k].to_s}
    req_str << secret
    return MD5.hexdigest(req_str)
  end
  
end

class CamelCase
  include DataMapper::Resource
  property :id, Serial, :index => true
  property :is_public, Boolean, :required => true, :default => false
  property :opt_in, Boolean, :required => true, :default => true
  property :how_many_trips, Integer
  property :num_adults, Integer
  property :num_children, Integer
  property :arrival_date, Date, :index => true, :required => true
  property :departure_date, Date, :index => true, :required => true
  property :created_at, DateTime, :index => true
  property :updated_at, DateTime
  
  belongs_to :user
  
  def to_s
    "#{self.arrival_date} to #{self.departure_date}"
  end
  
end
