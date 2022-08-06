require_relative "base_runner"

class TerraformUpdateRunner < BaseRunner
  # @param terraform_version [String]
  # @param dry_run [Boolean]
  # @param assignee [String]
  def initialize(terraform_version:, dry_run:, assignee:)
    @terraform_version = terraform_version
    super(dry_run:, assignee:)
  end

  # @return [String]
  def commit_message
    "Upgrade to Terraform #{@terraform_version} :rocket:"
  end

  # @param node [Hash]
  def update_node(node)
    node["terraform_version"] = @terraform_version
  end

  def recipe_file
    File.join(__dir__, "..", "cookbooks", "upgrade_terraform_version.rb")
  end

  def branch_name
    "terraform_#{@terraform_version}"
  end
end
