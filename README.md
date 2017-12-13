# maxscale
[![Puppet Forge](http://img.shields.io/puppetforge/v/Kotty666/maxscale.svg)](https://forge.puppetlabs.com/Kotty666/maxscale)
[![Github Tag](https://img.shields.io/github/tag/Kotty666/Kotty666-maxscale.svg)](https://github.com/Kotty666/Kotty666-maxscale)
[![Build Status](https://travis-ci.org/Kotty666/Kotty666-maxscale.png?branch=master)](https://travis-ci.org/Kotty666/Kotty666-maxscale)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with maxscale](#setup)
    * [What maxscale affects](#what-maxscale-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with maxscale](#beginning-with-maxscale)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)
6. [Contributers](#contributers)

## Description

Puppetmodule for installing and configuring the MaxScale database gateway which
is developed by the MariaDB.

## Setup

### What maxscale affects

* Installs maxscale in version 2.1.11
* overrides /etc/maxscale.cnf
* adds per default the mariadb-maxscale repository and its key to the system

### Setup Requirements 

* the module requires:
  - puppetlabs-stdlib
  - puppetlabs-apt (only if you wish to use the repo management)
  - puppetlabs-concat

### Beginning with maxscale

This code will
* install maxscale from the mariadb repo
* configure a galera monitor
* adds 2 sample servers
* adds a Maxscale CLI Listener
* adds the Maxscale CLI Service

```puppet
# add the default configuration and Package installation
include maxscale

# Configure the Galera Monitor to check the Nodes
::maxscale::config::monitor{"Galera":
  module  => 'galeramon',
  servers => 'mydb01,mydb02',
  user    => 'Monitor',
  passwd  => 'SamplePassword',
}

# Create the Server resources
::maxscale::config::server{"mydb01":
  address => '192.168.0.1',
}
::maxscale::config::server{"mydb02":
  address => '192.168.0.2',
}

# Create the Commandlineinterface Service
::maxscale::config::service{"CLI":
  router => "cli",
}

# Add the connection Listener for the CLI Service
::maxscale::config::listener{"CLI Listener":
  service  => "CLI",
  protocol => "maxscaled",
  address  => "localhost",
  port     => 6603,
}
```

## Usage

### Using the default values:
```puppet
include maxscale
```
### Variables and Default values for the Package and main configuration
```puppet
class {'maxscale':
  package_name              => 'maxscale',
  setup_mariadb_repository  => true,
  service_enable            => true,
  threads                   => 'auto',
  auth_connect_timeout      => 3,
  auth_read_timeout         => 1,
  auth_write_timeout        => 2,
  ms_timestamp              => 0,
  syslog                    => 0,
  maxlog                    => 1,
  log_to_shm                => 0,
  log_warning               => 1,
  log_notice                => 0,
  log_info                  => 0,
  log_debug                 => 0,
  log_augmentation          => 0,
  logdir                    => '/var/log/maxscale/',
  datadir                   => '/var/lib/maxscale/data/',
  cachedir                  => '/var/cache/maxscale/',
  piddir                    =>  '/var/run/maxscale/',
  configdir                 => '/etc',
}
```

### Configuration and default values for a Listener
```puppet
::maxscale::config::listener{"Listener Name":
  service,
  protocol,
  port,
  socket => undef,
  address => undef,
  ssl => undef,
  ssl_key => undef,
  ssl_cert => undef,
  ssl_ca_cert => undef,
  ssl_version => undef,
  ssl_cert_verification_depth => undef,
}
```
### Configuration and default values for a Monitor
```puppet
::maxscale::config::monitor{"Monitor Name":
  module,
  servers,
  user => undef,
  passwd => undef,
  monitor_interval => undef,
  backend_connect_timeout => undef,
  backend_write_timeout => undef,
  backend_read_timeout => undef,
}
```

### Configuration and default values for a Server
```puppet
::maxscale::config::server{"ServerName":
  address,
  port => 3306,
  protocol => 'MySQLBackend',
  monitoruser => undef,
  monitorpw => undef,
  persistpoolmax => undef,
  persistmaxtime => undef,
  serv_weight => undef,
}
```

### Configuration and default values for a Service
```puppet
::maxscale::config::service{"ServiceName":
  router,
  servers => undef,
  router_options => undef,
  filters => undef,
  user => undef,
  passwd => undef,
  enable_root_user => 0,
  localhost_match_wildcard_host => 1,
  version_string=>'MaxScale',
  weightby => undef,
  auth_all_servers => 1,
  strip_db_esc => 1,
  optimize_wildcard => 1,
  retry_on_failure => 1,
  log_auth_warnings => 0,
  connection_timeout => undef,
  max_slave_connections => undef,
  max_slave_replication_lag => undef,
  use_sql_variables_in => undef,
}
```


## Limitations

Tested on Debian wheezy and jessie with maxscale version 1.4.1 (GA), this should also work on Ubuntu 12.04, 14.04, 15.10

## Development
If you have whishes for features let me know.

### Contributers

**Release**  | **PR/Issue**                                        | **Contributer**
-------------|-----------------------------------------------------|----------------------------------------------------
1.0.0        |                                                     | [@Kotty666](https://github.com/Kotty666)
