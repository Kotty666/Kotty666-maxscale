# @summary Manages the MaxScale system user and group
#
# This class is only included when `maxscale::manage_user` is true.
# In most cases the maxscale package creates the user automatically.
# Set `manage_user` to true if you need Puppet to manage the user
# (e.g., when the user must exist before configuration files are created).
#
# @api private
#
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
