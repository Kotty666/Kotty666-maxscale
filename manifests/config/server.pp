# == define: maxscale::config::server
#
# creates a server in maxscale configuration
#
# === Parameters
# all parameters named like in the original maxscale documentation
define maxscale::config::server(
  String $address,
  Integer $port = 3306,
  String $protocol = 'MySQLBackend',
  $monitoruser = undef,
  $monitorpw = undef,
  $persistpoolmax = undef,
  $persistmaxtime = undef,
  $serv_weight = undef,
) {

  concat::fragment{ "Server ${name}":
    target  => $maxscale::configfile,
    content => template('maxscale/server.erb'),
    order   => '10',
  }

}
