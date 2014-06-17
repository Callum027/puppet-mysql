class mysql::params
{
  $packages = $mysql::type ? {
    'oracle'  => [ 'mysql-server' ],
    'percona' => [ 'percona-server-server-5.6' ],
    'mariadb' => [ 'mariadb-server-5.5' ],
    'mariadb-galera'  => [ 'mariadb-galera-server-5.5' ],
  }

  $packages_extra = $mysql::type ? {
    'oracle'  => [  ],
    'percona' => [ 'xtrabackup' ],
    'mariadb' => [ ],
    'mariadb-galera'  => [ 'galera' ],
  }

  $service = $mysql::type ? {
    'oracle'  => [ 'mysql' ],
    'percona' => [ 'mysql' ],
    /mariadb(-galera)?/ => [ 'mysql' ],
    
  }
}
