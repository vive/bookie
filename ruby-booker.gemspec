require File.join(File.dirname(__FILE__), 'lib','booker', 'version')
Gem::Specification.new do |s|
  s.name        = 'ruby-booker'
  s.version     = Booker::VERSION
  s.date        = '2015-006-10'
  s.summary     = "Ruby interface to Booker API"
  s.description = "Interact with Booker API through Ruby"
  s.authors     = ["Jake Craige", "Chris MacNaughton"]
  s.email       = 'development@beautynowapp.com'
  s.files       = ["lib/ruby-booker.rb", "LICENSE", "lib/booker.rb", "lib/booker/helpers.rb"]
  s.require_paths = ["lib"]
  s.homepage    =
    'https://github.com/BeautyNow/ruby-booker'
  s.license       = 'MIT'
  s.add_dependency "httparty"
  s.add_dependency "activesupport"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "awesome_print"
end
