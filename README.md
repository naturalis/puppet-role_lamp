puppet-role_lamp
===================

Puppet role definition for deployment of lamp stack

Parameters
-------------
Sensible defaults for Naturalis in init.pp, extra_users_hash for additional SSH users. 


```
role_lampng::extra_users_hash:
  user1:
    comment: "Example user 1"
    shell: "/bin/zsh"
    ssh_key:
      type: "ssh-rsa"
      comment: "user1.soortenregister.nl"
      key: "AAAAB3sdfgsdfgzyc2EAAAABJQAAAIEArnZ3K6vJ8ZisdqPhsdfgsdf5gdKkpuf5rCqOgGphDrBt3ntT7+rWzjx39Im64CCoL+q6ZKgckEZMjGaOKcV+c77nCmSb8eqAM/4eltwj+OgJ5K5DVi1pUaWxR5IoeiulZK36DetVZJCGCkxxLopjSDFGAS234aPC13cLM0Qqfxk="
```


Classes
-------------
- role_lamp
- role_lamp::instances

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

