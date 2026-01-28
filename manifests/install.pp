# @summary Manages MaxScale package installation
#
# This private class handles the installation of MaxScale packages
# and optionally configures the MariaDB repository.
#
# @api private
#
class maxscale::install {
  assert_private()

  # Install package
  package { $maxscale::package_name:
    ensure => $maxscale::package_version,
  }
}
