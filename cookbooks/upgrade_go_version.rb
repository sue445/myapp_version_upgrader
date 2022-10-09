gcp_runtime_version = "go#{node[:go_version].gsub(".", "")}"

%w(
  build
  release
  test
).each do |name|
  file "#{node[:repo_dir]}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      content.gsub!(/go-version:\s+[\d.]+\s*$/, "go-version: #{node[:go_version]}")
      content.gsub!(/GO_VERSION:\s+[\d.]+$/, "GO_VERSION: #{node[:go_version]}")
    end

    only_if "ls #{node[:repo_dir]}/.github/workflows/#{name}.yml"
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
    end

    only_if "ls #{node[:repo_dir]}/#{name}"
  end
end

file "#{node[:repo_dir]}/.circleci/config.yml" do
  action :edit

  block do |content|
    content.gsub!(%r{- image: circleci/golang:[\d.]+}, "- image: circleci/golang:#{node[:go_version]}")
    content.gsub!(%r{- image: cimg/go:[\d.]+}, "- image: cimg/go:#{node[:go_version]}")
  end

  only_if "ls #{node[:repo_dir]}/.circleci/config.yml"
end

file "#{node[:repo_dir]}/Dockerfile" do
  action :edit

  block do |content|
    content.gsub!(/^FROM golang:([\d.]+)/, %Q{FROM golang:#{node[:go_version]}})
  end

  only_if "ls #{node[:repo_dir]}/Dockerfile"
end

%w(
  app.yaml
  serverless.yml
  function/serverless.yml
).each do |name|
  file "#{node[:repo_dir]}/#{name}" do
    action :edit

    block do |content|
      content.gsub!(/^runtime: go\d+$/, "runtime: #{gcp_runtime_version}")
    end

    only_if "ls #{node[:repo_dir]}/#{name}"
  end
end
