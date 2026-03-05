# frozen_string_literal: true

require 'spec_helper'

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
              'priority' => 1,
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
