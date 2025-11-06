#
# @summary
#   adds the repo to the system configuration
#
# @example
#   include maxscale::install::apt
#
# @param repository_version
# @param repository_base_url
# @param gpg_key_id
#
class maxscale::install::apt (
  String $repository_version  = 'latest',
  String $repository_base_url = "http://downloads.mariadb.com/MaxScale/${repository_version}/${downcase($facts['os']['name'])}/",
  String $gpg_key_id          = '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
) {
  unless $facts['os']['architecture'] == 'amd64' {
    fail('Architectures != amd64 are not supported by the maxscale package repository!')
  }

  apt::source { 'mariadb-maxscale' :
    architecture => 'amd64',
    location     => $repository_base_url,
    include      => {
      'src' => false,
      'deb' => true,
    },
    key          => {
      'id'     => $gpg_key_id,
      'server' => 'hkp://keyserver.ubuntu.com:80',
    },
    repos        => 'main',
    release      => $facts['os']['distro']['codename'],
  }
}
