Capistrano GitTagging Extension
====

Automagically tag your current deployed release with capistrano

Install: 

    gem install capistrano-git-tags

usage: put this in the top in your deploy.rb:

    Dir.new(File.dirname("#{ENV['GEM_HOME']}/bundler/gems/*")).each do |file|
			$:.push("#{ENV['GEM_HOME']}/bundler/gems/#{file}/lib",ENV['GEM_HOME'])
		end
		require 'capistrano/git/tags'
		require 'capistrano/git/release_notes'

TODO
---

* specify the formatting of the tag

Original idea: 
---

* [http://wendbaar.nl/blog/2010/04/automagically-tagging-releases-in-github/](http://wendbaar.nl/blog/2010/04/automagically-tagging-releases-in-github/)

* [http://gist.github.com/381852](http://gist.github.com/381852)