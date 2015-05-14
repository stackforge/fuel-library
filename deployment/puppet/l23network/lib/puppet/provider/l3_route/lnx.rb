require 'ipaddr'
require 'yaml'
require 'puppetx/l23_utils'

Puppet::Type.type(:l3_route).provide(:lnx) do
  defaultfor :osfamily => :linux
  commands   :ip => 'ip'

  def ip_safe(*args)
    if @resource[:debug]
      debug (['ip'] + args).join ' '
      return
    end
    ip *args
  end

  def self.prefetch(resources)
    instances.each do |provider|
      resources.each do |name, resource|
        next unless resource[:destination] == provider.destination
        next unless resource[:metric] == provider.metric
        next unless resource[:gateway] == provider.gateway
        debug "Resource '#{name}' was prefetched as: #{provider.property_hash}"
        resource.provider = provider
      end
    end
  end

  def self.unpack_ip(ip)
    [ip].pack('H*').unpack('C4').reverse.join('.')
  end

  def self.unpack_mask(mask)
    [mask].pack('H*').unpack('B*').first.count('1')
  end

  # retreives the current routing table
  # return array of hashes - defined routes
  # cat /proc/net/route returns information about routing table in format:
  # Iface Destination Gateway   Flags RefCnt Use Metric Mask    MTU Window IRTT
  # eth0  00000000    0101010A  0003   0      0    0    00000000 0    0     0
  # eth0  0001010A    00000000  0001   0      0    0    00FFFFFF 0    0     0
  # @return [Array<Hash>]
  def self.routes
    routes = []

    routing_table = File.read '/proc/net/route'
    routing_table.split("\n").each do |line|
      next if line =~ %r(^[Ii]face.+)
      next if line =~ %r(^(\r\n|\n|\s*)$|^$)
      line = line.split

      interface = line[0]
      destination = line[1]
      gateway = line[2]
      metric = line[6]
      mask = line[7]

      # we don't care about link-local routes
      next if gateway == '00000000'

      # convert values
      gateway_ip = unpack_ip gateway
      destination_ip = unpack_ip destination
      destination_mask = unpack_mask mask
      destination_network = "#{destination_ip}/#{destination_mask}"

      route = {
          :destination    => destination_network,
          :gateway        => gateway_ip,
          :metric         => metric,
          :interface      => interface,
      }

      routes << route
    end

    routes.sort_by! do |route|
      route[:metric].to_i or 0
    end

    routes
  end

  def self.instances
    instances = []
    routes.each do |route|
      route[:ensure] = :present
      route[:name] = L23network.get_route_resource_name route[:destination], route[:metric]
      debug "Found route: #{route.inspect}"
      provider = self.new route
      instances << provider
    end
    return instances
  end

  def exists?
    debug 'Call: exists?'
    out = @property_hash[:ensure] == :present
    debug "Return: '#{out}'"
    out
  end

  def present?
    @resource[:ensure] == :presnet
  end

  def create
    debug 'Call: create'
    @property_hash = {}
    [:destination, :gateway, :metric, :vendor_specific].each do |property|
      @property_hash[property] = @resource[property]
    end
    @property_hash[:ensure] == :absent
    route_purge
    route_add
  end

  def destroy
    debug 'Call: destroy'
    route_delete
  end

  def route_purge
    begin
      cmd = ['--force', 'route', 'delete', @property_hash[:destination]]
      cmd += ['metric', @property_hash[:metric]]
      ip_safe cmd
    rescue
      false
    end
  end

  def route_delete
    begin
      cmd = ['--force', 'route', 'delete', @property_hash[:destination]]
      cmd += ['via', @property_hash[:gateway]]
      cmd += ['metric', @property_hash[:metric]]
      ip_safe cmd
    rescue
      false
    end
  end

  def route_add
    cmd = ['--force', 'route', 'add', @property_hash[:destination]]
    cmd += ['via', @property_hash[:gateway]]
    cmd += ['metric', @property_hash[:metric]]
    ip_safe cmd
  end

  def route_change
    cmd = ['--force', 'route', 'change', @property_hash[:destination]]
    cmd += ['via', @property_hash[:gateway]]
    cmd += ['metric', @property_hash[:metric]]
    ip_safe cmd
  end

  def flush
    debug 'Call: flush'
    route_change if exists? and present?
  end

  #####################################

  attr_reader :property_hash

  def destination
    @property_hash[:destination]
  end

  def destination=(value)
    @property_hash[:destination] = value
  end

  def gateway
    @property_hash[:gateway]
  end

  def gateway=(value)
    @property_hash[:gateway] = value
  end

  def metric
    @property_hash[:metric]
  end

  def metric=(value)
    @property_hash[:metric] = value
  end

  def interface
    @property_hash[:interface]
  end

  def interface=(value)
    @property_hash[:interface] = value
  end

  def vendor_specific
    @property_hash[:vendor_specific]
  end

  def vendor_specific=(value)
    @property_hash[:vendor_specific] = value
  end

end
# vim: set ts=2 sw=2 et :
