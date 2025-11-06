#
# @summary
#   configures maxscale, per default in /etc/maxscale.cnf.
#
# @param configdir
# @param configfile
# @param user
# @param group
#
# @param threads
# @param auth_connect_timeout
# @param ms_timestamp
# @param syslog
# @param maxlog
# @param log_warning
# @param log_notice
# @param log_info
# @param log_debug
# @param log_augmentation
# @param logdir
# @param datadir
# @param cachedir
# @param piddir
# @param max_auth_errors_until_block
# @param admin_host
# @param admin_port
# @param admin_ssl_key
# @param admin_ssl_cert
# @param admin_ssl_ca
# @param admin_secure_gui
# @param admin_pam_readonly_service
# @param admin_pam_readwrite_service
#
# @param auth_read_timeout
#   Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above.
#
# @param auth_write_timeout
#   Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above.
#
# @see
#   https://mariadb.com/docs/maxscale/reference/maxscale-configuration-settings
#   https://mariadb.com/docs/maxscale/maxscale-management/deployment/maxscale-configuration-guide#global-settings
#
class maxscale::config (
  Stdlib::Unixpath                        $configdir                   = $maxscale::configdir,
  String                                  $configfile                  = $maxscale::configfile,
  String                                  $user                        = $maxscale::user,
  String                                  $group                       = $maxscale::group,
  # Configs
  Variant[Integer,Enum['auto']]           $threads                     = $maxscale::threads,
  Optional[String]                        $auth_connect_timeout        = $maxscale::auth_connect_timeout,
  Optional[Boolean]                       $ms_timestamp                = $maxscale::ms_timestamp,
  Optional[Boolean]                       $syslog                      = $maxscale::syslog,
  Optional[Boolean]                       $maxlog                      = $maxscale::maxlog,
  Optional[Boolean]                       $log_warning                 = $maxscale::log_warning,
  Optional[Boolean]                       $log_notice                  = $maxscale::log_notice,
  Optional[Boolean]                       $log_info                    = $maxscale::log_info,
  Optional[Boolean]                       $log_debug                   = $maxscale::log_debug,
  Optional[Variant[Integer[0,1],Boolean]] $log_augmentation            = $maxscale::log_augmentation,
  Optional[Stdlib::Unixpath]              $logdir                      = $maxscale::logdir,
  Optional[Stdlib::Unixpath]              $datadir                     = $maxscale::datadir,
  Optional[Stdlib::Unixpath]              $cachedir                    = $maxscale::cachedir,
  Optional[Stdlib::Unixpath]              $piddir                      = $maxscale::piddir,
  Optional[Integer]                       $max_auth_errors_until_block = $maxscale::max_auth_errors_until_block,
  Optional[Stdlib::IP::Address]           $admin_host                  = $maxscale::admin_host,
  Optional[Stdlib::Port]                  $admin_port                  = $maxscale::admin_port,
  Optional[Stdlib::UnixPath]              $admin_ssl_key               = $maxscale::admin_ssl_key,
  Optional[Stdlib::UnixPath]              $admin_ssl_cert              = $maxscale::admin_ssl_cert,
  Optional[Stdlib::UnixPath]              $admin_ssl_ca                = $maxscale::admin_ssl_ca,
  Optional[Boolean]                       $admin_secure_gui            = $maxscale::admin_secure_gui,
  Optional[String]                        $admin_pam_readonly_service  = $maxscale::admin_pam_readonly_service,
  Optional[String]                        $admin_pam_readwrite_service = $maxscale::admin_pam_readwrite_service,
  # Deprecated
  Optional[String]                        $auth_read_timeout           = $maxscale::auth_read_timeout,  # Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above.
  Optional[String]                        $auth_write_timeout          = $maxscale::auth_write_timeout, # Deprecated and ignored as of MaxScale 2.5.0. See auth_connect_timeout above.
) {
  [$logdir,$datadir,$cachedir,$piddir].delete_undef_values().each | String $folder | {
    file { $folder:
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      mode    => '0755',
      require => Package[$maxscale::package_name],
    }
  }

  concat { $configfile:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    path  => "${configdir}/${configfile}",
  }
  concat::fragment { 'Config Header':
    target  => $configfile,
    content => "# This file is managed by Puppet. DO NOT EDIT.\n",
    order   => '01',
  }

  concat::fragment { 'GlobalSettings':
    target  => $configfile,
    content => epp('maxscale/global_settings.epp', {
        threads                     => $threads,
        auth_connect_timeout        => $auth_connect_timeout,
        ms_timestamp                => $ms_timestamp,
        syslog                      => $syslog,
        maxlog                      => $maxlog,
        log_warning                 => $log_warning,
        log_notice                  => $log_notice,
        log_info                    => $log_info,
        log_debug                   => $log_debug,
        log_augmentation            => $log_augmentation,
        logdir                      => $logdir,
        datadir                     => $datadir,
        cachedir                    => $cachedir,
        piddir                      => $piddir,
        max_auth_errors_until_block => $max_auth_errors_until_block,
        admin_host                  => $admin_host,
        admin_port                  => $admin_port,
        admin_ssl_key               => $admin_ssl_key,
        admin_ssl_cert              => $admin_ssl_cert,
        admin_ssl_ca                => $admin_ssl_ca,
        admin_secure_gui            => $admin_secure_gui,
        admin_pam_readonly_service  => $admin_pam_readonly_service,
        admin_pam_readwrite_service => $admin_pam_readwrite_service,
        # Deprecated
        auth_read_timeout           => $auth_read_timeout,
        auth_write_timeout          => $auth_write_timeout,
    }),
    order   => '02',
  }

  $_server_header = @(_EOF)
    ############################################################################
    # Server definitions                                                       #
    #                                                                          #
    # Set the address of the server to the network address of a MariaDB server.#
    ############################################################################
    | _EOF

  concat::fragment { 'Server Header':
    target  => $configfile,
    order   => 10,
    content => $_server_header,
  }

  $_monitor_header = @(_EOF)
    ##################################################################################################
    # Monitor for the servers                                                                        #
    #                                                                                                #
    # This will keep MaxScale aware of the state of the servers.                                     #
    # MariaDB Monitor documentation:                                                                 #
    # https://mariadb.com/kb/en/mariadb-maxscale-2501-maxscale-25-01-monitors/                       #
    #                                                                                                #
    # The GRANTs needed by the monitor user depend on the actual monitor.                            #
    # The GRANTs required by the MariaDB Monitor can be found here:                                  #
    # https://mariadb.com/kb/en/mariadb-maxscale-2501-maxscale-2501-mariadb-monitor/#required-grants #
    ##################################################################################################
    | _EOF

  concat::fragment { 'Monitor Header':
    target  => $configfile,
    order   => 20,
    content => $_monitor_header,
  }

  $_service_header = @(_EOF)
    #########################################################################################################
    # Service definitions                                                                                   #
    #                                                                                                       #
    # Service Definition for a read-only service and a read/write splitting service.                        #
    #                                                                                                       #
    # The GRANTs needed by the service user can be found here:                                              #
    # https://mariadb.com/kb/en/mariadb-maxscale-2501-maxscale-2501-authentication-modules/#required-grants #
    #########################################################################################################
    | _EOF
  concat::fragment { 'Service Header':
    target  => $configfile,
    order   => 30,
    content => $_service_header,
  }

  $_listener_header = @(_EOF)
    ####################################################################
    # Listener definitions                                             #
    #                                                                  #
    # These listeners represent the ports the services will listen on. #
    ####################################################################
    | _EOF
  concat::fragment { 'Listener Header':
    target  => $configfile,
    order   => 40,
    content => $_listener_header,
  }
}
