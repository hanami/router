# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", platforms: :mri
  gem "yard"
  gem "yard-junk"
end

if ENV["RACK_VERSION_CONSTRAINT"]
  gem "rack", ENV["RACK_VERSION_CONSTRAINT"]
end

gem "hanami-devtools", github: "hanami/devtools", branch: "main"
gem "rexml"
