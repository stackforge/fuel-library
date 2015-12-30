require 'spec_helper'
require 'shared-examples'
manifest = 'openstack-haproxy/openstack-haproxy-cinder.pp'

describe manifest do
  shared_examples 'catalog' do

    cinder_nodes = Noop.hiera('cinder_nodes')

    let(:cinder_address_map) do
      Noop.puppet_function 'get_node_to_ipaddr_map_by_network_role', cinder_nodes, 'heat/api'
    end

    let(:ipaddresses) do
      cinder_address_map.values
    end

    let(:server_names) do
      cinder_address_map.keys
    end

    use_cinder = Noop.hiera_structure('cinder/enabled', true)

    if use_cinder
      it "should properly configure cinder haproxy based on ssl" do
        public_ssl_cinder = Noop.hiera_structure('public_ssl/services', false)
        should contain_openstack__ha__haproxy_service('cinder-api').with(
          'order'                  => '070',
          'listen_port'            => 8776,
          'public'                 => true,
          'public_ssl'             => public_ssl_cinder,
          'require_service'        => 'cinder-api',
          'haproxy_config_options' => {
            'option'       => ['httpchk', 'httplog', 'httpclose'],
            'http-request' => 'set-header X-Forwarded-Proto https if { ssl_fc }',
          },
          'balancermember_options' => 'check inter 10s fastinter 2s downinter 3s rise 3 fall 3',
        )
      end
    end
  end
  test_ubuntu_and_centos manifest
end

