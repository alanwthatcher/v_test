#
# Cookbook:: v_test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Load the seed information
vinfo = data_bag_item('common', 'vault')

# Decrypt token for creating AppRole secret-id
ar_token = Vaultron::Helpers.transit_decode(
  vinfo['addr'],
  vinfo['ar-tran-token'],
  vinfo['ar-tran-key'],
  vinfo['ar-tran-cipher']
)

# Read a single secret
test_secret = Vaultron::Helpers.read(
  vinfo['addr'],
  ar_token,
  'chef-secret/test-secret',
  vinfo['chef-approle']
)

# Read multiple secrets
test_secrets = Vaultron::Helpers.read_multi(
  vinfo['addr'],
  ar_token,
  'chef-secret/stuff',
  vinfo['chef-approle']
)

# Write the single secret
template '/tmp/test_file-libraries' do
  source 'test_file.erb'
  variables token: ar_token, secret: test_secret
end

# Write multiple secrets raw
template '/tmp/test_file_multi-libraries' do
  source 'test_file_multi.erb'
  variables secrets: test_secrets
end
