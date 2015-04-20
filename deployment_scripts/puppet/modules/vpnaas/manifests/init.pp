class vpnaas (
  $vpnaas_interface_driver            = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  $vpnaas_vpn_device_driver           = 'neutron.services.vpn.device_drivers.ipsec.OpenSwanDriver',
  $vpnaas_ipsec_status_check_interval = '30',
  $vpnaas_plugin                      = 'neutron.services.vpn.plugin.VPNDriverPlugin',
) {

  include vpnaas::params

  package { $vpnaas::params::libreswan_package:
    ensure => present,
  }

  service { $vpnaas::params::l3_agent_service:
    ensure => running,
    enable => true,
  }

  file { 'replace-neutron-l3-agent':
    path   => "/usr/bin/${vpnaas::params::l3_agent_service}",
    ensure => file,
    backup => '.bak',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => "/usr/bin/${vpnaas::params::vpn_agent_service}"
  }

  neutron_vpnaas_config {
    'DEFAULT/interface_driver':          value => $vpnaas_interface_driver;
    'vpnagent/vpn_device_driver':        value => $vpnaas_vpn_device_driver;
    'ipsec/ipsec_status_check_interval': value => $vpnaas_ipsec_status_check_interval;
  }

  package { $vpnaas::params::agent_package:
    ensure => present,
  }

  Package[$vpnaas::params::agent_package] ->
    Neutron_vpnaas_config<||> ->
      File['replace-neutron-l3-agent'] ~>
        Service[$vpnaas::params::l3_agent_service]

  service { $vpnaas::params::server_service:
    ensure => running,
    enable => true,
  }

  neutron_config { 'DEFAULT/service_plugins':
    value          => $vpnaas_plugin,
    append_to_list => true,
  }

  Neutron_config<||> ~> Service[$vpnaas::params::server_service]

  service { $vpnaas::params::dashboard_service:
    ensure => running,
    enable => true,
  }

  exec { 'enable_vpnaas_dashboard':
    command => "/bin/echo \"OPENSTACK_NEUTRON_NETWORK['enable_vpn'] = True\" >> $vpnaas::params::dashboard_settings",
    unless  => "/bin/egrep \"^OPENSTACK_NEUTRON_NETWORK['enable_vpn'] = True\" $vpnaas:params::dashboard_settings",
  }

  Exec['enable_vpnaas_dashboard'] ~> Service[$vpnaas::params::dashboard_service]

}
