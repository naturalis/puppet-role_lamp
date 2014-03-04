# == Class: role_lamp
#
# Full description of class role_lamp here.
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_lamp (
  $docroot             = '/var/www/htdocs',
  $extra_users_hash    = undef,
  $webusers_hash       = undef,
  $webdirs             = ['/var/www/htdocs'],
  $rwwebdirs           = ['/var/www/htdocs/cache'],
  $mysql_root_password = 'rootpassword',
  $instances           = {'site.lampsite.nl' => {
                           'serveraliases'   => '*.lampsite.nl',
                           'docroot'         => '/var/www/htdocs',
                           'directories'     => [{ 'path' => '/var/www/htdocs', 'options' => '-Indexes FollowSymLinks MultiViews', 'allow_override' => 'All' }],
                           'port'            => 80,
                           'serveradmin'     => 'webmaster@naturalis.nl',
                           'priority'        => 10,
                          },
                         },
){

# create extra users
  if $extra_users_hash {
    create_resources('base::users', parseyaml($extra_users_hash))
  }

# create webusers
  if $webusers_hash {
    create_resources('role_lamp::webusers', parseyaml($webusers_hash))
  }

# create group webusers and set permissions for documents. 
  group { "webusers":
    ensure         => present
  }

  file { $webdirs:
    ensure         => 'directory',
    mode           => '0460',
    owner          => 'www-data',
    group          => 'webusers',
    recurse        => true,
    require        => Group['webusers']
  }->
  file { $rwwebdirs:
    ensure         => 'directory',
    mode           => '0660',
    owner          => 'www-data',
    group          => 'webusers',
    recurse        => true,
    require        => [Group['webusers'],File[$webdirs]]
  }

# install php module php-gd
  php::module { [ 'gd' ]: }

# Install apache and enable modules
  class { 'apache':
    default_mods     => true,
    mpm_module       => 'prefork',
  }
  include apache::mod::php
  include apache::mod::rewrite

# Create instances (vhosts)
  class { 'role_lamp::instances': 
      instances      => $instances,
  }

# Configure MySQL Security
  class { 'mysql::server::account_security':}
  class { 'mysql::server':
      root_password  => $mysql_root_password,
  }


  
}
