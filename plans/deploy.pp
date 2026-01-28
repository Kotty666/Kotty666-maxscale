plan maxscale::deploy(
  TargetSpec $targets,
  Boolean $restart = true,
  String $service_name = 'maxscale'
) {
  apply_prep($targets)

  $apply_result = apply($targets) {
    include maxscale
  }

  if $restart {
    run_command("systemctl restart ${service_name}", $targets)
  }

  # Checks ohne catch_errors-Hash: wir machen es shell-safe
  run_command("systemctl is-active ${service_name} || true", $targets)
  run_command("systemctl is-enabled ${service_name} || true", $targets)

  return $apply_result
}
