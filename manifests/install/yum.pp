#
# @summary
#   this class adds the YumRepo
#
# This class is used to create the yum repo to install the maxscale
#
# @example
#   include maxscale::install::yum
#
# @param repository_version
# @param repository_base_url
#
class maxscale::install::yum (
  String $repository_version  = 'latest',
  String $repository_base_url = "https://dlm.mariadb.com/repo/maxscale/${repository_version}/rhel/\$releasever/\$basearch"
) {
  unless $facts['os']['architecture'] == 'x86_64' {
    fail('Architectures != x86_64 are not supported by the maxscale package repository!')
  }

  class { 'yum':
    repos => {
      'mariadb-maxscale' => {
        baseurl  => $repository_base_url,
        enabled  => true,
        gpgkey   => 'https://downloads.mariadb.com/MaxScale/MariaDB-MaxScale-GPG-KEY',
        gpgcheck => '1',
      },
    },
  }
}
