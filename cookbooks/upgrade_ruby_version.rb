REPO_DIR = "tmp/repo/"

file "#{REPO_DIR}/.circleci/config.yml" do
  action :edit

  block do |content|
    content.gsub!(%r{- image: circleci/ruby:[\d.]+}, "- image: circleci/ruby:#{node[:ruby_version]}")
    content.gsub!(%r{- image: cimg/ruby:[\d.]+},     "- image: cimg/ruby:#{node[:ruby_version]}")
  end

  only_if "ls #{REPO_DIR}/.circleci/config.yml"
end

file "#{REPO_DIR}/wercker.yml" do
  action :edit

  block do |content|
    content.gsub!(%r{^box: ruby:([\d.]+)}, "box: ruby:#{node[:ruby_version]}")
  end

  only_if "ls #{REPO_DIR}/wercker.yml"
end

if node[:is_full_version]
  file "#{REPO_DIR}/.ruby-version" do
    action :edit

    block do |content|
      content.gsub!(/[\d.]+/, node[:ruby_version])
    end

    only_if "ls #{REPO_DIR}/.ruby-version"
  end
end

file "#{REPO_DIR}/Gemfile" do
  action :edit

  block do |content|
    if node[:is_full_version]
      content.gsub!(/^ruby "([\d.]+)"$/, %Q{ruby "#{node[:ruby_version]}"})
    else
      content.gsub!(/^ruby "([\d.]+)"$/, %Q{ruby "~> #{node[:ruby_minor_version]}.0"})
    end
  end

  only_if "ls #{REPO_DIR}/Gemfile"
end

if node[:ruby_version_with_patch_level]
  file "#{REPO_DIR}/Gemfile.lock" do
    action :edit

    block do |content|
      content.gsub!(/^RUBY VERSION\n   ruby ([\d.p]+)\n/m) do
        <<~GEMFILE_LOCK
        RUBY VERSION
           ruby #{node[:ruby_version_with_patch_level]}
        GEMFILE_LOCK
      end
    end

    only_if "ls #{REPO_DIR}/Gemfile.lock"
  end
end

file "#{REPO_DIR}/.rubocop.yml" do
  action :edit

  block do |content|
    content.gsub!(/TargetRubyVersion: ([\d.]+)/, "TargetRubyVersion: #{node[:ruby_minor_version]}")
  end

  only_if "ls #{REPO_DIR}/.rubocop.yml"
end

file "#{REPO_DIR}/Dockerfile" do
  action :edit

  block do |content|
    content.gsub!(/^FROM ruby:([\d.]+)$/, %Q{FROM ruby:#{node[:ruby_version]}})
  end

  only_if "ls #{REPO_DIR}/Dockerfile"
end

%w(
  bundle-update-pr
  deploy
  test
  build
).each do |name|
  file "#{REPO_DIR}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      content.gsub!(/ruby-version: "(.+)"/, %Q{ruby-version: "#{node[:ruby_version]}"})

      content.gsub!(/ruby\d{2}(?!\d)/, node[:gcf_runtime_version])
    end

    only_if "ls #{REPO_DIR}/.github/workflows/#{name}.yml"
  end
end

file "#{REPO_DIR}/.tool-versions" do
  action :edit

  block do |content|
    content.gsub!(/^ruby ([\d.]+)$/, %Q{ruby #{node[:ruby_version]}})
  end

  only_if "ls #{REPO_DIR}/.tool-versions"
end
