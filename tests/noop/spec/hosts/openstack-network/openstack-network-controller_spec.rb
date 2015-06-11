require 'spec_helper'
require 'shared-examples'
manifest = 'openstack-network/openstack-network-controller.pp'

describe manifest do
  shared_examples 'catalog' do

    # TODO All this stuff should be moved to shared examples controller* tests.

    use_neutron = Noop.hiera 'use_neutron'
    ceilometer_enabled = Noop.hiera_structure 'ceilometer/enabled'

    # Network
    if use_neutron
      it 'should declare openstack::network with neutron enabled' do
        should contain_class('openstack::network').with(
          'neutron_server' => 'true',
        )
      end

      it 'should declare neutron::agents::ml2::ovs with neutron enabled' do
        should contain_class('neutron::agents::ml2::ovs').with(
          'manage_service' => 'true',
        )
      end

      neutron_config =  Noop.node_hash['quantum_settings']

      if neutron_config && neutron_config.has_key?('L2') && neutron_config['L2'].has_key?('tunnel_id_ranges')
        tunnel_types = ['gre']
        it 'should configure tunnel_types for neutron' do
           should contain_class('openstack::network').with(
             'tunnel_types' => tunnel_types,
           )
           should contain_class_neutron_agent_ovs('agent/tunnel_types').with(
             'value' => join(tunnel_types, ','),
           )
        end
      elsif neutron_config && neutron_config.has_key?('L2') && !neutron_config['L2'].has_key?('tunnel_id_ranges')
          it 'should declare openstack::network with tunnel_types set to []' do
            should contain_class('openstack::network').with(
              'tunnel_types' => [],
            )
          end
      end
    else
      it 'should declare openstack::network with neutron disabled' do
        should contain_class('openstack::network').with(
          'neutron_server' => 'false',
        )
      end
    end

    # Ceilometer
    if ceilometer_enabled and use_neutron
      it 'should configure notification_driver for neutron' do
        should contain_neutron_config('DEFAULT/notification_driver').with(
          'value' => 'messaging',
        )
      end
    end
  end # end of shared_examples

  test_ubuntu_and_centos manifest
end

