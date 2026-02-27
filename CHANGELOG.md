# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0] - 2025-XX-XX

### Added
- Complete module rewrite with modern Puppet practices
- **Defined types** (`maxscale::config::server`, `maxscale::config::monitor`,
  `maxscale::config::listener`, `maxscale::config::service`, `maxscale::config::filter`)
  for individual component config files — enabling virtual resources, collected
  resources, and dynamic loops from external data sources
- `config.d` directory with automatic purging of unmanaged files
- Flexible, open `Hash`-based configuration — any key/value pair is passed
  through to the config file, ensuring forward compatibility with all current
  and future MaxScale versions without module changes
- EPP templates for better type safety
- Support for Sensitive data type for passwords
- Support for extra configuration files
- `manage_user` parameter to optionally manage the maxscale system user
- Updated OS support: Debian 11/12, Ubuntu 22.04/24.04, RHEL/Rocky/Alma 8/9
- Modern repository URLs for MaxScale 24.02
- Proper class ordering: install → config → service

### Changed
- **BREAKING**: Complete rewrite of all parameters
- **BREAKING**: Changed from ERB to EPP templates
- **BREAKING**: Minimum Puppet version now 7.0.0
- **BREAKING**: Removed individual parameters in favor of hash-based configuration
- **BREAKING**: Removed strict `Struct`-based custom types in favor of open Hashes
  for true forward compatibility
- Replaced `create_resources` with native iteration
- Replaced `::class` syntax with modern `contain`
- Replaced `concat`-based config assembly with single EPP template + config.d files
- Updated puppetlabs/apt dependency to >= 9.0.0
- Updated puppetlabs/stdlib dependency to >= 8.0.0
- `manage_user` defaults to `false` (the package creates the user)

### Removed
- `puppetlabs/concat` dependency (no longer needed)
- `puppet/yum` dependency (using native yumrepo)
- Strict `Struct` type aliases (Maxscale::Server, etc.) — replaced by open Hashes
- Direct install functionality (can be re-added if needed)
- Legacy parameter support
- ERB templates
- Support for EOL operating systems

### Migration Guide

The 3.0.0 release is a complete rewrite. Both the old `create_resources`-based
approach and the old individual-parameter approach are replaced.

**Before (2.x) — using defined types:**
```puppet
include maxscale

maxscale::config::server { 'db1':
  address  => '192.168.1.10',
  port     => 3306,
  protocol => 'MySQLBackend',
}

maxscale::config::monitor { 'Monitor':
  module   => 'mariadbmon',
  servers  => 'db1',
  user     => 'maxscale',
  password => 'secret',
}
```

**After (3.0.0) — using defined types (same pattern, modernized):**
```puppet
include maxscale

maxscale::config::server { 'db1':
  address => '192.168.1.10',
  port    => 3306,
}

maxscale::config::monitor { 'Monitor':
  module   => 'mariadbmon',
  servers  => 'db1',
  user     => 'maxscale',
  password => Sensitive('secret'),
  options  => {
    'auto_failover' => true,
  },
}
```

**After (3.0.0) — using hash-based main class:**
```puppet
class { 'maxscale':
  servers => {
    'db1' => { 'address' => '192.168.1.10', 'port' => 3306 },
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
