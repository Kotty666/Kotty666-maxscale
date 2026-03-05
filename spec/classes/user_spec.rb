# frozen_string_literal: true

require 'spec_helper'

describe 'maxscale' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with manage_user => true' do
        let(:params) do
          {
            manage_user: true,  # <-- Das fehlende Flag
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('maxscale::user') }
        it { is_expected.to contain_user('maxscale') }
        it { is_expected.to contain_group('maxscale') }
      end
    end
  end
end
