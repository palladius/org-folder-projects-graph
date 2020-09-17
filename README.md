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

I actually borrowed this awesome visualization:

    🌲 824879804362 # 'palladi.us'
    ├─ 🍕 xpn-main (398198244705)
    ├─ 🍕 orgnode-palladi-us (704861684515)
    ├─ 📁 993609995477 (customers)
        ├─ 📁 571390668780 (dirimpettai di EURF)
    ├─ 📁 885056483479 (dev and test)
        ├─ 🍕 prova-123-dentro-palladi-us (237925736669)
        ├─ 🍕 palladius-eu (177178925177)
        ├─ 🍕 prova123-160016 (262470358174)
        ├─ 🍕 gbanana-dev (150202633473)
        ├─ 🍕 folder-test-prod (1025012666423)
        ├─ 🍕 folder-test-dev (351173986048)
        ├─ 🍕 gae-django-trix (520622310274)
        ├─ 🍕 test-dataflow-152318 (831136101005)
        ├─ 📁 128544652663 (folderillo)
    ├─ 📁 887288965373 (prod stuff - for real)
        ├─ 🍕 gbanana-prod (626662139195)
    ├─ 📁 510416893777 (TFR Terraformed by Ricc)
        ├─ 📁 93350088776 (TF DEV)
            ├─ 📁 723110142384 (TF0b - titius)
            ├─ 📁 454527359325 (TF1 - foo)
            ├─ 📁 1026736501110 (TF1b - caius)
            ├─ 📁 403965627320 (TF2 - bar)
            ├─ 📁 802144187596 (TF2b - sempronius)
            ├─ 📁 986862742068 (TF3 - baz)
        ├─ 📁 99919748229 (TF PROD)


# BUGS

* Currently uses gcloud to call APIs, so it's slower and more inefficient than it could. Consider this a proof of concept, easy to optimize.

* If you have some tokens it might NOT work:

     - gcloud config unset auth/authorization_token_file
     - gcloud config configurations activate default

# Thanks

* Creator of gcp-org-hierarchy-viewer for the graphics :)