# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", require: false, platforms: :mri
  gem "yard",   require: false
end

gem "hanami-utils", "~> 1.3.beta", require: false, git: "https://github.com/hanami/utils.git", branch: "develop"
gem "hanami-devtools", require: false, git: "https://github.com/hanami/devtools.git"
