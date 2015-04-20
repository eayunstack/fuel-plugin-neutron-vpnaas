class vpnaas::params {

  if ($::osfamily == 'RedHat') {
    $server_service = 'neutron-server'

    $vpn_agent_service = 'neutron-vpn-agent'
    $l3_agent_service  = 'neutron-l3-agent'

    $dashboard_service  = 'httpd'
    $dashboard_settings = '/etc/openstack-dashboard/local_settings'

    $agent_package     = 'openstack-neutron-vpn-agent'
    $libreswan_package = 'libreswan'
  } else {
    fail("Unsopported osfamily ${::osfamily}")
  }

}
