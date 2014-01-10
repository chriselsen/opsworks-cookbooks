node[:deploy].each do |application, deploy|
  mysql_command = "/usr/bin/mysql -h #{deploy[:database][:host]} -u #{deploy[:database][:username]} #{node[:mysql][:server_root_password].blank? ? '' : "-p#{node[:mysql][:server_root_password]}"}"

  execute "Import Wordpress database backup" do
    command "if ls #{deploy[:deploy_to]}/current/*.sql &> /dev/null; then #{mysql_command} < #{deploy[:deploy_to]}/current/*.sql; fi; exit 0"
    action :run
  end
end