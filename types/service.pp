# @summary Type for MaxScale service definitions
#
# Defines the structure for a MaxScale service configuration.
# 'router' is required, all other parameters are optional.
#
# @example Read-Write Split Service
#   {
#     'router'   => 'readwritesplit',
#     'servers'  => 'db1,db2,db3',
#     'user'     => 'maxscale',
#     'password' => 'secret',
#     'max_slave_connections' => '100%',
#   }
#
# @example Read Connection Router
#   {
#     'router'         => 'readconnroute',
#     'servers'        => 'db1,db2',
#     'router_options' => 'slave',
#     'user'           => 'maxscale',
#     'password'       => 'secret',
#   }
#
type Maxscale::Service = Struct[{
    router                                => String,
    Optional[servers]                     => String,
    Optional[targets]                     => String,
    Optional[cluster]                     => String,
    Optional[user]                        => String,
    Optional[password]                    => Variant[String, Sensitive[String]],
    Optional[router_options]              => String,
    Optional[filters]                     => String,
    Optional[enable_root_user]            => Boolean,
    Optional[localhost_match_wildcard_host] => Boolean,
    Optional[version_string]              => String,
    Optional[weightby]                    => String,
    Optional[auth_all_servers]            => Boolean,
    Optional[strip_db_esc]                => Boolean,
    Optional[retry_on_failure]            => Boolean,
    Optional[log_auth_warnings]           => Boolean,
    Optional[connection_timeout]          => String,
    Optional[net_write_timeout]           => String,
    Optional[max_connections]             => Integer[0],
    Optional[connection_keepalive]        => String,
    Optional[max_slave_connections]       => Variant[Integer[0], String],
    Optional[max_slave_replication_lag]   => String,
    Optional[use_sql_variables_in]        => Enum['master', 'all'],
    Optional[master_accept_reads]         => Boolean,
    Optional[strict_multi_stmt]           => Boolean,
    Optional[strict_sp_calls]             => Boolean,
    Optional[master_failure_mode]         => Enum['fail_instantly', 'fail_on_write', 'error_on_write'],
    Optional[causal_reads]                => Variant[Boolean, Enum['none', 'local', 'global', 'fast', 'fast_global', 'universal']],
    Optional[causal_reads_timeout]        => String,
    Optional[transaction_replay]          => Boolean,
    Optional[transaction_replay_max_size] => String,
    Optional[optimistic_trx]              => Boolean,
    Optional[lazy_connect]                => Boolean,
    Optional[options]                     => Hash[String, Variant[String, Integer, Boolean]],
}]
