require 'spec_helper'
require 'shared-examples'
manifest = 'master/host-upgrade.pp'

describe manifest do

  before(:each) do
    Noop.puppet_function_load :file
    MockFunction.new(:file) do |function|
      allow(function).to receive(:call).with(['/etc/dockerctl/config']).and_return('dockerctl_data')
    end
    let(:containers_line) do
      containers_line = 'CONTAINER_SEQUENCE="postgres rabbitmq keystone rsync astute rsyslog nailgun ostf nginx cobbler mcollective"'
    end
  end

  test_centos manifest
end
