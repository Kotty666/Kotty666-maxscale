# frozen_string_literal: true

require 'spec_helper'

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
              'flush' => true,
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
