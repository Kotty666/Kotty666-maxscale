# @summary Manages the MariaDB MaxScale YUM repository
#
# This private class configures the YUM repository for MaxScale packages
# on RedHat-based systems.
#
# @api private
#
class maxscale::repo::yum {
  assert_private()

  # Determine repository URL
  $repo_url = $maxscale::repo_base_url ? {
    undef   => "https://dlm.mariadb.com/repo/maxscale/${maxscale::repo_version}/yum/rhel/\$releasever/\$basearch",
    default => $maxscale::repo_base_url,
  }

  # Supported architectures
  unless $facts['os']['architecture'] in ['x86_64', 'aarch64'] {
    fail("Architecture ${facts['os']['architecture']} is not supported by the MaxScale package repository")
  }

  yumrepo { 'maxscale':
    descr    => "MariaDB MaxScale ${maxscale::repo_version}",
    baseurl  => $repo_url,
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY',
  }
}
