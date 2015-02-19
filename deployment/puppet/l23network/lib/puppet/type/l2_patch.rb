Puppet::Type.newtype(:l2_patch) do
    @doc = "Manage a patchcords between two bridges"
    desc @doc

    ensurable

    newparam(:name) # workarround for following error:
    # Error 400 on SERVER: Could not render to pson: undefined method `merge' for []:Array
    # http://projects.puppetlabs.com/issues/5220

    newproperty(:bridges, :array_matching => :all) do
      desc "Array of bridges that will be connected"
      newvalues(/^[a-z][0-9a-z\-\_]*[0-9a-z]$/)
    end

    newproperty(:jacks, :array_matching => :all) do
      desc "Patchcord jacks. Read-only. for debug purpose."
    end

    newproperty(:cross) do
      desc "Cross-system patch. Read-only. for debug purpose."
    end

    newproperty(:vlan_ids, :array_matching => :all) do
      desc "Array of 802.1q tag for ends."
      #
      validate do |val|
        if !val.is_a?(Array) or val.size() != 2
          fail("Must be an array of two integers")
        end
        for i in val
          if !i.is_a?(Integer) or (i < 0 or i > 4094)
            fail("Wrong 802.1q tag. Tag must be an integer in 2..4094 interval")
          end
        end
      end
    end

    newproperty(:trunks, :array_matching => :all) do
      defaultto([])
      desc "Array of trunks id, for configure patch's ends as ports in trunk mode"
      #
      validate do |val|
        val = Array(val)  # prevents puppet conversion array of one Int to Int
        for i in val
          if !i.is_a?(Integer) or (i < 0 or i > 4094)
            fail("Wrong 802.1q tag. Tag must be an integer in 2..4094 interval")
          end
        end
      end
      munge do |val|
        Array(val)
      end
    end

    newproperty(:mtu) do
      desc "The Maximum Transmission Unit size to use for the interface"
      newvalues(/^\d+$/, :absent, :none, :undef, :nil)
      aliasvalue(:none,  :absent)
      aliasvalue(:undef, :absent)
      aliasvalue(:nil,   :absent)
      defaultto :absent   # MTU value should be undefined by default, because some network resources (bridges, subinterfaces)
      validate do |value| #     inherits it from a parent interface
        # Intel 82598 & 82599 chips support MTUs up to 16110; is there any
        # hardware in the wild that supports larger frames?
        #
        # It appears loopback devices routinely have large MTU values; Eg. 65536
        #
        # Frames small than 64bytes are discarded as runts.  Smallest valid MTU
        # is 42 with a 802.1q header and 46 without.
        min_mtu = 42
        max_mtu = 65536
        if ! (value.to_s == 'absent' or (min_mtu .. max_mtu).include?(value.to_i))
          raise ArgumentError, "'#{value}' is not a valid mtu (must be a positive integer in range (#{min_mtu} .. #{max_mtu})"
        end
      end
      munge do |val|
        if val == :absent
          :absent
        else
          begin
            val.to_i
          rescue
            :absent
          end
        end
      end
    end

    newproperty(:vendor_specific) do
      desc "Hash of vendor specific properties"
      #defaultto {}  # no default value should be!!!
      # provider-specific properties, can be validating only by provider.
      validate do |val|
        if ! val.is_a? Hash
          fail("Vendor_specific should be a hash!")
        end
      end

      munge do |value|
        L23network.reccursive_sanitize_hash(value)
      end

      def should_to_s(value)
        "\n#{value.to_yaml}\n"
      end

      def is_to_s(value)
        "\n#{value.to_yaml}\n"
      end

      def insync?(value)
        should_to_s(value) == should_to_s(should)
      end
    end

    autorequire(:l2_bridge) do
      self[:bridges]
    end
end
# vim: set ts=2 sw=2 et :