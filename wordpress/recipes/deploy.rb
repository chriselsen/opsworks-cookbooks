node[:deploy].each do |application, deploy|
  mysql_command = "/usr/bin/mysql -u #{deploy[:database][:username]} #{node[:mysql][:server_root_password].blank? ? '' : "-p#{node[:mysql][:server_root_password]}"}"

  execute "Import Wordpress database backup" do
    command "#{mysql_command} < #{deploy[:deploy_to]}/current/*.sql"
    action :run

    if do
      system("if ls #{deploy[:deploy_to]}/current/*.sql &> /dev/null")
    end
  end