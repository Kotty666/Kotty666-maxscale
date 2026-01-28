# @summary Manages the MariaDB MaxScale APT repository
#
# This private class configures the APT repository for MaxScale packages
# on Debian-based systems.
#
# @api private
#
class maxscale::repo::apt {
  assert_private()

  # Determine repository URL
  $repo_url = $maxscale::repo_base_url ? {
    undef   => "https://dlm.mariadb.com/repo/maxscale/${maxscale::repo_version}/apt",
    default => $maxscale::repo_base_url,
  }

  # Determine distribution codename
  $dist = $facts['os']['distro']['codename']

  # Supported architectures
  unless $facts['os']['architecture'] in ['amd64', 'arm64'] {
    fail("Architecture ${facts['os']['architecture']} is not supported by the MaxScale package repository")
  }

  apt::source { 'maxscale':
    location => $repo_url,
    release  => $dist,
    repos    => 'main',
    key      => {
      'id'     => $maxscale::gpg_key_id,
      'source' => 'https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY',
    },
    include  => {
      'src' => false,
      'deb' => true,
    },
  }

  # Ensure apt update runs before package installation
  Class['apt::update'] -> Package[$maxscale::package_name]
}
