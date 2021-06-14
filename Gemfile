# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", require: false, platforms: :mri
  gem "yard",   require: false
end

gem "hanami-utils", "~> 1.3", require: false, git: "https://github.com/hanami/utils.git", branch: "1.3.x"
gem "hanami-devtools",        require: false, git: "https://github.com/hanami/devtools.git", branch: "1.3.x"
