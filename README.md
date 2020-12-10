# org-folder-projects-graph

A script to parse Org, Folder, Projects and graph them all together in a convenient Graphviz dot file.

# INSTALL

To run it:

    # First time only
    gcloud auth login
    bundle install
    # Every time
    ruby recurse_folders.rb

Tested on ruby versions 2.6.3p62 / 2.7.1p83 and by gem installing whats needed.

# Alternatives

See this project developed by Google Professional Services. Definitely one step ahead of my repo (graphically):

* https://github.com/GoogleCloudPlatform/professional-services/tree/master/tools/gcp-org-hierarchy-viewer

I actually borrowed this awesome visualization (see in `out` for latest values):

    🌲 824879804362 # 'palladi.us'
    ├─ 🍕 xpn-main (398198244705)
    ├─ 🍕 orgnode-palladi-us (704861684515)
    ├─ 📁 993609995477 (customers)
        ├─ 📁 571390668780 (dirimpettai di EURF)
    ├─ 📁 885056483479 (dev and test)
        ├─ 🍕 prova-123-dentro-palladi-us (237925736669)
        ├─ 🍕 palladius-eu (177178925177)
        ├─ 🍕 prova123-160016 (262470358174)
        ├─ 🍕 folder-test-prod (1025012666423)
        ├─ 🍕 folder-test-dev (351173986048)
        ├─ 📁 128544652663 (folderillo)
    ├─ 📁 887288965373 (prod stuff - for real)
        ├─ 🍕 gbanana-prod (626662139195)
    ├─ 📁 510416893777 (TFR Terraformed by Ricc)
        ├─ 📁 93350088776 (TF DEV)
            ├─ 📁 723110142384 (TF0b - titius)
            ├─ 📁 1026736501110 (TF1b - caius)
            ├─ 📁 802144187596 (TF2b - sempronius)
        ├─ 📁 99919748229 (TF PROD)


# BUGS

* Currently uses gcloud to call APIs, so it's slower and more inefficient than it could. Consider this a proof of concept, easy to optimize.

* If you have some tokens it might NOT work:

     - gcloud config unset auth/authorization_token_file
     - gcloud config configurations activate default

# TODOs

Consider making the script faster with a couple of tips:

* Use APIs directly instead of gcloud (duh!)
* Optimize API call logically. for instance, I could fetch ALL folders in an org with a single call (today impossible) or all project in an Org once I know N folders (I believe this is possible using filters - see below).
* Smart filtering with gcloud: https://cloud.google.com/blog/products/gcp/filtering-and-formatting-fun-with
* Get alll folders at once using this aPI. Funny enough, this API is so powerful it spans across multiple orgs, not sure how to restrict it :)

    curl -H "Authorization: Bearer `gcloud auth print-access-token`" -X POST https://cloudresourcemanager.googleapis.com/v2/folders:search

# Thanks

* https://github.com/angstwad Paul Durivage (creator of gcp-org-hierarchy-viewer) for the graphics.
* My friend Daz for the script in `3rd-party/` which seems the best solution on purely bash solution (crazy you!)

