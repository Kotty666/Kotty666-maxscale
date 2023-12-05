# == class: maxscale::config
#
# configures maxscale, per default in /etc/maxscale.cnf.
#
# === Parameters
# all Parameters are copied from the default maxscale.cnf.
# they are set per default in /data/
class maxscale::config(
  Variant[Integer,Enum['auto']] $threads,
  Integer $max_auth_errors_until_block,
  String $auth_connect_timeout,
  String $auth_read_timeout,
  String $auth_write_timeout,
  Integer $ms_timestamp,
  Boolean $syslog,
  Boolean $maxlog,
  Boolean $log_warning,
  Boolean $log_notice,
  Boolean $log_info,
  Boolean $log_debug,
  Boolean $log_augmentation,
  String $logdir,
  String $datadir,
  String $cachedir,
  String $piddir,
  String $configdir,
  String $configfile,
  String $max_user,
  String $max_group,
) {


  [$logdir,$datadir,$cachedir,$piddir].each | String $folder | {
    file { $folder:
      ensure  => 'directory',
      owner   => $max_user,
      group   => $max_group,
      mode    => '0755',
      require => Package[$maxscale::package_name],
    }
  }

  concat { $configfile:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    path  => "${configdir}/${configfile}",
  }
  concat::fragment { 'Config Header':
    target  => $configfile,
    content => "# This file is managed by Puppet. DO NOT EDIT.\n",
    order   => '01',
  }
  concat::fragment{ 'GlobalSettings':
    target  => $configfile,
    content => template('maxscale/global_settings.erb'),
    order   => '02',
  }
}
