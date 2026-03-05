# @summary Creates a MaxScale service (routing) configuration
#
# This defined type creates an individual configuration file for a MaxScale
# service in the config.d directory.
#
# @param router
#   The router module to use (e.g., 'readwritesplit', 'readconnroute').
#
# @param servers
#   Comma-separated list of server names for this service.
#
# @param user
#   The database user for service authentication.
#
# @param password
#   The password for the service user. Supports Puppet's Sensitive type.
#
# @param filters
#   Pipe-separated list of filter names (e.g., 'QueryLog|Throttle').
#
# @param options
#   A hash of additional key/value pairs for the service section.
#
# @param ensure
#   Whether the configuration file should be present or absent.
#
# @example Read-Write Split Service
#   maxscale::config::service { 'RW-Service':
#     router  => 'readwritesplit',
#     servers => 'db1,db2,db3',
#     user    => 'maxscale',
#     password => Sensitive('secret'),
#     options  => {
#       'max_slave_connections' => '100%',
#       'causal_reads'         => 'local',
#     },
#   }
#
define maxscale::config::service (
  String                                       $router,
  Optional[String]                             $servers  = undef,
  Optional[String]                             $user     = undef,
  Optional[Variant[String, Sensitive[String]]] $password = undef,
  Optional[String]                             $filters  = undef,
  Hash                                         $options  = {},
  Enum['present','absent']                     $ensure   = 'present',
) {
  include maxscale

  $_config_d_path = "${maxscale::config_dir}/${maxscale::config_d_dir}"

  # Build the parameters hash
  $_base = { 'router' => $router }
  $_with_servers = $servers ? {
    undef   => $_base,
    default => $_base + { 'servers' => $servers },
  }
  $_with_user = $user ? {
    undef   => $_with_servers,
    default => $_with_servers + { 'user' => $user },
  }
  $_with_password = $password ? {
    undef   => $_with_user,
    default => $_with_user + { 'password' => $password },
  }
  $_with_filters = $filters ? {
    undef   => $_with_password,
    default => $_with_password + { 'filters' => $filters },
  }
  $_params = $_with_filters + $options

  file { "${_config_d_path}/service_${name}.cnf":
    ensure  => $ensure,
    owner   => $maxscale::config_owner,
    group   => $maxscale::config_group,
    mode    => $maxscale::config_mode,
    content => epp('maxscale/component.cnf.epp', {
      'name'           => $name,
      'component_type' => 'service',
      'params'         => $_params,
    }),
    notify  => Class['maxscale::service'],
  }
}
