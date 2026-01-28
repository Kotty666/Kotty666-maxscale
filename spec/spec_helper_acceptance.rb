# frozen_string_literal: true

require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module on all hosts
    install_module_on(hosts)
    install_module_dependencies_on(hosts)

    # Install required dependencies on all hosts
    hosts.each do |host|
      # Ensure puppet-agent is properly configured
      on(host, 'puppet config set --section main server $(hostname -f)')

      # Install dependencies based on OS
      case host['platform']
      when %r{debian|ubuntu}
        on(host, 'apt-get update')
        on(host, 'apt-get install -y apt-transport-https ca-certificates')
      when %r{el-|centos|redhat|rocky|alma}
        on(host, 'yum install -y epel-release')
      end
    end
  end
end

# Helper method to apply manifest and check for errors
def apply_manifest_on_with_exit(hosts, manifest, opts = {})
  opts[:catch_failures] = true unless opts.key?(:catch_failures)
  apply_manifest_on(hosts, manifest, opts)
end

# Helper method to check idempotency
def idempotent_apply(hosts, manifest)
  apply_manifest_on(hosts, manifest, catch_failures: true)
  apply_manifest_on(hosts, manifest, catch_changes: true)
end
