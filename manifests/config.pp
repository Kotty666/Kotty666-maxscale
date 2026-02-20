# == Class: maxscale::config
#
# @summary
#   Configures MariaDB MaxScale and manages the main configuration file.
#
# @param threads
#   Number of MaxScale worker threads. Can be an Integer or 'auto'.
#
# @param max_auth_errors_until_block
#   Number of authentication failures allowed before blocking a host.
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
#   Name of the main MaxScale configuration file.
#
# @param max_user
#   User account under which MaxScale runs.
#
# @param max_group
#   Group under which MaxScale runs.
#
class maxscale::config (
  Variant[Integer, Enum['auto']] $threads,
  Integer                        $max_auth_errors_until_block,
  String                         $auth_connect_timeout,
  String                         $auth_read_timeout,
  String                         $auth_write_timeout,
  Integer                        $ms_timestamp,
  Boolean                        $syslog,
  Boolean                        $maxlog,
  Boolean                        $log_warning,
  Boolean                        $log_notice,
  Boolean                        $log_info,
  Boolean                        $log_debug,
  Boolean                        $log_augmentation,
  String                         $logdir,
  String                         $datadir,
  String                         $cachedir,
  String                         $piddir,
  String                         $configdir,
  String                         $configfile,
  String                         $max_user,
  String                         $max_group,
) {
  # Ensure install happens first
  require Class['maxscale::install']

  [$logdir, $datadir, $cachedir, $piddir].each |String $folder| {
    file { $folder:
      ensure => directory,
      owner  => $max_user,
      group  => $max_group,
      mode   => '0755',
    }
  }

  concat { $configfile:
    path  => "${configdir}/${configfile}",
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  concat::fragment { 'config_header':
    target  => $configfile,
    content => "# This file is managed by Puppet. DO NOT EDIT.\n",
    order   => '01',
  }

  concat::fragment { 'global_settings':
    target  => $configfile,
    content => template('maxscale/global_settings.erb'),
    order   => '02',
  }
}
