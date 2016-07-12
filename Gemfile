source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'metadata-json-lint'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem 'rspec-puppet'
gem 'puppet-blacksmith', '~> 3.3', '>= 3.3.1'
gem 'iconv', '~> 1.0.3'

if RUBY_VERSION < '2.0.0'
  gem 'json' < '2.0.0'
end
if RUBY_VERSION >= '2.0.0'
  gem 'json' 
end
if RUBY_VERSION >= '2.1.0'
  gem 'syck'
end

