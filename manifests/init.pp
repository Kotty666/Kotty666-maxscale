# == Class: maxscale
#
# @summary
#   Installs and configures MariaDB MaxScale.
#
# @example
#   include maxscale
#
# @param package_name
#   Name of the MaxScale package to install.
#
# @param package_version
#   Specific version of the MaxScale package to install.
#
# @param setup_mariadb_repository
#   Whether to configure the official MariaDB repository for MaxScale.
#
# @param service_enable
#   Whether the MaxScale service should be enabled at boot.
#
# @param threads
#   Number of MaxScale worker threads. Can be an Integer or 'auto'.
#
# @param auth_connect_timeout
#   Connection timeout (in seconds) for backend MySQL connections.
#
# @param auth_read_timeout
#   Read timeout (in seconds) when fetching authentication data.
#
# @param auth_write_timeout
#   Write timeout (in seconds) when fetching authentication data.
#
# @param ms_timestamp
#   Enable (1) or disable (0) millisecond precision timestamps in logs.
#
# @param max_auth_errors_until_block
#   Number of authentication failures allowed before blocking a host.
#
# @param syslog
#   Enable or disable logging to syslog.
#
# @param maxlog
#   Enable or disable logging to the MaxScale log file.
#
# @param log_warning
#   Enable or disable logging of warning-level messages.
#
# @param log_notice
#   Enable or disable logging of notice-level messages.
#
# @param log_info
#   Enable or disable logging of info-level messages.
#
# @param log_debug
#   Enable or disable logging of debug-level messages.
#
# @param log_augmentation
#   Enable or disable log message augmentation.
#
# @param logdir
#   Directory where MaxScale log files are stored.
#
# @param datadir
#   Directory where MaxScale data files are stored.
#
# @param cachedir
#   Directory where MaxScale cached data is stored.
#
# @param piddir
#   Directory where the MaxScale PID file is stored.
#
# @param configdir
#   Directory containing MaxScale configuration files.
#
# @param configfile
#   Path to the main MaxScale configuration file.
#
# @param max_user
#   User account under which MaxScale runs.
#
# @param max_group
#   Group under which MaxScale runs.
#
# @param repository_base_url
#   Optional base URL for the MariaDB repository.
#
# @param monitor
#   Optional hash of monitor resources to create.
#
# @param server
#   Optional hash of server resources to create.
#
# @param service
#   Optional hash of service resources to create.
#
# @param listener
#   Optional hash of listener resources to create.
#
class maxscale (
  String                        $package_name,
  String                        $package_version,
  Boolean                       $setup_mariadb_repository,
  Boolean                       $service_enable,
  Variant[Integer, Enum['auto']] $threads,
  String                        $auth_connect_timeout,
  String                        $auth_read_timeout,
  String                        $auth_write_timeout,
  Integer                       $ms_timestamp,
  Integer                       $max_auth_errors_until_block,
  Boolean                       $syslog,
  Boolean                       $maxlog,
  Boolean                       $log_warning,
  Boolean                       $log_notice,
  Boolean                       $log_info,
  Boolean                       $log_debug,
  Boolean                       $log_augmentation,
  String                        $logdir,
  String                        $datadir,
  String                        $cachedir,
  String                        $piddir,
  String                        $configdir,
  String                        $configfile,
  String                        $max_user,
  String                        $max_group,
  Optional[String]              $repository_base_url = undef,
  Optional[Hash]                $monitor             = undef,
  Optional[Hash]                $server              = undef,
  Optional[Hash]                $service             = undef,
  Optional[Hash]                $listener            = undef,
) {

  class { 'maxscale::install':
    package_name             => $package_name,
    setup_mariadb_repository => $setup_mariadb_repository,
    repository_base_url      => $repository_base_url,
    package_version          => $package_version,
  }

  class { 'maxscale::config':
    threads                     => $threads,
    auth_connect_timeout        => $auth_connect_timeout,
    auth_read_timeout           => $auth_read_timeout,
    auth_write_timeout          => $auth_write_timeout,
    ms_timestamp                => $ms_timestamp,
    syslog                      => $syslog,
    maxlog                      => $maxlog,
    log_warning                 => $log_warning,
    log_notice                  => $log_notice,
    log_info                    => $log_info,
    log_debug                   => $log_debug,
    log_augmentation            => $log_augmentation,
    logdir                      => $logdir,
    datadir                     => $datadir,
    cachedir                    => $cachedir,
    piddir                      => $piddir,
    configdir                   => $configdir,
    configfile                  => $configfile,
    max_user                    => $max_user,
    max_group                   => $max_group,
    max_auth_errors_until_block => $max_auth_errors_until_block,
  }

  Class['maxscale::install']
    -> Class['maxscale::config']
    ~> Service['maxscale']

  service { 'maxscale':
    ensure    => $service_enable ? {
      true  => 'running',
      false => 'stopped',
    },
    name      => $package_name,
    enable    => $service_enable,
    subscribe => Package[$package_name],
  }

  create_resources(maxscale::config::monitor,  $monitor)
  create_resources(maxscale::config::server,   $server)
  create_resources(maxscale::config::service,  $service)
  create_resources(maxscale::config::listener, $listener)
}
