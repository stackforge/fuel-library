# HIERA: neut_tun.ceph.murano.sahara.ceil-controller
# HIERA: neut_tun.ceph.murano.sahara.ceil-primary-controller
# HIERA: neut_tun.ironic-primary-controller
# HIERA: neut_tun.l3ha-primary-controller
# HIERA: neut_vlan.ceph-primary-controller
# HIERA: neut_vlan.dvr-primary-controller
# HIERA: neut_vlan.murano.sahara.ceil-controller
# HIERA: neut_vlan.murano.sahara.ceil-primary-controller

require 'spec_helper'
require 'shared-examples'
manifest = 'virtual_ips/virtual_ips.pp'

describe manifest do
  shared_examples 'catalog' do
    # TODO: test vip parameters too

    Noop.hiera_structure('network_metadata/vips', {}).each do |name, params|
      next unless params['network_role']
      next unless params['node_roles']
      if params['namespace']
        it "should have '#{name}' VIP" do
          expect(subject).to contain_cluster__virtual_ip(name)
        end
      end
    end
  end

  test_ubuntu_and_centos manifest
end
