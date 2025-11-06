#
# @summary
#   installs the maxscale package
#   the parameters manages if ther should be used the original repo or not
#
# @param setup_mariadb_repository
# @param package_ensure
# @param package_name
# @param package_url
# @param direct_install
#
class maxscale::install (
  Boolean           $setup_mariadb_repository = $maxscale::setup_mariadb_repository,
  String            $package_ensure           = $maxscale::package_ensure,
  String            $package_name             = $maxscale::package_name,
  Optional[String]  $package_url              = undef,
  Boolean           $direct_install           = false,
) {
  if $setup_mariadb_repository {
    case $facts['os.family'] {
      'Debian' : {
        contain maxscale::install::apt
        Class['maxscale::install::apt'] -> Package[$package_name]
      }
      'RedHat': {
        contain maxscale::install::yum
        Class['maxscale::install::yum'] -> Package[$package_name]
      }
      default : {
        fail('sorry, no packages for your linux distribution available.')
      }
    }
  }
  if $direct_install {
    class { 'maxscale::install::direct':
      package_name => $package_name,
      package_url  => $package_url,
    }
  } else {
    package { $package_name :
      ensure => $package_ensure,
    }
  }
}
