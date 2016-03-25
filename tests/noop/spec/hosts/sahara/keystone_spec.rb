# RUN: neut_vxlan_dvr.murano.sahara-primary-controller.yaml ubuntu
# RUN: neut_vxlan_dvr.murano.sahara-primary-controller.overridden_ssl.yaml ubuntu
# RUN: neut_vxlan_dvr.murano.sahara-controller.yaml ubuntu
# RUN: neut_vxlan_dvr.murano.sahara-compute.yaml ubuntu
# RUN: neut_vxlan_dvr.murano.sahara-cinder.yaml ubuntu
# RUN: neut_vlan_l3ha.ceph.ceil-primary-mongo.yaml ubuntu
# RUN: neut_vlan_l3ha.ceph.ceil-primary-controller.yaml ubuntu
# RUN: neut_vlan_l3ha.ceph.ceil-controller.yaml ubuntu
# RUN: neut_vlan_l3ha.ceph.ceil-compute.yaml ubuntu
# RUN: neut_vlan_l3ha.ceph.ceil-ceph-osd.yaml ubuntu
# RUN: neut_vlan.ironic.controller.yaml ubuntu
# RUN: neut_vlan.ironic.conductor.yaml ubuntu
# RUN: neut_vlan.compute.ssl.yaml ubuntu
# RUN: neut_vlan.compute.ssl.overridden.yaml ubuntu
# RUN: neut_vlan.compute.nossl.yaml ubuntu
# RUN: neut_vlan.cinder-block-device.compute.yaml ubuntu
# RUN: neut_vlan.ceph.controller-ephemeral-ceph.yaml ubuntu
# RUN: neut_vlan.ceph.compute-ephemeral-ceph.yaml ubuntu
# RUN: neut_vlan.ceph.ceil-primary-controller.overridden_ssl.yaml ubuntu
# RUN: neut_vlan.ceph.ceil-compute.overridden_ssl.yaml ubuntu
# RUN: neut_gre.generate_vms.yaml ubuntu
require 'spec_helper'
require 'shared-examples'
manifest = 'sahara/keystone.pp'

describe manifest do
  shared_examples 'catalog' do
    let(:public_vip) { Noop.hiera('public_vip') }
    let(:admin_address) { Noop.hiera('management_vip') }
    let(:public_ssl) { Noop.hiera_structure('public_ssl/services') }
    let(:public_ssl_hostname) { Noop.hiera_structure('public_ssl/hostname') }

    let(:api_bind_port) { '8386' }
    let(:public_protocol) { public_ssl ? 'https' : 'http' }
    let(:public_address) { public_ssl ? public_ssl_hostname : public_vip }

    let(:sahara_user) { Noop.hiera_structure('sahara/user', 'sahara') }
    let(:sahara_password) { Noop.hiera_structure('sahara/user_password') }
    let(:tenant) { Noop.hiera_structure('sahara/tenant', 'services') }
    let(:region) { Noop.hiera_structure('sahara/region', 'RegionOne') }
    let(:service_name) { Noop.hiera_structure('sahara/service_name', 'sahara') }
    let(:public_url) { "#{public_protocol}://#{public_address}:#{api_bind_port}/v1.1/%(tenant_id)s" }
    let(:admin_url) { "http://#{admin_address}:#{api_bind_port}/v1.1/%(tenant_id)s" }

    it 'should have explicit ordering between LB classes and particular actions' do
      expect(graph).to ensure_transitive_dependency("Haproxy_backend_status[keystone-public]",
                                                      "Class[sahara::keystone::auth]")
      expect(graph).to ensure_transitive_dependency("Haproxy_backend_status[keystone-admin]",
                                                      "Class[sahara::keystone::auth]")
    end

    it 'should declare sahara::keystone::auth class correctly' do
      should contain_class('sahara::keystone::auth').with(
                 'auth_name' => sahara_user,
                 'password' => sahara_password,
                 'service_type' => 'data-processing',
                 'service_name' => service_name,
                 'region' => region,
                 'tenant' => tenant,
                 'public_url' => public_url,
                 'admin_url' => admin_url,
                 'internal_url' => admin_url
             )
    end
  end
  test_ubuntu_and_centos manifest
end
