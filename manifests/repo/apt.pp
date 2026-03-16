# @summary Manages the MaxScale APT repository
#
# @api private
#
class maxscale::repo::apt {
  assert_private()

  include apt

  $repo_url = $maxscale::repo_base_url ? {
    undef   => "https://dlm.mariadb.com/repo/maxscale/${maxscale::repo_version}/apt",
    default => $maxscale::repo_base_url,
  }

  apt::source { 'maxscale':
    location => $repo_url,
    release  => $facts['os']['distro']['codename'],
    repos    => 'main',
    key      => {
      'id'     => $maxscale::gpg_key_id,
      'source' => 'https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY',
    },
  }
}
