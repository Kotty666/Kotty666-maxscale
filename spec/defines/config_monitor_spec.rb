# frozen_string_literal: true

require 'spec_helper'

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
              'auto_failover' => true,
              'auto_rejoin' => true,
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
