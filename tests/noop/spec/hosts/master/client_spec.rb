require 'spec_helper'
require 'shared-examples'
manifest = 'master/client.pp'

# HIERA: master
# FACTS: master_centos7

describe manifest do
  run_test manifest
end
