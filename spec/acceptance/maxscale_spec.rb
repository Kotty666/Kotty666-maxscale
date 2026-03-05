# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'maxscale class' do
  context 'with default parameters' do
    let(:manifest) do
      <<-PUPPET
      class { 'maxscale':
        manage_repo => true,
      }
      PUPPET
    end

    it 'applies idempotently' do
      idempotent_apply(hosts, manifest)
    end

    describe package('maxscale') do
      it { is_expected.to be_installed }
    end

    describe service('maxscale') do
      it { is_expected.to be_enabled }

      it { is_expected.to be_running }
    end

    describe file('/etc/maxscale.cnf') do
      it { is_expected.to be_file }

      it { is_expected.to be_owned_by 'root' }

      its(:content) { is_expected.to match %r{\[maxscale\]} }

      its(:content) { is_expected.to match %r{threads=auto} }
    end
  end

  context 'with full configuration' do
    let(:manifest) do
      <<-PUPPET
      class { 'maxscale':
        manage_repo    => true,
        global_options => {
          'threads'    => 4,
          'log_info'   => true,
          'admin_host' => '127.0.0.1',
          'admin_port' => 8989,
        },
        servers        => {
          'testdb' => {
            'address' => '127.0.0.1',
            'port'    => 3306,
          },
        },
        monitors       => {
          'TestMonitor' => {
            'module'   => 'mariadbmon',
            'servers'  => 'testdb',
            'user'     => 'maxscale',
            'password' => 'test123',
          },
        },
        services       => {
          'TestService' => {
            'router'   => 'readconnroute',
            'servers'  => 'testdb',
            'user'     => 'maxscale',
            'password' => 'test123',
          },
        },
        listeners      => {
          'TestListener' => {
            'service'  => 'TestService',
            'protocol' => 'MariaDBClient',
            'port'     => 4006,
          },
        },
      }
      PUPPET
    end

    it 'applies idempotently' do
      idempotent_apply(hosts, manifest)
    end

    describe file('/etc/maxscale.cnf') do
      it { is_expected.to be_file }

      its(:content) { is_expected.to match %r{\[maxscale\]} }

      its(:content) { is_expected.to match %r{threads=4} }

      its(:content) { is_expected.to match %r{log_info=true} }

      its(:content) { is_expected.to match %r{\[testdb\]} }

      its(:content) { is_expected.to match %r{type=server} }

      its(:content) { is_expected.to match %r{\[TestMonitor\]} }

      its(:content) { is_expected.to match %r{type=monitor} }

      its(:content) { is_expected.to match %r{\[TestService\]} }

      its(:content) { is_expected.to match %r{type=service} }

      its(:content) { is_expected.to match %r{\[TestListener\]} }

      its(:content) { is_expected.to match %r{type=listener} }
    end
  end

  context 'with service disabled' do
    let(:manifest) do
      <<-PUPPET
      class { 'maxscale':
        manage_repo    => true,
        service_ensure => 'stopped',
        service_enable => false,
      }
      PUPPET
    end

    it 'applies idempotently' do
      idempotent_apply(hosts, manifest)
    end

    describe service('maxscale') do
      it { is_expected.not_to be_enabled }

      it { is_expected.not_to be_running }
    end
  end
end
