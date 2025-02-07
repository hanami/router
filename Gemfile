# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", platforms: :mri
  gem "yard"
  gem "yard-junk"
end

gem "hanami-devtools", github: "kyleplump/devtools", branch: "rack3"
# gem "hanami-devtools", github: "hanami/devtools", branch: "main"
gem "rexml"
