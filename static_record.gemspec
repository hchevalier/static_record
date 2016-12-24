$:.push File.expand_path("../lib", __FILE__)

require "static_record/version"

Gem::Specification.new do |s|
  s.name        = 'static_record'
  s.version     = StaticRecord::VERSION
  s.authors     = ['Hugo Chevalier']
  s.email       = ['drakhaine@gmail.com']
  s.homepage    = 'http://www.test.com'
  s.date        = '2016-12-23'
  s.summary     = 'Static immutable records gem'
  s.description = 'Use ruby files to represent immutable records and use them like ActiveRecords'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.2.0'
  # Database
  s.add_dependency 'sqlite3'
  # Tests
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  # Coding style
  s.add_development_dependency 'rubocop'
  # Debug
  s.add_development_dependency 'byebug'
end
