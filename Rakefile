# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task default: :spec

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby specs/api_spec.rb'
end

desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'specs/**/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task :style do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task release?: %i[spec style audit] do
  puts "\nReady for release!"
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task console: :print_env do
  sh 'pry -r ./specs/test_load_all'
end

namespace :db do # rubocop:disable BlockLength
  require_relative 'config/environments.rb' # load config info
  require 'sequel'

  Sequel.extension :migration
  app = MusicShare::Api

  desc 'Run migrations'
  task migrate: :print_env do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'app/db/migrations')
  end

  desc 'Delete database'
  task :delete do
    app.DB[:playlists_songs].delete
    app.DB[:songs].delete
    app.DB[:playlists].delete
  end

  desc 'Delete dev or test database file'
  task :drop do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    FileUtils.rm(app.config.DB_FILENAME)
    puts "Deleted #{app.config.DB_FILENAME}"
  end

  desc 'Delete and migrate again'
  task reset: %i[drop migrate]
end

namespace :newkey do
  desc 'Create sample cryptographic key for database'
  task :db do
    require_app('lib')
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
end
