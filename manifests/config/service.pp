# == define: maxscale::config::service
#
# creates a service in maxscale configuration
#
# === Parameters
# all parameters named like in the original maxscale documentation
define maxscale::config::service (
  $router,
  $servers = undef,
  $router_options = undef,
  $filters = undef,
  $user = undef,
  $passwd = undef,
  $enable_root_user = 0,
  $localhost_match_wildcard_host = 1,
  $version_string='MaxScale',
  $weightby = undef,
  $auth_all_servers = 1,
  $strip_db_esc = 1,
  $optimize_wildcard = 1,
  $retry_on_failure = 1,
  $log_auth_warnings = 0,
  $connection_timeout = undef,
  $max_slave_connections = undef,
  $max_slave_replication_lag = undef,
  $use_sql_variables_in = undef,
) {
  if $router == undef {
    fail('The Router Type must be set!')
  }
  concat::fragment{ "Service ${name}":
    target  => "$maxscale::configpath/$maxscale::configfile",
    content => template('maxscale/service.erb'),
    order   => '03',
  }

}
