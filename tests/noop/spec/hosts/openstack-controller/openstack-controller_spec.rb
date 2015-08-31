require 'spec_helper'
require 'shared-examples'
manifest = 'openstack-controller/openstack-controller.pp'

describe manifest do
  shared_examples 'catalog' do

    use_neutron = Noop.hiera 'use_neutron'
    primary_controller = Noop.hiera 'primary_controller'
    sahara_enabled = Noop.hiera_structure 'sahara/enabled'

    if !use_neutron && primary_controller
      floating_ips_range = Noop.hiera 'floating_network_range'
      access_hash  = Noop.hiera_structure 'access'
    end
    service_endpoint = Noop.hiera 'service_endpoint'
    if service_endpoint
      keystone_host = service_endpoint
    else
      keystone_host = Noop.hiera 'management_vip'
    end

    # TODO All this stuff should be moved to shared examples controller* tests.

    # Nova config options
    it 'nova config should have use_stderr set to false' do
      should contain_nova_config('DEFAULT/use_stderr').with(
        'value' => 'false',
      )
    end

    it 'nova config should have report_interval set to 60' do
      should contain_nova_config('DEFAULT/report_interval').with(
        'value' => '60',
      )
    end
    it 'nova config should have service_down_time set to 180' do
      should contain_nova_config('DEFAULT/service_down_time').with(
        'value' => '180',
      )
    end

    keystone_ec2_url = "http://#{keystone_host}:5000/v2.0/ec2tokens"
    it 'should declare class nova::api with keystone_ec2_url' do
      should contain_class('nova::api').with(
        'keystone_ec2_url' => keystone_ec2_url,
      )
    end

    it 'should configure keystone_ec2_url for nova api service' do
      should contain_nova_config('DEFAULT/keystone_ec2_url').with(
        'value' => keystone_ec2_url,
      )
    end

    it 'should configure nova quota for injected file path length' do
      should contain_class('nova::quota').with('quota_injected_file_path_length' => '4096')
      should contain_nova_config('DEFAULT/quota_injected_file_path_length').with(
        'value' => '4096',
      )
    end

    if floating_ips_range && access_hash
      floating_ips_range.each do |ips_range|
        it "should configure nova floating IP range for #{ips_range}" do
          should contain_nova_floating_range(ips_range).with(
            'ensure'      => 'present',
            'pool'        => 'nova',
            'username'    => access_hash['user'],
            'api_key'     => access_hash['password'],
            'auth_method' => 'password',
            'auth_url'    => "http://#{keystone_host}:5000/v2.0/",
            'api_retries' => '10',
          )
        end
      end
    end

    if sahara_enabled
      cinder_user = Noop.hiera_structure('cinder/user', "cinder")
      cinder_user_password = Noop.hiera_structure('cinder/user_password')
      cinder_tenant = Noop.hiera_structure('cinder/tenant', "services")
      storage_lvm = Noop.hiera_structure 'storage/volumes_lvm'
      if storage_lvm
        it "should contain cinder config with privileged user settings" do
          should contain_cinder_config('DEFAULT/os_privileged_user_password').with_value(cinder_user_password)
          should contain_cinder_config('DEFAULT/os_privileged_user_tenant').with_value(cinder_tenant)
          should contain_cinder_config('DEFAULT/os_privileged_user_auth_url').with_value("http://#{keystone_host}:5000")
          should contain_cinder_config('DEFAULT/os_privileged_user_name').with_value(cinder_user)
          should contain_cinder_config('DEFAULT/nova_catalog_admin_info').with_value("compute:nova:adminURL")
          should contain_cinder_config('DEFAULT/nova_catalog_info').with_value("compute:nova:publicURL")
        end
      end
    end

  end # end of shared_examples

  test_ubuntu_and_centos manifest
end

