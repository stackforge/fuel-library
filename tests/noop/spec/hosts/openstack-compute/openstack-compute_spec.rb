require 'spec_helper'
require 'shared-examples'
manifest = 'roles/compute.pp'

describe manifest do
  shared_examples 'catalog' do

   storage_hash = Noop.hiera_structure 'storage'

   it 'should declare class nova::compute with install_bridge_utils set to false' do
      should contain_class('nova::compute').with(
        'install_bridge_utils' => false,
      )
    end

    it 'should configure libvirt_inject_partition for compute node' do
      if storage_hash['ephemeral_ceph'] || storage_hash['volumes_ceph']
        libvirt_inject_partition = '-2'
      elsif facts[:operatingsystem] == 'CentOS'
        libvirt_inject_partition = '-1'
      else
        should contain_k_mod('nbd').with('ensure' => 'present')

        should contain_file_line('nbd_on_boot').with(
          'path' => '/etc/modules',
          'line' => 'nbd',
        )
        libvirt_inject_partition = '1'
      end
      should contain_class('nova::compute::libvirt').with(
        'libvirt_inject_partition' => libvirt_inject_partition,
      )
    end

    it 'should enable migration support for libvirt with vncserver listen on 0.0.0.0' do
      should contain_class('nova::compute::libvirt').with('migration_support' => true)
      should contain_class('nova::compute::libvirt').with('vncserver_listen' => '0.0.0.0')
      should contain_class('nova::migration::libvirt')
    end

    it 'should declare class nova::compute::libvirt with compute_driver set to libvirt.LibvirtDriver by default' do
      should contain_class('nova::compute::libvirt').with(
        'compute_driver' => 'libvirt.LibvirtDriver',
      )
    end

    it 'should declare class nova::compute::libvirt with compute_driver set to ironic.IronicDriver' do
      compute_driver = 'ironic.IronicDriver'
      should contain_class('nova::compute::libvirt').with(
        'compute_driver' => 'ironic.IronicDriver',
      )
    end

  end # end of shared_examples

  test_ubuntu_and_centos manifest
end
