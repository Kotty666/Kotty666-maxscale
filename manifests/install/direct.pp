# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include maxscale::install::direct
class maxscale::install::direct (
  String $package_url
) {
  case $facts['os']['family'] {
    'RedHat': {
      package { $maxscale::install::package_name:
        ensure   => present,
        source   => $package_url,
        provider => 'rpm',
      }
    }
    'Debian': {
      exec {'GetDebFile':
        command     => "curl --silent -k $package_url --output /tmp/maxscale.deb",
        path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
        provider    => 'shell',
        refreshonly => true,
      }
      package { $maxscale::install::package_name:
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
