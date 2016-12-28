$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'static_record/version'

Gem::Specification.new do |s|
  s.name        = 'static-record'
  s.version     = StaticRecord::VERSION
  s.authors     = ['Hugo Chevalier']
  s.email       = ['drakhaine@gmail.com']
  s.homepage    = 'https://github.com/hchevalier/static_record'
  s.date        = '2016-12-28'
  s.summary     = 'Static immutable records gem'
  s.description = <<-EOF
    StaticRecord is a module allowing to perform ActiveRecord-like queries
    over Ruby files.
    Those act as immutable database records that only developers can alter.
    Their attributes are stored in a SQLite3 database re-created on startup.
    Queries instantiate each retrieved records.
  EOF
  s.license     = 'MIT'

  s.files       = Dir[
                  '{app,config,db,lib}/**/*',
                  'MIT-LICENSE',
                  'Rakefile',
                  'README.rdoc'
                ]
  s.test_files  = Dir['spec/**/*.rb']

  s.add_dependency 'rails', '~> 4.2.0'
  # Database
  s.add_dependency 'sqlite3', '~> 1.3'
  # Tests
  s.add_development_dependency 'rake', '~> 12.0.0'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rspec-rails', '~> 3.5'
  # Test coverage
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0.0'
  # Coding style
  s.add_development_dependency 'rubocop', '~> 0.46.0'
end
