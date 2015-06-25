# -*- encoding: utf-8 -*-
# stub: locomotivecms_liquid_extensions 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "locomotivecms_liquid_extensions"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Didier Lafforgue"]
  s.date = "2015-06-25"
  s.description = "Extra liquid tags, filters for LocomotiveCMS"
  s.email = ["did@locomotivecms.com"]
  s.files = [
  "lib/locomotive", 
  "lib/locomotive/liquid_extensions", 
  "lib/locomotive/liquid_extensions.rb", 
  "lib/locomotive/liquid_extensions/filters", 
  "lib/locomotive/liquid_extensions/filters/hexdigest.rb", 
  "lib/locomotive/liquid_extensions/filters/json.rb", 
  "lib/locomotive/liquid_extensions/filters/math.rb", 
  "lib/locomotive/liquid_extensions/filters/number.rb", 
  "lib/locomotive/liquid_extensions/filters/sample.rb", 
  "lib/locomotive/liquid_extensions/misc", 
  "lib/locomotive/liquid_extensions/misc/number_helper.rb", 
  "lib/locomotive/liquid_extensions/tags", 
  "lib/locomotive/liquid_extensions/tags/create.rb", 
  "lib/locomotive/liquid_extensions/tags/facebook_posts.rb", 
  "lib/locomotive/liquid_extensions/tags/for.rb", 
  "lib/locomotive/liquid_extensions/tags/send_email.rb", 
  "lib/locomotive/liquid_extensions/tags/update.rb", 
  "lib/locomotive/liquid_extensions/version.rb", 
  "lib/locomotivecms_liquid_extensions.rb",
  "lib/locomotive/liquid_extensions/tags/editable.rb", 
  "lib/locomotive/liquid_extensions/tags/editable/text_interpreter.rb", 
  "lib/locomotive/liquid_extensions/tags/form_builder.rb", 
  "lib/locomotive/liquid_extensions/tags/teaser.rb" 
  ]
  s.homepage = "http://www.locomotivecms.com"
  s.rubyforge_project = "locomotivecms_liquid_extensions"
  s.rubygems_version = "2.4.6"
  s.summary = "LocomotiveCMS Liquid Extensions"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, ["~> 3"])
      s.add_runtime_dependency(%q<pony>, ["~> 1.8"])
      s.add_runtime_dependency(%q<locomotivecms_solid>, ["~> 0.2.2"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<activesupport>, ["~> 3"])
      s.add_dependency(%q<pony>, ["~> 1.8"])
      s.add_dependency(%q<locomotivecms_solid>, ["~> 0.2.2"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<activesupport>, ["~> 3"])
    s.add_dependency(%q<pony>, ["~> 1.8"])
    s.add_dependency(%q<locomotivecms_solid>, ["~> 0.2.2"])
  end
end
