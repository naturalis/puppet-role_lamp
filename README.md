puppet-role_lamp
===================

Puppet role definition for deployment of lamp stack

Parameters
-------------
Sensible defaults for Naturalis in init.pp, extra_users_hash for additional SSH users that are allowed root permissions and webusers_hash for users allowed login permissions and edit docroot permissions.  

```
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
  $mysql_key_buffer_size                  = undef,
  $mysql_query_cache_limit                = undef,
  $mysql_query_cache_size                 = undef,
  $mysql_innodb_buffer_pool_size          = undef,
  $mysql_innodb_additional_mem_pool_size  = undef,
  $mysql_innodb_log_buffer_size           = undef,
  $mysql_max_connections                  = undef,
  $mysql_max_heap_table_size              = undef,
  $mysql_lower_case_table_names           = undef,
  $mysql_innodb_file_per_table            = undef,
  $mysql_tmp_table_size                   = undef,
  $mysql_table_open_cache                 = undef,
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

```


Classes
-------------
- role_lamp
- role_lamp::instances
- role_lamp::ssl


Dependencies
-------------
- puppetlabs/mysql
- puppetlabs/apache
- puppetlabs/concat
- voxpupuli/php
- voxpupuli/letsencrypt



Puppet code
```
class { role_lamp: }
```
Result
-------------
Working Linux Apache (Mysql) PHP installation, with or without letsencrypt SSL


Limitations
-------------
This module has been built on and tested against Puppet 4 and higher.

The module has been tested on:
- Ubuntu 16.04LTS

Dependencies releases tested: 
- puppetlabs/mysql 3.3.0
- puppetlabs/apache 1.3.0
- puppetlabs/concat 1.2.0
- voxpupuli/php
- voxpupuli/letsencrypt



Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

