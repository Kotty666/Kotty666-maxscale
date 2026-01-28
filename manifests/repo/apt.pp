# @summary Manages the MaxScale APT repository
#
# @api private
#
class maxscale::repo::apt {
  assert_private()

  include apt

  apt::source { 'maxscale':
    location => "https://dlm.mariadb.com/repo/maxscale/${maxscale::repo_version}/apt",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main',
    key      => {
      'id'     => '177F4010FE56CA3336300305F1656F24C74CD1D8',
      'source' => 'https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY',
    },
  }
}
