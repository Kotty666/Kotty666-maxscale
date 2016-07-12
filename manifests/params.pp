# == class: maxscale::para,s
#
# defines the default parameters for a installation
#
class maxscale::params {
  $package_name = 'maxscale'
  $gpg_key_url = 'http://code.mariadb.com/mariadb-maxscale/MariaDB-MaxScale-GPG-KEY'
  $gpg_key_id = '13CFDE6DD9EE9784F41AF0F670E4618A8167EE24'
  $threads = 'auto'
  $auth_connect_timeout = 3
  $auth_read_timeout = 1
  $auth_write_timeout = 2
  $ms_timestamp = 0
  $syslog = 0
  $maxlog = 1
  $log_to_shm = 0
  $log_warning = 1
  $log_notice = 0
  $log_info = 0
  $log_debug = 0
  $log_augmentation = 0
  $logdir = '/var/log/maxscale/'
  $datadir = '/var/lib/maxscale/data/'
  $cachedir = '/var/cache/maxscale/'
  $piddir =  '/var/run/maxscale/'
  $configdir = '/etc'
  $configfile = "${configdir}/maxscale.cnf"
	$version = '1.4.1'

  case $::lsbdistid {
    'Debian' : {
      $repository_base_url = "http://code.mariadb.com/mariadb-maxscale/${version}/debian/"
    }
    'Ubuntu' : {
      $repository_base_url = "http://code.mariadb.com/mariadb-maxscale/${version}/ubuntu/"
    }
    default : {
      fail ('For your Distribution is no repository known!')
    }
  }
}
