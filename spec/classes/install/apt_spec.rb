# frozen_string_literal: true

require 'spec_helper'

describe 'maxscale::install::apt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<-PRE_COND
          include maxscale
        PRE_COND
      end

      it { is_expected.to compile }
    end
  end
end
