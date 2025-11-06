# == define: maxscale::config::monitor
#
# @summary
#   creates a monitor in maxscale configuration
#   all parameters named like in the original maxscale documentation
#
# @param module
# @param user
# @param password
# @param servers
# @param monitor_interval
# @param backend_connect_timeout
# @param backend_write_timeout
# @param backend_read_timeout
#
# @see
#   https://mariadb.com/docs/maxscale/reference/maxscale-configuration-settings
#   https://mariadb.com/docs/maxscale/maxscale-management/deployment/maxscale-configuration-guide#monitor-1
#
define maxscale::config::monitor (
  Enum['mariadbmon','galeramon']                          $module,
  String                                                  $user,
  Sensitive[String]                                       $password,
  Array[Stdlib::Host]                                     $servers,
  Optional[Maxscale::Duration]                            $monitor_interval             = undef,
  Optional[Maxscale::Duration]                            $backend_connect_timeout      = undef,
  Optional[Maxscale::Duration]                            $backend_write_timeout        = undef,
  Optional[Maxscale::Duration]                            $backend_read_timeout         = undef,
) {
  concat::fragment { "Monitor ${name}":
    target  => $maxscale::configfile,
    content => epp('maxscale/monitor.epp', {
        name                         => $name,
        module                       => $module,
        user                         => $user,
        password                     => $password,
        servers                      => $servers,
        monitor_interval             => $monitor_interval,
        backend_connect_timeout      => $backend_connect_timeout,
        backend_write_timeout        => $backend_write_timeout,
        backend_read_timeout         => $backend_read_timeout,
        auto_failover                => $auto_failover,
        auto_rejoin                  => $auto_rejoin,
        enforce_simple_topology      => $enforce_simple_topology,
        replication_user             => $replication_user,
        replication_password         => $replication_password,
        cooperative_monitoring_locks => $cooperative_monitoring_locks,
    }),
    order   => 21,
  }
}
