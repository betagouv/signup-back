CarrierWave.configure do |config|
  config.fog_provider = 'fog/openstack'
  config.fog_credentials = {
    provider: 'OpenStack',
    openstack_tenant: "",
    openstack_api_key: "",
    openstack_username: "",
    openstack_auth_url: "https://auth.cloud.ovh.net/v2.0/tokens",
    openstack_region: ""
  }
  config.fog_directory = "signup-uploads"
  config.fog_public = false
  config.storage = :fog
end
