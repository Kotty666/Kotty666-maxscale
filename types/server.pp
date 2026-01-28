# @summary Type for MaxScale server definitions
#
# Defines the structure for a MaxScale server configuration.
# Only 'address' is required, all other parameters are optional
# and will be passed through to the configuration file as-is.
#
# @example Minimal server definition
#   { 'address' => '192.168.1.10' }
#
# @example Full server definition
#   {
#     'address'         => '192.168.1.10',
#     'port'            => 3306,
#     'protocol'        => 'MariaDBBackend',
#     'ssl'             => true,
#     'ssl_cert'        => '/path/to/cert.pem',
#     'ssl_key'         => '/path/to/key.pem',
#     'ssl_ca'          => '/path/to/ca.pem',
#     'priority'        => 1,
#     'extra_port'      => 3307,
#     'proxy_protocol'  => true,
#   }
#
type Maxscale::Server = Struct[{
  address                    => Stdlib::Host,
  Optional[port]             => Stdlib::Port,
  Optional[protocol]         => String,
  Optional[authenticator]    => String,
  Optional[ssl]              => Variant[Boolean, Enum['required']],
  Optional[ssl_cert]         => Stdlib::Absolutepath,
  Optional[ssl_key]          => Stdlib::Absolutepath,
  Optional[ssl_ca]           => Stdlib::Absolutepath,
  Optional[ssl_version]      => Enum['TLSv10', 'TLSv11', 'TLSv12', 'TLSv13', 'MAX'],
  Optional[ssl_cert_verify_depth] => Integer[0],
  Optional[ssl_verify_peer_certificate] => Boolean,
  Optional[ssl_verify_peer_host] => Boolean,
  Optional[priority]         => Integer[0],
  Optional[extra_port]       => Stdlib::Port,
  Optional[proxy_protocol]   => Boolean,
  Optional[disk_space_threshold] => String,
  Optional[rank]             => Enum['primary', 'secondary'],
  # Allow any additional parameters for future compatibility
  Optional[options]          => Hash[String, Variant[String, Integer, Boolean]],
}]
