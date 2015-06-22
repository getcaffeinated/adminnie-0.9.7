# Customizing Adminnie #

* To specify specific columns in the list view, override self.list_attributes in the model:

`
	def self.list_attributes
  	["uid", "name", "email", "banned", "created"];
	end
`

* To specify specific columns in the edit view, override self.edit_attributes in the model:

`
	def self.edit_attributes
  	["title", "body"];
	end
`

* To allow user to edit a model, override self.readonly? in the model:

`
	def self.readonly?
  	false;
	end
`

* To prevent a model from showing up in the admin links, override self.listable? in the model:

`
	def self.listable?
  	false;
	end
`

* To prevent a model from being deletable, override self.indestructible? in the model:

`
	def self.indestructible?
  	true;
	end
`

* To change the default rendering of a model, add a to_s method (it defaults to self.name if available, or ModelName #xx if not):

`
	def to_s
  	self.descriptor;
	end
`

* To change how it looks, edit public/css/admin.css

* admin.yml:

`
	entries_per_page: 10 # entries per page in list view
	suppress_dashboard: false # don't show the "Home" link in the navigation
	uid_whitelist: # users for admin access
	    - '655764281' # Jen
	    - '100000981545471' # Dev Jen
			...
`