# @summary Type for MaxScale listener definitions
#
# Defines the structure for a MaxScale listener configuration.
# 'service' and 'protocol' are required, plus either 'port' or 'socket'.
#
# @example TCP Listener
#   {
#     'service'  => 'Read-Write-Service',
#     'protocol' => 'MariaDBClient',
#     'port'     => 4006,
#     'address'  => '0.0.0.0',
#   }
#
# @example Unix Socket Listener
#   {
#     'service'  => 'Read-Write-Service',
#     'protocol' => 'MariaDBClient',
#     'socket'   => '/var/run/maxscale/rwsplit.sock',
#   }
#
# @example SSL Listener
#   {
#     'service'  => 'Read-Write-Service',
#     'protocol' => 'MariaDBClient',
#     'port'     => 4006,
#     'ssl'      => true,
#     'ssl_cert' => '/etc/maxscale/ssl/server.crt',
#     'ssl_key'  => '/etc/maxscale/ssl/server.key',
#     'ssl_ca'   => '/etc/maxscale/ssl/ca.crt',
#   }
#
type Maxscale::Listener = Struct[{
    service                               => String,
    protocol                              => String,
    Optional[port]                        => Stdlib::Port,
    Optional[address]                     => Stdlib::Host,
    Optional[socket]                      => Stdlib::Absolutepath,
    Optional[authenticator]               => String,
    Optional[authenticator_options]       => String,
    Optional[ssl]                         => Variant[Boolean, Enum['required']],
    Optional[ssl_cert]                    => Stdlib::Absolutepath,
    Optional[ssl_key]                     => Stdlib::Absolutepath,
    Optional[ssl_ca]                      => Stdlib::Absolutepath,
    Optional[ssl_version]                 => Enum['TLSv10', 'TLSv11', 'TLSv12', 'TLSv13', 'MAX'],
    Optional[ssl_cipher]                  => String,
    Optional[ssl_cert_verify_depth]       => Integer[0],
    Optional[ssl_verify_peer_certificate] => Boolean,
    Optional[ssl_verify_peer_host]        => Boolean,
    Optional[connection_init_sql_file]    => Stdlib::Absolutepath,
    Optional[proxy_protocol_networks]     => String,
    Optional[options]                     => Hash[String, Variant[String, Integer, Boolean]],
}]
