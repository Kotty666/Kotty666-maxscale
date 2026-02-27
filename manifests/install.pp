# @summary Manages MaxScale package installation
#
# @api private
#
class maxscale::install {
  assert_private()

  package { $maxscale::package_name:
    ensure => $maxscale::package_version,
  }
}
