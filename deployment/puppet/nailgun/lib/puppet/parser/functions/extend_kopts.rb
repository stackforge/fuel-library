module MultipleKopts
  def self.string_to_hash(string)
    hash, option_order = {}, []
    string.to_s().split(' ').each() do |e|
      key, value = e.split("=", 2).map { |i| i.strip()}
      if hash.has_key?(key)
        hash[key] = "#{hash[key]} #{value}"
      else
        hash[key] = value
      end
      option_order << key
    end
    [hash, option_order]
  end

  def self.hash_to_string(hash, keys)
    string = ""
    keys.each() do |key|
      value = hash[key]
      if value.nil?
        string << " #{key}"
      else
        value.split(' ').each() do |e|
           string << " #{key}=#{e}"
        end
      end
    end
    string
  end

end

module Puppet::Parser::Functions
  newfunction(:extend_kopts, :type => :rvalue, :doc => <<-EOS
    This function changes "kopts" parameter if user modified it
    and return the string. It takes two arguments: string from
    metadata.yaml from "extend_kopts" option and default string
    in format "key1=value1 key2=value2 key3".
    For example:

    $metadata = loadyaml('path/to/metadata.yaml')
    extend_kopts($metadata['extend_kopts'], 'key1=a key2=b")

    Function compare two strings, make changes into default option
    and return it.

    So, if in the /path/to/metadata.yaml in the "extend_kopts" will be
    "key3=c key4 key1=not_a", we will get in the output:
    "key2=b key3=c key4 key1=not_a".
  EOS
  ) do |args|
    require 'set'

    unless args.length == 2
      raise Puppet::ParseError, ("extend_kopts(): wrong number of arguments - #{args.length}, must be 2")
    end

    hash_new_kopts, new_kopts_keys = MultipleKopts.string_to_hash(args[0])
    hash_default_kopts, default_kopts_keys = MultipleKopts.string_to_hash(args[1])

    keys = Set.new(new_kopts_keys + default_kopts_keys)

    return MultipleKopts.hash_to_string(hash_default_kopts.merge(hash_new_kopts), keys)
  end
end
