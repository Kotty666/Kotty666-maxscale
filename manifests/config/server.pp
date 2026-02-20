# == define: maxscale::config::server
# @summary
# creates a server in maxscale configuration
#
# === Parameters
# @param address
# @param port
# @param protocol
# @param monitoruser
# @param monitorpw
# @param persistpoolmax
# @param persistmaxtime
# @param serv_weight
# all parameters named like in the original maxscale documentation
define maxscale::config::server (
  String $address,
  Integer $port = 3306,
  String $protocol = 'MySQLBackend',
  Optional $monitoruser = undef,
  Optional $monitorpw = undef,
  Optional $persistpoolmax = undef,
  Optional $persistmaxtime = undef,
  Optional $serv_weight = undef,
) {
  concat::fragment { "Server ${name}":
    target  => $maxscale::configfile,
    content => template('maxscale/server.erb'),
    order   => '10',
  }
}
