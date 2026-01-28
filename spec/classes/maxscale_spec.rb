# frozen_string_literal: true

require 'spec_helper'

describe 'maxscale' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('maxscale') }
        it { is_expected.to contain_class('maxscale::install') }
        it { is_expected.to contain_class('maxscale::config') }
        it { is_expected.to contain_class('maxscale::service') }

        it { is_expected.to contain_package('maxscale').with_ensure('installed') }
        it { is_expected.to contain_service('maxscale').with_ensure('running').with_enable(true) }

        it {
          is_expected.to contain_file('/etc/maxscale.cnf')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
        }

        # Check directory management
        %w[/var/log/maxscale /var/lib/maxscale /var/cache/maxscale /var/run/maxscale].each do |dir|
          it {
            is_expected.to contain_file(dir)
              .with_ensure('directory')
              .with_owner('maxscale')
              .with_group('maxscale')
              .with_mode('0755')
          }
        end
      end

      context 'with manage_repo => true' do
        let(:params) { { manage_repo: true } }

        it { is_expected.to compile.with_all_deps }

        case os_facts[:os]['family']
        when 'Debian'
          it { is_expected.to contain_class('maxscale::repo::apt') }
          it { is_expected.to contain_apt__source('maxscale') }
        when 'RedHat'
          it { is_expected.to contain_class('maxscale::repo::yum') }
          it { is_expected.to contain_yumrepo('maxscale') }
        end
      end

      context 'with servers defined' do
        let(:params) do
          {
            servers: {
              'db1' => {
                'address' => '192.168.1.10',
                'port' => 3306,
              },
              'db2' => {
                'address' => '192.168.1.11',
                'port' => 3306,
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/maxscale.cnf')
            .with_content(%r{\[db1\]})
            .with_content(%r{type=server})
            .with_content(%r{address=192\.168\.1\.10})
            .with_content(%r{port=3306})
        }
      end

      context 'with monitor defined' do
        let(:params) do
          {
            servers: {
              'db1' => { 'address' => '192.168.1.10' },
            },
            monitors: {
              'MariaDB-Monitor' => {
                'module' => 'mariadbmon',
                'servers' => 'db1',
                'user' => 'maxscale',
                'password' => 'secret',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/maxscale.cnf')
            .with_content(%r{\[MariaDB-Monitor\]})
            .with_content(%r{type=monitor})
            .with_content(%r{module=mariadbmon})
        }
      end

      context 'with service defined' do
        let(:params) do
          {
            servers: {
              'db1' => { 'address' => '192.168.1.10' },
            },
            services: {
              'RW-Service' => {
                'router' => 'readwritesplit',
                'servers' => 'db1',
                'user' => 'maxscale',
                'password' => 'secret',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/maxscale.cnf')
            .with_content(%r{\[RW-Service\]})
            .with_content(%r{type=service})
            .with_content(%r{router=readwritesplit})
        }
      end

      context 'with listener defined' do
        let(:params) do
          {
            servers: {
              'db1' => { 'address' => '192.168.1.10' },
            },
            services: {
              'RW-Service' => {
                'router' => 'readwritesplit',
                'servers' => 'db1',
              },
            },
            listeners: {
              'RW-Listener' => {
                'service' => 'RW-Service',
                'protocol' => 'MariaDBClient',
                'port' => 4006,
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/maxscale.cnf')
            .with_content(%r{\[RW-Listener\]})
            .with_content(%r{type=listener})
            .with_content(%r{service=RW-Service})
            .with_content(%r{port=4006})
        }
      end

      context 'with filter defined' do
        let(:params) do
          {
            filters: {
              'QueryLog' => {
                'module' => 'qlafilter',
                'filebase' => '/var/log/maxscale/queries',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/maxscale.cnf')
            .with_content(%r{\[QueryLog\]})
            .with_content(%r{type=filter})
            .with_content(%r{module=qlafilter})
        }
      end

      context 'with global_options override' do
        let(:params) do
          {
            global_options: {
              'threads' => 4,
              'log_info' => true,
              'admin_host' => '0.0.0.0',
              'admin_port' => 8989,
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/maxscale.cnf')
            .with_content(%r{\[maxscale\]})
            .with_content(%r{threads=4})
            .with_content(%r{log_info=true})
            .with_content(%r{admin_host=0\.0\.0\.0})
            .with_content(%r{admin_port=8989})
        }
      end

      context 'with service disabled' do
        let(:params) do
          {
            service_ensure: 'stopped',
            service_enable: false,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('maxscale').with_ensure('stopped').with_enable(false) }
      end

      context 'with custom package version' do
        let(:params) { { package_version: '24.02.1' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('maxscale').with_ensure('24.02.1') }
      end

      context 'with extra_config_files' do
        let(:params) do
          {
            extra_config_files: {
              'extra.cnf' => {
                'extra-section' => {
                  'key1' => 'value1',
                  'key2' => 'value2',
                },
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/extra.cnf')
            .with_ensure('file')
            .with_content(%r{\[extra-section\]})
            .with_content(%r{key1=value1})
            .with_content(%r{key2=value2})
        }
      end
    end
  end
end
