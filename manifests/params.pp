# == class: maxscale::params
#
# defines the default parameters for a installation
#
class maxscale::params {
  $package_name = 'maxscale'
  $gpg_key_id = '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB'
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
  $version = '2.1.11'
  $user = 'maxscale'
  $group = 'maxscale'

  case $::lsbdistid {
    'Debian' : {
      $repository_base_url = "http://downloads.mariadb.com/MaxScale/${version}/debian/"
    }
    'Ubuntu' : {
      $repository_base_url = "http://downloads.mariadb.com/MaxScale/${version}/ubuntu/"
    }
    default : {
      fail ('For your Distribution is no repository known!')
    }
  }
}
