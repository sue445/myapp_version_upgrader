REPO_DIR = "tmp/repo/"

file "#{REPO_DIR}/.terraform-version" do
  content "#{node[:terraform_version]}\n"

  only_if "ls #{REPO_DIR}/.terraform-version"
end

file "#{REPO_DIR}/.github/workflows/terraform.yml" do
  action :edit

  block do |content|
    content.gsub!(/TERRAFORM_VERSION: [0-9.]+/, "TERRAFORM_VERSION: #{node[:terraform_version]}")
  end

  only_if "ls #{REPO_DIR}/.github/workflows/terraform.yml"
end
