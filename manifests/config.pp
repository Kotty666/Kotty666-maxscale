# @summary Manages MaxScale configuration
#
# This private class manages the MaxScale configuration files and directories.
# It uses a flexible, hash-based approach where all configuration options
# are passed through to the configuration file without hardcoding parameters.
#
# @api private
#
class maxscale::config {
  assert_private()

  # Manage directories if requested
  if $maxscale::manage_dirs {
    $managed_dirs = [
      $maxscale::log_dir,
      $maxscale::data_dir,
      $maxscale::cache_dir,
      $maxscale::pid_dir,
    ]

    $managed_dirs.each |String $dir| {
      file { $dir:
        ensure => directory,
        owner  => $maxscale::maxscale_user,
        group  => $maxscale::maxscale_group,
        mode   => '0755',
      }
    }
  }

  # Ensure config directory exists
  file { $maxscale::config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Build the complete configuration
  $config_path = "${maxscale::config_dir}/${maxscale::config_file}"

  # Merge default directory settings with user-provided global options
  $default_global = {
    'logdir'   => $maxscale::log_dir,
    'datadir'  => $maxscale::data_dir,
    'cachedir' => $maxscale::cache_dir,
    'piddir'   => $maxscale::pid_dir,
  }

  $merged_global_options = $default_global + $maxscale::global_options

  # Create the main configuration file using EPP template
  file { $config_path:
    ensure  => file,
    owner   => $maxscale::config_owner,
    group   => $maxscale::config_group,
    mode    => $maxscale::config_mode,
    content => epp('maxscale/maxscale.cnf.epp', {
        'global_options' => $merged_global_options,
        'servers'        => $maxscale::servers,
        'monitors'       => $maxscale::monitors,
        'services'       => $maxscale::services,
        'listeners'      => $maxscale::listeners,
        'filters'        => $maxscale::filters,
    }),
    require => User[$maxscale::maxscale_user],
  }

  # Create any extra configuration files
  $maxscale::extra_config_files.each |String $filename, Hash $config| {
    file { "${maxscale::config_dir}/${filename}":
      ensure  => file,
      owner   => $maxscale::config_owner,
      group   => $maxscale::config_group,
      mode    => $maxscale::config_mode,
      content => epp('maxscale/extra_config.epp', {
          'sections' => $config,
      }),
    }
  }
}
