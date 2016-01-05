# -*- encoding: utf-8 -*-
# stub: ruby-booker 0.0.26 ruby lib

Gem::Specification.new do |s|
  s.name = "bookie"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jake Craige", "Chris MacNaughton", "Vive Lifestyle"]
  s.date = "2015-06-10"
  s.description = "Interact with Booker API through Ruby"
  s.email = "engineering@vivestyle.com"
  s.files = ["LICENSE", "lib/booker.rb", "lib/booker/helpers.rb", "lib/bookie.rb"]
  s.homepage = "https://github.com/vive/bookie"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5"
  s.summary = "Ruby interface to Booker API"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 10.4"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 10.4"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<awesome_print>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 10.4"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<awesome_print>, [">= 0"])
  end
end
