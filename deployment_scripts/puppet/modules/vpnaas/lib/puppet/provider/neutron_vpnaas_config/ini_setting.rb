Puppet::Type.type(:neutron_vpnaas_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  # As neutron-vpn-agent inherits neutron-l3-agent, we modify the l3-agent's
  # configuration and restart it with VPNaaS support.
  def file_path
    '/etc/neutron/l3_agent.ini'
  end

end
