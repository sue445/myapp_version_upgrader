require_relative "base_runner"
require "open-uri"

class RubyUpdateRunner < BaseRunner
  # @param ruby_version [String]
  # @param dry_run [Boolean]
  # @param assignee [String]
  def initialize(ruby_version:, dry_run:, assignee:)
    @ruby_version = ruby_version
    super(dry_run:, assignee:)
  end

  # @return [String]
  def commit_message
    "Upgrade to Ruby #{@ruby_version} :gem:"
  end

  # @param node [Hash]
  def update_node(node)
    node[:ruby_version] = @ruby_version
    node[:ruby_version_with_patch_level] = ruby_version_with_patch_level

    v = @ruby_version.split(".")
    node[:is_full_version] = v.count == 3
    node[:ruby_minor_version] = "#{v[0]}.#{v[1]}"
    node[:gcf_runtime_version] = "ruby#{v[0]}#{v[1]}"
  end

  def recipe_file
    File.join(__dir__, "..", "cookbooks", "upgrade_ruby_version.rb")
  end

  def branch_name
    "ruby_#{@ruby_version}"
  end

  private

  def ruby_version_with_patch_level
    v = @ruby_version.split(".")
    return nil unless v.size == 3

    # Fetch RUBY_PATCHLEVEL from https://github.com/ruby/ruby/blob/master/version.h
    git_tag = "v" + @ruby_version.gsub(".", "_")
    version_h = URI.open("https://raw.githubusercontent.com/ruby/ruby/#{git_tag}/version.h").read
    ruby_patchlevel = /^#define\s+RUBY_PATCHLEVEL\s+(\d+)/.match(version_h).to_a[1]

    "#{@ruby_version}p#{ruby_patchlevel}"
  end
end
