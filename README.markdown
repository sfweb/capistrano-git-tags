Capistrano GitTagging Extension
====

Automagically tag your current deployed release with capistrano

Install: 

    gem install capistrano-git-tags

usage: put this in the top in your deploy.rb:

    require 'capistrano/git/tags'
    require 'capistrano/git/release_notes'
    require 'capistrano/git/notifier'
    set :email_recipients, "sfweb@sourcefire.com"

Execute with "bundle exec"  

TODO
---

* specify the formatting of the tag

Original idea: 
---

* [http://wendbaar.nl/blog/2010/04/automagically-tagging-releases-in-github/](http://wendbaar.nl/blog/2010/04/automagically-tagging-releases-in-github/)

* [http://gist.github.com/381852](http://gist.github.com/381852)
