# == Define: maxscale::config::service
#
# @summary
#   Creates a service section in the MaxScale configuration.
#
# @example
#   maxscale::config::service { 'rw-service':
#     router  => 'readwritesplit',
#     servers => 'server1,server2',
#   }
#
# @param router
#   Router module used by this service (for example, 'readwritesplit').
#
# @param servers
#   Comma-separated list of backend server names.
#
# @param router_options
#   Optional router-specific options.
#
# @param filters
#   Optional comma-separated list of filters applied to this service.
#
# @param user
#   Optional username used for authentication.
#
# @param password
#   Optional password used for authentication.
#
# @param enable_root_user
#   Enable (1) or disable (0) usage of the root user.
#
# @param localhost_match_wildcard_host
#   Enable (1) or disable (0) matching localhost to wildcard hosts.
#
# @param version_string
#   Version string reported by the service.
#
# @param weightby
#   Optional weighting parameter for backend selection.
#
# @param auth_all_servers
#   Enable (1) or disable (0) authentication against all servers.
#
# @param strip_db_esc
#   Enable (1) or disable (0) stripping database escape characters.
#
# @param optimize_wildcard
#   Enable (1) or disable (0) wildcard optimization.
#
# @param retry_on_failure
#   Enable (1) or disable (0) retry on backend failure.
#
# @param log_auth_warnings
#   Enable (1) or disable (0) authentication warning logging.
#
# @param connection_timeout
#   Optional connection timeout in seconds.
#
# @param max_slave_connections
#   Optional maximum number of slave connections.
#
# @param max_slave_replication_lag
#   Optional maximum allowed slave replication lag.
#
# @param use_sql_variables_in
#   Optional SQL variable handling mode.
#
define maxscale::config::service (
  String            $router,
  Optional[String]  $servers                       = undef,
  Optional[String]  $router_options                = undef,
  Optional[String]  $filters                       = undef,
  Optional[String]  $user                          = undef,
  Optional[String]  $password                      = undef,
  Integer           $enable_root_user              = 0,
  Integer           $localhost_match_wildcard_host = 1,
  String            $version_string                = 'MaxScale',
  Optional[String]  $weightby                      = undef,
  Integer           $auth_all_servers              = 1,
  Integer           $strip_db_esc                  = 1,
  Integer           $optimize_wildcard             = 1,
  Integer           $retry_on_failure              = 1,
  Integer           $log_auth_warnings             = 0,
  Optional[Integer] $connection_timeout            = undef,
  Optional[Integer] $max_slave_connections         = undef,
  Optional[Integer] $max_slave_replication_lag     = undef,
  Optional[String]  $use_sql_variables_in          = undef,
) {
  concat::fragment { "service_${name}":
    target  => $maxscale::configfile,
    content => template('maxscale/service.erb'),
    order   => '03',
  }
}
