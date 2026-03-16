# @summary Type for MaxScale filter definitions
#
# Defines the structure for a MaxScale filter configuration.
# 'module' is required, all other parameters depend on the filter type.
#
# @example Query Log Filter
#   {
#     'module'  => 'qlafilter',
#     'filebase' => '/var/log/maxscale/query',
#     'log_type' => 'unified',
#   }
#
# @example Regex Filter
#   {
#     'module' => 'regexfilter',
#     'match'  => 'SELECT.*FROM secret_table',
#     'replace' => 'SELECT 1',
#   }
#
# @example Tee Filter
#   {
#     'module'  => 'tee',
#     'service' => 'Analytics-Service',
#   }
#
type Maxscale::Filter = Struct[{
  module                        => String,
  Optional[filebase]            => String,
  Optional[log_type]            => Enum['session', 'unified'],
  Optional[flush]               => Boolean,
  Optional[append]              => Boolean,
  Optional[newline_replacement] => String,
  Optional[separator]           => String,
  Optional[match]               => String,
  Optional[replace]             => String,
  Optional[source]              => String,
  Optional[user]                => String,
  Optional[service]             => String,
  Optional[max_qps]             => Integer[0],
  Optional[throttling_duration] => String,
  Optional[sampling_duration]   => String,
  Optional[continuous_duration] => String,
  Optional[match01]             => String,
  Optional[target01]            => String,
  Optional[storage]             => String,
  Optional[ttl]                 => String,
  Optional[max_size]            => String,
  Optional[max_count]           => Integer[0],
  Optional[rules]               => Stdlib::Absolutepath,
  Optional[options]             => Hash[String, Variant[String, Integer, Boolean]],
}]
