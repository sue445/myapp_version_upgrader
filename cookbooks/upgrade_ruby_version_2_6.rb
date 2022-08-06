include_recipe "./definitions/upgrade_ruby_version"

upgrade_ruby_version node[:ruby][:version]["2.6"]
