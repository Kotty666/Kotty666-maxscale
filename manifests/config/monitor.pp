# == define: maxscale::config::monitor
#
# creates a monitor in maxscale configuration
#
# === Parameters
# all parameters named like in the original maxscale documentation
# @param module
# @param  servers
# @param user
# @param password
# @param monitor_interval
# @param backend_connect_timeout
# @param backend_write_timeout
# @param backend_read_timeout
define maxscale::config::monitor (
  $module,
  $servers,
  $user = undef,
  $password = undef,
  $monitor_interval = undef,
  $backend_connect_timeout = undef,
  $backend_write_timeout = undef,
  $backend_read_timeout = undef,
) {
  if $module == undef {
    fail('Monitoring Module must be set!')
  }
  if $servers == undef {
    fail('At least one server must be set!')
  }

  concat::fragment { "Monitor ${name}":
    target  => $maxscale::configfile,
    content => template('maxscale/monitor.erb'),
    order   => '05',
  }
}
