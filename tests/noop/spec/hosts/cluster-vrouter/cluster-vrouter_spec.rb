require 'spec_helper'
require 'shared-examples'
manifest = 'cluster-vrouter/cluster-vrouter.pp'

# HIERA: neut_vlan.ceph.controller-ephemeral-ceph
# FACTS: ubuntu centos6

describe manifest do

  shared_examples 'catalog' do
    let(:endpoints) do
      task.hiera_hash('network_scheme', {}).fetch('endpoints', {})
    end

    it "should delcare cluster::vrouter_ocf with correct other_networks" do
      expect(subject).to contain_class('cluster::vrouter_ocf').with(
        'other_networks' => task.puppet_function('direct_networks', endpoints),
      )
    end

  end

  test_ubuntu_and_centos manifest
end

