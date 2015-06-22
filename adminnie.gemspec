# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{adminnie}
  s.version = "0.9.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.4") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jen Oslislo"]
  s.date = %q{2014-02-19}
  s.email = ["jennifer@stepchangegroup.com"]
  s.files = ["lib/data_mapper", "lib/data_mapper/attachable.rb", "lib/data_mapper/model.rb", "lib/data_mapper/utils.rb", "lib/data_mapper/collection.rb", "lib/adminnie.rb", "lib/views", "lib/views/admin", "lib/views/admin/index.erb", "lib/views/admin/attachables", "lib/views/admin/attachables/checkable.erb", "lib/views/admin/attachables/footer.erb", "lib/views/admin/attachables/selectable.erb", "lib/views/admin/attachables/radioable.erb", "lib/views/admin/attachables/statusable.erb", "lib/views/admin/attachables/bannable.erb", "lib/views/admin/templates", "lib/views/admin/templates/layout.erb", "lib/views/admin/templates/_nav.erb", "lib/views/admin/templates/new.erb", "lib/views/admin/templates/_form.erb", "lib/views/admin/templates/_reports.erb", "lib/views/admin/templates/_messages.erb", "lib/views/admin/templates/connect.erb", "lib/views/admin/templates/index.erb", "lib/views/admin/templates/_error.erb", "lib/views/admin/templates/show.erb", "lib/views/admin/templates/edit.erb", "lib/views/admin/templates/_items.erb", "lib/adminnie", "lib/adminnie/helpers.rb", "lib/adminnie/admin.rb", "lib/adminnie/model.rb", "lib/adminnie/crudite.rb", "lib/adminnie/controller.rb", "lib/adminnie/render.rb", "Gemfile", "Gemfile.lock", "README.md"]
  s.homepage = %q{https://github.com/mjfreshyfresh/adminnie}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{adminnie}
  s.rubygems_version = %q{1.3.7.1}
  s.summary = %q{Automatic admin for Enterprise apps.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack-flash>, [">= 0.1.1"])
      s.add_runtime_dependency(%q<sinatra_messages>, [">= 0"])
      s.add_runtime_dependency(%q<dm-amazon_image>, [">= 2.0.1"])
      s.add_runtime_dependency(%q<rack-flash>, [">= 0"])
      s.add_runtime_dependency(%q<valibot>, [">= 0"])
      s.add_runtime_dependency(%q<extlib>, [">= 0"])
    else
      s.add_dependency(%q<rack-flash>, [">= 0.1.1"])
      s.add_dependency(%q<sinatra_messages>, [">= 0"])
      s.add_dependency(%q<dm-amazon_image>, [">= 2.0.1"])
      s.add_dependency(%q<rack-flash>, [">= 0"])
      s.add_dependency(%q<valibot>, [">= 0"])
      s.add_dependency(%q<extlib>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack-flash>, [">= 0.1.1"])
    s.add_dependency(%q<sinatra_messages>, [">= 0"])
    s.add_dependency(%q<dm-amazon_image>, [">= 2.0.1"])
    s.add_dependency(%q<rack-flash>, [">= 0"])
    s.add_dependency(%q<valibot>, [">= 0"])
    s.add_dependency(%q<extlib>, [">= 0"])
  end
end
