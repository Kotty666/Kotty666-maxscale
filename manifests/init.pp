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
#  If enabled, then the actual log file will be created under /dev/shm and a symbolic link to that file will be created in the MaxScale log directory.
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
  $package_name = undef,
  $repository_base_url = undef,
  $setup_mariadb_repository = true,
  $service_enable        = true,
  $threads = undef,
  $auth_connect_timeout = undef,
  $auth_read_timeout = undef,
  $auth_write_timeout = undef,
  $ms_timestamp = undef,
  $syslog = undef,
  $maxlog = undef,
  $log_to_shm = undef,
  $log_warning = undef,
  $log_notice = undef,
  $log_info = undef,
  $log_debug = undef,
  $log_augmentation = undef,
  $logdir = undef,
  $datadir = undef,
  $cachedir = undef,
  $piddir = undef,
  $configdir = undef,
)  {

  include ::maxscale::params

  if $package_name == undef { $package_name = $::maxscale::params::package_name }
  if $repository_base_url == undef { $repository_base_url = $::maxscale::params::repository_base_url }
  if $threads == undef { $threads = $::maxscale::params::threads }
  if $auth_connect_timeout == undef { $auth_connect_timeout = $::maxscale::params::auth_connect_timeout }
  if $auth_read_timeout == undef { $auth_read_timeout = $::maxscale::params::auth_read_timeout }
  if $auth_write_timeout == undef { $auth_write_timeout = $::maxscale::params::auth_write_timeout }
  if $ms_timestamp == undef { $ms_timestamp = $::maxscale::params::ms_timestamp }
  if $syslog == undef { $syslog = $::maxscale::params::syslog }
  if $maxlog == undef { $maxlog = $::maxscale::params::maxlog }
  if $log_to_shm == undef { $log_to_shm = $::maxscale::params::log_to_shm }
  if $log_warning == undef { $log_warning = $::maxscale::params::log_warning }
  if $log_notice == undef { $log_notice = $::maxscale::params::log_notice }
  if $log_info == undef { $log_info = $::maxscale::params::log_info }
  if $log_debug == undef { $log_debug = $::maxscale::params::log_debug }
  if $log_augmentation == undef { $log_augmentation = $::maxscale::params::log_augmentation }
  if $logdir == undef { $logdir = $::maxscale::params::logdir }
  if $datadir == undef { $datadir = $::maxscale::params::datadir }
  if $cachedir == undef { $cachedir = $::maxscale::params::cachedir }
  if $piddir == undef { $piddir = $::maxscale::params::piddir }
  if $configdir == undef { $configdir = $::maxscale::params::configdir }

  validate_bool($service_enable)

  ::maxscale::install { $package_name :
    setup_mariadb_repository => $setup_mariadb_repository,
    repository_base_url      => $repository_base_url,
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
