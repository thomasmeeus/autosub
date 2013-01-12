include_recipe "apt::default"

package "python-cheetah" do
  action :upgrade
end

bash "install_autosub" do
  user "root"
  cwd "/opt/"
  code <<-EOH
  wget -q http://auto-sub.googlecode.com/files/auto-sub.Beta.0.5.6.zip -O auto-sub.Beta.0.5.6.zip
  unzip -o auto-sub.Beta.0.5.6.zip
  EOH
   not_if do
        ::File.exists?("#{node['autosub']['location']}/config.properties") &&
        node['autosub']['force_download'] == false
    end
end

template "/etc/init.d/autosub" do
    source "autosub.erb"
    mode 0755
    owner "root"
    group "root"
end

template "#{node['autosub']['location']}/config.properties" do
    source "config.properties.erb"
    mode 644
    owner "root"
    group "root"
    notifies :restart, 'service[autosub]', :immediately
end

service "autosub" do
  action :start
end
