class mysql::repo
{
  include apt

  case $mysql::type{
    'oracle' : { # use standard packages
    }

    'percona': {
      apt::key {
        'CD2EFD2A':
      }

      # Puppetlabs/apt module
      apt::source { 'percona':
        ensure      => present,
        include_src => true,
        location    => 'http://repo.percona.com/apt',
        release     => $::lsbdistcodename,
        repos       => 'main',
        require     => Apt::Key['CD2EFD2A'],
      }
    }

    /mariadb(-galera)?/: {
      apt::key {
        '1BB943DB':
      }

      # Puppetlabs/apt module

      apt::source { 'mariadb5.5':
        ensure      => present,
        include_src => true,

        # 华中科技大学启明学院 - Qiming College of Huazhong UST mirror (China)
        #location    => 'http://mirrors.hustunique.com/mariadb/repo/5.5/ubuntu',

        # Syringa Networks (US)
        location      => 'http://mirrors.syringanetworks.net/mariadb/repo/5.5/ubuntu',

        release     => $::lsbdistcodename,
        repos       => 'main',
        require     => Apt::Key['1BB943DB'],
      }
    }
  }

}
