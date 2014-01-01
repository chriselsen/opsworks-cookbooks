aws_instance_id         = node[:opsworks][:instance][:aws_instance_id]
layer                   = node[:opsworks][:instance][:layers].first
hostname                = node[:opsworks][:instance][:hostname]
instances               = node[:opsworks][:layers].fetch(layer)[:instances].sort_by{|k,v| v[:booted_at] }
is_first_node           = instances.index{|i|i[0] == hostname} == 0

Chef::Log.debug("aws_instance_id: #{aws_instance_id}")
Chef::Log.debug("layer: #{layer}")
Chef::Log.debug("instances: #{instances.map{|i| i[0] }.join(', ')}")
Chef::Log.debug("is_first_node: #{is_first_node}")
Chef::Log.debug("hostname: #{hostname}")

if is_first_node && instances.count > 1 then
	Chef::Log.info("Glusterfs: More than one node and first one: Creating volume")

    instances.each do |i|
        instance = i[1]
        private_dns_name = instance[:private_dns_name]
        is_self = instance[:aws_instance_id] == aws_instance_id;

        Chef::Log.debug("Peer private_dns_name: #{private_dns_name}")

        execute "gluster peer probe #{private_dns_name}" do
            not_if "gluster peer status | grep '^Hostname: #{private_dns_name}'"
            not_if { is_self }
        end

    end
   
    node[:glusterfs][:server][:volumes].each do |volume_name|
    #node[:deploy].each do |application, deploy|
        Chef::Log.info("Gluster Volume: #{volume_name}")

        execute "gluster volume setup" do
            not_if "gluster volume info #{volume_name} | grep '^Volume Name: #{volume_name}'"
            bricks = instances.map{|i| i[1][:private_dns_name] + ":#{node[:glusterfs][:server][:export_directory]}/" + volume_name}.join(' ')
            command "gluster volume create #{volume_name} replica #{instances.count} transport tcp #{bricks}"
            action :run
        end

        execute "gluster volume start #{volume_name}" do
            not_if "gluster volume info #{volume_name} | grep '^Status: Started'"
            action :run
        end
    end
end

if instances.count > 1 then
	Chef::Log.info("Glusterfs: More than one node: Mounting volume")
	gluster_instances = node[:opsworks][:layers].fetch(layer)[:instances]
	Chef::Log.debug("Glusterfs: Instances: #{gluster_instances.map{|i| i[0] }.join(', ')}")

	puts gluster_instances.inspect
	if gluster_instances.count > 0 then
		gluster_server = gluster_instances.sort_by{|k,v| v[:booted_at] }[0][1][:private_ip].first
		Chef::Log.debug("Glusterfs: Server: #{gluster_server}")

		node[:glusterfs][:bind_mounts][:mounts].each do |source, dir|
			Chef::Log.debug("Glusterfs: Directory: #{dir}")
			Chef::Log.debug("Glsuterfs: Source: #{source}")
			directory dir do
				recursive true
				action :create
				mode "0755"
			end

			# mount -t glusterfs -o log-level=WARNING,log-file=/var/log/gluster.log 10.200.1.11:/test /mnt
			mount "#{dir}"  do
				device "#{gluster_server}:/#{source}"
				fstype "glusterfs"
				options "log-level=WARNING,log-file=/var/log/gluster.log"
				action :mount
			end
		end
	end	
end