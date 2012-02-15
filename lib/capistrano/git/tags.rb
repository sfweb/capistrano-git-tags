unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/git/tags requires Capistrano 2"
end
require 'capistrano'

Capistrano::Configuration.instance.load do

  after "git:release_notes:push_version_file", "git:tags:push_deploy_tag"

  namespace :git do

    namespace :tags do

      def tag_format(options = {})
        tag_format = ":rails_env_:release"
        tag_format = tag_format.gsub(":rails_env", options[:rails_env] || rails_env)
        tag_format = tag_format.gsub(":release",   options[:release]   || "")
        tag_format
      end

      desc "Place release tag into Git and push it to server."
      task :push_deploy_tag do
      	transaction do
      		on_rollback do
          	`git tag -d #{tag}`
          	`git push origin :refs/tags/#{tag}`
      		end
      	end
      	tag = tag_format(:release => release_name)
      	
        user = `git config --get user.name`
        email = `git config --get user.email`

        puts `git tag #{tag} #{revision} -m "Deployed by #{user} <#{email}>"`
        puts `git push --tags`
      end

    end

  end

end