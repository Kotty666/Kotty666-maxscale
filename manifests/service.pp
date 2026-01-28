# @summary Manages the MaxScale service
#
# This private class manages the MaxScale systemd service.
#
# @api private
#
class maxscale::service {
  assert_private()

  service { $maxscale::service_name:
    ensure     => $maxscale::service_ensure,
    enable     => $maxscale::service_enable,
    hasrestart => true,
    hasstatus  => true,
  }
}
