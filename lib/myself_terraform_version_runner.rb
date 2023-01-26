require_relative "base_runner"

require "json"

class MyselfTerraformVersionRunner < BaseRunner
  # @return [String]
  def commit_message
    "Upgrade to Terraform #{latest_terraform_version} :rocket:"
  end

  # @param node [Hash]
  def update_node(node)
    node[:latest_terraform_version] = latest_terraform_version
  end

  def recipe_file
    File.join(__dir__, "..", "cookbooks", "upgrade_myself_terraform_version.rb")
  end

  def branch_name
    "terraform_#{latest_terraform_version}"
  end

  def latest_terraform_version
    return @latest_terraform_version if @latest_terraform_version

    tags = github_stable_tag_names("hashicorp/terraform")
    versions = tags.map { |tag| tag.gsub(/^v/, "") }

    @latest_terraform_version = versions.max_by { |v| Gem::Version.create(v) }
  end

  def github_stable_tag_names(repo_name)
    tags = JSON.parse(`gh api repos/#{repo_name}/tags`)
    tag_names = tags.map { |tag| tag["name"] }
    tag_names.select { |tag| tag.match?(/v[.0-9]+$/) }
  end
end
