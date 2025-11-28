#
# @summary
#   creates a server in maxscale configuration
#   all parameters named like in the original maxscale documentation
#
# @param address
# @param port
# @param monitoruser
# @param monitorpw
# @param persistpoolmax
# @param persistmaxtime
# @param proxy_protocol
# @param rank
# @param ssl
# @param ssl_verify_peer_certificate
#
# @param protocol
#   This parameter no longer appear in the documentation, but is kept for backward compatibility
#
# @param serv_weight
#   This parameter no longer appear in the documentation, but is kept for backward compatibility
#
#
# @see
#   https://mariadb.com/docs/maxscale/reference/maxscale-configuration-settings
#   https://mariadb.com/docs/maxscale/maxscale-management/deployment/maxscale-configuration-guide#server-1
#
define maxscale::config::server (
  Stdlib::Host                 $address,
  Optional[Stdlib::Port]       $port                        = undef,
  Optional[String]             $monitoruser                 = undef,
  Optional[Sensitive[String]]  $monitorpw                   = undef,
  Optional[Integer]            $persistpoolmax              = undef,
  Optional[Maxscale::Duration] $persistmaxtime              = undef,
  Optional[Boolean]            $proxy_protocol              = undef,
  Optional[Maxscale::Rank]     $rank                        = undef,
  Optional[Boolean]            $ssl                         = undef,
  Optional[Boolean]            $ssl_verify_peer_certificate = undef,
  # Deprecated?
  Optional[String]             $protocol                    = undef,
  Optional                     $serv_weight                 = undef,
) {
  concat::fragment { "Server ${name}":
    target  => $maxscale::configfile,
    content => epp('maxscale/server.epp', {
        name                        => $name,
        address                     => $address,
        monitoruser                 => $monitoruser,
        monitorpw                   => $monitorpw,
        persistpoolmax              => $persistpoolmax,
        persistmaxtime              => $persistmaxtime,
        proxy_protocol              => $proxy_protocol,
        rank                        => $rank,
        ssl                         => $ssl,
        ssl_verify_peer_certificate => $ssl_verify_peer_certificate,
        # Deprecated?
        protocol                    => $protocol,
        serv_weight                 => $serv_weight,
    }),
    order   => 11,
  }
}
