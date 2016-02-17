require 'spec_helper'

describe Puppet::Parser::Functions.function(:prepare_cgroups_hash) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  subject do
    function_name = Puppet::Parser::Functions.function(:prepare_cgroups_hash)
    scope.method(function_name)
  end

  it 'should exist' do
    subject == Puppet::Parser::Functions.function(:prepare_cgroups_hash)
  end

  let :facts do
    { :memorysize_mb => 1024 }
  end

  context "transform simple hash" do
    let(:sample) {
      {
        'cinder' => {
          'label' => 'cinder',
          'type'  => 'text',
          'value' => '{"blkio":{"blkio.weight":500}}',
        },
        'keystone' => {
          'label' => 'keystone',
          'type'  =>  'text',
          'value' => '{"cpu":{"cpu.shares":70}}'
        }
      }
    }

    let(:result) {
      [
        {
          'cinder' => {
            'blkio' => {
              'blkio.weight' => 500
            }
          }
        },
        {
          'keystone' => {
            'cpu' => {
              'cpu.shares' => 70
            }
          }
        }
      ]
    }

    it 'should transform hash with simple values' do
      should run.with_params(sample).and_return(result)
    end

  end


  context "transform simple hash" do

    let(:sample) {
      {
        'neutron' => {
          'label' => 'neutron',
          'type'  =>  'text',
          'value' => '{"memory":{"memory.soft_limit_in_bytes":"%50, 300, 700"}}'
        }
      }
    }

    let(:result) {
      [
       {
         'neutron' => {
           'memory' => {
             'memory.soft_limit_in_bytes' => 512
           }
         }
       }
      ]
    }

    it 'should transform hash including expression to compute' do
      should run.with_params(sample).and_return(result)
    end

  end

end
