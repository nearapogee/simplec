$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simplec/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simplec"
  s.version     = Simplec::VERSION
  s.authors     = ["Matt Smith"]
  s.email       = ["matt@nearapogee.com"]
  s.homepage    = "https://github.com/nearapogee/simplec"
  s.summary     = "Developer oriented CMS."
  s.description = "A CMS that doesn't take over an application."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.1.0"
  s.add_dependency "pg", ">= 0.21.0"
  s.add_dependency "dragonfly", ">= 1.0.0"

  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "bootstrap-sass", ">= 3.0.0"
  s.add_development_dependency "bcrypt"
  s.add_development_dependency "redcarpet"
end
