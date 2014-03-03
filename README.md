puppet-role_lamp
===================

Puppet role definition for deployment of lamp stack

Parameters
-------------
Sensible defaults for Naturalis in init.pp, extra_users_hash for additional SSH users that are allowed root permissions and webusers_hash for users allowed login permissions and edit docroot permissions.  

```
  docroot              = documentroot
  extra_users_hash     = see example
  webusers_hash        = see example
  webdirs              = Array with webdirectories, starting at the highest path, the docroot. 0460 permissions will be applied owner: www-data  group: webusers
  rwwebdirs            = Array with webdirectories that need read and write permissions, starting at the highest path, 0660 permissions will be applied owner: www-data  group: webusers
  mysql_root_password  = Mysql Root password
  $instances           = Instance hash, see the default for parameters
```


User hash example
```
role_lamp::extra_users_hash:
  user1:
    comment: "Example user 1"
    shell: "/bin/zsh"
    ssh_key:
      type: "ssh-rsa"
      comment: "user1.lampsite.nl"
      key: "AAAAB3sdfgsdfgzyc2EAAAABJQAAAIEArnZ3K6vJ8ZisdqPhsdfgsdf5gdKkpuf5rCqOgGphDrBt3ntT7+rWzjx39Im64CCoL+q6ZKgckEZMjGaOKcV+c77nCmSb8eqAM/4eltwj+OgJ5K5DVi1pUaWxR5IoeiulZK36DetVZJCGCkxxLopjSDFGAS234aPC13cLM0Qqfxk="
```


Classes
-------------
- role_lamp
- role_lamp::instances
- role_lamp::webusers

Dependencies
-------------
- naturalis/base
- puppetlabs/mysql
- puppetlabs/apache2
- thias/php


Puppet code
```
class { role_lamp: }
```
Result
-------------
Working Linux Apache Mysql PHP installation. 


Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.


The module has been tested on:
- Ubuntu 12.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

