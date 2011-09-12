unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/git/release_notes requires Capistrano 2"
end

require 'capistrano'
require 'tempfile'

Capistrano::Configuration.instance.load do

	before "deploy:update", "git:release_notes:build"
	after "git:release_notes:build", "git:release_notes:push_version_file"

  namespace :git do

    namespace :release_notes do

			def tag_format(options = {})
        tag_format = ":rails_env_:release"
        tag_format = tag_format.gsub(":rails_env", options[:rails_env] || rails_env)
        tag_format = tag_format.gsub(":release",   options[:release]   || "")
        tag_format
      end

      desc "Ask deploy user if release notes have been updated and build VERSION file"
      task :build do
        user = `git config --get user.name`
        email = `git config --get user.email`
        deployed = "#{tag_format(:release => release_name)}"

				response = Capistrano::CLI.ui.ask("Have you updated the release notes in config/CHANGELOG?")
				if response =~ /y(es)?/i
					release_notes = File.read(rails_root + "/config/CHANGELOG")
					if release_notes  != ""
						Tempfile.open File.basename(rails_root + "/public/tmp") do |tempfile|
				      # prepend data to tempfile
				      tempfile << "----------------------------------------------------------------\n"
							tempfile << "Version: #{deployed.strip}\n"
				      tempfile << "Deployed: #{Date.today} at #{Time.now}\n"
				      tempfile << "Contact: #{user.strip} (#{email.strip})\n"
				      tempfile << "----------------------------------------------------------------\n"
				      tempfile << release_notes.gsub(/^ */, ' ' * 4)
				      tempfile << "\n----------------------------------------------------------------\n\n"
				
				      File.open(rails_root + "/public/VERSION", File::RDWR|File::CREAT) do |file|
				        # append original data to tempfile
				        tempfile << file.read
				        # reset file positions
				        file.pos = tempfile.pos = 0
				        # copy all data back to original file
				        file.write(tempfile.read)
				      end
				    end
						File.open(rails_root + "/config/CHANGELOG",'w') {|file| file << ""}
					else
						raise Capistrano::CommandError, "You must update /config/CHANGELOG before deploying this application."
					end
				else
					raise Capistrano::CommandError, "You must update /config/CHANGELOG before deploying this application."
				end
      end
      
      desc "Push git revision with new VERSION file"
			task :push_version_file
				version_notes = File.read(rails_root + "/public/VERSION")
				`git add #{version_notes}` unless version_notes.exists?
				`git commit -a -m "update version file for deploy"`
				`git push origin master`
			end

    end

  end

end