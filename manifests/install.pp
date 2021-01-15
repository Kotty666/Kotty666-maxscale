# == class: maxscale::install
#
# installs the maxscale package
#
# === Parameters
# the parameters manages if ther should be used the original repo or not
class maxscale::install (
    Boolean $setup_mariadb_repository,
    String $repository_base_url,
    String $package_version,
    String $package_name,
) {
    if $setup_mariadb_repository {
        case $::osfamily {
            'Debian' : {
                class { '::maxscale::install::apt':
                    repository_base_url => $repository_base_url,
                }
                Class['::maxscale::install::apt'] -> Package[$package_name]
            }
            default : {
                fail('sorry, no packages for your linux distribution available.')
            }
        }
    }
    package { $package_name :
        ensure => $package_version,
    }
}
