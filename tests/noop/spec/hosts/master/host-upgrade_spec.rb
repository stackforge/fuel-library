require 'spec_helper'
require 'shared-examples'
manifest = 'master/host-upgrade.pp'

# HIERA: master
# FACTS: master_centos6 master_centos7

describe manifest do

  before(:each) do
    task.puppet_function_load :file
    MockFunction.new(:file) do |function|
      allow(function).to receive(:call).with(['/etc/dockerctl/config']).and_return('dockerctl_data')
    end
  end

  test_centos manifest
end
