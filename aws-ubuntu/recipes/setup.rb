# AWS OpsWorks Recipe for Ubuntu VMs to be executed during the Setup lifecycle phase
# - Adds memory swap: This should be used in instances with low RAM -
#   e.g. AWS t1.micro - to prevent "out of memory" issues.

swap_size = node[:awsubuntu][:swapsize]
Chef::Log.debug("Creating SWAP with size #{swap_size} bytes")

script "memory_swap" do
  interpreter "bash"
  user "root"
  cwd "/"
  code <<-EOH
  /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=#{swap_size}
  /sbin/mkswap /var/swap.1
  /sbin/swapon /var/swap.1
  EOH
end
