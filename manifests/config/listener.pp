#
# @summary
#   Creates a listener in maxscale configuration
#   all parameters named like in the original maxscale documentation
#
# @param service
# @param protocol
# @param address
# @param port
# @param socket
# @param ssl
# @param ssl_key
# @param ssl_cert
# @param ssl_ca
# @param ssl_version
# @param ssl_cert_verification_depth
#
# @param ssl_ca_cert
#   Deprecated since Mariadb MaxScale 22.08.  See ssl_ca
#
# @see
#   https://mariadb.com/docs/maxscale/reference/maxscale-configuration-settings
#   https://mariadb.com/docs/maxscale/maxscale-management/deployment/maxscale-configuration-guide#listener-1
#
define maxscale::config::listener (
  String                            $service,
  Optional[Enum['mariadb','nosql']] $protocol                    = undef,
  Optional[Stdlib::Ip::Address]     $address                     = undef,
  Optional[Stdlib::Port]            $port                        = undef,
  Optional[Stdlib::UnixPath]        $socket                      = undef,
  Optional[Boolean]                 $ssl                         = undef,
  Optional[Stdlib::UnixPath]        $ssl_key                     = undef,
  Optional[Stdlib::UnixPath]        $ssl_cert                    = undef,
  Optional[Stdlib::UnixPath]        $ssl_ca                      = undef,
  Array[Maxscale::TLS]              $ssl_version                 = [],
  Optional[Integer]                 $ssl_cert_verification_depth = undef,
  # Deprecated
  Optional[Stdlib::UnixPath]        $ssl_ca_cert                 = undef, # Deprecated since Mariadb MaxScale 22.08.  See ssl_ca
) {
  concat::fragment { "Listener ${name}":
    target  => $maxscale::configfile,
    content => epp('maxscale/listener.epp', {
        name                        => $name,
        service                     => $service,
        protocol                    => $protocol,
        address                     => $address,
        port                        => $port,
        socket                      => $socket,
        ssl                         => $socket,
        ssl_key                     => $ssl_key,
        ssl_cert                    => $ssl_cert,
        ssl_ca                      => $ssl_ca,
        ssl_version                 => $ssl_version,
        ssl_cert_verification_depth => $ssl_cert_verification_depth,
        # Deprecated
        ssl_ca_cert                 => $ssl_ca_cert,
    }),
    order   => 41,
  }
}
