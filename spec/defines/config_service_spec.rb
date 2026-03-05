# frozen_string_literal: true

require 'spec_helper'

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
              'causal_reads' => 'local',
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
