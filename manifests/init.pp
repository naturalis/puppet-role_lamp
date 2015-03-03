# == Class: role_lamp
#
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_lamp (
  $docroot                      = '/var/www/htdocs',
  $webdirs                      = ['/var/www/htdocs'],
  $rwwebdirs                    = ['/var/www/htdocs/cache'],
  $enable_mysql                 = undef,
  $enable_phpmyadmin            = false,
  $mysql_root_password          = 'rootpassword',
  $mysql_manage_config_file     = 'true',
  $mysql_key_buffer_size        = undef,
  $mysql_query_cache_limit      = undef,
  $mysql_query_cache_size       = undef,
  $mysql_innodb_buffer_pool_size = undef,
  $mysql_innodb_additional_mem_pool_size = undef,
  $mysql_innodb_log_buffer_size = undef,
  $mysql_max_connections        = undef,
  $mysql_tmp_table_size         = undef,
  $mysql_max_heap_table_size    = undef,
  $mysql_open-files-limit       = undef,
  $mysql_max_allowed_packet     = undef,
  $mysql_sort_buffer_size       = undef,
  $mysql_read_buffer_size       = undef,
  $mysql_read_rnd_buffer_size   = undef,
  $mysql_join_buffer_size       = undef,
  $mysql_thread_stack           = undef,
  $mysql_thread_cache_size      = undef,
  $instances                    = {'site.lampsite.nl' => {
                           'serveraliases'   => '*.lampsite.nl',
                           'docroot'         => '/var/www/htdocs',
                           'directories'     => [{ 'path' => '/var/www/htdocs', 'options' => '-Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' }],
                           'port'            => 80,
                           'serveradmin'     => 'webmaster@naturalis.nl',
                           'priority'        => 10,
                          },
                         },
  $keepalive                  = 'Off',
  $max_keepalive_requests     = '100', 
  $keepalive_timeout          = '15',
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
    keepalive              => $keepalive,
    max_keepalive_requests => $max_keepalive_requests,
    keepalive_timeout      => $keepalive_timeout,
  }
  
  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::speling

# Create instances (vhosts)
  class { 'role_lamp::instances': 
      instances      => $instances,
  }

# Configure MySQL Security and finetuning if needed
  if $enable_mysql {
    class { 'mysql::server::account_security':}
    class { 'mysql::server':
        root_password      => $mysql_root_password,
        service_enabled    => true,
        service_manage     => true,
        manage_config_file => $mysql_manage_config_file,
        override_options   => {
          'mysqld' => {
            'key_buffer_size'                 => $mysql_key_buffer_size,
            'query_cache_limit'               => $mysql_query_cache_limit,
            'query_cache_size'                => $mysql_query_cache_size,
            'innodb_buffer_pool_size'         => $mysql_innodb_buffer_pool_size
            'innodb_additional_mem_pool_size' => $mysql_innodb_additional_mem_pool_size
            'innodb_log_buffer_size'          => $mysql_innodb_log_buffer_size
            'max_connections'                 => $mysql_max_connections
            'tmp_table_size'                  => $mysql_tmp_table_size
            'max_heap_table_size'             => $mysql_max_heap_table_size
            'open-files-limit'                => $mysql_open-files-limit
            'max_allowed_packet'              => $mysql_max_allowed_packet
            'sort_buffer_size'                => $mysql_sort_buffer_size
            'read_buffer_size'                => $mysql_read_buffer_size
            'read_rnd_buffer_size'            => $mysql_read_rnd_buffer_size
            'join_buffer_size'                => $mysql_join_buffer_size
            'thread_stack'                    => $mysql_thread_stack
            'thread_cache_size'               => $mysql_thread_cache_size
          }
        }
    }
  }
# Configure phpMyadmin
  if $enable_phpmyadmin {
    package { 'phpmyadmin':
      ensure            => "installed",
      require           => Package['apache2'],
      notify            => Exec['link-phpmyadmin', 'enable-mcrypt'],
    }
    exec { "link-phpmyadmin":
      command           => "ln -sf /usr/share/phpmyadmin ${webdirs}/phpmyadmin",
      path              => ["/bin"],
      require           => File[$webdirs],
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
