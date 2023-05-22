require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "hanami/devtools/rake_tasks"

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |task|
    file_list = FileList["spec/**/*_spec.rb"]

    task.pattern = file_list
  end
end

task default: "spec:unit"
