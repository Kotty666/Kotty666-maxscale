# == class: maxscale::install::apt
#
# adds the repo to the system configuration
class maxscale::install::apt (
    $repository_base_url = undef
) {

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
            if ($::lsbdistrelease !~ /^(14\.04|16\.04)$/) {
                fail ('This Ubuntu release is not supported by the MariaDB MaxScale repository!')
            }
        }
        default : {
            fail ('This Debian based distribution is not supported by the MariaDB MaxScale repository!')
        }
    }

    if $repository_base_url == undef {
      $repository_base_url = $maxscale::repository_base_url
    }

    ::apt::source { 'mariadb-maxscale' :
        architecture => 'amd64',
        location     => $repository_base_url,
        include      => {
            'src' => false,
            'deb' => true,
        },
        key          => {
            'id'     => $maxscale::gpg_key_id,
            'server' => 'hkp://keyserver.ubuntu.com:80'
        },
        repos        => 'main',
        release      => $::lsbdistcodename,
    }
}
