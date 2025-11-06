# @summary
#   creates a service in maxscale configuration
#   all parameters named like in the original maxscale documentation
#
# @param router
# @param user
# @param password
# @param router_options
# @param filters
# @param servers
# @param enable_root_user
# @param localhost_match_wildcard_host
# @param version_string
# @param auth_all_servers
# @param strip_db_esc
# @param log_auth_warnings
# @param max_slave_connections
# @param use_sql_variables_in
#
# @param weightby
#   This parameter no longer appear in the documentation, but is kept for backward compatibility
#
# @param optimize_wildcard
#   This parameter no longer appear in the documentation, but is kept for backward compatibility
#
# @param retry_on_failure
#   This parameter no longer appear in the documentation, but is kept for backward compatibility
#
# @param connection_timeout
#   This parameter no longer appear in the documentation, but is kept for backward compatibility
#
# @param max_slave_replication_lag
#   This parameter no longer appear in the documentation, but is kept for backward compatibility
#
# @see
#   https://mariadb.com/docs/maxscale/reference/maxscale-configuration-settings
#   https://mariadb.com/docs/maxscale/maxscale-management/deployment/maxscale-configuration-guide#service-1
#
define maxscale::config::service (
  Enum['readwritesplit','readconnroute']           $router,
  String                                           $user,
  Sensitive[String]                                $password,
  Array[Enum['master','slave','synced','running']] $router_options                = [],
  Array[String]                                    $filters                       = [],
  Array[String]                                    $servers                       = [],
  Optional[Boolean]                                $enable_root_user              = undef,
  Optional[Boolean]                                $localhost_match_wildcard_host = undef,
  Optional[String]                                 $version_string                = undef,
  Optional[Boolean]                                $auth_all_servers              = undef,
  Optional[Boolean]                                $strip_db_esc                  = undef,
  Optional[Boolean]                                $log_auth_warnings             = undef,
  Optional[Integer]                                $max_slave_connections         = undef,
  Optional[Enum['master','all']]                   $use_sql_variables_in          = undef,
  # Deprecated?
  Optional                                         $weightby                      = undef,
  Optional                                         $optimize_wildcard             = undef,
  Optional                                         $retry_on_failure              = undef,
  Optional                                         $connection_timeout            = undef,
  Optional                                         $max_slave_replication_lag     = undef,
) {
  if $router == undef {
    fail('The Router Type must be set!')
  }
  concat::fragment { "Service ${name}":
    target  => $maxscale::configfile,
    content => epp('maxscale/service.epp', {
        name                          => $name,
        router                        => $router,
        router_options                => $router_options,
        filters                       => $filters,
        servers                       => $servers,
        user                          => $user,
        password                      => $password,
        enable_root_user              => $enable_root_user,
        localhost_match_wildcard_host => $localhost_match_wildcard_host,
        version_string                => $version_string,
        auth_all_servers              => $auth_all_servers,
        strip_db_esc                  => $strip_db_esc,
        log_auth_warnings             => $log_auth_warnings,
        max_slave_connections         => $max_slave_connections,
        use_sql_variables_in          => $use_sql_variables_in,
        # Deprecated?
        weightby                      => $weightby,
        optimize_wildcard             => $optimize_wildcard,
        retry_on_failure              => $retry_on_failure,
        connection_timeout            => $connection_timeout,
        max_slave_replication_lag     => $max_slave_replication_lag,
    }),
    order   => '03',
  }
}
