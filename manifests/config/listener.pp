# == define: maxscale::config::listener
#
# creates a listener in maxscale configuration
#
# === Parameters
# all parameters named like in the original maxscale documentation
define maxscale::config::listener (
  String $service,
  String $protocol,
  Integer $port,
  $socket = undef,
  $address = undef,
  $ssl = undef,
  $ssl_key = undef,
  $ssl_cert = undef,
  $ssl_ca_cert = undef,
  $ssl_version = undef,
  $ssl_cert_verification_depth = undef,
) {

  concat::fragment{ "Listener ${name}":
    target  => $maxscale::configfile,
    content => template('maxscale/listener.erb'),
    order   => '04',
  }


}
