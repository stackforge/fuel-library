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
manifest = 'cluster/cluster.pp'

describe manifest do
  shared_examples 'catalog' do

    cluster_recheck_interval = Noop.hiera('cluster_recheck_interval', '190s')

    it { should contain_class('cluster').with({
      'cluster_recheck_interval' => cluster_recheck_interval,
      })
    }
    it { should contain_pcmk_nodes('pacemaker') }
    it { should contain_service('corosync').that_comes_before('Pcmk_nodes[pacemaker]') }
    it { should contain_service('corosync').with({
         'subscribe' => 'File[/etc/corosync/service.d]',
         'require'   => 'File[/etc/corosync/corosync.conf]',
         })
    }

    it do
      if (facts[:operatingsystem] == 'Ubuntu')
        should contain_file('/etc/corosync/uidgid.d/pacemaker').that_requires('File[/etc/corosync/corosync.conf]')
      elsif
        should_not contain_file('/etc/corosync/uidgid.d/pacemaker')
      end
    end

    it do
      if (facts[:operatingsystem] == 'Ubuntu')
        should contain_file('/etc/corosync/uidgid.d/pacemaker').that_comes_before('Service[corosync]')
      end
    end

  end
  test_ubuntu_and_centos manifest
end

