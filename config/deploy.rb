# Necessary to run on Site5
user = "grawerpix"
load 'deploy/assets', :on_error => :continue
require "rvm/capistrano"
require "bundler/capistrano"

set :use_sudo, false
set :group_writable, false
set :default_env,  'production'
set :rails_env,     ENV['rails_env'] || ENV['RAILS_ENV'] || default_env
set :gemhome, "/home/grawerpix/ruby/gems"
set :gempath, "/home/grawerpix/ruby/gems"
set :rake, "source /home/grawerpix/.bash_profile && GEM_HOME=/home/grawerpix/ruby/gems rake"
set :rvm_ruby_string, 'ruby-1.9.3-p194@greg-bud.info'
set :rvm_gemset_name, 'greg-bud.info'
#set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
set :rvm_type, :system
#set :rvm_path, '/usr/local/rvm'

set :normalize_asset_timestamps, false #to avoid warnings for asset pipeline

#set :bundle_cmd, 'source /home/grawerpix/.bash_profile && bundle'

# Less releases, less space wasted
set :keep_releases, 2

# The mandatory stuff
set :application, "greg-bud.info"
set :user, "#{user}"

# GIT information
default_run_options[:pty] = true
set :repository,  "git@github.com:MariuszHenn/greg-bud.info.git"

set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache



# This is related to site5 too.
set :deploy_to, "/home/grawerpix/rubyapps/greg-bud.info"
app_name = "greg-bud.info"
role :app, app_name
role :web, app_name
role :db,  app_name, :primary => true
ssh_options[:port] = 123 
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end

after "deploy" do
 deploy::cleanup
end

task :link_shared_directories do
  #do uploadow
  shared_dir = File.join(shared_path, 'uploads')
  release_dir = File.join(current_release,'uploads')
  run("mkdir -p #{shared_dir} && ln -s -f #{shared_dir} #{release_dir}")
  #do uploadow
  shared_dir = File.join(shared_path, 'bundle')
  release_dir = File.join(current_release, 'vendor','bundle')
  run("mkdir -p #{shared_dir} && ln -s -f #{shared_dir} #{release_dir}")
  #do logow
  shared_dir = File.join(shared_path, 'log')
  release_dir = File.join(current_release, 'log')
  run("mkdir -p #{shared_dir}")
  #do cache
  shared_dir = File.join(shared_path, 'tmp','cache')
  release_dir = File.join(current_release, 'tmp','cache')
  run("mkdir -p #{shared_dir} && ln -s -f #{shared_dir} #{release_dir}")
  #do cache
  shared_dir = File.join(shared_path, 'assets')
  release_dir = File.join(current_release, 'public','assets')
  run("mkdir -p #{shared_dir} && ln -s -f #{shared_dir} #{release_dir}")
  #do pictures
  shared_dir = File.join(shared_path, 'pictures')
  release_dir = File.join(current_release, 'public','pictures')
  run("mkdir -p #{shared_dir} && ln -s -f #{shared_dir} #{release_dir}")
  
end

task :migrate_db, :roles => :app do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake db:migrate"
end

task :compile_deface, :roles => :app do
  #run "cd #{release_path} && RAILS_ENV=production bundle exec rake deface:precompile"
end


after "deploy:update_code", :link_shared_directories, :migrate_db

namespace :dragonfly do
  desc "Symlink the Rack::Cache files"
  task :create_symlink, :roles => [:app] do
    run "mkdir -p #{shared_path}/tmp/dragonfly && ln -nfs #{shared_path}/tmp/dragonfly #{release_path}/tmp/dragonfly"
  end
end
after 'deploy:update_code', 'dragonfly:create_symlink'

#compiling assets whe necessary
set :max_asset_age, 2 ## Set asset age in minutes to test modified date against.

after "deploy:finalize_update", "deploy:assets:determine_modified_assets", "deploy:assets:conditionally_precompile"

namespace :deploy do
  namespace :assets do

    desc "Figure out modified assets."
    task :determine_modified_assets, :roles => assets_role, :except => { :no_release => true } do
      set :updated_assets, capture("find #{latest_release}/app/assets -type d -name .git -prune -o -mmin -#{max_asset_age} -type f -print", :except => { :no_release => true }).split
    end

    desc "Remove callback for asset precompiling unless assets were updated in most recent git commit."
    task :conditionally_precompile, :roles => assets_role, :except => { :no_release => true } do
      if(updated_assets.empty?)
        callback = callbacks[:after].find{|c| c.source == "deploy:assets:precompile" }
        callbacks[:after].delete(callback)
        logger.info("Skipping asset precompiling, no updated assets.")
      else
        logger.info("#{updated_assets.length} updated assets. Will precompile.")
      end
    end

  end
end
