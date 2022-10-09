require "tmpdir"
require "yaml"

class BaseRunner
  REPO_DIR = "tmp/repo"

  # @param dry_run [Boolean]
  def initialize(dry_run:, assignee:)
    @dry_run = dry_run
    @assignee = assignee
    @log_level = "info"

    @node = YAML.load_file(node_yaml)
  end

  def run
    run_itamae

    within_repo_dir(REPO_DIR) do
      if !@dry_run && updated_repo?
        escaped_commit_message = commit_message.gsub("'", "'\\\\''")

        assignee =
          if @assignee && !@assignee.empty?
            "--assignee #{@assignee}"
          else
            ""
          end

        sh "git checkout -b #{branch_name}"
        sh "git commit -am '#{escaped_commit_message}'"
        sh "git push origin #{branch_name}"
        sh "gh pr create #{assignee} --fill --title '#{escaped_commit_message}'"
      end
    end
  end

  private

  def node_yaml
    File.join(__dir__, "..", "node.yml")
  end

  def run_itamae
    Dir.mktmpdir("ci-config-itamae") do |tmp_dir|
      node = YAML.load_file(node_yaml)
      node ||= {}
      node[:github_workflow_files] = github_workflow_files(node[:repo_dir])

      update_node(node)

      tmp_node_yml = File.join(tmp_dir, "node.yml")
      File.open(tmp_node_yml, "wb") do |f|
        f.write(node.to_yaml)
      end

      args = [
        recipe_file,
        "--node-yaml=#{tmp_node_yml}",
        "--log-level=#{@log_level}"
      ]
      args << "--dry-run" if @dry_run

      sh "itamae local #{args.join(" ")}"
    end
  end

  def github_workflow_files(repo_dir)
    workflow_dir = File.join(repo_dir, ".github/workflows")
    Dir.glob("#{workflow_dir}/*.yml")
  end

  # @param repo_dir [String]
  def within_repo_dir(repo_dir)
    Dir.chdir(repo_dir) do
      yield
    end
  end

  def sh(command)
    if debug_logging?
      puts command
    end
    system(command, exception: true)
  end

  def debug_logging?
    @log_level == "debug"
  end

  def updated_repo?
    !`git status`.include?("nothing to commit, working tree clean")
  end
end
