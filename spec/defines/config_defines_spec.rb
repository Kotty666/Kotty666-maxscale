# frozen_string_literal: true

require 'spec_helper'

describe 'maxscale::config defines' do
  describe 'maxscale::config::server' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:title) { 'db1' }

        context 'with minimal parameters' do
          let(:params) { { address: '192.168.1.10' } }

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/server_db1.cnf').
              with_ensure('present').
              with_content(%r{\[db1\]}).
              with_content(%r{type=server}).
              with_content(%r{address=192\.168\.1\.10})
          }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/server_db1.cnf').
              that_notifies('Class[maxscale::service]')
          }
        end

        context 'with port and options' do
          let(:params) do
            {
              address: '192.168.1.10',
              port: 3306,
              options: {
                'priority'       => 1,
                'proxy_protocol' => true,
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/server_db1.cnf').
              with_content(%r{port=3306}).
              with_content(%r{priority=1}).
              with_content(%r{proxy_protocol=true})
          }
        end

        context 'with ensure absent' do
          let(:params) do
            {
              address: '192.168.1.10',
              ensure: 'absent',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/maxscale.cnf.d/server_db1.cnf').with_ensure('absent') }
        end
      end
    end
  end

  describe 'maxscale::config::monitor' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:title) { 'MariaDB-Monitor' }

        context 'with required parameters' do
          let(:params) do
            {
              module: 'mariadbmon',
              servers: 'db1,db2',
              user: 'maxscale',
              password: 'secret',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/monitor_MariaDB-Monitor.cnf').
              with_content(%r{\[MariaDB-Monitor\]}).
              with_content(%r{type=monitor}).
              with_content(%r{module=mariadbmon}).
              with_content(%r{servers=db1,db2}).
              with_content(%r{user=maxscale})
          }
        end

        context 'with failover options' do
          let(:params) do
            {
              module: 'mariadbmon',
              servers: 'db1,db2',
              user: 'maxscale',
              password: 'secret',
              options: {
                'auto_failover'    => true,
                'auto_rejoin'      => true,
                'monitor_interval' => '2000ms',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/monitor_MariaDB-Monitor.cnf').
              with_content(%r{auto_failover=true}).
              with_content(%r{auto_rejoin=true}).
              with_content(%r{monitor_interval=2000ms})
          }
        end
      end
    end
  end

  describe 'maxscale::config::listener' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:title) { 'RW-Listener' }

        context 'with TCP listener' do
          let(:params) do
            {
              service: 'RW-Service',
              protocol: 'MariaDBClient',
              port: 4006,
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/listener_RW-Listener.cnf').
              with_content(%r{\[RW-Listener\]}).
              with_content(%r{type=listener}).
              with_content(%r{service=RW-Service}).
              with_content(%r{protocol=MariaDBClient}).
              with_content(%r{port=4006})
          }
        end

        context 'with address binding' do
          let(:params) do
            {
              service: 'RW-Service',
              protocol: 'MariaDBClient',
              port: 4006,
              address: '0.0.0.0',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/listener_RW-Listener.cnf').
              with_content(%r{address=0\.0\.0\.0})
          }
        end

        context 'with SSL options' do
          let(:params) do
            {
              service: 'RW-Service',
              protocol: 'MariaDBClient',
              port: 4006,
              options: {
                'ssl'      => true,
                'ssl_cert' => '/etc/maxscale/ssl/server.crt',
                'ssl_key'  => '/etc/maxscale/ssl/server.key',
                'ssl_ca'   => '/etc/maxscale/ssl/ca.crt',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/listener_RW-Listener.cnf').
              with_content(%r{ssl=true}).
              with_content(%r{ssl_cert=/etc/maxscale/ssl/server\.crt})
          }
        end
      end
    end
  end

  describe 'maxscale::config::service' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:title) { 'RW-Service' }

        context 'with basic parameters' do
          let(:params) do
            {
              router: 'readwritesplit',
              servers: 'db1,db2',
              user: 'maxscale',
              password: 'secret',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/service_RW-Service.cnf').
              with_content(%r{\[RW-Service\]}).
              with_content(%r{type=service}).
              with_content(%r{router=readwritesplit}).
              with_content(%r{servers=db1,db2})
          }
        end

        context 'with filters and options' do
          let(:params) do
            {
              router: 'readwritesplit',
              servers: 'db1,db2',
              user: 'maxscale',
              password: 'secret',
              filters: 'QueryLog|Throttle',
              options: {
                'max_slave_connections' => '100%',
                'causal_reads'         => 'local',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/service_RW-Service.cnf').
              with_content(%r{filters=QueryLog\|Throttle}).
              with_content(%r{max_slave_connections=100%}).
              with_content(%r{causal_reads=local})
          }
        end
      end
    end
  end

  describe 'maxscale::config::filter' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:title) { 'QueryLog' }

        context 'with basic parameters' do
          let(:params) do
            {
              module: 'qlafilter',
              options: {
                'filebase' => '/var/log/maxscale/queries',
                'log_type' => 'unified',
                'flush'    => true,
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/etc/maxscale.cnf.d/filter_QueryLog.cnf').
              with_content(%r{\[QueryLog\]}).
              with_content(%r{type=filter}).
              with_content(%r{module=qlafilter}).
              with_content(%r{filebase=/var/log/maxscale/queries}).
              with_content(%r{flush=true})
          }
        end
      end
    end
  end
end
