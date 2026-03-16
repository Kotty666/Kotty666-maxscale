# frozen_string_literal: true

require 'spec_helper'

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
              'ssl' => true,
              'ssl_cert' => '/etc/maxscale/ssl/server.crt',
              'ssl_key' => '/etc/maxscale/ssl/server.key',
              'ssl_ca' => '/etc/maxscale/ssl/ca.crt',
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
