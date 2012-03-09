# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rake-version"
  gem.homepage = "http://github.com/AlphaHydrae/rake-version"
  gem.license = "MIT"
  gem.summary = %Q{Rake tasks for version management.}
  gem.description = %Q{Rake tasks for version management.}
  gem.email = "hydrae.alpha@gmail.com"
  gem.authors = ["AlphaHydrae"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  #t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

task :default => :spec

desc "Generate documentation"
task :doc => ['doc:generate']
namespace :doc do
  project_root = File.dirname __FILE__
  doc_destination = File.join project_root, 'doc'

  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + 
                   [ File.join(project_root, 'README.md') ]
      yt.options = ['--output-dir', doc_destination, '--readme', 'README.md', '--private', '--protected']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end
end
