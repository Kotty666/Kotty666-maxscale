# @summary Creates a MaxScale filter configuration
#
# This defined type creates an individual configuration file for a MaxScale
# filter in the config.d directory.
#
# @param module
#   The filter module to use (e.g., 'qlafilter', 'regexfilter', 'tee').
#
# @param options
#   A hash of additional key/value pairs for the filter section.
#
# @param ensure
#   Whether the configuration file should be present or absent.
#
# @example Query Log Filter
#   maxscale::config::filter { 'QueryLog':
#     module  => 'qlafilter',
#     options => {
#       'filebase' => '/var/log/maxscale/queries',
#       'log_type' => 'unified',
#       'flush'    => true,
#     },
#   }
#
define maxscale::config::filter (
  String                     $module,
  Hash                       $options = {},
  Enum['present','absent']   $ensure  = 'present',
) {
  include maxscale

  $_config_d_path = "${maxscale::config_dir}/${maxscale::config_d_dir}"

  $_params = { 'module' => $module } + $options

  file { "${_config_d_path}/filter_${name}.cnf":
    ensure  => $ensure,
    owner   => $maxscale::config_owner,
    group   => $maxscale::config_group,
    mode    => $maxscale::config_mode,
    content => epp('maxscale/component.cnf.epp', {
      'name'           => $name,
      'component_type' => 'filter',
      'params'         => $_params,
    }),
    notify  => Class['maxscale::service'],
  }
}
