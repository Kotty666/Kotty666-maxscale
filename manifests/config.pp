# == class: maxscale::config
#
# configures maxscale, per default in /etc/maxscale.cnf.
#
# === Parameters
# all Parameters are copied from the default maxscale.cnf.
# they are set per default in /data/
class maxscale::config(
  $threads,
  $auth_connect_timeout,
  $auth_read_timeout,
  $auth_write_timeout,
  $ms_timestamp,
  $syslog,
  $maxlog,
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
  $configfile,
  $user,
  $group,
) {


  [$logdir,$datadir,$cachedir,$piddir].each | String $folder | {
    file { $folder:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0774'
    }
  }

  concat { "$configfile":
    owner => 'root',
    group => 'root',
    mode  => '0644',
    path  => "$configdir/$configfile",
  }
  concat::fragment { 'Config Header':
    target  => "$configfile",
    content => "# This file is managed by Puppet. DO NOT EDIT.\n",
    order   => '01',
  }
  concat::fragment{ 'GlobalSettings':
    target  => "$configfile",
    content => template('maxscale/global_settings.erb'),
    order   => '02',
  }
}
