# frozen_string_literal: true

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'

begin
  require 'puppet_strings/tasks'
rescue LoadError
  # puppet-strings not available
end

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

desc 'Generate REFERENCE.md'
task :reference do
  sh 'puppet strings generate --format markdown --out REFERENCE.md'
end

desc 'Run all CI tasks'
task ci: %i[validate lint spec]
