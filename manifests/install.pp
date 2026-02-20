# == class: maxscale::install
#
# @summary
#   Installs the maxscale package
#
# @example
#   include maxscale
#
# @param package_name
#   Name of the MaxScale package to install.
#
# @param setup_mariadb_repository
#   TODO
#
# @param repository_base_url
#   TODO
#
# @param package_version
#   TODO
#
# @param direct_install
#   TODO
#
# @param package_url
#   TODO
#
# === Parameters
# the parameters manages if ther should be used the original repo or not
class maxscale::install (
  Boolean $setup_mariadb_repository,
  String $repository_base_url,
  String $package_version,
  String $package_name,
  Boolean $direct_install,
  String $package_url
) {
  if $setup_mariadb_repository {
    case $facts['os.family'] {
      'Debian' : {
        class { 'maxscale::install::apt':
          repository_base_url => $repository_base_url,
        }
        Class['maxscale::install::apt'] -> Package[$package_name]
      }
      'RedHat': {
        class { 'maxscale::install::yum':
          repository_base_url => $repository_base_url,
        }
        Class['maxscale::install::yum'] -> Package[$package_name]
      }
      default : {
        fail('sorry, no packages for your linux distribution available.')
      }
    }
  }
  if $direct_install {
    class { 'maxscale::install::direct':
      package_url => $package_url,
    }
  } else {
    package { $package_name :
      ensure => $package_version,
    }
  }
}
