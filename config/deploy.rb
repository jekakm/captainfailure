# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'captainfailure'
set :repo_url, 'https://github.com/stfalcon-studio/captainfailure.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/captainfailure'

set :rvm_type, :user
set :rvm_ruby_version, '2.2.2'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/application.rb', 'config/initializers/devise.rb', 'config/database.yml', 'config/secrets.yml', 'config/unicorn.rb')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :unicorn_restart do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "/etc/init.d/unicorn upgrade"
    end
  end

  after :finishing, 'deploy:unicorn_restart'
  
  after :restart, :clear_cache do
    on roles(:web) do
    end
  end

end
