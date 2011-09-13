unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/git/notifier requires Capistrano 2"
end

require 'capistrano'
require 'tinder'
require 'pony'

Capistrano::Configuration.instance.load do

	after "deploy:update", "git:notifier:campfire"
	
  namespace :git do

		namespace :notifier do

			def tag_format(options = {})
        tag_format = ":rails_env_:release"
        tag_format = tag_format.gsub(":rails_env", options[:rails_env] || rails_env)
        tag_format = tag_format.gsub(":release",   options[:release]   || "")
        tag_format
      end

			branch_name = `git branch`.split(/\s/)[1]
			user = `git config --get user.name`
			email = `git config --get user.email`
			deployer = "#{user} (#{email})"
			source_repo = `git config --get remote.origin.url`.split(':')[1].split('.')[0]
			application_name = `git config --get remote.origin.url`.strip.split('/').last.split('.').first
			tags = `git tag -l`.split(/\n/).reverse
			
			deployed_version = "#{tag_format(:release => release_name)}"
			deployed = tags[1]
			deploying = tags[0]
			compare_url = "http://github.com/#{source_repo}/compare/#{deployed}...#{deploying}"
      
		  desc 'Alert Campfire of a deploy'
		  task :campfire do

				campfire = Tinder::Campfire.new 'pig', :token => 'f40051873e877ad46c2adcf59902174e7fab0376'
				room = campfire.find_room_by_name("The Web Team")
				room.speak "#{deployer} deployed "
				room.speak "#{branch_name} branch of #{application_name} to #{rails_env} "
				room.speak "with `cap #{ARGV.join(' ')}` (#{compare_url})"
				
				release_notes = File.read(rails_root + "/config/CHANGELOG").split(/\n/)
				release_notes.each do |line|
					room.speak "#{line}"
				end
				
		  end
		
		
			desc 'Alert e-mail lists of a deploy'
			task :mailer do
				release_notes = File.read(rails_root + "/config/CHANGELOG")
				body = ""
				body << "----------------------------------------------------------------\n"
				body << "Version: #{deployed_version.strip}\n"
	      body << "Deployed: #{Date.today} at #{Time.now}\n"
	      body << "Contact: #{user.strip} (#{email.strip})\n"
	      body << "----------------------------------------------------------------\n"
	      body << release_notes.gsub(/^ */, ' ' * 4)
	      body << "\n----------------------------------------------------------------\n\n"
				      
				Pony.mail(:to => 'sfweb@sourcefire.com', 
				:via => :sendmail, 
				:subject => "deployment notice: #{branch_name} branch of #{application_name} to #{rails_env}" ,
				:body => body)
			end
		end
	end
end