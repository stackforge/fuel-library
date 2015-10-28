class { 'Settings':
  name => 'Settings',
}

class { 'main':
  name => 'main',
}

file { '/etc/hiera/globals.yaml':
  ensure  => 'present',
  content => '
--- 
  access_hash: 
    user: admin
    password: admin
    email: "admin@localhost"
    tenant: admin
    metadata: 
      weight: 10
      label: Access
  amqp_hosts: "192.168.0.3:5673"
  amqp_port: "5673"
  apache_ports: 
    - "80"
    - "8888"
    - "5000"
    - "35357"
  base_mac: "fa:16:3e:00:00:00"
  base_syslog_hash: 
    syslog_port: "514"
    syslog_server: "10.109.37.2"
  ceph_monitor_nodes: 
    node-1: &id001
      
      swift_zone: "1"
      uid: "1"
      fqdn: node-1.test.domain.local
      network_roles: 
        keystone/api: "192.168.0.3"
        neutron/api: "192.168.0.3"
        mgmt/database: "192.168.0.3"
        sahara/api: "192.168.0.3"
        heat/api: "192.168.0.3"
        ceilometer/api: "192.168.0.3"
        ex: "172.16.51.117"
        ceph/public: "192.168.0.3"
        mgmt/messaging: "192.168.0.3"
        management: "192.168.0.3"
        swift/api: "192.168.0.3"
        storage: "192.168.1.2"
        mgmt/corosync: "192.168.0.3"
        cinder/api: "192.168.0.3"
        public/vip: "172.16.51.117"
        swift/replication: "192.168.1.2"
        ceph/radosgw: "172.16.51.117"
        admin/pxe: "10.109.37.4"
        ironic/baremetal: "192.168.3.3"
        mongo/db: "192.168.0.3"
        neutron/private: 
        neutron/floating: 
        fw-admin: "10.109.37.4"
        glance/api: "192.168.0.3"
        mgmt/vip: "192.168.0.3"
        murano/api: "192.168.0.3"
        ironic/api: "192.168.0.3"
        nova/api: "192.168.0.3"
        horizon: "192.168.0.3"
        nova/migration: "192.168.0.3"
        mgmt/memcache: "192.168.0.3"
        cinder/iscsi: "192.168.1.2"
        ceph/replication: "192.168.1.2"
      user_node_name: "Untitled (cc:a5)"
      node_roles: &id002
        
        - primary-controller
      name: node-1
  ceph_primary_monitor_node: 
    node-1: *id001
  ceph_rgw_nodes: 
    node-1: *id001
  ceilometer_hash: 
    db_password: KEOghUJZJKLV5LdUnxjQqu1V
    user_password: duH6N8su3soEWT1UbHQEoVPi
    metering_secret: zPaQgIhyUYD1q0MWBf1UJgjb
    enabled: false
    event_time_to_live: "604800"
    metering_time_to_live: "604800"
    http_timeout: "600"
  ceilometer_nodes: 
    node-1: *id001
  cinder_hash: 
    db_password: x5fu0gJc3Y2RMfcT3J9E39hL
    user_password: HzHZy5whrrFCRjziVSE7oL7X
    fixed_key: "1d036355c174967c01ddc542cb65e57a6000cfa43a8588e9ae6e30b2ecbb71a9"
  cinder_nodes: 
    node-1: *id001
  cinder_rate_limits: 
    POST: "100000"
    POST_SERVERS: "100000"
    PUT: "100000"
    GET: "100000"
    DELETE: "100000"
  corosync_roles: 
    - primary-controller
    - controller
  custom_mysql_setup_class: galera
  database_nodes: 
    node-1: *id001
  debug: false
  default_gateway: 
    - "172.16.51.113"
  deployment_mode: ha_compact
  dns_nameservers: []
  glance_backend: file
  glance_hash: 
    image_cache_max_size: "10714349568"
    user_password: lDOkW0TlkoMY4CmPy8PiW80E
    db_password: nNVZnNgNLYYIolcKRcWb2c3J
  glance_known_stores: false
  heat_hash: 
    db_password: qugZa4RJl8iT0K7060f1buWM
    user_password: CxKs9UObDHZOgw20Gv3kwtGT
    enabled: true
    auth_encryption_key: ce489de3a39996b694db7c8d4804a93d
    rabbit_password: hN4hSVxhTei1ViFOfS5sbPv8
  heat_roles: 
    - primary-controller
    - controller
  horizon_nodes: 
    node-1: *id001
  node_name: node-1
  idle_timeout: "3600"
  keystone_hash: 
    service_token_off: false
    db_password: xl0tg0dvg80jNMGvBfb83YSn
    admin_token: fEba1VO69rCHVWjM61sZ4Q5x
  manage_volumes: false
  management_network_range: "192.168.0.0/24"
  master_ip: "10.109.37.2"
  max_overflow: 20
  max_pool_size: 20
  max_retries: "-1"
  mirror_type: external
  mountpoints: 
    - "1"
    - "2"
  mongo_roles: 
    - primary-mongo
    - mongo
  multi_host: true
  murano_hash: 
    db_password: K8EARFe83CmiuTgiVftdoX0B
    user_password: mLMZMBvmZyvdv6J1CKA1TuLM
    enabled: false
    rabbit_password: "8h3k5Uf3U7uT39Fr2wggpXOH"
  murano_roles: 
    - primary-controller
    - controller
  mysql_hash: 
    root_password: POvhJ6iQOcf9d4TCsul2ZRQI
    wsrep_password: XV0HBh9vJSqHOp8782RZRBgU
  network_config: 
  network_manager: 
  network_scheme: 
    transformations: 
      - action: add-br
        name: br-baremetal
      - action: add-br
        name: br-fw-admin
      - action: add-br
        name: br-mgmt
      - action: add-br
        name: br-storage
      - action: add-br
        name: br-ex
      - action: add-br
        name: br-floating
        provider: ovs
      - action: add-patch
        bridges: 
          - br-floating
          - br-ex
        provider: ovs
        mtu: 65000
      - action: add-br
        name: br-prv
        provider: ovs
      - action: add-patch
        bridges: 
          - br-prv
          - br-fw-admin
        provider: ovs
        mtu: 65000
      - action: add-port
        bridge: br-fw-admin
        name: eth0
      - action: add-port
        bridge: br-mgmt
        name: eth0.101
      - action: add-port
        bridge: br-storage
        name: eth0.102
      - action: add-port
        bridge: br-ex
        name: eth1
      - action: add-port
        bridge: br-baremetal
        name: eth5
      - action: add-br
        name: br-ironic
        provider: ovs
      - action: add-patch
        bridges: 
          - br-ironic
          - br-baremetal
        provider: ovs
    roles: 
      murano/api: br-mgmt
      keystone/api: br-mgmt
      neutron/api: br-mgmt
      mgmt/database: br-mgmt
      sahara/api: br-mgmt
      ceilometer/api: br-mgmt
      ex: br-ex
      ceph/public: br-mgmt
      mgmt/messaging: br-mgmt
      management: br-mgmt
      swift/api: br-mgmt
      storage: br-storage
      mgmt/corosync: br-mgmt
      cinder/api: br-mgmt
      public/vip: br-ex
      swift/replication: br-storage
      ceph/radosgw: br-ex
      admin/pxe: br-fw-admin
      ironic/baremetal: br-baremetal
      mongo/db: br-mgmt
      neutron/private: br-prv
      neutron/floating: br-floating
      fw-admin: br-fw-admin
      glance/api: br-mgmt
      mgmt/vip: br-mgmt
      heat/api: br-mgmt
      cinder/iscsi: br-storage
      nova/api: br-mgmt
      horizon: br-mgmt
      nova/migration: br-mgmt
      mgmt/memcache: br-mgmt
      ironic/api: br-mgmt
      ceph/replication: br-storage
    interfaces: 
      eth5: 
        vendor_specific: 
          driver: e1000
          bus_info: "0000:00:08.0"
      eth4: 
        vendor_specific: 
          driver: e1000
          bus_info: "0000:00:07.0"
      eth3: 
        vendor_specific: 
          driver: e1000
          bus_info: "0000:00:06.0"
      eth2: 
        vendor_specific: 
          driver: e1000
          bus_info: "0000:00:05.0"
      eth1: 
        vendor_specific: 
          driver: e1000
          bus_info: "0000:00:04.0"
      eth0: 
        vendor_specific: 
          driver: e1000
          bus_info: "0000:00:03.0"
    version: "1.1"
    provider: lnx
    endpoints: 
      br-fw-admin: 
        IP: 
          - "10.109.37.4/24"
      br-baremetal: 
        IP: 
          - "192.168.3.3/24"
      br-prv: 
        IP: none
      br-floating: 
        IP: none
      br-storage: 
        IP: 
          - "192.168.1.2/24"
      br-mgmt: 
        IP: 
          - "192.168.0.3/24"
      br-ex: 
        IP: 
          - "172.16.51.117/28"
        gateway: "172.16.51.113"
  network_size: 
  neutron_config: 
    database: 
      passwd: R7CwXDC1rgSbz6z0oL38xb4S
    keystone: 
      admin_password: XzCvbGgI0KfqgoHYGXPTkTgY
    L3: 
      use_namespaces: true
    L2: 
      phys_nets: 
        physnet2: 
          bridge: br-prv
          vlan_range: "1000:1030"
        physnet-ironic: 
          bridge: br-ironic
          vlan_range: 
      base_mac: "fa:16:3e:00:00:00"
      segmentation_type: vlan
    predefined_networks: 
      net04_ext: 
        shared: false
        L2: 
          network_type: local
          router_ext: true
          physnet: 
          segment_id: 
        L3: 
          nameservers: []
          subnet: "172.16.51.112/28"
          floating: "172.16.51.121:172.16.51.126"
          gateway: "172.16.51.113"
          enable_dhcp: false
        tenant: admin
      net04: 
        shared: false
        L2: 
          network_type: vlan
          router_ext: false
          physnet: physnet2
          segment_id: 
        L3: 
          nameservers: 
            - "8.8.4.4"
            - "8.8.8.8"
          subnet: "192.168.111.0/24"
          floating: 
          gateway: "192.168.111.1"
          enable_dhcp: true
        tenant: admin
      baremetal: 
        shared: true
        L2: 
          network_type: flat
          router_ext: false
          physnet: physnet-ironic
          segment_id: 
        L3: 
          nameservers: 
            - "8.8.4.4"
            - "8.8.8.8"
          subnet: "192.168.3.0/24"
          floating: "192.168.3.52:192.168.3.254"
          gateway: "192.168.3.51"
          enable_dhcp: true
        tenant: admin
    metadata: 
      metadata_proxy_shared_secret: IFcIv8CuNbllNccJs2bvcrkH
  neutron_db_password: R7CwXDC1rgSbz6z0oL38xb4S
  neutron_metadata_proxy_secret: IFcIv8CuNbllNccJs2bvcrkH
  neutron_nodes: 
    node-1: *id001
  neutron_user_password: XzCvbGgI0KfqgoHYGXPTkTgY
  node: *id001
  nodes_hash: 
    - user_node_name: "Untitled (cc:a5)"
      uid: "1"
      public_address: "172.16.51.117"
      internal_netmask: "255.255.255.0"
      fqdn: node-1.test.domain.local
      role: primary-controller
      public_netmask: "255.255.255.240"
      internal_address: "192.168.0.3"
      storage_address: "192.168.1.2"
      swift_zone: "1"
      storage_netmask: "255.255.255.0"
      name: node-1
    - user_node_name: "Untitled (6c:19)"
      uid: "2"
      internal_netmask: "255.255.255.0"
      fqdn: node-2.test.domain.local
      role: ironic
      internal_address: "192.168.0.4"
      storage_address: "192.168.1.1"
      swift_zone: "2"
      storage_netmask: "255.255.255.0"
      name: node-2
  nova_db_password: HyPHllrMCyYPLDhhT93Cs7TJ
  nova_hash: 
    db_password: HyPHllrMCyYPLDhhT93Cs7TJ
    user_password: jxcyBid9g7iEWreQdmQzsJ8I
    state_path: /var/lib/nova
    vncproxy_protocol: https
  nova_rate_limits: 
    POST: "100000"
    POST_SERVERS: "100000"
    PUT: "1000"
    GET: "100000"
    DELETE: "100000"
  nova_report_interval: "60"
  nova_service_down_time: "180"
  novanetwork_params: {}
  num_networks: 
  openstack_version: "2015.1.0-8.0"
  primary_controller: true
  private_int: 
  queue_provider: rabbitmq
  rabbit_ha_queues: true
  rabbit_hash: 
    password: OLCrvt99FgutnBs63PeFJchF
    user: nova
  node_role: primary-controller
  roles: *id002
  sahara_hash: 
    db_password: kjIx6v8OeeZxQUENkwB1mcHG
    user_password: "1Zhv0E5kprZOcoh0JFlIv4vf"
    enabled: false
  sahara_roles: 
    - primary-controller
    - controller
  sql_connection: "mysql://nova:HyPHllrMCyYPLDhhT93Cs7TJ@192.168.0.2/nova?read_timeout = 6 0"
  storage_hash: 
    iser: false
    volumes_ceph: false
    per_pool_pg_nums: 
      compute: 128
      default_pg_num: 128
      volumes: 128
      images: 128
      backups: 128
      ".rgw": 128
    objects_ceph: false
    ephemeral_ceph: false
    volumes_lvm: true
    images_vcenter: false
    osd_pool_size: "2"
    pg_num: 128
    images_ceph: false
    metadata: 
      weight: 60
      label: Storage
  swift_hash: 
    user_password: Dik6hafM81P9KQrqWtOXTnTp
  syslog_hash: 
    syslog_port: "514"
    syslog_transport: tcp
    syslog_server: ""
    metadata: 
      enabled: false
      toggleable: true
      weight: 50
      label: Syslog
  syslog_log_facility_ceilometer: LOG_LOCAL0
  syslog_log_facility_ceph: LOG_LOCAL0
  syslog_log_facility_cinder: LOG_LOCAL3
  syslog_log_facility_glance: LOG_LOCAL2
  syslog_log_facility_heat: LOG_LOCAL0
  syslog_log_facility_keystone: LOG_LOCAL7
  syslog_log_facility_murano: LOG_LOCAL0
  syslog_log_facility_neutron: LOG_LOCAL4
  syslog_log_facility_nova: LOG_LOCAL6
  syslog_log_facility_sahara: LOG_LOCAL0
  use_ceilometer: false
  use_monit: false
  use_neutron: true
  use_syslog: true
  vcenter_hash: {}
  verbose: true
  vlan_start: 
  management_vip: "192.168.0.2"
  database_vip: "192.168.0.2"
  service_endpoint: "192.168.0.2"
  public_vip: "172.16.51.116"
  management_vrouter_vip: "192.168.0.1"
  public_vrouter_vip: "172.16.51.115"
  memcache_roles: 
    - primary-controller
    - controller
  swift_master_role: primary-controller
  swift_nodes: 
    node-1: *id001
  swift_proxies: 
    node-1: *id001
  swift_proxy_caches: 
    node-1: *id001
  is_primary_swift_proxy: true
  nova_api_nodes: 
    node-1: *id001
',
  group   => 'root',
  mode    => '0644',
  owner   => 'root',
  path    => '/etc/hiera/globals.yaml',
}

stage { 'main':
  name => 'main',
}

