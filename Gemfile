# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puppet', ENV['PUPPET_GEM_VERSION'] || '>= 7.0'
gem 'facterdb', '>= 1.18.0'

group :development do
  gem 'pdk', '~> 3.0'
  gem 'rake'
end

group :test do
  gem 'puppet-lint', '>= 4.0'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper', '>= 5.0'
  gem 'rspec-puppet', '>= 4.0'
  gem 'rspec-puppet-facts', '>= 4.0'
  gem 'simplecov'
  gem 'simplecov-console'
end

group :acceptance do
  gem 'beaker', '>= 5.0'
  gem 'beaker-puppet'
  gem 'beaker-docker'
  gem 'beaker-rspec'
end

group :documentation do
  gem 'puppet-strings', '>= 4.0'
  gem 'yard'
end
