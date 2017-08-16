# == Class: role_lamp::ssl
#
# ssl code for enabline ssl with or without letsencrypt
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_lamp::ssl (
)
{

# Install modssl when ssl is enabled
  if ($role_lamp::enablessl == true) {
    class { 'apache::mod::ssl':
      ssl_compression => false,
      ssl_options     => [ 'StdEnvVars' ],
    }
  }

# install letsencrypt certs only and crontab
  if ($role_lamp::enableletsencrypt == true) {
    class { ::letsencrypt:
      config => {
        email  => $role_lamp::letsencrypt_email,
        server => $role_lamp::letsencrypt_server,
      }
    }
    letsencrypt::certonly { 'letsencrypt_cert':
      domains       => $role_lamp::letsencrypt_domains,
      manage_cron   => true,
    }
  }
}

