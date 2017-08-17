# == Class: role_lamp
#
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_lamp (
  $docroot                                = '/var/www/htdocs',
  $webdirs                                = ['/var/www/htdocs'],
  $webdirowner                            = 'root',
  $webdirgroup                            = 'www-data',
  $webdirmode                             = '0750',
  $enable_mysql                           = undef,
  $enable_phpmyadmin                      = false,
  $enablessl                              = false,
  $enableletsencrypt                      = false,
  $letsencrypt_email                      = 'letsencypt@mydomain.me',
  $letsencrypt_version                    = 'master',
  $letsencrypt_domains                    = ['www.lampsite.nl'],
  $letsencrypt_server                     = 'https://acme-v01.api.letsencrypt.org/directory',
  $mysql_root_password                    = 'rootpassword',
  $mysql_manage_config_file               = true,
  $mysql_key_buffer_size                  = '16M',
  $mysql_query_cache_limit                = '1M',
  $mysql_query_cache_size                 = '16M',
  $mysql_innodb_buffer_pool_size          = '32M',
  $mysql_innodb_log_buffer_size           = '16M',
  $mysql_max_connections                  = '100',
  $mysql_max_heap_table_size              = '32M',
  $mysql_lower_case_table_names           = '0',
  $mysql_innodb_file_per_table            = '1',
  $mysql_tmp_table_size                   = '32M',
  $mysql_table_open_cache                 = '100',
  $php_memory_limit                       = '128M',
  $php_post_max_size                      = '2M',
  $php_upload_max_filesize                = '8M',
  $instances                              =
          {'site.lampsite.nl' => {
            'serveraliases'   => '*.lampsite.nl',
            'docroot'         => '/var/www/htdocs',
            'directories'     => [{ 'path' => '/var/www/htdocs', 'options' => '-Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' }],
            'port'            => 80,
            'serveradmin'     => 'webmaster@naturalis.nl',
            'priority'        => 10,
            },
          },
# add rewrite block to instances to rewrite http to https
#
#                                 'rewrites'        => [{ 'rewrite_rule' => '^/?(.*) https://%{SERVER_NAME}/$1 [R,L]' }],
#
# Foreman yaml format:
#
#  rewrites:
#  - rewrite_rule:
#    - "^/?(.*) https://%{SERVER_NAME}/$1 [R,L]"
#
  $sslinstances                = {'site.lampsites.nl-ssl' => {
                                  'serveraliases'   => '*.lampsites.nl',
                                  'docroot'         => '/var/www/lamp',
                                  'directories'     => [{ 'path' => '/var/www/lamp', 'options' => '-Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' }],
                                  'port'            => 443,
                                  'serveradmin'     => 'webmaster@naturalis.nl',
                                  'priority'        => 10,
                                  'ssl'             => 'true',
                                  'ssl_cert'        => '/etc/letsencrypt/live/site.lampsite.nl/cert.pem',
                                  'ssl_key'         => '/etc/letsencrypt/live/site.lampsite.nl/privkey.pem',
                                  'ssl_chain'       => '"/etc/letsencrypt/live/site.lampsite.nl/chain.pem',
                                  'additional_includes' =>  '/opt/letsencrypt/certbot-apache/certbot_apache/options-ssl-apache.conf',
                                  },
                                },

  $keepalive                            = 'Off',
  $max_keepalive_requests               = '100',
  $keepalive_timeout                    = '15',
){

  file { $webdirs:
    ensure                  => 'directory',
    mode                    => $webdirmode,
    owner                   => $webdirowner,
    group                   => $webdirgroup,
    require                 => Class['apache']
  }

# install php and configure php.ini
  class { '::php':
    ensure              => latest,
    composer            => false,
    manage_repos        => true,
    extensions => {
      gd         => {
        provider => 'apt',
        source   => 'php7-gd',
      },
      curl       => {
        provider => 'apt',
        source   => 'php-curl',
      },
      mysql     => {
      },
      mcrypt     => {
        provider => 'apt',
        source   => 'php-mcrypt',
      },
      mbstring   => {
        provider => 'apt',
        source   => 'php-mbstring',
      },
    },
    settings   => {
        'PHP/apc.rfc1867'         => '1',
        'PHP/max_execution_time'  => '90',
        'PHP/max_input_time'      => '300',
        'PHP/memory_limit'        => $role_lamp::php_memory_limit,
        'PHP/post_max_size'       => $role_lamp::php_post_max_size,
        'PHP/upload_max_filesize' => $role_lamp::php_upload_max_filesize,
        'Date/date.timezone'      => 'Europe/Amsterdam',
    },
  }

# Install apache and enable modules
  class { 'apache':
    default_mods              => true,
    mpm_module                => 'prefork',
    keepalive                 => $role_lamp::keepalive,
    max_keepalive_requests    => $role_lamp::max_keepalive_requests,
    keepalive_timeout         => $role_lamp::keepalive_timeout,
  }

  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::speling

# enable ssl with or without letsencrypt based on config
  class { 'role_lamp::ssl': }


# Create instances (vhosts)
  class { 'role_lamp::instances':
  }

# Configure MySQL Security and finetuning if needed
  if $role_lamp::enable_mysql {
    class { 'mysql::server::account_security':}
    class { 'mysql::server':
        root_password         => $role_lamp::mysql_root_password,
        service_enabled       => true,
        service_manage        => true,
        manage_config_file    => $role_lamp::mysql_manage_config_file,
        override_options      => {
          'mysqld'            => {
            'key_buffer_size'                 => $role_lamp::mysql_key_buffer_size,
            'query_cache_limit'               => $role_lamp::mysql_query_cache_limit,
            'query_cache_size'                => $role_lamp::mysql_query_cache_size,
            'innodb_buffer_pool_size'         => $role_lamp::mysql_innodb_buffer_pool_size,
            'innodb_log_buffer_size'          => $role_lamp::mysql_innodb_log_buffer_size,
            'max_connections'                 => $role_lamp::mysql_max_connections,
            'max_heap_table_size'             => $role_lamp::mysql_max_heap_table_size,
            'lower_case_table_names'          => $role_lamp::mysql_lower_case_table_names,
            'innodb_file_per_table'           => $role_lamp::mysql_innodb_file_per_table,
            'tmp_table_size'                  => $role_lamp::mysql_tmp_table_size,
            'table_open_cache'                => $role_lamp::mysql_table_open_cache,
          }
        }
    }
  }
# Configure phpMyadmin
  if $role_lamp::enable_phpmyadmin {
    package { 'phpmyadmin':
      ensure                  => 'installed',
      require                 => Class['apache'],
      notify                  => Exec['link-phpmyadmin'],
    }
    exec { 'link-phpmyadmin':
      command                 => "ln -sf /usr/share/phpmyadmin ${role_lamp::docroot}/phpmyadmin",
      path                    => ['/bin'],
      require                 => File[$role_lamp::webdirs],
      refreshonly             => true,
    }
  }

}
