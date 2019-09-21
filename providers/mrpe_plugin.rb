# frozen_string_literal: true

action :create do
  # Template file
  template_file = node['check_mk']['agent']['mrpe']

  new_path = new_resource.path
  new_arguments = new_resource.arguments
  new_plugin = new_resource.plugin

  # The magic!
  t = begin
    new_template = resource_collection.find(template: template_file)

    # Warn if we are about to override a previously configured MRPE plugin
    Chef::Log.warn "Check_MK MRPE plugin #{new_resource.plugin} will be overridden" if new_template.variables.key?(:plugins) \
      && new_template.variables[:plugins].key?(new_plugin)
    new_template
      rescue ArgumentError, ::Chef::Exceptions::ResourceNotFound
        template template_file do
          owner 'root'
          group 'root'
          mode '0644'
          cookbook 'check_mk'
          variables plugins: {}
        end
  end

  # Add a plugin or set an existing one
  new_plugins = t.variables.fetch(:plugins, {}).merge(new_plugin => {
                                                        path: new_path,
                                                        arguments: new_arguments,
                                                      })
  t.variables t.variables.merge(plugins: new_plugins)

  new_resource.updated_by_last_action(@current_mrpe_cfg.find { |s| s == new_resource_expected_line })
end

def load_current_resource
  @current_mrpe_cfg = read_mrpe_cfg
end

def new_resource_expected_line
  "#{new_resource.plugin} #{new_resource.path} #{new_resource.arguments}\n"
end

def read_mrpe_cfg
  ::File.open node['check_mk']['agent']['mrpe'], &:readlines
rescue StandardError
  []
end
