# maxscale

[![Puppet Forge](https://img.shields.io/puppetforge/v/kotty666/maxscale.svg)](https://forge.puppet.com/kotty666/maxscale)
[![License](https://img.shields.io/github/license/Kotty666/puppet-maxscale.svg)](LICENSE)

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
    * [Requirements](#requirements)
    * [Beginning with maxscale](#beginning-with-maxscale)
3. [Usage](#usage)
    * [Basic Installation](#basic-installation)
    * [Full Configuration Example](#full-configuration-example)
    * [MariaDB Monitor with Auto-Failover](#mariadb-monitor-with-auto-failover)
    * [Galera Cluster Configuration](#galera-cluster-configuration)
    * [Read-Write Split with SSL](#read-write-split-with-ssl)
    * [Using Filters](#using-filters)
    * [Extra Configuration Files](#extra-configuration-files)
4. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)

## Description

This Puppet module manages the installation and configuration of [MariaDB MaxScale](https://mariadb.com/kb/en/maxscale/), 
a database proxy that extends the functionality of MariaDB/MySQL servers.

**Key Features:**

- **Flexible, hash-based configuration** - All parameters are passed through without hardcoding, allowing support for any current or future MaxScale options
- **Modern Puppet practices** - Uses EPP templates, strong typing, and Puppet 7/8 syntax
- **Repository management** - Optionally configures official MariaDB repositories
- **Support for all MaxScale components** - Servers, Monitors, Services, Listeners, and Filters
- **Sensitive data handling** - Passwords can use Puppet's `Sensitive` type

## Setup

### Requirements

- Puppet >= 7.0.0
- puppetlabs/stdlib >= 8.0.0
- puppetlabs/apt >= 9.0.0 (for Debian-based systems)

### Beginning with maxscale

The simplest way to get started is:

```puppet
class { 'maxscale':
  manage_repo => true,
}
```

This will install MaxScale from the official MariaDB repository with default settings.

## Usage

### Basic Installation

Install MaxScale without repository management (assumes package is available):

```puppet
include maxscale
```

### Full Configuration Example

A complete configuration with servers, monitor, service, and listener:

```puppet
class { 'maxscale':
  manage_repo    => true,
  repo_version   => '24.02',
  global_options => {
    'threads'              => 'auto',
    'log_info'             => false,
    'log_warning'          => true,
    'admin_host'           => '127.0.0.1',
    'admin_port'           => 8989,
    'admin_secure_gui'     => false,
  },
  servers        => {
    'db-master' => {
      'address'  => '192.168.1.10',
      'port'     => 3306,
      'priority' => 1,
    },
    'db-slave1' => {
      'address'  => '192.168.1.11',
      'port'     => 3306,
      'priority' => 2,
    },
    'db-slave2' => {
      'address'  => '192.168.1.12',
      'port'     => 3306,
      'priority' => 3,
    },
  },
  monitors       => {
    'MariaDB-Monitor' => {
      'module'             => 'mariadbmon',
      'servers'            => 'db-master,db-slave1,db-slave2',
      'user'               => 'maxscale_monitor',
      'password'           => Sensitive('monitor_secret'),
      'monitor_interval'   => '2000ms',
      'auto_failover'      => true,
      'auto_rejoin'        => true,
      'enforce_read_only_slaves' => true,
    },
  },
  services       => {
    'Read-Write-Service' => {
      'router'                => 'readwritesplit',
      'servers'               => 'db-master,db-slave1,db-slave2',
      'user'                  => 'maxscale_router',
      'password'              => Sensitive('router_secret'),
      'master_accept_reads'   => false,
      'max_slave_connections' => '100%',
      'causal_reads'          => 'local',
    },
  },
  listeners      => {
    'Read-Write-Listener' => {
      'service'  => 'Read-Write-Service',
      'protocol' => 'MariaDBClient',
      'port'     => 4006,
      'address'  => '0.0.0.0',
    },
  },
}
```

### MariaDB Monitor with Auto-Failover

Configure automatic failover for MariaDB replication:

```puppet
class { 'maxscale':
  monitors => {
    'MariaDB-Monitor' => {
      'module'                 => 'mariadbmon',
      'servers'                => 'db1,db2,db3',
      'user'                   => 'maxscale',
      'password'               => Sensitive('secret'),
      'monitor_interval'       => '2000ms',
      'auto_failover'          => true,
      'auto_rejoin'            => true,
      'failcount'              => 3,
      'failover_timeout'       => '90s',
      'switchover_timeout'     => '90s',
      'verify_master_failure'  => true,
      'master_failure_timeout' => '30s',
      'replication_user'       => 'repl_user',
      'replication_password'   => Sensitive('repl_secret'),
      'cooperative_monitoring_locks' => 'majority_of_running',
    },
  },
}
```

### Galera Cluster Configuration

Configure MaxScale for a Galera cluster:

```puppet
class { 'maxscale':
  servers  => {
    'galera1' => { 'address' => '192.168.1.10', 'port' => 3306 },
    'galera2' => { 'address' => '192.168.1.11', 'port' => 3306 },
    'galera3' => { 'address' => '192.168.1.12', 'port' => 3306 },
  },
  monitors => {
    'Galera-Monitor' => {
      'module'                    => 'galeramon',
      'servers'                   => 'galera1,galera2,galera3',
      'user'                      => 'maxscale',
      'password'                  => Sensitive('secret'),
      'monitor_interval'          => '2000ms',
      # Additional options via the options hash
      'options'                   => {
        'disable_master_failback' => true,
        'use_priority'            => true,
      },
    },
  },
  services => {
    'Galera-RW' => {
      'router'  => 'readwritesplit',
      'servers' => 'galera1,galera2,galera3',
      'user'    => 'maxscale',
      'password'=> Sensitive('secret'),
    },
    'Galera-RR' => {
      'router'         => 'readconnroute',
      'servers'        => 'galera1,galera2,galera3',
      'router_options' => 'synced',
      'user'           => 'maxscale',
      'password'       => Sensitive('secret'),
    },
  },
  listeners => {
    'Galera-RW-Listener' => {
      'service'  => 'Galera-RW',
      'protocol' => 'MariaDBClient',
      'port'     => 4006,
    },
    'Galera-RR-Listener' => {
      'service'  => 'Galera-RR',
      'protocol' => 'MariaDBClient',
      'port'     => 4007,
    },
  },
}
```

### Read-Write Split with SSL

Configure SSL-encrypted connections:

```puppet
class { 'maxscale':
  servers   => {
    'db1' => {
      'address'  => '192.168.1.10',
      'port'     => 3306,
      'ssl'      => true,
      'ssl_cert' => '/etc/maxscale/ssl/client-cert.pem',
      'ssl_key'  => '/etc/maxscale/ssl/client-key.pem',
      'ssl_ca'   => '/etc/maxscale/ssl/ca-cert.pem',
    },
  },
  listeners => {
    'SSL-Listener' => {
      'service'   => 'RW-Service',
      'protocol'  => 'MariaDBClient',
      'port'      => 4006,
      'ssl'       => true,
      'ssl_cert'  => '/etc/maxscale/ssl/server-cert.pem',
      'ssl_key'   => '/etc/maxscale/ssl/server-key.pem',
      'ssl_ca'    => '/etc/maxscale/ssl/ca-cert.pem',
      'ssl_version' => 'TLSv12',
    },
  },
}
```

### Using Filters

Add query logging and other filters:

```puppet
class { 'maxscale':
  filters  => {
    'QueryLog' => {
      'module'   => 'qlafilter',
      'filebase' => '/var/log/maxscale/queries',
      'log_type' => 'unified',
      'flush'    => true,
    },
    'Throttle' => {
      'module'              => 'throttlefilter',
      'max_qps'             => 500,
      'throttling_duration' => '10s',
      'sampling_duration'   => '250ms',
    },
  },
  services => {
    'RW-Service' => {
      'router'  => 'readwritesplit',
      'servers' => 'db1,db2',
      'user'    => 'maxscale',
      'password'=> Sensitive('secret'),
      'filters' => 'QueryLog|Throttle',
    },
  },
}
```

### Extra Configuration Files

Create additional configuration files for modular setups:

```puppet
class { 'maxscale':
  extra_config_files => {
    'servers.cnf' => {
      'db1' => {
        'type'    => 'server',
        'address' => '192.168.1.10',
        'port'    => 3306,
      },
      'db2' => {
        'type'    => 'server',
        'address' => '192.168.1.11',
        'port'    => 3306,
      },
    },
  },
}
```

### Using Hiera

Example Hiera configuration:

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

### Using the `options` Hash for Unknown Parameters

Each component type supports an `options` hash for parameters not explicitly defined in the type. This ensures forward compatibility with new MaxScale versions:

```puppet
class { 'maxscale':
  monitors => {
    'My-Monitor' => {
      'module'  => 'mariadbmon',
      'servers' => 'db1,db2',
      'user'    => 'maxscale',
      'password'=> Sensitive('secret'),
      # Use options for parameters not in the type definition
      'options' => {
        'some_new_parameter'    => 'value',
        'another_future_option' => true,
      },
    },
  },
}
```

## Reference

See [REFERENCE.md](REFERENCE.md) for detailed parameter documentation (generated with `puppet strings`).

### Main Class Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `package_name` | String | `'maxscale'` | Name of the MaxScale package |
| `package_version` | String | `'installed'` | Package version to install |
| `service_ensure` | Enum | `'running'` | Service state |
| `service_enable` | Boolean | `true` | Enable service at boot |
| `manage_repo` | Boolean | `false` | Manage MariaDB repository |
| `repo_version` | String | `'24.02'` | MaxScale repository version |
| `global_options` | Hash | `{...}` | Global [maxscale] section options |
| `servers` | Hash | `{}` | Server definitions |
| `monitors` | Hash | `{}` | Monitor definitions |
| `services` | Hash | `{}` | Service definitions |
| `listeners` | Hash | `{}` | Listener definitions |
| `filters` | Hash | `{}` | Filter definitions |

## Limitations

- Supported on Debian 11/12, Ubuntu 22.04/24.04, RHEL 8/9, Rocky 8/9, AlmaLinux 8/9
- Requires Puppet 7 or 8
- ARM64 architecture support depends on MaxScale repository availability

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for your changes
4. Submit a pull request

### Testing

```bash
# Run syntax checks
pdk validate

# Run unit tests
pdk test unit

# Run acceptance tests (requires Docker)
pdk test unit --parallel
```

## Authors

- Philipp Frik <kotty@guns-n-girls.de>

## License

Apache-2.0
