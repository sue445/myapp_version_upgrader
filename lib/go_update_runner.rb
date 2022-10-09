require_relative "base_runner"

class GoUpdateRunner < BaseRunner
  # @param go_version [String]
  # @param dry_run [Boolean]
  # @param assignee [String]
  def initialize(go_version:, dry_run:, assignee:)
    @go_version = go_version
    super(dry_run:, assignee:)
  end

  # @return [String]
  def commit_message
    "Upgrade to Go #{@go_version} :rocket:"
  end

  # @param node [Hash]
  def update_node(node)
    node[:go_version] = @go_version
  end

  def recipe_file
    File.join(__dir__, "..", "cookbooks", "upgrade_go_version.rb")
  end

  def branch_name
    "go_#{@go_version}"
  end
end
