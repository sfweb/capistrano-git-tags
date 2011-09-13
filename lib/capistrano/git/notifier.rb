unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/git/notifier requires Capistrano 2"
end

require 'capistrano'
require 'campfire'

Capistrano::Configuration.instance.load do

	after "deploy:update", "git:notify:campfire"
	
  namespace :git do

		namespace :notify do
		  desc 'Alert Campfire of a deploy'
		  task :campfire do
		    branch_name = branch.split('/', 2).last
		    user = `git config --get user.name`
        email = `git config --get user.email`
		    deployer = "#{user} (#{email})"
		    

		    deployed = `curl -s http://github.com/site/sha`[0,7]
		    deploying = `git rev-parse HEAD`[0,7]
		    compare_url = "#{source_repo_url}/compare/#{deployed}...#{deploying}"
		
		    Campfire.notify(
		      "#{deployer} deployed " +
		      "#{branch_name} (#{deployed}..#{deploying}) to #{rails_env} " +
		      "with `cap #{ARGV.join(' ')}` (#{compare_url})"
		    )
		  end
		end
	end
end