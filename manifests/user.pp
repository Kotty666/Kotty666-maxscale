# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include maxscale::user
class maxscale::user {
  assert_private()

  group { $maxscale::maxscale_group:
    ensure => present,
    system => true,
  }

  user { $maxscale::maxscale_user:
    ensure     => present,
    gid        => $maxscale::maxscale_group,
    system     => true,
    managehome => false,
    shell      => '/usr/sbin/nologin',
    require    => Group[$maxscale::maxscale_group],
  }
}
