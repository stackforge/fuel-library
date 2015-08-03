require 'puppetx/l23_utils'
#
module Puppet::Parser::Functions
  newfunction(:get_pair_of_jack_names, :type => :rvalue) do |arguments|
    if !arguments[0].is_a? Array or arguments.size < 2 or arguments[0].size != 2
      raise(Puppet::ParseError, "get_pair_of_jack_names(): Wrong arguments given. " +
        "Should be array of two bridge names.")
    end

    bridges = arguments[0]
    provider_name = arguments[1]
    # name shouldn't depend from bridge order
    L23network.get_pair_of_jack_names(bridges, provider_name)
  end
end
# vim: set ts=2 sw=2 et :