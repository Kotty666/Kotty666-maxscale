# @summary Type for MaxScale monitor definitions
#
# Defines the structure for a MaxScale monitor configuration.
# 'module' and 'servers' are required, all other parameters are optional.
#
# @example MariaDB Monitor
#   {
#     'module'           => 'mariadbmon',
#     'servers'          => 'db1,db2,db3',
#     'user'             => 'maxscale',
#     'password'         => 'secret',
#     'monitor_interval' => '2000ms',
#     'auto_failover'    => true,
#     'auto_rejoin'      => true,
#   }
#
# @example Galera Monitor
#   {
#     'module'                => 'galeramon',
#     'servers'               => 'node1,node2,node3',
#     'user'                  => 'maxscale',
#     'password'              => 'secret',
#     'disable_master_failback' => true,
#   }
#
type Maxscale::Monitor = Struct[{
  module                               => String,
  servers                              => String,
  Optional[user]                       => String,
  Optional[password]                   => Variant[String, Sensitive[String]],
  Optional[monitor_interval]           => String,
  Optional[backend_connect_timeout]    => String,
  Optional[backend_write_timeout]      => String,
  Optional[backend_read_timeout]       => String,
  Optional[journal_max_age]            => String,
  Optional[script]                     => Stdlib::Absolutepath,
  Optional[script_timeout]             => String,
  Optional[events]                     => String,
  Optional[auto_failover]              => Boolean,
  Optional[auto_rejoin]                => Boolean,
  Optional[replication_user]           => String,
  Optional[replication_password]       => Variant[String, Sensitive[String]],
  Optional[failcount]                  => Integer[1],
  Optional[failover_timeout]           => String,
  Optional[switchover_timeout]         => String,
  Optional[master_failure_timeout]     => String,
  Optional[verify_master_failure]      => Boolean,
  Optional[master_conditions]          => String,
  Optional[slave_conditions]           => String,
  Optional[enforce_read_only_slaves]   => Boolean,
  Optional[cooperative_monitoring_locks] => Enum['none', 'majority_of_running', 'majority_of_all'],
  Optional[options]                    => Hash[String, Variant[String, Integer, Boolean]],
}]
