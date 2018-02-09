# == define: maxscale::config::server
#
# creates a server in maxscale configuration
#
# === Parameters
# all parameters named like in the original maxscale documentation
define maxscale::config::server(
  $address,
  $port = 3306,
  $protocol = 'MySQLBackend',
  $monitoruser = undef,
  $monitorpw = undef,
  $persistpoolmax = undef,
  $persistmaxtime = undef,
  $serv_weight = undef,
) {

  if $address == undef {
    fail('The Server address must be set to an IP oder FQDN!')
  }
  if $port == undef or !(is_integer($port)) {
    fail('Port must be an Integer and must be set!')
  }

  concat::fragment{ "Server ${name}":
    target  => lookup(maxscale::configfile),
    content => template('maxscale/server.erb'),
    order   => '10',
  }

}
