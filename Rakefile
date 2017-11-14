# frozen_string_literal: true

require "rake"
require "rake/testtask"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
  t.libs.push "test"
end

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |task|
    file_list = FileList["spec/**/*_spec.rb"]

    task.pattern = file_list
  end

  task :coverage do
    ENV["COVERAGE"] = "true"
    Rake::Task["spec:unit"].invoke
  end
end

task default: "spec:unit"
