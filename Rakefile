###############################################################################
#
#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
###############################################################################
#
# Rakefile
#   This file implements the lint and spec tasks for rake so that it will loop
#   through all of the puppet modules in the deployment/puppet/ folder and run
#   the respective lint or test tasks for each module. It will then return 0 if
#   there are issues or return 1 if any of the modules fail.
#
# Author Alex Schultz <aschultz@mirantis.com>
#

require 'rake'
# Use puppet-syntax for the syntax tasks
require 'puppet-syntax/tasks/puppet-syntax'
PuppetSyntax.exclude_paths ||= []
PuppetSyntax.exclude_paths << "**/spec/fixtures/**/*"
PuppetSyntax.exclude_paths << "**/pkg/**/*"
PuppetSyntax.exclude_paths << "**/vendor/**/*"
PuppetSyntax.future_parser = true if ENV['FUTURE_PARSER'] == 'yes'

task :spec => ["spec:gemfile"]
task :lint => ["lint:gemfile", "lint:manual"]
task :syntax => ["syntax:manifests", "syntax:hiera", "syntax:files", "syntax:templates"]

namespace :common do 
  desc 'Task to generate a list of modules to skip'
  task :modulelist, [:skip_file] do |t,args|
    args.with_defaults(:skip_file => nil)

    library_dir = Dir.pwd
    skip_module_list = []
    $module_directories = []
    # TODO(aschultz): Fix all modules so they have tests and we no longer need
    # this file to exclude bad module tests
    if not args[:skip_file].nil? and File.exists?(args[:skip_file])
      File.open(args[:skip_file], 'r').each_line { |line|
        skip_module_list << line.chomp
      }
    end

    Dir.glob('./deployment/puppet/*') do |mod|
      next unless File.directory?(mod)
      if skip_module_list.include?(File.basename(mod))
        puts "Skipping tests... modules.disable_rspec includes #{mod}"
        next
      end
      $module_directories << mod
    end
  end
end


# our spec task to loop through the modules and run the tests
namespace :spec do
  desc 'Run spec tasks via module bundler with Gemfile'
  task :gemfile do |t|
    Rake::Task["modulelist"].invoke('./utils/jenkins/modules.disable_rspec')
    library_dir = Dir.pwd
    status = true

    ENV['GEM_HOME']="#{library_dir}/.bundled_gems"
    system("gem install bundler --no-rdoc --no-ri --verbose")

    $module_directories.each do |mod|
      next unless File.exists?("#{mod}/Gemfile")
      puts '-'*80
      puts "Running tests for #{mod}"
      puts '-'*80
      Dir.chdir(mod)
      begin
        result = system("bundle exec rake spec")
        if !result
          status = false
          puts "!"*80
          puts "Unit tests failed for #{mod}"
          puts "!"*80
        end
        rescue Exception => e
          puts "ERROR: Unable to run tests for #{mod}, #{e.message}"
          status = false
        end
        Dir.chdir(library_dir)
    end
    fail unless status
  end
end

# Our lint tasks
# TODO(aschultz): replace with shared lint task from the puppet helpers
namespace :lint do
  desc 'Run lint tasks from modules with an existing Gemfile/Rakefile'
  task :gemfile do |t|
    Rake::Task["modulelist"].invoke('./utils/jenkins/modules.disable_rake-lint')
    library_dir = Dir.pwd
    status = true

    ENV['GEM_HOME']="#{library_dir}/.bundled_gems"
    system("gem install bundler --no-rdoc --no-ri --verbose")

    $module_directories.each do |mod|
      next unless File.exists?("#{mod}/Gemfile")
      puts '-'*80
      puts "Running lint for #{mod}"
      puts '-'*80
      Dir.chdir(mod)
      begin
        result = system("bundle exec rake lint")
        if !result
          status = false
          puts "!"*80
          puts "Lint failed for #{mod}"
          puts "!"*80
        end
        rescue Exception => e
          puts "ERROR: Unable to run lint for #{mod}, #{e.message}"
          status = false
        end
        Dir.chdir(library_dir)
    end
    fail unless status
  end

  desc 'Find all the puppet files and run puppet-lint on them'
  task :manual do |t|
    Rake::Task["modulelist"].invoke('./utils/jenkins/modules.disable_rake-lint')
    # lint checks to skip if no Gemfile or Rakefile
    skip_checks = [ "--no-80chars-check",
        "--no-autoloader_layout-check",
        "--no-nested_classes_or_defines-check",
        "--no-only_variable_string-check",
        "--no-2sp_soft_tabs-check",
        "--no-trailing_whitespace-check",
        "--no-hard_tabs-check",
        "--no-class_inherits_from_params_class-check",
        "--with-filename"]
    library_dir = Dir.pwd
    status = true

    ENV['GEM_HOME']="#{library_dir}/.bundled_gems"
    system("gem install bundler --no-rdoc --no-ri --verbose")

    $module_directories.each do |mod|
      next unless File.exists?("#{mod}/Gemfile")
      puts '-'*80
      puts "Running lint for #{mod}"
      puts '-'*80
      Dir.chdir(mod)
      begin
        result = true
        Dir.glob("**/**.pp") do |puppet_file|
          result = false unless system("puppet-lint #{skip_checks.join(" ")} #{puppet_file}")
        end
        if !result
          status = false
          puts "!"*80
          puts "Lint failed for #{mod}"
          puts "!"*80
        end
      rescue Exception => e
          puts "ERROR: Unable to run lint for #{mod}, #{e.message}"
          status = false
      end
     Dir.chdir(library_dir)
    end
    fail unless status
  end
end

# Our syntax checking jobs
# The tasks here are an extension on top of the existing puppet helper ones.
namespace :syntax do
  desc 'Syntax check for files/ folder'
  task :files do |t|
    $stderr.puts '---> syntax:files'
    status = true
    Dir.glob('./files/**/*') do |ocf_file|
      next if File.directory?(ocf_file)

      mime_type =`file --mime --brief #{ocf_file}`
      begin
        case mime_type.to_s
        when /shellscript/
          result = system("bash -n #{ocf_file}")
        when /ruby/
          result = system("ruby -c #{ocf_file}")
        when /python/
          result = system("python -m py_compile #{ocf_file}")
        when /perl/
          result = system("perl -c #{ocf_file}")
        else
          result = true
          $stderr.puts "Unknown file format, skipping syntax check for #{ocf_file}"
        end
      rescue Exception => e
        result = false
        $stderr.puts "Checking #{ocf_file} failed with #{e.message}"
      end
      if !result
        status = false
        $stderr.puts "!"*80
        $stderr.puts "Syntax check failed for #{ocf_file}"
        $stderr.puts "!"*80
      end
    end
    fail unless status
  end
end

