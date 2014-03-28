Gem::Specification.new do |s|
  s.name        = 'ruby-booker'
  s.version     = '0.0.17'
  s.date        = '2014-03-28'
  s.summary     = "Ruby querying of Booker API"
  s.description = "Interact with booker api through Ruby"
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
