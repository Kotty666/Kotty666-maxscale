# @summary Creates a MaxScale server configuration
#
# This defined type creates an individual configuration file for a MaxScale
# server in the config.d directory. This enables the use of virtual resources,
# collected resources, and dynamic loops from external data sources.
#
# All parameters (except `address`) are optional and passed through to the
# configuration file as-is, ensuring forward compatibility with any MaxScale
# version.
#
# @param address
#   The hostname or IP address of the database server.
#
# @param port
#   The port number of the database server.
#
# @param options
#   A hash of additional key/value pairs to include in the server section.
#   This is the primary mechanism for forward compatibility — any parameter
#   MaxScale supports can be passed here without updating the module.
#
# @param ensure
#   Whether the configuration file should be present or absent.
#
# @example Basic server
#   maxscale::config::server { 'db1':
#     address => '192.168.1.10',
#   }
#
# @example Server with all options
#   maxscale::config::server { 'db-master':
#     address => '192.168.1.10',
#     port    => 3306,
#     options => {
#       'ssl'             => true,
#       'ssl_cert'        => '/etc/maxscale/ssl/client-cert.pem',
#       'ssl_key'         => '/etc/maxscale/ssl/client-key.pem',
#       'ssl_ca'          => '/etc/maxscale/ssl/ca-cert.pem',
#       'priority'        => 1,
#       'proxy_protocol'  => true,
#     },
#   }
#
# @example Virtual resource (define elsewhere, realize where needed)
#   @maxscale::config::server { 'db2':
#     address => '192.168.1.11',
#     port    => 3306,
#   }
#
# @example Loop from external data
#   $db_servers.each |$name, $config| {
#     maxscale::config::server { $name:
#       address => $config['address'],
#       port    => $config['port'],
#       options => $config['options'],
#     }
#   }
#
define maxscale::config::server (
  Stdlib::Host           $address,
  Optional[Stdlib::Port] $port    = undef,
  Hash                   $options = {},
  Enum['present','absent'] $ensure = 'present',
) {
  include maxscale

  $_config_d_path = "${maxscale::config_dir}/${maxscale::config_d_dir}"

  # Build the parameters hash
  $_base = { 'address' => $address }
  $_with_port = $port ? {
    undef   => $_base,
    default => $_base + { 'port' => $port },
  }
  $_params = $_with_port + $options

  file { "${_config_d_path}/server_${name}.cnf":
    ensure  => $ensure,
    owner   => $maxscale::config_owner,
    group   => $maxscale::config_group,
    mode    => $maxscale::config_mode,
    content => epp('maxscale/component.cnf.epp', {
      'name'           => $name,
      'component_type' => 'server',
      'params'         => $_params,
    }),
    notify  => Class['maxscale::service'],
  }
}
