class mysql::config
{
  file {
    "/etc/mysql/":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => 755;
    "/etc/mysql/conf.d/":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => 755;
    "/var/lib/mysql":
      ensure  => directory,
      owner   => mysql,
      group   => mysql,
      mode    => 755;

    "/etc/mysql/my.cnf":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 644,
      source  => [ "puppet:///modules/mysql/my.cnf-${mysql::type}" ],
      notify  => $service_class;
  }
  
  if ($mysql::type != 'mariadb-galera')
  {
    File["/etc/mysql/my.cnf"]
    {
      # we only install a config file if the package doesn't install one
      replace => false,
    }
    
    # This file is managed by the user in mariadb-galera.
    file
    { "/etc/mysql/debian.cnf":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 600,
      notify  => $service_class;
    }
  }
  else
  {
    # In the case of mariadb-galera, we DO want to replace my.cnf.
    File["/etc/mysql/my.cnf"]
    {
      replace => true,
    }
  }

  define param($section, $param=$name, $value)
  {
    augeas { "${section}_${param}":
      context => "/files/etc/mysql/my.cnf",
      changes => [
          "set target[ . = '${section}'] ${section}",
          "set target[ . = '${section}']/${param} ${value}",
        ],
      require => File['/etc/mysql/my.cnf']
    }

    if($mysql::notify_services)
    {
      if($mysql::multi)
      {
        if($section =~ /^mysqld([1-9])+$/)
        {
          Augeas["${section}_${param}"] ~> Service[$section]
        }
      }else
      {
        Augeas["${section}_${param}"] ~> Class['mysql::service']
      }
    }
  }
}
