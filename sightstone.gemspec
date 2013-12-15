Gem::Specification.new do |s|
  s.name = 'sightstone'
  s.version = '0.2.0'
  s.date  = '2012-12-15'
  s.summary = 'Ruby wrapper for riots league of legends api'
  s.description = s.summary
  s.authors = ["Daniel Bauer"]
  s.email = 'danijob88@googlemail.com'
  s.files = Dir["lib/**/*"]
  s.homepage = 'http://rubygems.org/gems/outrage'
  s.license = 'MIT'
  s.add_runtime_dependency 'rest-client'
  s.add_runtime_dependency 'json'
end
