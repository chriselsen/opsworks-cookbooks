require 'uri'
require 'net/http'
require 'net/https'

uri = URI.parse("https://api.wordpress.org/secret-key/1.1/salt/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
keys = response.body

node[:deploy].each do |app_name, deploy|

    template "#{deploy[:deploy_to]}/current/wp-config.php" do
        source "wp-config.php.erb"
        mode 0660
        group deploy[:group]

        if platform?("ubuntu")
          owner "www-data"
        elsif platform?("amazon")
          owner "apache"
        end

        variables(
            :database   => (deploy[:database][:database] rescue nil),
            :user       => (deploy[:database][:username] rescue nil),
            :password   => (deploy[:database][:password] rescue nil),
            :host       => (deploy[:database][:host] rescue nil),
            :keys       => (keys rescue nil)
        )
    end

	mysql_command = "/usr/bin/mysql -h #{deploy[:database][:host]} -u #{deploy[:database][:username]} #{node[:mysql][:server_root_password].blank? ? '' : "-p#{node[:mysql][:server_root_password]}"} #{deploy[:database][:database]}"

	script "memory_swap" do
		interpreter "bash"
		user "root"
		cwd "#{deploy[:deploy_to]}/current/"
		code <<-EOH
			if ls #{deploy[:deploy_to]}/current/*.sql &> /dev/null; then 
				#{mysql_command} < #{deploy[:deploy_to]}/current/*.sql;
			fi;
		EOH
	end
	
end

cron "wordpress" do
  hour "*"
  minute "*/15"
  weekday "*"
  command "wget -q -O - http://localhost/wp-cron.php?doing_wp_cron >/dev/null 2>&1"
end