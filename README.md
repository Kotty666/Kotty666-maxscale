# maxscale

[![Puppet Forge](https://img.shields.io/puppetforge/v/kotty666/maxscale.svg)](https://forge.puppet.com/kotty666/maxscale)
[![License](https://img.shields.io/github/license/Kotty666/puppet-maxscale.svg)](LICENSE)

## Description

This Puppet module manages the installation and configuration of [MariaDB MaxScale](https://mariadb.com/kb/en/maxscale/),
a database proxy that extends the functionality of MariaDB/MySQL servers.

**Key Features:**

- **Two configuration approaches** — hash-based (main class) *and* defined types
  (config.d), fully combinable
- **Virtual & collected resources** — defined types enable `@maxscale::config::server`
  and `realize()` patterns, exported resources, and dynamic loops
- **Forward compatible** — open hash parameters pass any key/value through to MaxScale
  config files without module changes
- **Modern Puppet practices** — EPP templates, strong typing, Puppet 7/8 syntax, `contain`
- **Repository management** — optional official MariaDB repository setup
- **Sensitive data handling** — passwords support Puppet's `Sensitive` type

## Setup

### Requirements

- Puppet >= 7.0.0
- puppetlabs/stdlib >= 8.0.0
- puppetlabs/apt >= 9.0.0 (for Debian-based systems)

### Beginning with maxscale

```puppet
class { 'maxscale':
  manage_repo => true,
}
```

## Usage

### Approach 1: Hash-Based (Main Config File)

All components are defined as hashes and rendered into `/etc/maxscale.cnf`.
Best for static setups where all config is known at declaration time.

```puppet
class { 'maxscale':
  manage_repo    => true,
  repo_version   => '24.02',
  global_options => {
    'threads'          => 'auto',
    'admin_host'       => '127.0.0.1',
    'admin_port'       => 8989,
    'admin_secure_gui' => false,
  },
  servers => {
    'db-master' => { 'address' => '192.168.1.10', 'port' => 3306, 'priority' => 1 },
    'db-slave1' => { 'address' => '192.168.1.11', 'port' => 3306, 'priority' => 2 },
  },
  monitors => {
    'MariaDB-Monitor' => {
      'module'         => 'mariadbmon',
      'servers'        => 'db-master,db-slave1',
      'user'           => 'maxscale',
      'password'       => Sensitive('secret'),
      'auto_failover'  => true,
      'auto_rejoin'    => true,
    },
  },
  services => {
    'RW-Service' => {
      'router'  => 'readwritesplit',
      'servers' => 'db-master,db-slave1',
      'user'    => 'maxscale',
      'password' => Sensitive('secret'),
    },
  },
  listeners => {
    'RW-Listener' => {
      'service'  => 'RW-Service',
      'protocol' => 'MariaDBClient',
      'port'     => 4006,
    },
  },
}
```

### Approach 2: Defined Types (Config.d Files)

Each component gets its own file in `/etc/maxscale.cnf.d/`. This enables
virtual resources, collected resources, and dynamic loops — perfect when
server lists come from external sources like PuppetDB, Hiera lookups, or
other modules.

```puppet
include maxscale

# Basic server definitions
maxscale::config::server { 'db1':
  address => '192.168.1.10',
  port    => 3306,
}

maxscale::config::server { 'db2':
  address => '192.168.1.11',
  port    => 3306,
}

# Monitor
maxscale::config::monitor { 'MariaDB-Monitor':
  module   => 'mariadbmon',
  servers  => 'db1,db2',
  user     => 'maxscale',
  password => Sensitive('secret'),
  options  => {
    'auto_failover'    => true,
    'auto_rejoin'      => true,
    'monitor_interval' => '2000ms',
  },
}

# Service
maxscale::config::service { 'RW-Service':
  router   => 'readwritesplit',
  servers  => 'db1,db2',
  user     => 'maxscale',
  password => Sensitive('secret'),
}

# Listener
maxscale::config::listener { 'RW-Listener':
  service  => 'RW-Service',
  protocol => 'MariaDBClient',
  port     => 4006,
}
```

### Virtual Resources

Perfect for setups where server definitions come from multiple places:

```puppet
# In a profile or base class — declare virtual resources
@maxscale::config::server { 'db-master':
  address => '192.168.1.10',
  port    => 3306,
}

@maxscale::config::server { 'db-slave1':
  address => '192.168.1.11',
  port    => 3306,
}

# Somewhere else — realize what you need
realize(Maxscale::Config::Server['db-master'])
realize(Maxscale::Config::Server['db-slave1'])
```

### Dynamic Loops from External Data

When your server list comes from Hiera, PuppetDB, or another data source:

```puppet
# From Hiera
$db_servers = lookup('myapp::db_servers', Hash, 'deep', {})

$db_servers.each |String $name, Hash $config| {
  maxscale::config::server { $name:
    address => $config['address'],
    port    => $config['port'],
    options => pick($config['options'], {}),
  }
}
```

### Combining Both Approaches

Hash-based config goes into `maxscale.cnf`, defined types create files in
`maxscale.cnf.d/`. Both are loaded by MaxScale.

```puppet
# Global settings and static components in the main config
class { 'maxscale':
  manage_repo    => true,
  global_options => { 'threads' => 'auto' },
  monitors => {
    'MariaDB-Monitor' => {
      'module'  => 'mariadbmon',
      'servers' => 'db1,db2',
      'user'    => 'maxscale',
      'password' => Sensitive('secret'),
    },
  },
}

# Servers added dynamically from another source
$servers_from_hiera.each |$name, $cfg| {
  maxscale::config::server { $name:
    address => $cfg['address'],
    port    => $cfg['port'],
  }
}
```

### Hiera Configuration

```yaml
---
maxscale::manage_repo: true
maxscale::repo_version: '24.02'

maxscale::global_options:
  threads: 'auto'
  log_info: false
  admin_host: '0.0.0.0'
  admin_port: 8989

maxscale::servers:
  db-master:
    address: '192.168.1.10'
    port: 3306
  db-slave:
    address: '192.168.1.11'
    port: 3306

maxscale::monitors:
  MariaDB-Monitor:
    module: 'mariadbmon'
    servers: 'db-master,db-slave'
    user: 'maxscale'
    password: ENC[PKCS7,...]
    auto_failover: true
    auto_rejoin: true

maxscale::services:
  RW-Service:
    router: 'readwritesplit'
    servers: 'db-master,db-slave'
    user: 'maxscale'
    password: ENC[PKCS7,...]

maxscale::listeners:
  RW-Listener:
    service: 'RW-Service'
    protocol: 'MariaDBClient'
    port: 4006
```

### Forward Compatibility

Any MaxScale parameter can be passed — either as a direct key in the hash
(main class) or via the `options` hash (defined types). No module update
needed when MaxScale adds new parameters:

```puppet
maxscale::config::monitor { 'My-Monitor':
  module   => 'mariadbmon',
  servers  => 'db1,db2',
  user     => 'maxscale',
  password => Sensitive('secret'),
  options  => {
    'some_future_parameter'  => 'value',
    'another_new_option'     => true,
  },
}
```

## Reference

### Main Class Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `package_name` | String | `'maxscale'` | Name of the MaxScale package |
| `package_version` | String | `'installed'` | Package version to install |
| `service_ensure` | Enum | `'running'` | Service state |
| `service_enable` | Boolean | `true` | Enable service at boot |
| `manage_repo` | Boolean | `false` | Manage MariaDB repository |
| `repo_version` | String | `'24.02'` | MaxScale repository version |
| `config_d_dir` | String | `'maxscale.cnf.d'` | Config.d directory name |
| `manage_user` | Boolean | `false` | Manage the maxscale system user |
| `global_options` | Hash | `{...}` | Global [maxscale] section options |
| `servers` | Hash | `{}` | Server definitions (main config) |
| `monitors` | Hash | `{}` | Monitor definitions (main config) |
| `services` | Hash | `{}` | Service definitions (main config) |
| `listeners` | Hash | `{}` | Listener definitions (main config) |
| `filters` | Hash | `{}` | Filter definitions (main config) |

### Defined Types

| Type | Required Parameters | Description |
|------|-------------------|-------------|
| `maxscale::config::server` | `address` | Creates a server config in config.d |
| `maxscale::config::monitor` | `module`, `servers` | Creates a monitor config in config.d |
| `maxscale::config::service` | `router` | Creates a service config in config.d |
| `maxscale::config::listener` | `service`, `protocol` | Creates a listener config in config.d |
| `maxscale::config::filter` | `module` | Creates a filter config in config.d |

All defined types accept an `options` hash for arbitrary additional parameters.

## Limitations

- Supported on Debian 11/12, Ubuntu 22.04/24.04, RHEL 8/9, Rocky 8/9, AlmaLinux 8/9
- Requires Puppet 7 or 8
- ARM64 architecture support depends on MaxScale repository availability

## Development

```bash
pdk validate
pdk test unit
```

## Authors

- Philipp Frik <kotty@guns-n-girls.de>

## License

Apache-2.0
