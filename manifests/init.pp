# @summary
#   Install MariaDB MaxScale.
#
# @param service_enable
#   Manages if the service should be enabled
#
# @param configdir
#   Configure the directory for the configuration file for MaxScale.
#
# @param configfile
# @param user
# @param group
#
# @param package_name
#   Override the name of the maxscale package
#
# @param package_ensure
#
# @param setup_mariadb_repository
#   Setup the apt repositories from MariaDB for MaxScale.
#
# @param threads
#   Manages the number of maxscale threads
#
# @param auth_connect_timeout
#   The connection timeout in seconds for the MySQL connections to the backend server
#
# @param ms_timestamp
#   Enable or disable the high precision timestamps in logfiles.
#   Enabling this adds millisecond precision to all logfile timestamps.
#
# @param syslog
#   Enable or disable the logging of messages to syslog.
#
# @param maxlog
#   Enable or disable the logging of messages to MaxScale's log file.
#
# @param log_warning
#   Enable or disable the logging of messages whose syslog priority is warning.
#
# @param log_notice
#   Enable or disable the logging of messages whose syslog priority is notice.
#
# @param log_info
#   Enable or disable the logging of messages whose syslog priority is info.
#
# @param log_debug
#   Enable or disable the logging of messages whose syslog priority is debug.
#
# @param log_augmentation
#   Enable or disable the augmentation of messages.
#
# @param logdir
#   Set the directory where the logfiles are stored.
#
# @param datadir
#   Set the directory where the data files used by MaxScale are stored.
#
# @param cachedir
#   Configure the directory MaxScale uses to store cached data.
#
# @param piddir
#   Configure the directory for the PID file for MaxScale.
#
# @param auth_read_timeout
#   The read timeout in seconds for the MySQL connection to the backend database when user authentication data is fetched.
#   Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above
#
# @param auth_write_timeout
#   The write timeout in seconds for the MySQL connection to the backend database when user authentication data is fetched.
#   Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above
#
# @param max_auth_errors_until_block
#
# @param monitor
# @param server
# @param service
# @param listener
#
# @author
#   Philipp Frik <kotty@guns-n-girls.de>
#
# @see
#   https://mariadb.com/docs/maxscale/reference/maxscale-configuration-settings
#   https://mariadb.com/docs/maxscale/maxscale-management/deployment/maxscale-configuration-guide
#
class maxscale (
  Boolean                       $service_enable              = true,
  Stdlib::UnixPath              $configdir                   = '/etc',
  String                        $configfile                  = 'maxscale.cnf',
  String                        $user                        = 'maxscale',
  String                        $group                       = 'maxscale',
  # Install
  String                        $package_name                = 'maxscale',
  String                        $package_ensure              = 'present',
  Boolean                       $setup_mariadb_repository    = false,
  ## Configs
  Variant[Integer,Enum['auto']]           $threads                     = 'auto',
  Optional[Maxscale::Duration]            $auth_connect_timeout        = undef,
  Optional[Boolean]                       $ms_timestamp                = undef,
  Optional[Boolean]                       $syslog                      = undef,
  Optional[Boolean]                       $maxlog                      = undef,
  Optional[Boolean]                       $log_warning                 = undef,
  Optional[Boolean]                       $log_notice                  = undef,
  Optional[Boolean]                       $log_info                    = undef,
  Optional[Boolean]                       $log_debug                   = undef,
  Optional[Variant[Integer[0,1],Boolean]] $log_augmentation            = undef,
  Optional[Stdlib::Unixpath]              $logdir                      = undef,
  Optional[Stdlib::Unixpath]              $datadir                     = undef,
  Optional[Stdlib::Unixpath]              $cachedir                    = undef,
  Optional[Stdlib::Unixpath]              $piddir                      = undef,
  Optional[Integer]                       $max_auth_errors_until_block = undef,
  # Configs (Deprecated)
  Optional[Maxscale::Duration]            $auth_read_timeout           = undef, # Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above
  Optional[Maxscale::Duration]            $auth_write_timeout          = undef, # Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above
  ## defines
  Hash                                    $monitor                     = {},
  Hash                                    $server                      = {},
  Hash                                    $service                     = {},
  Hash                                    $listener                    = {},
) {
  contain maxscale::install
  contain maxscale::config

  # make sure maxscale user is available before writing config files
  Class['maxscale::install'] -> Class['maxscale::config'] ~> Service['maxscale']

  service { 'maxscale':
    ensure    => $service_enable,
    name      => $package_name,
    enable    => $service_enable,
    subscribe => Package[$package_name],
  }

  create_resources(maxscale::config::monitor, $monitor)
  create_resources(maxscale::config::server, $server)
  create_resources(maxscale::config::service, $service)
  create_resources(maxscale::config::listener, $listener)
}
