require 'spec_helper'

describe 'l23network::examples::run_network_scheme', :type => :class do
let(:network_scheme) do
<<eof
---
network_scheme:
  version: 1.1
  provider: lnx
  interfaces:
    eth2: {}
    eth3: {}
  transformations:
    - action: add-bond
      name: bond23
      interfaces:
        - eth2
        - eth3
      mtu: 4000
      bond_properties:
        mode: balance-rr
      interface_properties:
        mtu: 9000
        vendor_specific:
          disable_offloading: true
  emdpoints: {}
  roles: {}
eof
end

  context 'with bond (lnx) two interfaces' do
    let(:title) { 'empty network scheme' }
    let(:facts) {
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :kernel => 'Linux',
        :l23_os => 'ubuntu',
        :l3_fqdn_hostname => 'stupid_hostname',
      }
    }

    let(:params) do {
      :settings_yaml => network_scheme,
    } end

    let(:rings) do
      {
        'rings' => {
          'RX' => '4096',
          'TX' => '4096'
        }
      }
    end

    get_nic_maxrings = {}
    before(:each) do
      puppet_debug_override()
      Puppet::Parser::Functions.newfunction(:get_nic_maxrings, :type => :rvalue) {
        |args| get_nic_maxrings.call(args[0])
      }

      [2, 3].each { |i| get_nic_maxrings.stubs(:call).with("eth#{i}").returns(rings) }
    end

    it do
      should compile.with_all_deps
    end

    it do
      should contain_l2_bond('bond23').with({
        'ensure' => 'present',
        'slaves' => ['eth2', 'eth3'],
        'mtu'    => 4000,
      })
    end

    ['eth2', 'eth3'].each do |iface|
      it do
        should contain_l2_port(iface).with({
          'ensure'  => 'present',
          'mtu'     => 9000,
          'bond_master'  => 'bond23',
          'ethtool' =>  {
              'offload' => {
                'generic-receive-offload'      => false,
                'generic-segmentation-offload' => false
              }
            }
        })
        should contain_l23_stored_config(iface).with({
          'ensure'  => 'present',
          'mtu'     => 9000,
          'bond_master'  => 'bond23',
          'ethtool' =>  {
              'offload' => {
                'generic-receive-offload'      => false,
                'generic-segmentation-offload' => false
              }
            }.merge(rings)
        })
      end
    end

  end

end

describe 'l23network::examples::run_network_scheme', :type => :class do
let(:network_scheme) do
<<eof
---
network_scheme:
  version: 1.1
  provider: lnx
  interfaces:
    eth2: {}
    eth3: {}
  transformations:
    - action: add-bond
      name: bond23
      interfaces:
        - eth2
        - eth3
      bridge: some-bridge
      mtu: 4000
      bond_properties:
        mode: balance-rr
      interface_properties:
        mtu: 9000
        vendor_specific:
          disable_offloading: true
      provider: ovs
  emdpoints: {}
  roles: {}
eof
end

  context 'with bond (ovs) two interfaces' do
    let(:title) { 'empty network scheme' }
    let(:facts) {
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :kernel => 'Linux',
        :l23_os => 'ubuntu',
        :l3_fqdn_hostname => 'stupid_hostname',
      }
    }

    let(:params) do {
      :settings_yaml => network_scheme,
    } end

    let(:rings) do
      {
        'rings' => {
          'RX' => '4096',
          'TX' => '4096'
        }
      }
    end

    get_nic_maxrings = {}
    before(:each) do
      puppet_debug_override()
      Puppet::Parser::Functions.newfunction(:get_nic_maxrings, :type => :rvalue) {
        |args| get_nic_maxrings.call(args[0])
      }

      [2, 3].each { |i| get_nic_maxrings.stubs(:call).with("eth#{i}").returns(rings) }
    end

    it do
      should compile.with_all_deps
    end

    it do
      should contain_l2_bond('bond23').with({
        'ensure'   => 'present',
        'provider' => 'ovs',
        'slaves'   => ['eth2', 'eth3'],
        'mtu'      => 4000,
      })
    end

    ['eth2', 'eth3'].each do |iface|
      it do
        should contain_l2_port(iface).with({
          'ensure'      => 'present',
          'mtu'         => 9000,
          'bond_master' => nil,
          'ethtool' =>  {
              'offload' => {
                'generic-receive-offload'      => false,
                'generic-segmentation-offload' => false
              }
            }.merge(rings)
        })
        should contain_l23_stored_config(iface).with({
          'ensure'      => 'present',
          'mtu'         => 9000,
          'bond_master' => nil,
          'ethtool' =>  {
              'offload' => {
                'generic-receive-offload'      => false,
                'generic-segmentation-offload' => false
              }
            }.merge(rings)
        })
      end
    end

  end

end

###
