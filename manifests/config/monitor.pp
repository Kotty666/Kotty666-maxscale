# @summary Creates a MaxScale monitor configuration
#
# This defined type creates an individual configuration file for a MaxScale
# monitor in the config.d directory. This enables the use of virtual resources,
# collected resources, and dynamic loops from external data sources.
#
# @param module
#   The monitor module to use (e.g., 'mariadbmon', 'galeramon').
#
# @param servers
#   Comma-separated list of server names this monitor should watch.
#
# @param user
#   The database user for monitor connections.
#
# @param password
#   The password for the monitor user. Supports Puppet's Sensitive type.
#
# @param options
#   A hash of additional key/value pairs for the monitor section.
#
# @param ensure
#   Whether the configuration file should be present or absent.
#
# @example MariaDB Monitor with failover
#   maxscale::config::monitor { 'MariaDB-Monitor':
#     module  => 'mariadbmon',
#     servers => 'db1,db2,db3',
#     user    => 'maxscale_mon',
#     password => Sensitive('secret'),
#     options  => {
#       'monitor_interval' => '2000ms',
#       'auto_failover'    => true,
#       'auto_rejoin'      => true,
#     },
#   }
#
# @example Galera Monitor
#   maxscale::config::monitor { 'Galera-Monitor':
#     module  => 'galeramon',
#     servers => 'galera1,galera2,galera3',
#     user    => 'maxscale',
#     password => Sensitive('secret'),
#   }
#
define maxscale::config::monitor (
  String                                   $module,
  String                                   $servers,
  Optional[String]                         $user     = undef,
  Optional[Variant[String, Sensitive[String]]] $password = undef,
  Hash                                     $options  = {},
  Enum['present','absent']                 $ensure   = 'present',
) {
  include maxscale

  $_config_d_path = "${maxscale::config_dir}/${maxscale::config_d_dir}"

  # Build the parameters hash
  $_base = {
    'module'  => $module,
    'servers' => $servers,
  }
  $_with_user = $user ? {
    undef   => $_base,
    default => $_base + { 'user' => $user },
  }
  $_with_password = $password ? {
    undef   => $_with_user,
    default => $_with_user + { 'password' => $password },
  }
  $_params = $_with_password + $options

  file { "${_config_d_path}/monitor_${name}.cnf":
    ensure  => $ensure,
    owner   => $maxscale::config_owner,
    group   => $maxscale::config_group,
    mode    => $maxscale::config_mode,
    content => epp('maxscale/component.cnf.epp', {
        'name'           => $name,
        'component_type' => 'monitor',
        'params'         => $_params,
    }),
    notify  => Class['maxscale::service'],
  }
}
