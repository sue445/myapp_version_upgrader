require "tmpdir"
require "yaml"

class BaseRunner
  REPO_DIR = "tmp/repo"

  # @param dry_run [Boolean]
  # @param assignee [String]
  # @param log_level [String]
  def initialize(dry_run:, assignee:, log_level:)
    @dry_run = dry_run
    @assignee = assignee
    @log_level = log_level
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

  def run_itamae
    Dir.mktmpdir("ci-config-itamae") do |tmp_dir|
      repo_dir = "tmp/repo/"

      node = {
        repo_dir: repo_dir,
        github_workflow_files: github_workflow_files(repo_dir)
      }

      update_node(node)

      node.transform_keys!(&:to_s)

      tmp_node_yml = File.join(tmp_dir, "node.yml")
      File.open(tmp_node_yml, "wb") do |f|
        f.write(node.to_yaml)
      end

      if @log_level == "debug"
        puts "[DEBUG] #{tmp_node_yml}"
        puts node.to_yaml
        puts ""
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
