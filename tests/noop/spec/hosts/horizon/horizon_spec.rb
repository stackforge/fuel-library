require 'spec_helper'
require 'shared-examples'
manifest = 'horizon/horizon.pp'

# HIERA: neut_vlan.ceph.controller-ephemeral-ceph
# FACTS: ubuntu

describe manifest do
  shared_examples 'catalog' do

    let(:network_scheme) do
      task.hiera_hash 'network_scheme'
    end

    let(:service_endpoint) do
      task.hiera 'service_endpoint'
    end

    let(:prepare) do
      task.puppet_function 'prepare_network_config', network_scheme
    end

    let(:bind_address) do
      prepare
      task.puppet_function 'get_network_role_property', 'horizon', 'ipaddr'
    end

    let(:nova_quota) do
      task.hiera 'nova_quota'
    end

    let(:management_vip) do
      task.hiera 'management_vip'
    end

    let(:ssl_hash) { task.hiera_hash 'use_ssl', {} }

    let(:internal_auth_protocol) { task.puppet_function 'get_ssl_property',ssl_hash,{},'keystone','internal','protocol','http' }

    let(:internal_auth_address) { task.puppet_function 'get_ssl_property',ssl_hash,{},'keystone','internal','hostname',[service_endpoint, management_vip] }

    let(:keystone_url) do
      "#{internal_auth_protocol}://#{internal_auth_address}:5000/v3"
    end

    let(:cache_options) do
      {
          'SOCKET_TIMEOUT' => 1,
          'SERVER_RETRIES' => 1,
          'DEAD_RETRY'     => 1,
      }
    end

    memcache_addresses   = task.hiera 'memcached_addresses', false
    memcache_server_port = task.hiera 'memcache_server_port', '11211'

    let(:memcache_nodes) do
      task.puppet_function 'get_nodes_hash_by_roles', network_metadata, memcache_roles
    end

    let(:memcache_address_map) do
      task.puppet_function 'get_node_to_ipaddr_map_by_network_role', memcache_nodes, 'mgmt/memcache'
    end

    let (:memcache_servers) do
      if not memcache_addresses
        memcache_address_map.values
      else
        memcache_addresses
      end
    end

    storage_hash = task.hiera 'storage_hash'
    let(:cinder_options) do
      { 'enable_backup' => storage_hash.fetch('volumes_ceph', false) }
    end

    ###########################################################################

    it 'should declare openstack::horizon class' do
      should contain_class('openstack::horizon').with(
                 'cinder_options'     => cinder_options,
                 'hypervisor_options' => {'enable_quotas' => nova_quota},
                 'bind_address'       => bind_address
             )
    end

    it 'should declare openstack::horizon class with keystone_url' do
      should contain_class('openstack::horizon').with(
                 'keystone_url' => keystone_url,
                 'cache_server_ip' => memcache_servers,
                 'cache_server_port' => memcache_server_port
             )
    end

    it 'should specify default custom theme for horizon' do
      if facts[:os_package_type] == 'debian'
          custom_theme_path = 'themes/vendor'
      else
          custom_theme_path = 'undef'
      end
    end

    it 'should declare horizon class with correct values' do
      if !facts.has_key?(:os_package_type) or facts[:os_package_type] == 'debian'
          cache_backend = 'horizon.backends.memcached.HorizonMemcached'
      else
          cache_backend = 'django.core.cache.backends.memcached.MemcachedCache'
      end

      should contain_class('horizon').with(
                 'cache_backend'       => cache_backend,
                 'cache_options'       => cache_options,
                 'log_handler'         => 'file',
                 'overview_days_range' => 1,
             )
    end

    context 'with Neutron DVR', :if => task.hiera_structure('neutron_advanced_configuration/neutron_dvr') do
      it 'should configure horizon for neutron DVR' do
        should contain_class('openstack::horizon').with(
                   'neutron_options' => {
                       'enable_distributed_router' => task.hiera_structure('neutron_advanced_configuration/neutron_dvr')
                   }
               )
      end
    end


    it 'should have explicit ordering between LB classes and particular actions' do
      expect(graph).to ensure_transitive_dependency("Class[openstack::horizon]", "Haproxy_backend_status[keystone-public]")
      expect(graph).to ensure_transitive_dependency("Class[openstack::horizon]", "Haproxy_backend_status[keystone-admin]")
    end


    it {
      should contain_service('httpd').with(
           'hasrestart' => true,
           'restart'    => 'sleep 30 && apachectl graceful || apachectl restart'
      )
    }

    it "should handle openstack-dashboard-apache package based on osfamily" do
      if facts[:osfamily] == 'Debian'
        should contain_package('openstack-dashboard-apache').with_ensure('absent')
      else
        should_not contain_package('openstack-dashboard-apache')
      end
    end
  end

  test_ubuntu_and_centos manifest
end

