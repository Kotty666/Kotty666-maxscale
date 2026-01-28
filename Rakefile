# frozen_string_literal: true

require 'bundler/gem_tasks' if File.exist?('Gemfile')
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_strings/tasks' if Bundler.rubygems.find_name('puppet-strings').any?

PuppetLint.configuration.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('relative')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_single_quote_string_with_variables')

exclude_paths = %w[
  bundle/**/*
  pkg/**/*
  vendor/**/*
  .vendor/**/*
  spec/**/*
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc 'Run all validation and unit tests'
task default: %i[validate lint spec]

desc 'Run acceptance tests'
task :acceptance do
  sh 'pdk bundle exec rake beaker'
end

# Beaker tasks for different nodesets
namespace :beaker do
  desc 'Run beaker acceptance tests with default nodeset'
  task :default do
    sh 'BEAKER_setfile=spec/acceptance/nodesets/default.yml bundle exec rspec spec/acceptance/'
  end

  %w[debian-11 debian-12 ubuntu-2204 ubuntu-2404 rockylinux-8 rockylinux-9].each do |nodeset|
    desc "Run beaker acceptance tests on #{nodeset}"
    task nodeset.to_sym do
      sh "BEAKER_setfile=spec/acceptance/nodesets/#{nodeset}.yml bundle exec rspec spec/acceptance/"
    end
  end
end

desc 'Generate REFERENCE.md'
task :reference do
  sh 'puppet strings generate --format markdown --out REFERENCE.md'
end

desc 'Run all CI tasks'
task ci: %i[validate lint spec]

desc 'Clean build artifacts'
task :clean do
  FileUtils.rm_rf('pkg')
  FileUtils.rm_rf('spec/fixtures/modules')
  FileUtils.rm_rf('coverage')
  FileUtils.rm_rf('log')
  FileUtils.rm_rf('junit')
end
