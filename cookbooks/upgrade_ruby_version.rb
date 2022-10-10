file "#{node[:repo_dir]}/.circleci/config.yml" do
  action :edit

  block do |content|
    content.gsub!(%r{- image: circleci/ruby:[\d.]+}, "- image: circleci/ruby:#{node[:ruby_version]}")
    content.gsub!(%r{- image: cimg/ruby:[\d.]+},     "- image: cimg/ruby:#{node[:ruby_version]}")
  end

  only_if "ls #{node[:repo_dir]}/.circleci/config.yml"
end

file "#{node[:repo_dir]}/wercker.yml" do
  action :edit

  block do |content|
    content.gsub!(%r{^box: ruby:([\d.]+)}, "box: ruby:#{node[:ruby_version]}")
  end

  only_if "ls #{node[:repo_dir]}/wercker.yml"
end

if node[:is_full_version]
  file "#{node[:repo_dir]}/.ruby-version" do
    action :edit

    block do |content|
      content.gsub!(/[\d.]+/, node[:ruby_version])
    end

    only_if "ls #{node[:repo_dir]}/.ruby-version"
  end
end

file "#{node[:repo_dir]}/Gemfile" do
  action :edit

  block do |content|
    if node[:is_full_version]
      content.gsub!(/^ruby "([\d.]+)"$/, %Q{ruby "#{node[:ruby_version]}"})
    else
      content.gsub!(/^ruby "([\d.]+)"$/, %Q{ruby "~> #{node[:ruby_minor_version]}.0"})
    end
  end

  only_if "ls #{node[:repo_dir]}/Gemfile"
end

if node[:ruby_version_with_patch_level]
  file "#{node[:repo_dir]}/Gemfile.lock" do
    action :edit

    block do |content|
      content.gsub!(/^RUBY VERSION\n   ruby ([\d.p]+)\n/m) do
        <<~GEMFILE_LOCK
        RUBY VERSION
           ruby #{node[:ruby_version_with_patch_level]}
        GEMFILE_LOCK
      end
    end

    only_if "ls #{node[:repo_dir]}/Gemfile.lock"
  end
end

file "#{node[:repo_dir]}/.rubocop.yml" do
  action :edit

  block do |content|
    content.gsub!(/TargetRubyVersion: ([\d.]+)/, "TargetRubyVersion: #{node[:ruby_minor_version]}")
  end

  only_if "ls #{node[:repo_dir]}/.rubocop.yml"
end

file "#{node[:repo_dir]}/Dockerfile" do
  action :edit

  block do |content|
    content.gsub!(/^FROM ruby:([\d.]+)$/, %Q{FROM ruby:#{node[:ruby_version]}})
  end

  only_if "ls #{node[:repo_dir]}/Dockerfile"
end

node[:github_workflow_files].each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      content.gsub!(/ruby-version: "(.+)"/, %Q{ruby-version: "#{node[:ruby_version]}"})

      content.gsub!(/ruby\d{2}(?!\d)/, node[:gcf_runtime_version])
    end

    only_if "ls #{workflow_file}"
  end
end

file "#{node[:repo_dir]}/.tool-versions" do
  action :edit

  block do |content|
    content.gsub!(/^ruby ([\d.]+)$/, "ruby #{node[:ruby_version]}")
  end

  only_if "ls #{node[:repo_dir]}/.tool-versions"
end
