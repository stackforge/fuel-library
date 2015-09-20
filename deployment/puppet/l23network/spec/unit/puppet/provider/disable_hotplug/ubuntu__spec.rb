require 'spec_helper'

provider_class = Puppet::Type.type(:disable_hotplug).provider(:ubuntu)

describe provider_class do
  let(:name) { 'global' }

  let(:resource) do
    Puppet::Type.type(:disable_hotplug).new(
      :name        => name,
      :ensure      => 'present',
    )
  end

  let(:provider) do
    provider = provider_class.new
    provider.resource = resource
    provider
  end

  before(:each) do
    puppet_debug_override()
  end

  it 'Disable hotplug' do
    File.stubs(:exist?).with('/etc/udev/rules.d/99-disable-network-interface-hotplug.rules').returns(false)
    provider.class.stubs(:udevadm).with('control', '--stop-exec-queue').returns(0)
    File.stubs(:open).with('/etc/udev/rules.d/99-disable-network-interface-hotplug.rules', 'w').returns(0)
    provider.create
  end

  it 'File open error' do
    File.stubs(:exist?).with('/etc/udev/rules.d/99-disable-network-interface-hotplug.rules').returns(false)
    provider.class.stubs(:udevadm).with('control', '--stop-exec-queue').returns(0)
    File.stubs(:open).with('/etc/udev/rules.d/99-disable-network-interface-hotplug.rules', 'w').raises(Puppet::ExecutionFailure,'')
    expect{provider.create}.to raise_error(Puppet::ExecutionFailure)
  end

  it 'Udevadm error' do
    File.stubs(:exist?).with('/etc/udev/rules.d/99-disable-network-interface-hotplug.rules').returns(false)
    provider.class.stubs(:udevadm).with('control', '--stop-exec-queue').raises(Puppet::ExecutionFailure,'')
    expect{provider.create}.to raise_error(Puppet::ExecutionFailure)
  end

  it 'Do nothing' do
    File.stubs(:exist?).with('/etc/udev/rules.d/99-disable-network-interface-hotplug.rules').returns(true)
    provider.class.expects(:udevadm).with('control', '--stop-exec-queue').never
  end

end

# vim: set ts=2 sw=2 et
