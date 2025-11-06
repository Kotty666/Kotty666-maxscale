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
# @param auto_failover
# @param auto_rejoin
# @param enforce_simple_topology
# @param replication_user
# @param replication_password
# @param cooperative_monitoring_locks
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
  Optional[Variant[Boolean,Enum['safe']]]                 $auto_failover                = undef,
  Optional[Boolean]                                       $auto_rejoin                  = undef,
  Optional[Boolean]                                       $enforce_simple_topology      = undef,
  Optional[String]                                        $replication_user             = undef,
  Optional[Sensitive[String]]                             $replication_password         = undef,
  Optional[Enum['majority_of_all','majority_of_running']] $cooperative_monitoring_locks = undef,
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
