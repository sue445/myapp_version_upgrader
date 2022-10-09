file "#{node[:repo_dir]}/.terraform-version" do
  content "#{node[:terraform_version]}\n"

  only_if "ls #{node[:repo_dir]}/.terraform-version"
end

file "#{node[:repo_dir]}/.github/workflows/terraform.yml" do
  action :edit

  block do |content|
    content.gsub!(/TERRAFORM_VERSION: [0-9.]+/, "TERRAFORM_VERSION: #{node[:terraform_version]}")
  end

  only_if "ls #{node[:repo_dir]}/.github/workflows/terraform.yml"
end
