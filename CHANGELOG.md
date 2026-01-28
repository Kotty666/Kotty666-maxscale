# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2025-01-28

### Added
- Complete module rewrite with modern Puppet practices
- Flexible hash-based configuration for all MaxScale components
- Support for all current and future MaxScale parameters via `options` hash
- EPP templates for better type safety
- Custom Puppet types for Server, Monitor, Service, Listener, and Filter
- Support for Sensitive data type for passwords
- Support for extra configuration files
- Updated OS support: Debian 11/12, Ubuntu 22.04/24.04, RHEL/Rocky/Alma 8/9
- Modern repository URLs for MaxScale 24.02

### Changed
- **BREAKING**: Complete rewrite of all parameters
- **BREAKING**: Removed individual parameters in favor of hash-based configuration
- **BREAKING**: Changed from ERB to EPP templates
- **BREAKING**: Minimum Puppet version now 7.0.0
- Replaced `create_resources` with native iteration
- Replaced `::class` syntax with modern `contain`
- Updated puppetlabs/apt dependency to >= 9.0.0
- Updated puppetlabs/stdlib dependency to >= 8.0.0
- Removed puppetlabs/concat dependency (no longer needed)
- Removed puppet/yum dependency (using native yumrepo)

### Removed
- Direct install functionality (can be re-added if needed)
- Legacy parameter support
- ERB templates
- Support for EOL operating systems

### Migration Guide

The 3.0.0 release is a complete rewrite. Migration from 2.x requires updating your configuration to use the new hash-based approach.

**Before (2.x):**
```puppet
class { 'maxscale':
  threads              => 4,
  auth_connect_timeout => '3s',
  auth_read_timeout    => '1s',
}

maxscale::config::server { 'db1':
  address => '192.168.1.10',
  port    => 3306,
}

maxscale::config::monitor { 'Monitor':
  module  => 'mariadbmon',
  servers => 'db1',
  user    => 'maxscale',
  password=> 'secret',
}
```

**After (3.0.0):**
```puppet
class { 'maxscale':
  global_options => {
    'threads' => 4,
  },
  servers => {
    'db1' => {
      'address' => '192.168.1.10',
      'port'    => 3306,
    },
  },
  monitors => {
    'Monitor' => {
      'module'   => 'mariadbmon',
      'servers'  => 'db1',
      'user'     => 'maxscale',
      'password' => Sensitive('secret'),
    },
  },
}
```

## [2.4.1] - 2023-12-05

### Fixed
- Minor bug fixes

## [2.4.0] - 2023-06-15

### Added
- Initial public release
