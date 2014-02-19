Gem::Specification.new do |s|
  s.name        = 'ruby-booker'
  s.version     = '0.0.1'
  s.date        = '2014-02-19'
  s.summary     = "Ruby querying of Booker API"
  s.description = "Interact with booker api through Ruby"
  s.authors     = ["Jake Craige"]
  s.email       = 'jake@poeticsystems.com'
  s.files       = ["lib/ruby-booker.rb", "LICENSE", "lib/booker.rb"]
  s.require_paths = ["lib"]
  s.homepage    =
    'http://rubygems.org/gems/ruby-booker'
  s.license       = 'MIT'
  s.add_dependency "httparty"
  s.add_development_dependency "rspec"
end
