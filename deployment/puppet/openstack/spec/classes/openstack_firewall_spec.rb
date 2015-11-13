require 'spec_helper'

  describe 'openstack::firewall' do
    let(:params) { {:private_nets => ['10.20.0.0/24'],
                    :public_nets  => ['10.20.1.0/24'],
                    :storage_nets => ['10.20.2.0/24'],
                 } }
    let(:facts) { {:kernel => 'Linux'} }

    it 'should contain firewall rules for ssh' do
      should contain_firewall('020 ssh from 10.20.0.0/24')
      should contain_firewall('020 ssh from 10.20.2.0/24')
    end

    it 'should contain firewall rules for mysql' do
      should contain_firewall('101 mysql from 10.20.0.0/24')
    end

    it 'should contain firewall rules for mysql' do
      should contain_firewall('101 mysql from 10.20.0.0/24')
    end

    it 'should contain firewall rule from private nova services' do
      should contain_firewall('105 nova private - no ssl from 10.20.0.0/24')
    end

    it 'should contain firewall rules for rabbitmq' do
      should contain_firewall('106 rabbitmq from 10.20.0.0/24')
    end

    it 'should contain firewall rules for memcache' do
      should contain_firewall('107 memcache tcp from 10.20.0.0/24')
      should contain_firewall('107 memcache udp from 10.20.0.0/24')
    end

    it 'should contain firewall rules for rsync' do
      should contain_firewall('108 rsync from 10.20.0.0/24')
      should contain_firewall('108 rsync from 10.20.2.0/24')
    end

    it 'should contain firewall rules for iscsi' do
      should contain_firewall('109 iscsi from 10.20.2.0/24')
    end

    it 'should contain firewall rules for dns-server' do
      should contain_firewall('111 dns-server udp from 10.20.0.0/24')
      should contain_firewall('111 dns-server tcp from 10.20.0.0/24')
    end

    it 'should contain firewall rules for ntp-server' do
      should contain_firewall('112 ntp-server from 10.20.0.0/24')
    end

    it 'should contain firewall rules for corosync' do
      should contain_firewall('113 corosync-input from 10.20.0.0/24')
      should contain_firewall('114 corosync-output from 10.20.0.0/24')
      should contain_firewall('115 pcsd-server from 10.20.0.0/24')
    end

    it 'should contain firewall rules for ovs' do
      should contain_firewall('116 openvswitch db from 10.20.0.0/24')
    end

    it 'should contain firewall rules for nrpe' do
      should contain_firewall('117 nrpe-server from 10.20.0.0/24')
    end

    it 'should contain firewall rules for libvirt' do
      should contain_firewall('118 libvirt from 10.20.0.0/24')
      should contain_firewall('119 libvirt-migration from 10.20.0.0/24')
    end


end
