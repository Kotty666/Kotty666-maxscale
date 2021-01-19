# frozen_string_literal: true

require 'spec_helper'

describe 'maxscale' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if f[:os]['family'] == 'Debian'
        let('include maxscale::install')

      end
      it { is_expected.to compile }
    end
  end
end
