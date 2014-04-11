Gem::Specification.new do |s|
  s.name        = 'ruby-booker'
  s.version     = '0.0.19'
  s.date        = '2014-04-11'
  s.summary     = "Ruby interface to Booker API"
  s.description = "Interact with Booker API through Ruby"
  s.authors     = ["Jake Craige"]
  s.email       = 'jake@poeticsystems.com'
  s.files       = ["lib/ruby-booker.rb", "LICENSE", "lib/booker.rb", "lib/booker/helpers.rb"]
  s.require_paths = ["lib"]
  s.homepage    =
    'http://rubygems.org/gems/ruby-booker'
  s.license       = 'MIT'
  s.add_dependency "httparty"
  s.add_dependency "activesupport"
  s.add_development_dependency "rspec"
  s.add_development_dependency "awesome_print"
end
