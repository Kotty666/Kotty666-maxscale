# == define: maxscale::config::listener
#
# adds the repo to the system configuration
define maxscale::install::apt (
    $package_version,
    $package_name = $name,
    $repository_base_url = undef
) {

    require ::maxscale::params

    if ($::architecture != 'amd64') {
        fail('Architectures != amd64 are not supported by the maxscale package repository!')
    }

    case $::lsbdistid {
        'Debian' : {
            if ($::lsbmajdistrelease !~ /^(7|8)$/) {
                fail ('This Debian release is not supported by the MariaDB MaxScale repository!')
            }
        }
        'Ubuntu' : {
            if ($::lsbdistrelease !~ /^(12\.04|14\.04|15\.10)$/) {
                fail ('This Ubuntu release is not supported by the MariaDB MaxScale repository!')
            }
        }
        default : {
            fail ('This Debian based distribution is not supported by the MariaDB MaxScale repository!')
        }
    }

    if $repository_base_url == undef {
      $repository_base_url = $::maxscale::params::repository_base_url
    }

    ::apt::source { 'mariadb-maxscale' :
        architecture => 'amd64',
        location     => $repository_base_url,
        include      => {
            'src' => false,
            'deb' => true,
        },
        key          => {
            'id'     => $::maxscale::params::gpg_key_id,
            'server' => 'keys.gnupg.net'
        },
        repos        => 'main',
        release      => $::lsbdistcodename,
        require      => ::Apt::Key['mariadb-maxscale']
    }

    package { $package_name :
        ensure  => installed,
        require => ::Apt::Source['mariadb-maxscale']
    }

}
