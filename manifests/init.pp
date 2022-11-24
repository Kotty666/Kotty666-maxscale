# == Class: maxscale
#
# Install MariaDB MaxScale.
#
# === Parameters
#
# [*maxscale_package_name*]
#  Override the name of the maxscale package
#
# [*setup_mariadb_repository*]
#  Setup the apt repositories from MariaDB for MaxScale.
#
# [*repository_base_url*]
#  Overrides the default repositorie.
#
# [*service_enable*]
#  Manages if the service should be enabled
#
# [*threads*]
#  Manages the number of maxscale threads
#
# [*auth_connect_timeout*]
#  The connection timeout in seconds for the MySQL connections to the backend server
#
# [*auth_read_timeout*]
#  The read timeout in seconds for the MySQL connection to the backend database when user authentication data is fetched.
#
# [*auth_write_timeout*]
#  The write timeout in seconds for the MySQL connection to the backend database when user authentication data is fetched.
#
# [*ms_timestamp*]
#  Enable or disable the high precision timestamps in logfiles.
#  Enabling this adds millisecond precision to all logfile timestamps.
#
# [*syslog*]
#  Enable or disable the logging of messages to syslog.
#
# [*maxlog*]
#  Enable or disable the logging of messages to MaxScale's log file.
#
# [*log_warning*]
#  Enable or disable the logging of messages whose syslog priority is warning.
#
# [*log_notice*]
#  Enable or disable the logging of messages whose syslog priority is notice.
#
# [*log_info*]
#  Enable or disable the logging of messages whose syslog priority is info.
#
# [*log_debug*]
#  Enable or disable the logging of messages whose syslog priority is debug.
#
# [*log_augmentation*]
#  Enable or disable the augmentation of messages.
#
# [*logdir*]
#  Set the directory where the logfiles are stored.
#
# [*datadir*]
#  Set the directory where the data files used by MaxScale are stored.
#
# [*cachedir*]
#  Configure the directory MaxScale uses to store cached data.
#
# [*piddir*]
#  Configure the directory for the PID file for MaxScale.
#
# [*configdir*]
#  Configure the directory for the configuration file for MaxScale.
#
# === Authors
#
# Philipp Frik <kotty@guns-n-girls.de>
class maxscale (
  String                        $package_name,
  String                        $package_version,
  Boolean                       $setup_mariadb_repository,
  Boolean                       $service_enable,
  Variant[Integer,Enum['auto']] $threads,
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
  Optional[String]              $repository_base_url,
  Optional[Hash]                $monitor,
  Optional[Hash]                $server,
  Optional[Hash]                $service,
  Optional[Hash]                $listener,
) {

  class { '::maxscale::install':
    package_name             => $package_name,
    setup_mariadb_repository => $setup_mariadb_repository,
    repository_base_url      => $repository_base_url,
    package_version          => $package_version,
  }
  class { '::maxscale::config':
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

  # make sure maxscale user is available before writing config files
  Class['::maxscale::install'] -> Class['::maxscale::config'] ~> Service['maxscale']

  service { 'maxscale':
    ensure    => $service_enable,
    name      => $package_name,
    enable    => $service_enable,
    subscribe => Package[$package_name],
  }

  create_resources(maxscale::config::monitor, $monitor)
  create_resources(maxscale::config::server, $server)
  create_resources(maxscale::config::service, $service)
  create_resources(maxscale::config::listener, $listener)

}
