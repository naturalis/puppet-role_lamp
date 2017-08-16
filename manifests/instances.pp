# Create all virtual hosts from hiera
class role_lamp::instances (
)
{
  create_resources('apache::vhost', $role_lamp::instances)
  if ($role_lamp::enablessl == true) {
    create_resources('apache::vhost', $role_lamp::sslinstances)
  }
}
