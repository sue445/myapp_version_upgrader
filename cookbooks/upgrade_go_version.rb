REPO_DIR = "tmp/repo/"

%w(test build release).each do |name|
  file "#{REPO_DIR}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      content.gsub!(/go-version:\s+[\d.]+\s*$/, "go-version: #{node[:go_version]}")
      content.gsub!(/GO_VERSION:\s+[\d.]+$/, "GO_VERSION: #{node[:go_version]}")
    end

    only_if "ls #{REPO_DIR}/.github/workflows/#{name}.yml"
  end
end

file "#{REPO_DIR}/go.mod" do
  action :edit

  block do |content|
    content.gsub!(/^go [\d.]+$/, "go #{node[:go_version]}")
  end

  only_if "ls #{REPO_DIR}/go.mod"
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

file "#{REPO_DIR}/app.yaml" do
  action :edit

  block do |content|
    gae_runtime_version = "go#{node[:go_version].gsub(".", "")}"

    content.gsub!(/^runtime: go\d+$/, "runtime: #{gae_runtime_version}")
  end

  only_if "ls #{REPO_DIR}/app.yaml"
end
