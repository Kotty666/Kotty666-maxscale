# @summary Manages MariaDB MaxScale installation and configuration
#
# This module installs and configures MariaDB MaxScale with a flexible,
# hash-based configuration approach that supports all current and future
# MaxScale parameters without code changes.
#
# @param package_name
#   Name of the MaxScale package to install.
#
# @param package_version
#   Version of the MaxScale package. Use 'installed', 'latest', or a specific version.
#
# @param service_ensure
#   Whether the service should be running or stopped.
#
# @param service_enable
#   Whether the service should be enabled at boot.
#
# @param service_name
#   Name of the MaxScale service.
#
# @param manage_repo
#   Whether to manage the MariaDB repository for MaxScale.
#
# @param repo_version
#   MaxScale repository version (e.g., '24.02', '23.08').
#
# @param repo_base_url
#   Base URL for the MaxScale repository. If not set, defaults are used.
#
# @param config_dir
#   Directory for MaxScale configuration files.
#
# @param config_file
#   Name of the main configuration file.
#
# @param config_owner
#   Owner of the configuration files.
#
# @param config_group
#   Group of the configuration files.
#
# @param config_mode
#   File mode for the main configuration file.
#
# @param global_options
#   Hash of global [maxscale] section options. Supports any valid MaxScale parameter.
#
# @param servers
#   Hash of server definitions. Each server is a hash with address and optional parameters.
#
# @param monitors
#   Hash of monitor definitions.
#
# @param services
#   Hash of service definitions.
#
# @param listeners
#   Hash of listener definitions.
#
# @param filters
#   Hash of filter definitions.
#
# @param manage_dirs
#   Whether to manage MaxScale directories (log, data, cache, pid).
#
# @param log_dir
#   Directory for MaxScale log files.
#
# @param data_dir
#   Directory for MaxScale data files.
#
# @param cache_dir
#   Directory for MaxScale cache files.
#
# @param pid_dir
#   Directory for MaxScale PID files.
#
# @param maxscale_user
#   System user for MaxScale.
#
# @param maxscale_group
#   System group for MaxScale.
#
# @param gpg_key_id
#   GPG key ID for package verification.
#
# @param extra_config_files
#   Hash of additional configuration files to create in config_dir.
#
# @example Basic installation with defaults
#   include maxscale
#
# @example Full configuration with servers, monitor, service and listener
#   class { 'maxscale':
#     manage_repo    => true,
#     repo_version   => '24.02',
#     global_options => {
#       'threads'    => 'auto',
#       'log_info'   => true,
#     },
#     servers        => {
#       'db1' => {
#         'address' => '192.168.1.10',
#         'port'    => 3306,
#       },
#       'db2' => {
#         'address' => '192.168.1.11',
#         'port'    => 3306,
#       },
#     },
#     monitors       => {
#       'MariaDB-Monitor' => {
#         'module'             => 'mariadbmon',
#         'servers'            => 'db1,db2',
#         'user'               => 'maxscale',
#         'password'           => 'secret',
#         'monitor_interval'   => '2000ms',
#         'auto_failover'      => true,
#         'auto_rejoin'        => true,
#       },
#     },
#     services       => {
#       'Read-Write-Service' => {
#         'router'  => 'readwritesplit',
#         'servers' => 'db1,db2',
#         'user'    => 'maxscale',
#         'password'=> 'secret',
#       },
#     },
#     listeners      => {
#       'Read-Write-Listener' => {
#         'service'  => 'Read-Write-Service',
#         'protocol' => 'MariaDBClient',
#         'port'     => 4006,
#       },
#     },
#   }
#
class maxscale (
  # Package parameters
  String                        $package_name,
  String                        $package_version,

  # Service parameters
  Enum['running', 'stopped']    $service_ensure,
  Boolean                       $service_enable,
  String                        $service_name,

  # Repository parameters
  Boolean                       $manage_repo,
  String                        $repo_version,
  Optional[String]              $repo_base_url,
  String                        $gpg_key_id,

  # Configuration file parameters
  Stdlib::Absolutepath          $config_dir,
  String                        $config_file,
  String                        $config_owner,
  String                        $config_group,
  Stdlib::Filemode              $config_mode,

  # Global MaxScale options - flexible hash for any parameters
  Hash                          $global_options,

  # Component definitions - all hash-based for flexibility
  Hash[String, Maxscale::Server]   $servers,
  Hash[String, Maxscale::Monitor]  $monitors,
  Hash[String, Maxscale::Service]  $services,
  Hash[String, Maxscale::Listener] $listeners,
  Hash[String, Maxscale::Filter]   $filters,

  # Directory management
  Boolean                       $manage_dirs,
  Stdlib::Absolutepath          $log_dir,
  Stdlib::Absolutepath          $data_dir,
  Stdlib::Absolutepath          $cache_dir,
  Stdlib::Absolutepath          $pid_dir,

  # System user/group
  String                        $maxscale_user,
  String                        $maxscale_group,

  # Extra configuration files
  Hash[String, Hash]            $extra_config_files,
) {
  # Ensure proper class ordering
  include maxscale::user
  include maxscale::config
  include maxscale::install
  include maxscale::service

  Class['maxscale::user']
  -> Class['maxscale::config']
  ~> Class['maxscale::service']

  Class['maxscale::install']
  -> Class['maxscale::service']

  if $manage_repo {
    case $facts['os']['family'] {
      'Debian': {
        include maxscale::repo::apt
        Class['maxscale::repo::apt'] -> Class['maxscale::install']
      }
      'RedHat': {
        include maxscale::repo::yum
        Class['maxscale::repo::yum'] -> Class['maxscale::install']
      }
      default: {}
    }
  }
}
