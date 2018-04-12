# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["TRAVIS"]
  gem "byebug", require: false, platforms: :mri
  gem "yard",   require: false
end

gem "hanami-utils", "~> 2.0.alpha", require: false, git: "https://github.com/hanami/utils.git", branch: "unstable"
gem "hanami-devtools",              require: false, git: "https://github.com/hanami/devtools.git"
gem "coveralls",                    require: false
