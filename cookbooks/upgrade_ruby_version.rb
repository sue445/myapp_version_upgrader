require "open-uri"

REPO_DIR = "tmp/repo/"

# Fetch RUBY_PATCHLEVEL from https://github.com/ruby/ruby/blob/master/version.h
git_tag = "v" + node[:ruby_full_version].gsub(".", "_")
version_h = URI.open("https://raw.githubusercontent.com/ruby/ruby/#{git_tag}/version.h").read
ruby_patchlevel = /^#define\s+RUBY_PATCHLEVEL\s+(\d+)/.match(version_h).to_a[1]
full_version_with_patch_level = "#{node[:ruby_full_version]}p#{ruby_patchlevel}"

v = node[:ruby_full_version].split(".")
minor_version = "#{v[0]}.#{v[1]}"

gcf_runtime_version = "ruby#{v[0]}#{v[1]}"

file "#{REPO_DIR}/.circleci/config.yml" do
  action :edit

  block do |content|
    if node[:only_minor_version]
      content.gsub!(%r{- image: circleci/ruby:[\d.]+}, "- image: circleci/ruby:#{minor_version}")
      content.gsub!(%r{- image: cimg/ruby:[\d.]+},     "- image: cimg/ruby:#{minor_version}")
    else
      content.gsub!(%r{- image: circleci/ruby:[\d.]+}, "- image: circleci/ruby:#{node[:ruby_full_version]}")
      content.gsub!(%r{- image: cimg/ruby:[\d.]+},     "- image: cimg/ruby:#{node[:ruby_full_version]}")
    end
  end

  only_if "ls #{REPO_DIR}/.circleci/config.yml"
end

file "#{REPO_DIR}/wercker.yml" do
  action :edit

  block do |content|
    if node[:only_minor_version]
      content.gsub!(%r{^box: ruby:([\d.]+)}, "box: ruby:#{minor_version}")
    else
      content.gsub!(%r{^box: ruby:([\d.]+)}, "box: ruby:#{node[:ruby_full_version]}")
    end
  end

  only_if "ls #{REPO_DIR}/wercker.yml"
end

unless node[:only_minor_version]
  file "#{REPO_DIR}/.ruby-version" do
    action :edit

    block do |content|
      content.gsub!(/[\d.]+/, node[:ruby_full_version])
    end

    only_if "ls #{REPO_DIR}/.ruby-version"
  end
end

file "#{REPO_DIR}/Gemfile" do
  action :edit

  block do |content|
    if node[:only_minor_version]
      content.gsub!(/^ruby "([\d.]+)"$/, %Q{ruby "~> #{minor_version}.0"})
    else
      content.gsub!(/^ruby "([\d.]+)"$/, %Q{ruby "#{node[:ruby_full_version]}"})
    end
  end

  only_if "ls #{REPO_DIR}/Gemfile"
end

file "#{REPO_DIR}/Gemfile.lock" do
  action :edit

  block do |content|
    content.gsub!(/^RUBY VERSION\n   ruby ([\d.p]+)\n/m) do
      <<~GEMFILE_LOCK
        RUBY VERSION
           ruby #{full_version_with_patch_level}
      GEMFILE_LOCK
    end
  end

  only_if "ls #{REPO_DIR}/Gemfile.lock"
end

file "#{REPO_DIR}/.rubocop.yml" do
  action :edit

  block do |content|
    content.gsub!(/TargetRubyVersion: ([\d.]+)/, "TargetRubyVersion: #{minor_version}")
  end

  only_if "ls #{REPO_DIR}/.rubocop.yml"
end

file "#{REPO_DIR}/Dockerfile" do
  action :edit

  block do |content|
    if node[:only_minor_version]
      content.gsub!(/^FROM ruby:([\d.]+)$/, %Q{FROM ruby:#{minor_version}.0})
    else
      content.gsub!(/^FROM ruby:([\d.]+)$/, %Q{FROM ruby:#{node[:ruby_full_version]}})
    end
  end

  only_if "ls #{REPO_DIR}/Dockerfile"
end

%w(
  bundle-update-pr
  deploy
  test
).each do |name|
  file "#{REPO_DIR}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      if node[:only_minor_version]
        content.gsub!(/ruby-version: "(.+)"/, %Q{ruby-version: "#{minor_version}"})
      else
        content.gsub!(/ruby-version: "(.+)"/, %Q{ruby-version: "#{node[:ruby_full_version]}"})
      end

      content.gsub!(/ruby\d{2}(?!\d)/, gcf_runtime_version)
    end

    only_if "ls #{REPO_DIR}/.github/workflows/#{name}.yml"
  end
end
