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

  s.add_dependency "rails", "~> 4.0.13"

  s.add_development_dependency "mysql2",          '~> 0.3.20'
end
