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
  Optional[Stdlib::Port]       $port           = undef,
  Optional[String]             $monitoruser    = undef,
  Optional[Sensitive[String]]  $monitorpw      = undef,
  Optional[Integer]            $persistpoolmax = undef,
  Optional[Maxscale::Duration] $persistmaxtime = undef,
  # Deprecated?
  Optional[String]             $protocol       = undef,
  Optional                     $serv_weight    = undef,
) {
  concat::fragment { "Server ${name}":
    target  => $maxscale::configfile,
    content => epp('maxscale/server.epp', {
        name           => $name,
        address        => $address,
        monitoruser    => $monitoruser,
        monitorpw      => $monitorpw,
        persistpoolmax => $persistpoolmax,
        persistmaxtime => $persistmaxtime,
        # Deprecated?
        protocol       => $protocol,
        serv_weight    => $serv_weight,
    }),
    order   => 11,
  }
}
