# @summary this class adds the YumRepo
#
# This class is used to create the yum repo to install the maxscale
#
# @example
#   include maxscale::install::yum
class maxscale::install::yum (
      String $repository_base_url
) {

  if ($::architecture != 'amd64') {
            fail('Architectures != amd64 are not supported by the maxscale package repository!')

  }

  class {'yum':
    repos => {
      'mariadb-maxscale' => {
        baseurl  => $repository_base_url,
        enabled  => true,
        gpgkey   => 'https://downloads.mariadb.com/MaxScale/MariaDB-MaxScale-GPG-KEY',
        gpgcheck => '1'
      }
    }
  }
}
