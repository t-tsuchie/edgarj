$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "edgarj/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "edgarj"
  s.version     = Edgarj::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Edgarj."
  s.description = "TODO: Description of Edgarj."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails",               "~> 4.0.13"
  s.add_dependency 'jquery-rails',        '~> 3.1', '>= 3.1.0'
  s.add_dependency 'jquery-ui-rails',     '~> 5.0', '>= 5.0.0'
  s.add_dependency 'config',              '~> 1.0.0'
  s.add_dependency "kaminari",            '~> 0.15'
  s.add_dependency "remotipart",          '~> 1.2'
  s.add_dependency 'awesome_nested_set',  '~> 3'
  s.add_dependency 'activerecord-session_store',  '~> 0.1'

  s.add_development_dependency "mysql2",          '~> 0.3.20'
end
