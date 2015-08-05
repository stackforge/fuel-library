require 'spec_helper'
require 'shared-examples'
manifest = 'api-proxy/api-proxy.pp'

describe manifest do
  shared_examples 'catalog' do

    let(:master_ip) do
      Noop.hiera('master_ip')
    end

    let(:limit_request_field_size) do
      Noop.hiera('limit_request_field_size', '81900')
    end

    it "should delcare osnailyfacter::apache_api_proxy" do
      expect(subject).to contain_class('osnailyfacter::apache_api_proxy').with(
        'master_ip'                => master_ip,
        'limit_request_field_size' => limit_request_field_size,
      )
    end
  end
  test_ubuntu_and_centos manifest
end
