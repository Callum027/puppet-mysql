class mysql::params
{
  $packages = $type ? {
    'oracle'  => [ 'mysql-server-5.1' ],
    'percona' => [ 'percona-server-server-5.5' ],
    'mariadb' => [ 'mariadb-server-5.3' ],
  } 

  $packages_extra = $type ? {
    'oracle'  => [ 'maatkit' ],
    'percona' => [ 'maatkit', 'xtrabackup' ],
    'mariadb' => [ 'maatkit'],
  } 

  $service = $type ? {
    'oracle'  => [ 'mysql' ],
    'percona' => [ 'mysql' ],
    'mariadb' => [ 'mysql' ],
  } 
}
