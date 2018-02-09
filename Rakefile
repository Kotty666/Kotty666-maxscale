require 'puppet_blacksmith/rake_tasks'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
PuppetLint.configuration.send('disable_80chars')
PuppetLint::RakeTask.new :lint do |config|
config.log_format = "%{path}:%{line}:%{check}:%{KIND}:%{message}"
config.fail_on_warnings = true
config.ignore_paths = [
	"test/**/*.pp",
	"vendor/**/*.pp",
	"examples/**/*.pp",
	"spec/**/*.pp",
	"pkg/**/*.pp"
]
config.disable_checks = []
end
