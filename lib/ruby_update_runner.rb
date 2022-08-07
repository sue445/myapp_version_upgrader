require_relative "base_runner"

class RubyUpdateRunner < BaseRunner
  # @param ruby_minor_version [String]
  # @param only_minor_version [Boolean]
  # @param dry_run [Boolean]
  # @param assignee [String]
  def initialize(ruby_minor_version:, only_minor_version:, dry_run:, assignee:)
    @ruby_minor_version = ruby_minor_version
    @only_minor_version = only_minor_version
    super(dry_run:, assignee:)
  end

  # @return [String]
  def commit_message
    if @only_minor_version
      "Upgrade to Ruby #{@ruby_minor_version} :gem:"
    else
      "Upgrade to Ruby #{ruby_full_version} :gem:"
    end
  end

  # @param node [Hash]
  def update_node(node)
    node["only_minor_version"] = @only_minor_version
    node["ruby_full_version"] = ruby_full_version
  end

  def recipe_file
    File.join(__dir__, "..", "cookbooks", "upgrade_ruby_version.rb")
  end

  def branch_name
    return "ruby_#{@ruby_minor_version}" if @only_minor_version

    "ruby_#{ruby_full_version}"
  end

  private

  # @return [String]
  def ruby_full_version
    @node["ruby"]["version"][@ruby_minor_version]
  end
end
