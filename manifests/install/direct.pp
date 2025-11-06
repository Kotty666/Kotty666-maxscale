# @summary
#   Install package from provided URL
#
# @example
#   include maxscale::install::direct
#
# @param package_name
# @param package_url
#
class maxscale::install::direct (
  String $package_name,
  String $package_url,
) {
  case $facts['os']['family'] {
    'RedHat': {
      package { $package_name:
        ensure   => present,
        source   => $package_url,
        provider => 'dnf',
      }
    }

    'Debian': {
      exec { 'GetDebFile':
        command     => "curl --silent -k ${package_url} --output /tmp/maxscale.deb",
        path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
        provider    => 'shell',
        refreshonly => true,
      }
      package { $package_name:
        ensure  => present,
        source  => '/tmp/maxscale.deb',
        require => Exec['GetDebFile'],
      }
    }
    default: {
      fail('sorry, no packages for your linux distribution available.')
    }
  }
}
