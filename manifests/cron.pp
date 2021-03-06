# Class cronjobs
# Provides: mastercronjobs, nodesonlycron, cronjobs
#
class mastercronjobs {
    cron { pull_from_repo:
        command => "/usr/local/bin/ring-puppet-repo-sync > /dev/null 2>&1",
        minute  => "*/5",
        user    => root,
        ensure  => present,
    }

}


class nodesonlycron {

# we want smokeping to restart every day
# restart is required because smokeping reload only works
# for local configuration, but we have master/slave setup

    cron { "restartsmokeping":
        command => "/etc/init.d/smokeping restart > /dev/null 2>&1",
        minute  => fqdn_rand(60),
        hour    => fqdn_rand(23),
        user    => "root",
        ensure  => absent,
    }

}

# this class is executed on all ring-nodes including the master 
class cronjobs {
    $first = fqdn_rand(30)
    $second = (fqdn_rand(30) + 30)
    
    $cron1 = (fqdn_rand(50) + 1)
    $cron2 = (fqdn_rand(50) + 5)
    $cron3 = (fqdn_rand(50) + 3)

    cron { weeklyreboot:
        command => "/sbin/reboot",
        weekday => "sunday",
        hour => "4",
        user => "root",
        ensure => absent,
    }

    cron { update_motd:
        command => "run-parts --lsbsysinit /etc/update-motd.d > /var/run/motd",
        hour => "7",
        minute => "15",
        user => "root",
    }
    cron { aptupdate:
        command => "apt-get update > /dev/null 2>&1",
        hour => "3",
        user => "root",
        minute => $cron1,
        environment => ["PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"],
    }
    
   cron {
        "puppetagent":
        command => "/usr/sbin/puppetd --test > /dev/null 2>&1",
        user => root,
        minute => [ $first, $second ],
    }
    
    cron {
        "reload-smokeping":
        command => "/usr/sbin/service smokeping restart > /dev/null 2>&1",
        user => root,
        weekday => "*",
        hour => "3",
        minute => $cron2,
        ensure => absent,
    }
   
    cron {
        "zombiekiller":
        command => "/usr/local/bin/puppet_zombiecleanup > /dev/null 2>&1",
        user => root,
        minute => "42",
    }

# our munin module makes this useless
# see msp01 example in nodes.pp if you want to enable specific plugins on a host
    cron { "munin-configure":
        command => "/usr/sbin/munin-node-configure --shell | bash > /dev/null 2>&1",
        user => root,
        hour => "3",
        weekday => "1",
        minute => $cron3,
        ensure => absent,
    }

}
