node[:go_minor_version] = node[:go_version].to_f

node[:github_workflow_files].each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      content.gsub!(/go-version:\s+[\d.]+\s*$/, "go-version: #{node[:go_version]}")
      content.gsub!(/GO_VERSION:\s+[\d.]+$/, "GO_VERSION: #{node[:go_version]}")
    end

    only_if "ls #{workflow_file}"
  end
end

%w(
  go.mod
  function/go.mod
).each do |name|
  file "#{node[:repo_dir]}/#{name}" do
    action :edit

    block do |content|
      content.gsub!(/^go [\d.]+$/, "go #{node[:go_version]}")

      if content.match?(/^toolchain go[\d.]+$/)
        if node[:go_minor_version] >= 1.21 && node[:go_minor_version] < 1.23
          content.gsub!(/^toolchain go[\d.]+$/, "toolchain go#{node[:go_minor_version]}.0")
        else
          # toolchain is needless since Go 1.23
          # c.f. https://github.com/golang/go/issues/62278#issuecomment-2062002018
          content.gsub!(/^toolchain go[\d.]+$/, "")
        end
      else
        if node[:go_minor_version] >= 1.21 && node[:go_minor_version] < 1.23
          # toolchain is requires for dependabot
          # c.f. https://github.com/orgs/community/discussions/65431#discussioncomment-6875620
          content.gsub!(/^go [\d.]+$/, "go #{node[:go_version]}\ntoolchain go#{node[:go_minor_version]}.0")
        end
      end
    end

    only_if "ls #{node[:repo_dir]}/#{name}"
  end
end

file "#{node[:repo_dir]}/.circleci/config.yml" do
  action :edit

  block do |content|
    content.gsub!(%r{- image: circleci/golang:[\d.]+}, "- image: circleci/golang:#{node[:go_minor_version]}")
    content.gsub!(%r{- image: cimg/go:[\d.]+}, "- image: cimg/go:#{node[:go_minor_version]}")
  end

  only_if "ls #{node[:repo_dir]}/.circleci/config.yml"
end


%w(
  Dockerfile
  function/Dockerfile
).each do |name|
  file "#{node[:repo_dir]}/#{name}" do
    action :edit

    block do |content|
      content.gsub!(/^FROM golang:([\d.]+)/, %Q{FROM golang:#{node[:go_minor_version]}})
    end

    only_if "ls #{node[:repo_dir]}/#{name}"
  end
end

(node[:github_workflow_files] + ["#{node[:repo_dir]}/app.yaml"]).each do |name|
  file name do
    action :edit

    block do |content|
      content.gsub!(/go\d{3}(?!\d)/, node[:gcp_runtime_version] )
    end

    only_if "ls #{name}"
  end
end
