# @summary Manages MariaDB MaxScale installation and configuration
#
# This module installs and configures MariaDB MaxScale with a flexible,
# hash-based configuration approach that supports all current and future
# MaxScale parameters without code changes.
#
# Configuration can be provided in two ways:
# 1. **Hash-based** (via the main class parameters) - all components are
#    defined in the main config file
# 2. **Defined types** (via `maxscale::config::server` etc.) - each component
#    gets its own file in `config.d/`, enabling virtual resources, collected
#    resources and dynamic loops from external data sources
#
# Both approaches can be combined: hash-based config goes into the main
# `maxscale.cnf`, while defined types create individual files in
# `maxscale.cnf.d/`.
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
# @param config_d_dir
#   Directory for additional per-component configuration files.
#   Used by the defined types (maxscale::config::server, etc.).
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
#   Hash of server definitions for the main config file.
#
# @param monitors
#   Hash of monitor definitions for the main config file.
#
# @param services
#   Hash of service definitions for the main config file.
#
# @param listeners
#   Hash of listener definitions for the main config file.
#
# @param filters
#   Hash of filter definitions for the main config file.
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
# @param manage_user
#   Whether to manage the maxscale system user and group.
#   Set to false if the package creates them or they are managed elsewhere.
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
# @example Full configuration via hashes (main config file)
#   class { 'maxscale':
#     manage_repo    => true,
#     repo_version   => '24.02',
#     global_options => {
#       'threads' => 'auto',
#       'log_info' => true,
#     },
#     servers => {
#       'db1' => { 'address' => '192.168.1.10', 'port' => 3306 },
#       'db2' => { 'address' => '192.168.1.11', 'port' => 3306 },
#     },
#     monitors => {
#       'MariaDB-Monitor' => {
#         'module'  => 'mariadbmon',
#         'servers' => 'db1,db2',
#         'user'    => 'maxscale',
#         'password' => Sensitive('secret'),
#       },
#     },
#   }
#
# @example Using defined types for dynamic server lists
#   include maxscale
#
#   # From a loop, virtual resource, or collected resource:
#   maxscale::config::server { 'db1':
#     address => '192.168.1.10',
#     port    => 3306,
#   }
#
#   # Or via virtual resources:
#   @maxscale::config::server { 'db2':
#     address => '192.168.1.11',
#   }
#   realize(Maxscale::Config::Server['db2'])
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
  String                        $config_d_dir,
  String                        $config_owner,
  String                        $config_group,
  Stdlib::Filemode              $config_mode,

  # Global MaxScale options - flexible hash for any parameters
  Hash                          $global_options,

  # Component definitions - open Hash for maximum flexibility
  # All key/value pairs are passed through to the config file as-is.
  Hash[String, Hash]            $servers,
  Hash[String, Hash]            $monitors,
  Hash[String, Hash]            $services,
  Hash[String, Hash]            $listeners,
  Hash[String, Hash]            $filters,

  # Directory management
  Boolean                       $manage_dirs,
  Stdlib::Absolutepath          $log_dir,
  Stdlib::Absolutepath          $data_dir,
  Stdlib::Absolutepath          $cache_dir,
  Stdlib::Absolutepath          $pid_dir,

  # System user/group
  Boolean                       $manage_user,
  String                        $maxscale_user,
  String                        $maxscale_group,

  # Extra configuration files
  Hash[String, Hash]            $extra_config_files,
) {
  # Ensure proper class ordering:
  # 1. Repo (if managed) -> Install -> Config -> Service
  # 2. User (if managed) -> Config

  contain maxscale::install
  contain maxscale::config
  contain maxscale::service

  Class['maxscale::install']
  -> Class['maxscale::config']
  ~> Class['maxscale::service']

  if $manage_user {
    contain maxscale::user
    Class['maxscale::user'] -> Class['maxscale::config']
  }

  if $manage_repo {
    case $facts['os']['family'] {
      'Debian': {
        contain maxscale::repo::apt
        Class['maxscale::repo::apt'] -> Class['maxscale::install']
      }
      'RedHat': {
        contain maxscale::repo::yum
        Class['maxscale::repo::yum'] -> Class['maxscale::install']
      }
      default: {
        fail("Unsupported OS family: ${facts['os']['family']}")
      }
    }
  }
}
