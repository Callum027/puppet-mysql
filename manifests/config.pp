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
      # we only install a config file if the package doesn't install one
      replace => false,
      notify  => $service_class;
  }
  
  if ($mysql::type != 'mariadb-galera')
  {
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
    # Specific settings for mariadb-galera.
    mysql::config::param
  	{ 'query_cache_size':
  		section	=> 'mysql',
  		value	=> 0,
  	}
  
  	mysql::config::param
  	{ 'binlog_format':
  		section	=> 'mysql',
  		value	=> 'ROW',
  	}
  
  	mysql::config::param
  	{ 'default_storage_engine':
  		section	=> 'mysql',
  		value	=> 'InnoDB',
  	}
  
  	mysql::config::param
  	{ 'innodb_autoinc_log_mode':
  		section	=> 'mysql',
  		value	=> 2,
  	}
  
  	mysql::config::param
  	{ 'query_cache_type':
  		section	=> 'mysql',
  		value	=> 0,
  	}
  
  	mysql::config::param
  	{ 'bind-address':
  		section	=> 'mysql',
  		value	=> '0.0.0.0',
  	}
  
  	# Galera Provider configuration.
  	mysql::config::param { 'wsrep_provider':
  		section	=> 'mysql',
  		value	=> '/usr/lib/galera/libgalera_smm.so',
  	}
  
  	# wsrep_drupal_282555_workaround
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
