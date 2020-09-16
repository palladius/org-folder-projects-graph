# org-folder-projects-graph
A script to parse Org, Folder, Projects and graph them all together in a convenient Graphviz dot file

# INSTALL

To run it:

    # First time only
    gcloud auth login
    bundle install
    # Every time
    ruby recurse_folders.rb

Tested on ruby versions 2.6.3p62 / 2.7.1p83 and by gem installing whats needed.

# BUGS

* Currently uses gcloud to call APIs, so it's slower and more inefficient than it could. Consider this a proof of concept, easy to optimize.

* If you have some tokens it wont work:

     - gcloud config unset auth/authorization_token_file
     - gcloud config configurations activate default
