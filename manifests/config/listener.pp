# == Define: maxscale::config::listener
#
# @summary
#   Creates a listener section in the MaxScale configuration.
#
# @param service
#   The name of the MaxScale service this listener is associated with.
#
# @param protocol
#   The protocol module to use for this listener (for example, 'MariaDBClient').
#
# @param port
#   The TCP port number on which the listener will accept connections.
#
# @param socket
#   Optional Unix socket path for the listener.
#
# @param address
#   Optional IP address for the listener to bind to.
#
# @param ssl
#   Optional boolean to enable or disable SSL for the listener.
#
# @param ssl_key
#   Optional path to the SSL private key file.
#
# @param ssl_cert
#   Optional path to the SSL certificate file.
#
# @param ssl_ca_cert
#   Optional path to the SSL CA certificate file.
#
# @param ssl_version
#   Optional SSL/TLS protocol version to allow.
#
# @param ssl_cert_verification_depth
#   Optional verification depth for SSL certificate chain validation.
#
define maxscale::config::listener (
  String                         $service,
  String                         $protocol,
  Integer                        $port,
  Optional[String]               $socket                       = undef,
  Optional[String]               $address                      = undef,
  Optional[Boolean]              $ssl                          = undef,
  Optional[String]               $ssl_key                      = undef,
  Optional[String]               $ssl_cert                     = undef,
  Optional[String]               $ssl_ca_cert                  = undef,
  Optional[String]               $ssl_version                  = undef,
  Optional[Integer]              $ssl_cert_verification_depth  = undef,
) {

  concat::fragment { "Listener ${name}":
    target  => $maxscale::configfile,
    content => template('maxscale/listener.erb'),
    order   => '04',
  }
}
