# @summary Creates a MaxScale listener configuration
#
# This defined type creates an individual configuration file for a MaxScale
# listener in the config.d directory. This enables the use of virtual resources,
# collected resources, and dynamic loops from external data sources.
#
# @param service
#   The name of the MaxScale service this listener is associated with.
#
# @param protocol
#   The protocol module to use (typically 'MariaDBClient').
#
# @param port
#   The TCP port to listen on.
#
# @param address
#   The address to bind to.
#
# @param socket
#   Path to a Unix domain socket (alternative to port).
#
# @param options
#   A hash of additional key/value pairs for the listener section.
#
# @param ensure
#   Whether the configuration file should be present or absent.
#
# @example TCP Listener
#   maxscale::config::listener { 'RW-Listener':
#     service  => 'RW-Service',
#     protocol => 'MariaDBClient',
#     port     => 4006,
#   }
#
# @example SSL Listener
#   maxscale::config::listener { 'SSL-Listener':
#     service  => 'RW-Service',
#     protocol => 'MariaDBClient',
#     port     => 4006,
#     options  => {
#       'ssl'      => true,
#       'ssl_cert' => '/etc/maxscale/ssl/server.crt',
#       'ssl_key'  => '/etc/maxscale/ssl/server.key',
#       'ssl_ca'   => '/etc/maxscale/ssl/ca.crt',
#     },
#   }
#
define maxscale::config::listener (
  String                            $service,
  String                            $protocol,
  Optional[Stdlib::Port]            $port    = undef,
  Optional[Stdlib::Host]            $address = undef,
  Optional[Stdlib::Absolutepath]    $socket  = undef,
  Hash                              $options = {},
  Enum['present','absent']          $ensure  = 'present',
) {
  include maxscale

  $_config_d_path = "${maxscale::config_dir}/${maxscale::config_d_dir}"

  # Build the parameters hash
  $_base = {
    'service'  => $service,
    'protocol' => $protocol,
  }
  $_with_port = $port ? {
    undef   => $_base,
    default => $_base + { 'port' => $port },
  }
  $_with_address = $address ? {
    undef   => $_with_port,
    default => $_with_port + { 'address' => $address },
  }
  $_with_socket = $socket ? {
    undef   => $_with_address,
    default => $_with_address + { 'socket' => $socket },
  }
  $_params = $_with_socket + $options

  file { "${_config_d_path}/listener_${name}.cnf":
    ensure  => $ensure,
    owner   => $maxscale::config_owner,
    group   => $maxscale::config_group,
    mode    => $maxscale::config_mode,
    content => epp('maxscale/component.cnf.epp', {
        'name'           => $name,
        'component_type' => 'listener',
        'params'         => $_params,
    }),
    notify  => Class['maxscale::service'],
  }
}
