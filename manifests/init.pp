# == Class: teamspeak
#
# Full description of class teamspeak here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { teamspeak:
#      version => '3.0.10.3',
#      arch    => 'amd64',
#  }
#
# === Authors
#
# Martin Groeneveld <martin@groveld.com>
#
# === Copyright
#
# Copyright 2014 Martin Groeneveld.
#
class teamspeak (
    $version = '3.0.10.3',
    $arch    = $::architecture,
){

    if !($arch in ['i386', 'amd64']) {
        fail{"${arch} is currently not supported!": }
    }
    if $arch == 'i386' {
        $arch_str = 'x86'
    } else {
        $arch_str = $architecture
    }

    $src_url = [
        "http://dl.4players.de/ts/releases/${version}/teamspeak3-server_linux-${arch_str}-${version}.tar.gz",
        "http://teamspeak.gameserver.gamed.de/ts3/releases/${version}/teamspeak3-server_linux-${arch_str}-${version}.tar.gz",
        "http://files.teamspeak-services.com/releases/${version}/teamspeak3-server_linux-${arch_str}-${version}.tar.gz"
    ]

    $random = fqdn_rand(count($src_url))

    group{'teamspeak':
        ensure => present,
    }

    user{'teamspeak':
        ensure     => present,
        comment    => 'teamspeak service',
        managehome => true,
        home       => '/opt/teamspeak',
        require    => Group['teamspeak'],
    }

    package{'wget':
        ensure => present
    }

    exec{'fetch_teamspeak':
        command => "/usr/bin/wget -q ${src_url[$random]}",
        cwd     => '/opt/teamspeak',
        user    => 'teamspeak',
        creates => "/opt/teamspeak/teamspeak3-server_linux-${arch}-${version}.tar.gz",
        require => [User['teamspeak'], Package['wget']],
    }

    exec{'untar_teamspeak':
        command => "/bin/tar -xzf /opt/teamspeak/teamspeak3-server_linux-${arch}-${version}.tar.gz -C /opt/teamspeak",
        user    => 'teamspeak',
        require => Exec['fetch_teamspeak'],
    }
}

