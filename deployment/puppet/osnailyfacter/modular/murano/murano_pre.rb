require File.join File.dirname(__FILE__), '../test_common.rb'

class MuranoPreTest < Test::Unit::TestCase

  # def test_mysql_accessible_for_murano
  #   TestCommon::MySQL.pass = TestCommon::Settings.murano['db_password']
  #   TestCommon::MySQL.user = 'murano'
  #   TestCommon::MySQL.host = TestCommon::Settings.management_vip
  #   TestCommon::MySQL.port = 3306
  #   TestCommon::MySQL.db = 'murano'
  #   assert TestCommon::MySQL.connection?, 'Cannot connect to MySQL with Glance auth!'
  # end
  
  def test_amqp_accessible
    assert TestCommon::AMQP.connection?, 'Cannot connect to AMQP server!'
  end

  def test_haproxy_murano_backend_present
    assert TestCommon::HAProxy.backend_present?('murano'), 'No murano haproxy backend!'
  end

  def test_horizon_haproxy_backend_online
    assert TestCommon::HAProxy.backend_up?('horizon'), 'Horizon HAProxy backend is not up!'
  end

end
