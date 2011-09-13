unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/git/notifier requires Capistrano 2"
end

require 'capistrano'
require 'tinder'

Capistrano::Configuration.instance.load do

	after "deploy:update", "git:notify:campfire"
	
  namespace :git do

		namespace :notifier do
		
			def tag_format(options = {})
        tag_format = ":rails_env_:release"
        tag_format = tag_format.gsub(":rails_env", options[:rails_env] || rails_env)
        tag_format = tag_format.gsub(":release",   options[:release]   || "")
        tag_format
      end
      
		  desc 'Alert Campfire of a deploy'
		  task :campfire do
		
		    branch_name = `git branch`.split(/\s/)[1]
		    user = `git config --get user.name`
        email = `git config --get user.email`
		    deployer = "#{user} (#{email})"
		    

		    deployed = `curl -s http://github.com/site/sha`[0,7]
		    deploying = `git rev-parse HEAD`[0,7]
		    compare_url = "#{source_repo_url}/compare/#{deployed}...#{deploying}"
		
				campfire = Tinder::Campfire.new 'pig', :token => 'f40051873e877ad46c2adcf59902174e7fab0376'
				room = campfire.find_room_by_name("The Web Team")
				room.speak "#{deployer} deployed "
				room.speak "#{branch_name} (#{deployed}..#{deploying}) to #{rails_env} "
				room.speak "with `cap #{ARGV.join(' ')}` (#{compare_url})"
				
		  end
		end
	end
end