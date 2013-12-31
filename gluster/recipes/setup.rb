package "glusterfs-server" do
        action :install
end


directory node[:glusterfs][:server][:export_directory] do
  recursive true
end

service "glusterfs-server" do
  supports :status => true, :restart => true, :reload => true
  action :start
end

rule_before = `iptables -L INPUT --line-numbers | grep reject-with | awk '{print $1}'`.strip
execute "iptables for gluster #1" do
        command "iptables -I INPUT #{rule_before} -m state --state NEW -m tcp -p tcp --dport 24007:24008 -j ACCEPT"
        not_if "iptables -L -n | grep 24007 | grep ACCEPT"
end

execute "iptables for gluster #2" do
        command "iptables -I INPUT #{rule_before} -m state --state NEW -m tcp -p tcp --dport 24009:24014 -j ACCEPT"
        not_if "iptables -L -n | grep 24009 | grep ACCEPT"
end