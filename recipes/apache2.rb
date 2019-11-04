# Recipe:: apache2

include_recipe 'apache2'
include_recipe 'apache2::mod_php5'

include_recipe 'apache2::mod_alias' if node['check_mk']['apache']['redirect_root']

include_recipe 'apache2::mod_ssl' if node['check_mk']['apache']['enable_ssl']
