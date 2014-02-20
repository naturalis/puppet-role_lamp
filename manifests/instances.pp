# Create all virtual hosts from hiera
class role_lamp::instances (
    $instances,
)
{
  create_resources('apache::vhost', $instances)
}
