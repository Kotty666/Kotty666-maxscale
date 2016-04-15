define maxscale::install (
    $setup_mariadb_repository,
    $package_name = $name,
		$repository_base_url
) {
    if $setup_mariadb_repository {
        case $::osfamily {
            'Debian' : {
                ::maxscale::install::apt { $package_name : 
								repository_base_url => $repository_base_url,
							}
            }
            'Ubuntu' : {
                ::maxscale::install::apt { $package_name : 
								repository_base_url => $repository_base_url,
							}
            }
            default : {
                fail('sorry, no packages for your linux distribution available.')
            }
        }
    } else {
        package { $package_name :
            ensure => installed,
        }
    }
}


