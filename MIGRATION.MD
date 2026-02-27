# Migration Guide: v2.x → v3.0.0

Dieses Dokument beschreibt alle notwendigen Schritte, um von der alten Version (2.x / main Branch)
auf die neue Version (3.0.0) zu migrieren.

> **Wichtig:** Version 3.0.0 ist ein kompletter Rewrite. Es gibt keine automatische
> Rückwärtskompatibilität. Alle Manifests und Hiera-Daten müssen angepasst werden.

---

## Inhaltsverzeichnis

1. [Voraussetzungen prüfen](#1-voraussetzungen-prüfen)
2. [Dependencies anpassen](#2-dependencies-anpassen)
3. [Hauptklasse migrieren](#3-hauptklasse-migrieren)
    - [3.1 Parameter-Mapping](#31-parameter-mapping-hauptklasse)
    - [3.2 Beispiel: Globale Optionen](#32-beispiel-hauptklasse)
    - [3.3 Hash-basierte Komponenten (create_resources-Pattern)](#33-hash-basierte-komponenten-über-die-hauptklasse-create_resources-pattern)
    - [3.4 Hiera-Kurzreferenz für das Hash-Pattern](#34-hiera-kurzreferenz-für-das-hash-pattern)
4. [Defined Types migrieren](#4-defined-types-migrieren)
5. [Hiera-Daten migrieren](#5-hiera-daten-migrieren)
6. [Entfernte Features](#6-entfernte-features)
7. [Neue Features](#7-neue-features)
8. [Vollständiges Vorher/Nachher Beispiel](#8-vollständiges-vorhernachher-beispiel)
9. [Checkliste](#9-checkliste)

---

## 1. Voraussetzungen prüfen

| Anforderung | v2.x | v3.0.0 |
|-------------|------|--------|
| Puppet | 5+ | **7.0.0+** |
| puppetlabs/stdlib | 4.x+ | **8.0.0+** |
| puppetlabs/apt | 4.x+ | **9.0.0+** |
| puppetlabs/concat | **erforderlich** | **nicht mehr nötig** |
| puppet/yum | erforderlich (RedHat) | **nicht mehr nötig** |

**Aktion:** `puppetlabs/concat` und `puppet/yum` können aus der `metadata.json` und dem
Puppetfile entfernt werden, sofern sie nicht von anderen Modulen benötigt werden.

---

## 2. Dependencies anpassen

### Puppetfile

```ruby
# ALT
mod 'puppetlabs/concat', '7.x'
mod 'puppet/yum', '6.x'
mod 'kotty666/maxscale', '2.x'

# NEU
mod 'kotty666/maxscale', '3.0.0'
# concat und puppet/yum werden nicht mehr benötigt (durch maxscale)
```

### metadata.json (wenn du das Modul als Dependency nutzt)

```json
// ALT
{ "name": "puppetlabs/concat", "version_requirement": ">= 4.0.0 < 8.0.0" }

// NEU — diese Zeile komplett entfernen
```

---

## 3. Hauptklasse migrieren

Die Hauptklasse hat sich fundamental geändert. Individuelle Parameter wurden durch
einen `global_options`-Hash ersetzt, und alle anderen Parameter wurden umbenannt.

### 3.1 Parameter-Mapping (Hauptklasse)

| v2.x Parameter | v3.0.0 Äquivalent | Hinweis |
|----------------|-------------------|---------|
| `$threads` | `global_options => { 'threads' => ... }` | Jetzt im Hash |
| `$auth_connect_timeout` | `global_options => { 'auth_connect_timeout' => ... }` | Jetzt im Hash |
| `$auth_read_timeout` | `global_options => { 'auth_read_timeout' => ... }` | Jetzt im Hash |
| `$auth_write_timeout` | `global_options => { 'auth_write_timeout' => ... }` | Jetzt im Hash |
| `$ms_timestamp` | `global_options => { 'ms_timestamp' => ... }` | Jetzt im Hash |
| `$syslog` | `global_options => { 'syslog' => ... }` | Jetzt Boolean statt Integer |
| `$maxlog` | `global_options => { 'maxlog' => ... }` | Jetzt Boolean statt Integer |
| `$log_warning` | `global_options => { 'log_warning' => ... }` | Jetzt Boolean statt Integer |
| `$log_notice` | `global_options => { 'log_notice' => ... }` | Jetzt Boolean statt Integer |
| `$log_info` | `global_options => { 'log_info' => ... }` | Jetzt Boolean statt Integer |
| `$log_debug` | `global_options => { 'log_debug' => ... }` | Jetzt Boolean statt Integer |
| `$log_augmentation` | `global_options => { 'log_augmentation' => ... }` | Jetzt Boolean statt Integer |
| `$max_auth_errors_until_block` | `global_options => { 'max_auth_errors_until_block' => ... }` | Jetzt im Hash |
| `$logdir` | `$log_dir` | Umbenannt, kein trailing slash |
| `$datadir` | `$data_dir` | Umbenannt, kein trailing slash |
| `$cachedir` | `$cache_dir` | Umbenannt |
| `$piddir` | `$pid_dir` | Umbenannt |
| `$configdir` | `$config_dir` | Umbenannt |
| `$configfile` | `$config_file` | Umbenannt |
| `$max_user` | `$maxscale_user` | Umbenannt |
| `$max_group` | `$maxscale_group` | Umbenannt |
| `$setup_mariadb_repository` | `$manage_repo` | Umbenannt |
| `$repository_base_url` | `$repo_base_url` | Umbenannt |
| `$service_enable` (Boolean) | `$service_ensure` + `$service_enable` | Aufgeteilt in zwei Parameter |
| `$monitor` | `$monitors` | Umbenannt (Plural), neues Format |
| `$server` | `$servers` | Umbenannt (Plural), neues Format |
| `$service` | `$services` | Umbenannt (Plural), neues Format |
| `$listener` | `$listeners` | Umbenannt (Plural), neues Format |
| — | `$filters` | **Neu** |
| — | `$manage_user` | **Neu** (default: false) |
| — | `$config_d_dir` | **Neu** |
| — | `$manage_dirs` | **Neu** |
| — | `$extra_config_files` | **Neu** |
| — | `$repo_version` | **Neu** |
| `$gpg_key_id` | `$gpg_key_id` | Gleicher Name, neuer Standardwert |

### 3.2 Beispiel: Hauptklasse

```puppet
# ============================================================
# ALT (v2.x)
# ============================================================
class { 'maxscale':
  package_name             => 'maxscale',
  setup_mariadb_repository => true,
  service_enable           => true,
  threads                  => 4,
  auth_connect_timeout     => '3s',
  auth_read_timeout        => '1s',
  auth_write_timeout       => '2s',
  ms_timestamp             => 0,
  syslog                   => 0,
  maxlog                   => 1,
  log_warning              => 1,
  log_notice               => 0,
  log_info                 => 0,
  log_debug                => 0,
  log_augmentation         => 0,
  logdir                   => '/var/log/maxscale/',
  datadir                  => '/var/lib/maxscale/data/',
  cachedir                 => '/var/cache/maxscale/',
  piddir                   => '/var/run/maxscale/',
}

# ============================================================
# NEU (v3.0.0)
# ============================================================
class { 'maxscale':
  manage_repo    => true,
  service_ensure => 'running',
  service_enable => true,
  global_options => {
    'threads'                     => 4,
    'auth_connect_timeout'        => '3s',
    'auth_read_timeout'           => '1s',
    'auth_write_timeout'          => '2s',
    'ms_timestamp'                => false,
    'syslog'                      => false,
    'maxlog'                      => true,
    'log_warning'                 => true,
    'log_notice'                  => false,
    'log_info'                    => false,
    'log_debug'                   => false,
    'log_augmentation'            => false,
    'max_auth_errors_until_block' => 10,
  },
  log_dir        => '/var/log/maxscale',
  data_dir       => '/var/lib/maxscale',
  cache_dir      => '/var/cache/maxscale',
  pid_dir        => '/var/run/maxscale',
}
```

> **Hinweis:** Die meisten der oben genannten `global_options` haben sinnvolle Defaults
> in `data/common.yaml`. Du musst nur die Werte angeben, die du explizit ändern willst.
> Typischerweise reicht:
>
> ```puppet
> class { 'maxscale':
>   manage_repo    => true,
>   global_options => {
>     'threads' => 4,
>   },
> }
> ```

### 3.3 Hash-basierte Komponenten über die Hauptklasse (create_resources-Pattern)

In v2.x konnte man Server, Monitore, Services und Listener als Hashes direkt an die
Hauptklasse übergeben. Intern wurden diese per `create_resources()` in Defined Types
umgewandelt:

```puppet
# ALT (v2.x) — Hashes an die Hauptklasse übergeben
class { 'maxscale':
  setup_mariadb_repository => true,
  threads                  => 4,
  server => {
    'mydb01' => {
      'address'  => '192.168.0.1',
      'port'     => 3306,
      'protocol' => 'MySQLBackend',
    },
    'mydb02' => {
      'address'  => '192.168.0.2',
      'port'     => 3306,
      'protocol' => 'MySQLBackend',
    },
  },
  monitor => {
    'Galera' => {
      'module'   => 'galeramon',
      'servers'  => 'mydb01,mydb02',
      'user'     => 'Monitor',
      'password' => 'SamplePassword',
    },
  },
  service => {
    'RW-Service' => {
      'router'  => 'readwritesplit',
      'servers' => 'mydb01,mydb02',
      'user'    => 'maxscale',
      'password' => 'secret',
    },
  },
  listener => {
    'RW-Listener' => {
      'service'  => 'RW-Service',
      'protocol' => 'MariaDBClient',
      'port'     => 4006,
    },
  },
}
```

**Dieses Pattern funktioniert in v3.0.0 weiterhin** — mit folgenden Änderungen:

1. **Parameter sind jetzt Plural:** `server` → `servers`, `monitor` → `monitors`,
   `service` → `services`, `listener` → `listeners`
2. **Hash-Format ist offen:** Beliebige Key/Value-Paare werden direkt durchgereicht —
   kein `options`-Sub-Hash nötig (der ist nur bei Defined Types relevant)
3. **Unter der Haube:** Statt `create_resources()` → `concat::fragment` rendert jetzt
   ein EPP-Template die Hashes direkt in `maxscale.cnf`

```puppet
# NEU (v3.0.0) — gleiches Pattern, nur Plural + offene Hashes
class { 'maxscale':
  manage_repo    => true,
  global_options => {
    'threads' => 4,
  },
  servers => {                                  # war: server
    'mydb01' => {
      'address' => '192.168.0.1',
      'port'    => 3306,
      # 'protocol' nicht mehr nötig — MaxScale erkennt es automatisch
    },
    'mydb02' => {
      'address' => '192.168.0.2',
      'port'    => 3306,
    },
  },
  monitors => {                                 # war: monitor
    'Galera' => {
      'module'   => 'galeramon',
      'servers'  => 'mydb01,mydb02',
      'user'     => 'Monitor',
      'password' => Sensitive('SamplePassword'), # optional: Sensitive()
    },
  },
  services => {                                 # war: service
    'RW-Service' => {
      'router'   => 'readwritesplit',
      'servers'  => 'mydb01,mydb02',
      'user'     => 'maxscale',
      'password' => Sensitive('secret'),
    },
  },
  listeners => {                                # war: listener
    'RW-Listener' => {
      'service'  => 'RW-Service',
      'protocol' => 'MariaDBClient',
      'port'     => 4006,
    },
  },
}
```

> **Schnellregel:** Suche in deinem Code und Hiera nach `maxscale::server:`,
> `maxscale::monitor:`, `maxscale::service:` und `maxscale::listener:` und
> hänge jeweils ein `s` an. Die inneren Hash-Werte können so bleiben wie sie sind —
> veraltete MaxScale-Parameter (wie `protocol => 'MySQLBackend'`) solltest du bei
> der Gelegenheit gleich aufräumen.

### 3.4 Hiera-Kurzreferenz für das Hash-Pattern

```yaml
# ALT (v2.x)                          # NEU (v3.0.0)
maxscale::server:                      maxscale::servers:
  mydb01:                                mydb01:
    address: '192.168.0.1'               address: '192.168.0.1'
    port: 3306                           port: 3306
    protocol: 'MySQLBackend'           # protocol entfällt

maxscale::monitor:                     maxscale::monitors:
  Galera:                                Galera:
    module: 'galeramon'                    module: 'galeramon'
    servers: 'mydb01'                      servers: 'mydb01'
    user: 'Monitor'                        user: 'Monitor'
    password: 'secret'                     password: ENC[PKCS7,...]

maxscale::service:                     maxscale::services:
  RW-Service:                            RW-Service:
    router: 'readwritesplit'               router: 'readwritesplit'

maxscale::listener:                    maxscale::listeners:
  RW-Listener:                           RW-Listener:
    service: 'RW-Service'                  service: 'RW-Service'
    protocol: 'MariaDBClient'              protocol: 'MariaDBClient'
    port: 4006                             port: 4006
```

---

## 4. Defined Types migrieren

Die Defined Types existieren weiter, haben aber eine neue Signatur. Der Kernunterschied:

- **v2.x:** Jeder Parameter war ein eigener Define-Parameter → `concat::fragment` in einer Datei
- **v3.0.0:** Wenige Kernparameter + ein `options`-Hash → eigene Datei in `config.d/`

### 4.1 Server

```puppet
# ALT
::maxscale::config::server { 'mydb01':
  address        => '192.168.0.1',
  port           => 3306,
  protocol       => 'MySQLBackend',
  monitoruser    => 'monitor',
  monitorpw      => 'secret',
  persistpoolmax => 10,
  persistmaxtime => 600,
  serv_weight    => 1,
}

# NEU
maxscale::config::server { 'mydb01':
  address => '192.168.0.1',
  port    => 3306,
  options => {
    'protocol'       => 'MariaDBBackend',    # Hinweis: 'MySQLBackend' heißt jetzt 'MariaDBBackend'
    'monitoruser'    => 'monitor',
    'monitorpw'      => 'secret',
    'persistpoolmax' => 10,
    'persistmaxtime' => 600,
    'priority'       => 1,                   # Hinweis: 'serv_weight' durch 'priority' ersetzt (MaxScale 2.5+)
  },
}
```

**Entfernte Default-Werte:**

| v2.x Default | v3.0.0 |
|-------------|--------|
| `port => 3306` | Kein Default — explizit angeben wenn nötig |
| `protocol => 'MySQLBackend'` | Kein Default — MaxScale setzt selbst den richtigen Default |

> **Tipp:** Moderne MaxScale-Versionen (2.5+) benötigen `protocol` nicht mehr.
> MaxScale erkennt das Protokoll automatisch. Du kannst den Parameter weglassen.

### 4.2 Monitor

```puppet
# ALT
::maxscale::config::monitor { 'Galera':
  module                  => 'galeramon',
  servers                 => 'mydb01,mydb02',
  user                    => 'Monitor',
  password                => 'SamplePassword',
  monitor_interval        => 10000,
  backend_connect_timeout => 3,
  backend_write_timeout   => 3,
  backend_read_timeout    => 3,
}

# NEU
maxscale::config::monitor { 'Galera':
  module   => 'galeramon',
  servers  => 'mydb01,mydb02',
  user     => 'Monitor',
  password => Sensitive('SamplePassword'),    # Optional: Sensitive() verwenden
  options  => {
    'monitor_interval'        => '10000ms',   # Hinweis: MaxScale 2.5+ erwartet Zeiteinheit
    'backend_connect_timeout' => '3s',
    'backend_write_timeout'   => '3s',
    'backend_read_timeout'    => '3s',
  },
}
```

### 4.3 Service

```puppet
# ALT
::maxscale::config::service { 'RW-Service':
  router                       => 'readwritesplit',
  servers                      => 'mydb01,mydb02',
  user                         => 'maxscale',
  password                     => 'secret',
  enable_root_user             => 0,
  localhost_match_wildcard_host => 1,
  version_string               => 'MaxScale',
  auth_all_servers             => 1,
  strip_db_esc                 => 1,
  optimize_wildcard            => 1,
  retry_on_failure             => 1,
  log_auth_warnings            => 0,
  max_slave_connections        => '100%',
}

# NEU
maxscale::config::service { 'RW-Service':
  router   => 'readwritesplit',
  servers  => 'mydb01,mydb02',
  user     => 'maxscale',
  password => Sensitive('secret'),
  options  => {
    'enable_root_user'             => false,   # Jetzt Boolean statt Integer
    'localhost_match_wildcard_host' => true,
    'version_string'               => 'MaxScale',
    'auth_all_servers'             => true,
    'strip_db_esc'                 => true,
    'retry_on_failure'             => true,
    'log_auth_warnings'            => false,
    'max_slave_connections'        => '100%',
  },
}
```

> **Hinweis:** Viele dieser Parameter (`optimize_wildcard`, `strip_db_esc`, etc.)
> existieren in aktuellen MaxScale-Versionen (6.x+) nicht mehr. Prüfe die
> [MaxScale Dokumentation](https://mariadb.com/kb/en/maxscale/) für deine Version.

### 4.4 Listener

```puppet
# ALT
::maxscale::config::listener { 'RW-Listener':
  service                     => 'RW-Service',
  protocol                    => 'MariaDBClient',
  port                        => 4006,
  address                     => '0.0.0.0',
  ssl                         => 'required',
  ssl_key                     => '/etc/maxscale/ssl/server.key',
  ssl_cert                    => '/etc/maxscale/ssl/server.crt',
  ssl_ca_cert                 => '/etc/maxscale/ssl/ca.crt',
  ssl_version                 => 'TLSv12',
  ssl_cert_verification_depth => 9,
}

# NEU
maxscale::config::listener { 'RW-Listener':
  service  => 'RW-Service',
  protocol => 'MariaDBClient',
  port     => 4006,
  address  => '0.0.0.0',
  options  => {
    'ssl'                         => 'required',
    'ssl_key'                     => '/etc/maxscale/ssl/server.key',
    'ssl_cert'                    => '/etc/maxscale/ssl/server.crt',
    'ssl_ca'                      => '/etc/maxscale/ssl/ca.crt',      # Hinweis: 'ssl_ca_cert' → 'ssl_ca'
    'ssl_version'                 => 'TLSv12',
    'ssl_cert_verification_depth' => 9,
  },
}
```

**Umbenannte MaxScale-Parameter:**

| v2.x (MaxScale alt) | v3.0.0 / MaxScale aktuell |
|---------------------|---------------------------|
| `ssl_ca_cert` | `ssl_ca` |

### 4.5 Filter (NEU)

Filter waren in v2.x nicht als Defined Type vorhanden. In v3.0.0 gibt es
`maxscale::config::filter`:

```puppet
maxscale::config::filter { 'QueryLog':
  module  => 'qlafilter',
  options => {
    'filebase' => '/var/log/maxscale/queries',
    'log_type' => 'unified',
    'flush'    => true,
  },
}
```

---

## 5. Hiera-Daten migrieren

### 5.1 Globale Parameter

```yaml
# ============================================================
# ALT (v2.x)
# ============================================================
maxscale::setup_mariadb_repository: true
maxscale::service_enable: true
maxscale::threads: 4
maxscale::auth_connect_timeout: '3s'
maxscale::auth_read_timeout: '1s'
maxscale::auth_write_timeout: '2s'
maxscale::ms_timestamp: 0
maxscale::syslog: false
maxscale::maxlog: true
maxscale::log_warning: true
maxscale::log_info: false
maxscale::logdir: '/var/log/maxscale/'
maxscale::datadir: '/var/lib/maxscale/data/'
maxscale::cachedir: '/var/cache/maxscale/'
maxscale::piddir: '/var/run/maxscale/'
maxscale::configdir: '/etc'
maxscale::configfile: 'maxscale.cnf'
maxscale::max_user: 'maxscale'
maxscale::max_group: 'maxscale'

# ============================================================
# NEU (v3.0.0)
# ============================================================
maxscale::manage_repo: true
maxscale::service_ensure: 'running'
maxscale::service_enable: true
maxscale::repo_version: '24.02'

maxscale::global_options:
  threads: 4
  auth_connect_timeout: '3s'
  auth_read_timeout: '1s'
  auth_write_timeout: '2s'
  ms_timestamp: false
  syslog: false
  maxlog: true
  log_warning: true
  log_info: false

# Nur angeben, wenn vom Default abweichend:
# maxscale::log_dir: '/var/log/maxscale'
# maxscale::data_dir: '/var/lib/maxscale'
# maxscale::config_dir: '/etc'
# maxscale::config_file: 'maxscale.cnf'
# maxscale::maxscale_user: 'maxscale'
# maxscale::maxscale_group: 'maxscale'
```

### 5.2 Komponenten (Server, Monitor, etc.)

```yaml
# ============================================================
# ALT (v2.x) — für create_resources
# ============================================================
maxscale::server:
  mydb01:
    address: '192.168.0.1'
    port: 3306
    protocol: 'MySQLBackend'
  mydb02:
    address: '192.168.0.2'
    port: 3306
    protocol: 'MySQLBackend'

maxscale::monitor:
  Galera:
    module: 'galeramon'
    servers: 'mydb01,mydb02'
    user: 'Monitor'
    password: 'SamplePassword'

maxscale::service:
  CLI:
    router: 'cli'

maxscale::listener:
  CLI Listener:
    service: 'CLI'
    protocol: 'maxscaled'
    address: 'localhost'
    port: 6603

# ============================================================
# NEU (v3.0.0) — für Hash-basierte Hauptklasse
# ============================================================
maxscale::servers:
  mydb01:
    address: '192.168.0.1'
    port: 3306
  mydb02:
    address: '192.168.0.2'
    port: 3306

maxscale::monitors:
  Galera:
    module: 'galeramon'
    servers: 'mydb01,mydb02'
    user: 'Monitor'
    password: ENC[PKCS7,...]

maxscale::services:
  CLI:
    router: 'cli'

maxscale::listeners:
  CLI Listener:
    service: 'CLI'
    protocol: 'maxscaled'
    address: 'localhost'
    port: 6603
```

> **Hinweis:** Die Hash-Schlüssel haben sich von Singular (`server`, `monitor`, `service`,
> `listener`) zu Plural (`servers`, `monitors`, `services`, `listeners`) geändert.
> Das ist der häufigste Fehler bei der Migration!

---

## 6. Entfernte Features

### 6.1 Direct Install

Die `direct_install`-Funktionalität (Installation über URL statt Repository) wurde entfernt.

```puppet
# ALT — funktioniert NICHT mehr
maxscale::install::direct_install: true
maxscale::install::package_url: 'https://..../maxscale.deb'
```

Wenn du das benötigst, installiere das Paket vor dem `maxscale`-Modul über eine
eigene Puppet-Ressource.

### 6.2 Concat-basiertes Config-Assembly

Die gesamte Konfiguration wurde von `concat::fragment`-basiertem Assembly auf
EPP-Templates (Hauptconfig) + einzelne Dateien in `config.d/` (Defined Types) umgestellt.

### 6.3 ERB Templates

Alle ERB-Templates (`*.erb`) sind durch EPP-Templates (`*.epp`) ersetzt.

### 6.4 `::class` Syntax

Die veraltete `class { '::maxscale::install': ... }` Syntax wurde durch `contain` ersetzt.

### 6.5 Strikte Struct-Types

Die Custom Types (`Maxscale::Server`, `Maxscale::Monitor`, etc.) aus dem Zwischen-Refactor
wurden durch offene `Hash[String, Hash]` ersetzt. Das bedeutet **beliebige** Key/Value-Paare
werden durchgereicht — keine Modul-Änderung nötig wenn MaxScale neue Parameter einführt.

---

## 7. Neue Features

### 7.1 Config.d Verzeichnis

Defined Types erstellen jetzt einzelne Dateien in `/etc/maxscale.cnf.d/` statt
Fragmente in einer einzelnen Datei. Das Verzeichnis wird automatisch gemanaged
mit `purge => true` — nicht von Puppet verwaltete Dateien werden entfernt.

### 7.2 Virtual Resources & Collected Resources

```puppet
# Virtual Resources deklarieren
@maxscale::config::server { 'db1':
  address => '192.168.1.10',
}

# An anderer Stelle realisieren
realize(Maxscale::Config::Server['db1'])

# Oder per Collector (z.B. mit PuppetDB exported Resources)
Maxscale::Config::Server <<| tag == 'production' |>>
```

### 7.3 Dynamische Schleifen

```puppet
$servers_from_external = lookup('myapp::db_servers', Hash)

$servers_from_external.each |String $name, Hash $config| {
  maxscale::config::server { $name:
    address => $config['address'],
    port    => $config['port'],
    options => pick($config['options'], {}),
  }
}
```

### 7.4 `manage_user` Parameter

```puppet
class { 'maxscale':
  manage_user => true,   # Puppet verwaltet den User
  # manage_user => false, # Package verwaltet den User (Default)
}
```

### 7.5 `ensure => absent` auf Defined Types

```puppet
maxscale::config::server { 'old-server':
  address => '192.168.1.99',
  ensure  => 'absent',
}
```

### 7.6 Filter als Defined Type

```puppet
maxscale::config::filter { 'QueryLog':
  module  => 'qlafilter',
  options => { 'filebase' => '/var/log/maxscale/queries' },
}
```

### 7.7 Beide Ansätze kombinierbar

Hash-basierte Config (Hauptklasse) und Defined Types (config.d) können gleichzeitig
verwendet werden. Die Hauptklasse schreibt nach `/etc/maxscale.cnf`, die Defined Types
nach `/etc/maxscale.cnf.d/*.cnf`. MaxScale liest beides.

---

## 8. Vollständiges Vorher/Nachher Beispiel

### v2.x — Vollständiges Setup

```puppet
class { 'maxscale':
  setup_mariadb_repository => true,
  service_enable           => true,
  threads                  => 4,
}

::maxscale::config::server { 'mydb01':
  address => '192.168.0.1',
  port    => 3306,
}

::maxscale::config::server { 'mydb02':
  address => '192.168.0.2',
  port    => 3306,
}

::maxscale::config::monitor { 'Galera':
  module   => 'galeramon',
  servers  => 'mydb01,mydb02',
  user     => 'Monitor',
  password => 'SamplePassword',
}

::maxscale::config::service { 'RW-Service':
  router  => 'readwritesplit',
  servers => 'mydb01,mydb02',
  user    => 'maxscale',
  password => 'secret',
}

::maxscale::config::listener { 'RW-Listener':
  service  => 'RW-Service',
  protocol => 'MariaDBClient',
  port     => 4006,
}
```

### v3.0.0 — Äquivalent mit Defined Types

```puppet
class { 'maxscale':
  manage_repo    => true,
  global_options => {
    'threads' => 4,
  },
}

maxscale::config::server { 'mydb01':
  address => '192.168.0.1',
  port    => 3306,
}

maxscale::config::server { 'mydb02':
  address => '192.168.0.2',
  port    => 3306,
}

maxscale::config::monitor { 'Galera':
  module   => 'galeramon',
  servers  => 'mydb01,mydb02',
  user     => 'Monitor',
  password => Sensitive('SamplePassword'),
}

maxscale::config::service { 'RW-Service':
  router   => 'readwritesplit',
  servers  => 'mydb01,mydb02',
  user     => 'maxscale',
  password => Sensitive('secret'),
}

maxscale::config::listener { 'RW-Listener':
  service  => 'RW-Service',
  protocol => 'MariaDBClient',
  port     => 4006,
}
```

### v3.0.0 — Äquivalent rein Hash-basiert

```puppet
class { 'maxscale':
  manage_repo    => true,
  global_options => {
    'threads' => 4,
  },
  servers => {
    'mydb01' => { 'address' => '192.168.0.1', 'port' => 3306 },
    'mydb02' => { 'address' => '192.168.0.2', 'port' => 3306 },
  },
  monitors => {
    'Galera' => {
      'module'   => 'galeramon',
      'servers'  => 'mydb01,mydb02',
      'user'     => 'Monitor',
      'password' => Sensitive('SamplePassword'),
    },
  },
  services => {
    'RW-Service' => {
      'router'   => 'readwritesplit',
      'servers'  => 'mydb01,mydb02',
      'user'     => 'maxscale',
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

---

## 9. Checkliste

Arbeite diese Liste Punkt für Punkt ab:

- [ ] **Puppet Version** prüfen: mindestens 7.0.0
- [ ] **stdlib** aktualisieren: mindestens 8.0.0
- [ ] **apt** Modul aktualisieren: mindestens 9.0.0 (Debian/Ubuntu)
- [ ] **concat** Dependency entfernen (falls nur von maxscale benötigt)
- [ ] **puppet/yum** Dependency entfernen (falls nur von maxscale benötigt)
- [ ] `setup_mariadb_repository` → `manage_repo` umbenennen
- [ ] `service_enable` aufteilen in `service_ensure` + `service_enable`
- [ ] Alle individuellen Global-Parameter in `global_options`-Hash verschieben
- [ ] `logdir` → `log_dir` (ohne trailing slash)
- [ ] `datadir` → `data_dir` (ohne trailing slash)
- [ ] `cachedir` → `cache_dir`
- [ ] `piddir` → `pid_dir`
- [ ] `configdir` → `config_dir`
- [ ] `configfile` → `config_file`
- [ ] `max_user` → `maxscale_user`
- [ ] `max_group` → `maxscale_group`
- [ ] Hiera-Keys: `server` → `servers`, `monitor` → `monitors`, etc.
- [ ] `::maxscale::config::server` Aufrufe: `protocol` entfernen oder in `options` verschieben
- [ ] `::maxscale::config::server` Aufrufe: `monitoruser`/`monitorpw`/`serv_weight` in `options` verschieben
- [ ] `::maxscale::config::monitor` Aufrufe: Timeout-Werte mit Zeiteinheit versehen (`'3s'` statt `3`)
- [ ] `::maxscale::config::service` Aufrufe: Integer-Flags (0/1) durch Booleans ersetzen
- [ ] `::maxscale::config::listener` Aufrufe: `ssl_ca_cert` → `ssl_ca` (MaxScale Rename)
- [ ] `::` Prefix bei Defined Type Aufrufen entfernen (optional, aber empfohlen)
- [ ] Passwörter optional in `Sensitive()` wrappen
- [ ] `pdk validate` ausführen
- [ ] `pdk test unit` ausführen
- [ ] Auf einem Testknoten deployen und Konfiguration prüfen
- [ ] MaxScale-Service startet korrekt (`systemctl status maxscale`)
