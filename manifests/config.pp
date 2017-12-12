# == class: maxscale::config
#
# configures maxscale, per default in /etc/maxscale.cnf.
#
# === Parameters
# all Parameters are copied from the default maxscale.cnf.
# they are set per default in ::maxscale::params
class maxscale::config(
  $threads,
  $auth_connect_timeout,
  $auth_read_timeout,
  $auth_write_timeout,
  $ms_timestamp,
  $syslog,
  $maxlog,
  $log_to_shm,
  $log_warning,
  $log_notice,
  $log_info,
  $log_debug,
  $log_augmentation,
  $logdir,
  $datadir,
  $cachedir,
  $piddir,
  $configdir,
)  {
  require ::maxscale::params

  if $threads == undef {
    $real_threads = $maxscale::params::threads
  } else {
    $real_threads = $threads
  }

  if $auth_connect_timeout == undef {
    $real_auth_connect_timeout = $maxscale::params::auth_connect_timeout
  } else {
    $real_auth_connect_timeout = $auth_connect_timeout
  }

  if $auth_read_timeout == undef {
    $real_auth_read_timeout = $maxscale::params::auth_read_timeout
  } else {
    $real_auth_read_timeout = $auth_read_timeout
  }

  if $auth_write_timeout == undef {
    $real_auth_write_timeout = $maxscale::params::auth_write_timeout
  } else {
    $real_auth_write_timeout = $auth_write_timeout
  }

  if $ms_timestamp == undef {
    $real_ms_timestamp = $maxscale::params::ms_timestamp
  } else {
    $real_ms_timestamp = $ms_timestamp
  }

  if $syslog == undef {
    $real_syslog = $maxscale::params::syslog
  } else {
    $real_syslog = $syslog
  }

  if $maxlog == undef {
    $real_maxlog = $maxscale::params::maxlog
  } else {
    $real_maxlog = $maxlog
  }

  if $log_to_shm == undef {
    $real_log_to_shm = $maxscale::params::log_to_shm
  } else {
    $real_log_to_shm = $log_to_shm
  }

  if $log_warning == undef {
    $real_log_warning = $maxscale::params::log_warning
  } else {
    $real_log_warning = $log_warning
  }

  if $log_notice == undef {
    $real_log_notice = $maxscale::params::log_notice
  } else {
    $real_log_notice = $log_notice
  }

  if $log_info == undef {
    $real_log_info = $maxscale::params::log_info
  } else {
    $real_log_info = $log_info
  }

  if $log_debug == undef {
    $real_log_debug = $maxscale::params::log_debug
  } else {
    $real_log_debug = $log_debug
  }

  if $log_augmentation == undef {
    $real_log_augmentation = $maxscale::params::log_augmentation
  } else {
    $real_log_augmentation = $log_augmentation
  }

  if $logdir == undef {
    $real_logdir = $::maxscale::params::logdir
  } else {
    $real_logdir = $logdir
  }

  if $datadir == undef {
    $real_datadir = $maxscale::params::datadir
  } else {
    $real_datadir = $datadir
  }

  if $cachedir == undef {
    $real_cachedir = $maxscale::params::cachedir
  } else {
    $real_cachedir = $cachedir
  }

  if $piddir == undef {
    $real_piddir = $maxscale::params::piddir
  } else {
    $real_piddir = $piddir
  }

  if $configdir == undef {
    $real_configdir = $maxscale::params::configdir
  } else {
    $real_configdir = $configdir
  }

  file {[$real_logdir,$real_datadir,$real_cachedir,$real_piddir]:
    ensure => 'directory',
    owner  => $maxscale::params::user,
    group  => $maxscale::params::group,
  }

  concat { $::maxscale::params::configfile:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['maxscale'],
  }
  concat::fragment { 'Config Header':
    target  => $::maxscale::params::configfile,
    content => "# This file is managed by Puppet. DO NOT EDIT.\n",
    order   => '01',
  }
  concat::fragment{ 'GlobalSettings':
    target  => $::maxscale::params::configfile,
    content => template('maxscale/global_settings.erb'),
    order   => '02',
  }
}
