#
# Cookbook Name:: arcgis-notebooks
# Attributes:: default
#
# Copyright 2019 Esri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_attribute 'arcgis-repository'

default['arcgis']['notebook_server'].tap do |notebook_server|
  notebook_server['url'] = "https://#{node['fqdn']}:11443/arcgis"
  notebook_server['wa_name'] = 'notebooks'
  notebook_server['wa_url'] = "https://#{node['fqdn']}/#{node['arcgis']['notebook_server']['wa_name']}"

  notebook_server['domain_name'] = node['fqdn']
  notebook_server['private_url'] = "https://#{node['arcgis']['notebook_server']['domain_name']}:11443/arcgis"
  notebook_server['web_context_url'] = "https://#{node['arcgis']['notebook_server']['domain_name']}/#{node['arcgis']['notebook_server']['wa_name']}"

  notebook_server['ports'] = '11443'
  notebook_server['authorization_file'] = node['arcgis']['server']['authorization_file']
  notebook_server['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  notebook_server['license_level'] = 'standard'
  notebook_server['configure_autostart'] = true
  notebook_server['install_system_requirements'] = true

  notebook_server['setup_archive'] = ''

  notebook_server['admin_username'] = 'siteadmin'
  if ENV['ARCGIS_NOTEBOOK_SERVER_ADMIN_PASSWORD'].nil?
    notebook_server['admin_password'] = 'change.it'
  else
    notebook_server['admin_password'] = ENV['ARCGIS_NOTEBOOK_SERVER_ADMIN_PASSWORD']
  end

  case node['platform']
  when 'windows'
    notebook_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                           'ArcGIS ' + node['arcgis']['version'],
                                           'NotebookServer', 'Setup.exe')
    notebook_server['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\NotebookServer').gsub('/', '\\')
    notebook_server['install_subdir'] = ''
    notebook_server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
      'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')

    notebook_server['directories_root'] = 'C:\\arcgisnotebookserver\\directories'
    notebook_server['config_store_connection_string'] = 'C:\\arcgisnotebookserver\\config-store'
    notebook_server['workspace'] = 'C:\\arcgisnotebookserver\\arcgisworkspace'

    case node['arcgis']['version']
    when '10.8'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_108_172941.exe').gsub('/', '\\')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_108_172942.tar.gz').gsub('/', '\\')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_108_172943.tar.gz').gsub('/', '\\')
      notebook_server['product_code'] = '{B1DB581E-E66C-4E58-B9E3-50A4D6CB5982}'
    when '10.7.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_1071_169734.exe').gsub('/', '\\')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_1071_169736.tar.gz').gsub('/', '\\')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_1071_169738.tar.gz').gsub('/', '\\')
      notebook_server['product_code'] = '{F6DF77B9-F35E-4877-A7B1-63E1918B4E19}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Notebook Server version'
    end
  else # node['platform'] == 'linux'
    notebook_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                           node['arcgis']['version'],
                                           'NotebookServer_Linux', 'Setup')
    notebook_server['install_dir'] = "/home/#{node['arcgis']['run_as_user']}"
    notebook_server['install_subdir'] = node['arcgis']['notebook_server']['install_dir'].end_with?('/arcgis') ?
                                        'notebookserver' : 'arcgis/notebookserver'

    if node['arcgis']['notebook_server']['install_dir'].nil?
      notebook_server_install_dir = notebook_server['install_dir']
    else
      notebook_server_install_dir = node['arcgis']['notebook_server']['install_dir']
    end

    if node['arcgis']['notebook_server']['install_subdir'].nil?
      notebook_server_install_subdir = notebook_server['install_subdir']
    else
      notebook_server_install_subdir = node['arcgis']['notebook_server']['install_subdir']
    end

    notebook_server['authorization_tool'] = ::File.join(notebook_server_install_dir,
                                                        notebook_server_install_subdir,
                                                        '/tools/authorizeSoftware')

    notebook_server['directories_root'] = ::File.join(notebook_server_install_dir,
                                                      notebook_server_install_subdir,
                                                      'usr', 'directories')
    notebook_server['config_store_connection_string'] = ::File.join(notebook_server_install_dir,
                                                                    notebook_server_install_subdir,
                                                                    'usr', 'config-store')
    notebook_server['workspace'] = ::File.join(notebook_server_install_dir,
                                               notebook_server_install_subdir,
                                               'usr', 'arcgisworkspace')

    case node['arcgis']['version']
    when '10.8'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_108_173012.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_108_172942.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_108_172943.tar.gz')
    when '10.7.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_1071_169927.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_1071_169736.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_1071_169738.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Notebook Server version'
    end
  end
end
