require 'spec_helper'
require 'bolt_spec/plans'

describe 'maxscale::deploy' do
  include BoltSpec::Plans

  it 'compiles' do
    is_expected.to run_plan('maxscale::deploy')
  end
end

