unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/git/release_notes requires Capistrano 2"
end

require 'capistrano'

Capistrano::Configuration.instance.load do

  after  "git:tags:push_deploy_tag", "git:release_notes:build_release_notes"
  before "git:tags:cleanup_deploy_tag", "git:release_notes:cleanup_release_notes"

  namespace :git do

    namespace :release_notes do

      def tag_format(options = {})
        tag_format = git_tag_format || ":rails_env_:release"
        tag_format = tag_format.gsub(":rails_env", options[:rails_env] || rails_env)
        tag_format = tag_format.gsub(":release",   options[:release]   || "")
        tag_format
      end

      desc "Ask deploy user if release notes have been updated and build VERSION file"
      task :build_release_notes do
        user = `git config --get user.name`
        email = `git config --get user.email`
        deployed = `git describe --abbrev=0`

				response = Capistrano::CLI.ui.ask("Have you updated the release notes in config/CHANGELOG?")
				if response !~ /y(es)?/i
					release_notes = File.read(RAILS_ROOT + "/config/CHANGELOG")
					public_version = File.read(RAILS_ROOT + "/public/VERSION")
					
					new_public_version = File.open(RAILS_ROOT + "/public/VERSION", 'w')
					new_public_version.puts("deployed on #{Date.today} at #{Time.now} by #{user} (#{email})\n")
					new_public_version.puts("version: #{deployed}\n\n")
					new_public_version.puts(release_notes+"\n\n")
					new_public_version.puts(public_version)
				else
					puts "You must update the release notes before deploying this application."
				end
      end

      desc "Remove deleted release tag from Git and push it to server."
      task :cleanup_deploy_tag do
        count = fetch(:keep_releases, 5).to_i
        if count >= releases.length
          logger.important "no old release tags to clean up"
        else
          logger.info "keeping #{count} of #{releases.length} release tags"

          tags = (releases - releases.last(count)).map { |release| tag_format(:release => release) }

          tags.each do |tag|
            `git tag -d #{tag}`
            `git push origin :refs/tags/#{tag}`
          end
        end
      end

    end

  end

end