REPO_DIR = "tmp/repo/"

gcp_runtime_version = "go#{node[:go_version].gsub(".", "")}"

%w(
  build
  release
  test
).each do |name|
  file "#{REPO_DIR}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      content.gsub!(/go-version:\s+[\d.]+\s*$/, "go-version: #{node[:go_version]}")
      content.gsub!(/GO_VERSION:\s+[\d.]+$/, "GO_VERSION: #{node[:go_version]}")
    end

    only_if "ls #{REPO_DIR}/.github/workflows/#{name}.yml"
  end
end

%w(
  go.mod
  function/go.mod
).each do |name|
  file "#{REPO_DIR}/#{name}" do
    action :edit

    block do |content|
      content.gsub!(/^go [\d.]+$/, "go #{node[:go_version]}")
    end

    only_if "ls #{REPO_DIR}/#{name}"
  end
end

file "#{REPO_DIR}/.circleci/config.yml" do
  action :edit

  block do |content|
    content.gsub!(%r{- image: circleci/golang:[\d.]+}, "- image: circleci/golang:#{node[:go_version]}")
    content.gsub!(%r{- image: cimg/go:[\d.]+}, "- image: cimg/go:#{node[:go_version]}")
  end

  only_if "ls #{REPO_DIR}/.circleci/config.yml"
end

file "#{REPO_DIR}/Dockerfile" do
  action :edit

  block do |content|
    content.gsub!(/^FROM golang:([\d.]+)/, %Q{FROM golang:#{node[:go_version]}})
  end

  only_if "ls #{REPO_DIR}/Dockerfile"
end

%w(
  app.yaml
  serverless.yml
  function/serverless.yml
).each do |name|
  file "#{REPO_DIR}/#{name}" do
    action :edit

    block do |content|
      content.gsub!(/^runtime: go\d+$/, "runtime: #{gcp_runtime_version}")
    end

    only_if "ls #{REPO_DIR}/#{name}"
  end
end
