puppet-role_lamp
===================

Puppet role definition for deployment of lamp stack

Parameters
-------------
Sensible defaults for Naturalis in init.pp, extra_users_hash for additional SSH users that are allowed root permissions and webusers_hash for users allowed login permissions and edit docroot permissions.  

```
  docroot              = documentroot
  webdirs              = Array with webdirectories, 0770 permissions will be applied owner: www-data  group: www-data
  rwwebdirs            = Array with webdirectories that need read and write permissions, starting at the highest path, 0777 permissions will be applied owner: www-data  group: www-data
  enablemysql          = when set to true a mysql server will be installed
  mysql_root_password  = Mysql Root password
  instances            = Instance hash, see the default for parameters
```


Classes
-------------
- role_lamp
- role_lamp::instances


Dependencies
-------------
- puppetlabs/mysql
- puppetlabs/apache2
- thias/php


Puppet code
```
class { role_lamp: }
```
Result
-------------
Working Linux Apache (Mysql) PHP installation


Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.


The module has been tested on:
- Ubuntu 12.04LTS
- Ubuntu 14.04LTS

Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

