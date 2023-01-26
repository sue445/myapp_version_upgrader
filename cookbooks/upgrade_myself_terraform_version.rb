file "#{node[:repo_dir]}/.github/workflows/upgrade_terraform.yml" do
  action :edit

  block do |content|
    content.gsub!(%r(terraform_version: +".+"), %Q(terraform_version: "#{node[:latest_terraform_version]}"))
  end

  only_if "ls #{node[:repo_dir]}/.github/workflows/upgrade_terraform.yml"
end
