#
# Cookbook:: v_test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Load the seed information
vinfo = data_bag_item('common', 'vault')

# Decrypt AR token via transit backend
vault 'get transit decrypt token' do
  destination 'ar-token'
  payload ciphertext: vinfo['ar-tran-cipher']
  address vinfo['addr']
  token vinfo['ar-tran-token']
  path vinfo['ar-tran-key']
  action :transit_decrypt
end

# Read a single secret
vault 'read chef-secret/test-secret' do
  address vinfo['addr']
  token lazy { node.run_state['ar-token'] }
  path 'chef-secret/test-secret'
  approle vinfo['chef-approle']
end

# Read all secrets in a path
vault 'read secrets from chef-secret/stuff' do
  address vinfo['addr']
  token lazy { node.run_state['ar-token'] }
  path 'chef-secret/stuff'
  approle vinfo['chef-approle']
  action :read_multi
end

# Write the single secret
template '/tmp/test_file-resources' do
  source 'test_file.erb'
  variables lazy {
    {
      token: node.run_state['ar-token'],
      secret: node.run_state['chef-secret/test-secret']
    }
  }
end

# Write multiple secrets raw
template '/tmp/test_file_multi-resources' do
  source 'test_file_multi.erb'
  variables lazy {
    { secrets: node.run_state['chef-secret/stuff'] }
  }
end
