plan maxscale::deploy(
  TargetSpec $targets,
  Boolean $noop = false,
  Boolean $restart = true,
  Optional[String] $service_name = 'maxscale',
) {
  # Apply the maxscale class via 'apply_prep' and 'apply'
  apply_prep($targets)

  $apply_result = apply($targets, _noop => $noop) {
    include maxscale
  }

  # Optional: restart service after apply (only if not noop)
  if $restart and !$noop {
    run_command("systemctl restart ${service_name}", targets => $targets, description => 'Restart MaxScale service')
  }

  # Basic checks (best effort)
  $status = run_command("systemctl is-active ${service_name}", targets => $targets, catch_errors => true, description => 'Check service status')
  $enabled = run_command("systemctl is-enabled ${service_name}", targets => $targets, catch_errors => true, description => 'Check service enabled')

  return {
    'apply'   => $apply_result,
    'active'  => $status,
    'enabled' => $enabled,
  }
}

