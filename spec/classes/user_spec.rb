require 'spec_helper'

describe 'maxscale' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      # Minimal sinnvolle Parameter, falls dein module strikte Typen ohne Defaults hat
      let(:params) do
        {
          package_name: 'maxscale',
          package_version: 'present',
          service_ensure: 'running',
          service_enable: true,
          service_name: 'maxscale',
          manage_repo: false,
          repo_version: '24.02',          # oder was du erwartest
          repo_base_url: nil,
          gpg_key_id: '0xDEADBEEF',        # dummy ok, wenn nicht validiert
          config_dir: '/etc/maxscale',
          config_file: 'maxscale.cnf',
          config_owner: 'maxscale',
          config_group: 'maxscale',
          config_mode: '0640',
          global_options: {},
          servers: {},
          monitors: {},
          services: {},
          listeners: {},
          filters: {},
          manage_dirs: false,
          log_dir: '/var/log/maxscale',
          data_dir: '/var/lib/maxscale',
          cache_dir: '/var/cache/maxscale',
          pid_dir: '/run/maxscale',
          maxscale_user: 'maxscale',
          maxscale_group: 'maxscale',
          extra_config_files: {},
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('maxscale::user') }
    end
  end
end

