# == Class: role_lamp
#
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_lamp (
  $docroot             = '/var/www/htdocs',
  $webdirs             = ['/var/www/htdocs'],
  $rwwebdirs           = ['/var/www/htdocs/cache'],
  $enable_mysql        = undef,
  $enable_phpmyadmin   = false,
  $mysql_root_password = 'rootpassword',
  $instances           = {'site.lampsite.nl' => {
                           'serveraliases'   => '*.lampsite.nl',
                           'docroot'         => '/var/www/htdocs',
                           'directories'     => [{ 'path' => '/var/www/htdocs', 'options' => '-Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' }],
                           'port'            => 80,
                           'serveradmin'     => 'webmaster@naturalis.nl',
                           'priority'        => 10,
                          },
                         },
){

    file { $webdirs:
      ensure         => 'directory',
      mode           => '0750',
      owner          => 'root',
      group          => 'www-data',
      require        => Class['apache']
    }->
    file { $rwwebdirs:
      ensure         => 'directory',
      mode           => '0777',
      owner          => 'www-data',
      group          => 'www-data',
      require        => File[$webdirs]
    }
  

# install php module php-gd
  php::module { [ 'gd','mysql','curl' ]: }

# Install apache and enable modules
  class { 'apache':
    default_mods     => true,
    mpm_module       => 'prefork',
  }
  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::speling

# Create instances (vhosts)
  class { 'role_lamp::instances': 
      instances      => $instances,
  }

# Configure MySQL Security
  if $enable_mysql {
    class { 'mysql::server::account_security':}
    class { 'mysql::server':
        root_password   => $mysql_root_password,
        service_enabled => true,
        service_manage  => true,
    }
  }
# Configure phpMyadmin
  if $enable_phpmyadmin {
    
    package { 'phpmyadmin':
      ensure            => "installed",
      require           => File[$webdirs],
      notify            => Exec['link-phpmyadmin', 'enable-mcrypt'], Package['apache2'],
    }
    exec { "link-phpmyadmin":
      command           => "ln -sf /usr/share/phpmyadmin ${webdirs}/phpmyadmin",
      path              => ["/bin"],
      require           => Package['phpmyadmin', 'apache2'],
      refreshonly       => true,
    }
    exec { 'enable-mcrypt':
    command             => 'php5enmod mcrypt',
    path                => ['/bin', '/usr/bin', '/usr/sbin'],
    require             => Package['phpmyadmin', 'apache2'],
    refreshonly         => true,
    notify              => Service['apache2'],
  }
  }
  
}
