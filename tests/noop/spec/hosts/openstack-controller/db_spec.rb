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
manifest = 'openstack-controller/db.pp'

describe manifest do
  shared_examples 'catalog' do
    nova_hash            = Noop.hiera_structure 'nova'
    nova_db_user         = nova_hash.fetch('db_user', 'nova')
    nova_db_dbname       = nova_hash.fetch('db_name', 'nova')
    nova_db_password     = nova_hash['db_password']
    nova_api_db_user     = nova_hash.fetch('api_db_user', 'nova_api')
    nova_api_db_dbname   = nova_hash.fetch('api_db_name', 'nova_api')
    nova_api_db_password = Noop.puppet_function 'pick', nova_hash['api_db_password'], nova_hash['db_password']
    allowed_hosts        = ['localhost','127.0.0.1','%']

    it 'should install proper mysql-client' do
      if facts[:osfamily] == 'RedHat'
        pkg_name = 'MySQL-client-wsrep'
      elsif facts[:osfamily] == 'Debian'
        pkg_name = 'mysql-client-5.6'
      end
      should contain_class('mysql::client').with(
        'package_name' => pkg_name,
      )
    end
    it 'should declare nova::db::mysql class with user,password,dbname' do
      should contain_class('nova::db::mysql').with(
        'user'          => nova_db_user,
        'password'      => nova_db_password,
        'dbname'        => nova_db_dbname,
        'allowed_hosts' => allowed_hosts,
      )
    end
    it 'should declare nova::db::mysql_api class with user,password,dbname' do
      should contain_class('nova::db::mysql_api').with(
        'user'          => nova_api_db_user,
        'password'      => nova_api_db_password,
        'dbname'        => nova_api_db_dbname,
        'allowed_hosts' => allowed_hosts,
      )
    end

    allowed_hosts.each do |host|
      it "should define openstacklib::db::mysql::host_access for #{nova_db_dbname} DB for #{host}" do
        should contain_openstacklib__db__mysql__host_access("#{nova_db_dbname}_#{host}")
      end
    end

  end # end of shared_examples
  test_ubuntu_and_centos manifest
end

