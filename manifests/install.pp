# @summary Manages MaxScale package installation
#
# This private class handles the installation of MaxScale packages
# and optionally configures the MariaDB repository.
#
# @api private
#
class maxscale::install {
  assert_private()

  # Manage repository if requested
  if $maxscale::manage_repo {
    case $facts['os']['family'] {
      'Debian': {
        contain maxscale::repo::apt
      }
      'RedHat': {
        contain maxscale::repo::yum
      }
      default: {
        fail("Unsupported OS family: ${facts['os']['family']}")
      }
    }
  }

  # Install package
  package { $maxscale::package_name:
    ensure => $maxscale::package_version,
  }

  # If managing repo, ensure repo is configured before package install
  if $maxscale::manage_repo {
    case $facts['os']['family'] {
      'Debian': {
        Class['maxscale::repo::apt'] -> Package[$maxscale::package_name]
      }
      'RedHat': {
        Class['maxscale::repo::yum'] -> Package[$maxscale::package_name]
      }
      default: {}
    }
  }
}
