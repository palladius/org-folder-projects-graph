# org-folder-projects-graph

A script to parse Org, Folder, Projects and graph them all together in a convenient Graphviz dot file.

# INSTALL

* bundle install # TODO(ricc)
* ruby recurse_folders.rb

Testewd on ruby 2.6.3p62 and by gem installing whats needed.

# Alternatives

See this project developed by Google Professional Services. Definitely one step ahead of my repo (graphically):

* https://github.com/GoogleCloudPlatform/professional-services/tree/master/tools/gcp-org-hierarchy-viewer

I might borrow this awesome visualization:

    🏢 palladi.us (824879804362)
     +-- 📁 customers (993609995477)
     |   +-- 📁 dirimpettai di EURF (571390668780)
     +-- 📁 dev and test (885056483479)
     |   +-- 📁 folderillo (128544652663)

# BUGS

* Currently uses gcloud to call APIs, so it's slower and more inefficient than it could. Consider this a proof of concept, easy to optimize.

* If you have some tokens it might NOT work:

     - gcloud config unset auth/authorization_token_file
     - gcloud config configurations activate default

