# @summary Manages MaxScale configuration
#
# This private class manages the MaxScale configuration files and directories.
# It creates the main configuration file from hash parameters and manages
# the config.d directory where defined types place their individual files.
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

  # Manage config_dir only if it's NOT a system directory like /etc.
  # Managing /etc causes dependency cycles with other modules (yum, puppet_agent, etc.)
  # that also have resources under /etc (autorequire chains).
  # Custom directories like /etc/maxscale need to be created.
  if $maxscale::config_dir != '/etc' {
    file { $maxscale::config_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  # Manage the config.d directory for defined-type based config files.
  # purge + recurse ensures that files not managed by Puppet are removed,
  # keeping the config directory in sync with the catalog.
  $config_d_path = "${maxscale::config_dir}/${maxscale::config_d_dir}"

  file { $config_d_path:
    ensure  => directory,
    owner   => $maxscale::config_owner,
    group   => $maxscale::config_group,
    mode    => '0755',
    purge   => true,
    recurse => true,
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
