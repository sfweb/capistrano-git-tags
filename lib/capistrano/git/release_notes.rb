unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/git/release_notes requires Capistrano 2"
end

require 'capistrano'
require 'tempfile'

Capistrano::Configuration.instance.load do

  after  "git:tags:push_deploy_tag", "git:release_notes:build_release_notes"

  namespace :git do

    namespace :release_notes do

      desc "Ask deploy user if release notes have been updated and build VERSION file"
      task :build_release_notes do
        user = `git config --get user.name`
        email = `git config --get user.email`
        deployed = `git describe --abbrev=0`

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
						puts "Lies! You must update /config/CHANGELOG before deploying this application."
					end
				else
					puts "You must update /config/CHANGELOG before deploying this application."
				end
      end

    end

  end

end