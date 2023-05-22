source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", platforms: :mri
  gem "yard"
  gem "yard-junk"
end

gem "hanami-utils", "~> 2.0", git: "https://github.com/hanami/utils.git", branch: "main"
gem "hanami-devtools", git: "https://github.com/hanami/devtools.git", branch: "main"
