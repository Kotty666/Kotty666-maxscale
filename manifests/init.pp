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
# [*log_to_shm*]
#  Enable or disable the writing of the maxscale.log file to shared memory.
#  If enabled, then the actual log file will be created under /dev/shm and
#  a symbolic link to that file will be created in the MaxScale log directory.
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
  $package_name = $::maxscale::params::package_name,
  $repository_base_url = $::maxscale::params::repository_base_url,
  $package_version = $::maxscale::params::version,
  $setup_mariadb_repository = true,
  $service_enable        = true,
  $threads = $::maxscale::params::threads,
  $auth_connect_timeout = $::maxscale::params::auth_connect_timeout,
  $auth_read_timeout = $::maxscale::params::auth_read_timeout,
  $auth_write_timeout = $::maxscale::params::auth_write_timeout,
  $ms_timestamp = $::maxscale::params::ms_timestamp,
  $syslog = $::maxscale::params::syslog,
  $maxlog = $::maxscale::params::maxlog,
  $log_to_shm = $::maxscale::params::log_to_shm,
  $log_warning = $::maxscale::params::log_warning,
  $log_notice = $::maxscale::params::log_notice,
  $log_info = $::maxscale::params::log_info,
  $log_debug = $::maxscale::params::log_debug,
  $log_augmentation = $::maxscale::params::log_augmentation,
  $logdir = $::maxscale::params::logdir,
  $datadir = $::maxscale::params::datadir,
  $cachedir = $::maxscale::params::cachedir,
  $piddir = $::maxscale::params::piddir,
  $configdir = $::maxscale::params::configdir,
) inherits ::maxscale::params {

  validate_bool($service_enable)

  ::maxscale::install { $package_name :
    setup_mariadb_repository => $setup_mariadb_repository,
    repository_base_url      => $repository_base_url,
    package_version          => $package_version,
  }
  ::maxscale::config{$package_name:
    threads              => $threads,
    auth_connect_timeout => $auth_connect_timeout,
    auth_read_timeout    => $auth_read_timeout,
    auth_write_timeout   => $auth_write_timeout,
    ms_timestamp         => $ms_timestamp,
    syslog               => $syslog,
    maxlog               => $maxlog,
    log_to_shm           => $log_to_shm,
    log_warning          => $log_warning,
    log_notice           => $log_notice,
    log_info             => $log_info,
    log_debug            => $log_debug,
    log_augmentation     => $log_augmentation,
    logdir               => $logdir,
    datadir              => $datadir,
    cachedir             => $cachedir,
    piddir               => $piddir,
    configdir            => $configdir,
  }

  service { 'maxscale':
    ensure    => $service_enable,
    name      => $package_name,
    enable    => $service_enable,
    subscribe => Package[$package_name],
  }

  concat { $::maxscale::params::configfile:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['maxscale'],
    require => Package[$package_name],
  }

  concat::fragment { 'Config Header':
    target  => $::maxscale::params::configfile,
    content => "# This file is managed by Puppet. DO NOT EDIT.\n",
    order   => 01,
  }
}
