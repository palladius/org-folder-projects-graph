=begin
  This script tries to address the problem of recurively
  get folders and projects from an org locally.
  My question asked here: https://stackoverflow.com/questions/63851466/how-to-get-all-the-gcp-folders-from-an-organization-with-gcloud/63852670#63852670
=end

$org_id = nil 

require 'json'
require 'erb'
require 'graph'
require 'net/http'
require 'uri'
require 'set'

$folders = {}
$orgs = {}  # get_org_domain and stuff
$projects = {}
$stop_un_duplicates = false
$org_print = ''

# remember what to print fopr the org, helps with TXT version of tree.
def org_print(level, str)
    # this will simulate the tree :) 
    level_str = " " * 2 * level
    $org_print  << "#{level_str}+ #{str}\n"
end

def fill_org_domain(org_id, opts={})
    #domain = `gcloud organizations describe #{org_id}|egrep ^display`.split(': ')[1].chomp rescue "some-error.com"
    #ret =  JSON.parse(`gcloud organizations describe #{org_id} --format json`)
    ret = return_hash_from_cached_json_results(org_id, "org-list", "gcloud organizations describe #{org_id} --format json", opts)
    $orgs[org_id] = ret 
    org_print 0, "#{org_id} # Domain: '#{ret['displayName']}'"
    #return domain
end
def yellow(str)
    "\033[1;33m#{str}\033[0m"
end
=begin
  you want to call gcloud organizations list? No probs!
  Cache the content

  return JSON.parse()
=end
def return_hash_from_cached_json_results(orgid, filename, command, opts={})
  out_dir = ".cache/#{orgid}/"
  cached_filename = "#{out_dir}/#{filename}.json"
   #`maxlevelkdir -p .cache/`
   `mkdir -p #{out_dir}/`
   if File.exists?(cached_filename)
     puts "File exists '#{cached_filename}': parse JSON from here. #cache_hit" # use hash tags for Stackdriver logging ;)
     return JSON.parse(File.read(cached_filename))
   else
     puts "File does NOT exist: '#{cached_filename}'. Calling gcloud ('#{yellow command}') and then putting stuff into file. #cache_miss"
     ret = `#{command}`
     #File.write
     File.open(cached_filename, "w"){|f| f.write ret}
     return JSON.parse(ret)
   end
end

# I found out its the same API call whether its Org or folder, so this is pointless :) 
def find_projects_by_org_or_folder(level, parent_id, opts={})
    #projects = JSON.parse(`gcloud projects list --filter=parent.id:#{parent_id} --format json`)
    projects = return_hash_from_cached_json_results($org_id, "projects-childrenof-#{parent_id}", "gcloud projects list --filter=parent.id:#{parent_id} --format json", opts)
    #puts "Project(#{parent_type},#{parent_id}): '#{projects[0]}'"
    projects.each{ |p|
        project_id = p['projectId']
        org_print(level, "Project/#{p['projectNumber']}\t#{project_id}")
        p[:riccardo] = {}
        #p[:riccardo][:parent_type_obsolete] = parent_type # TODO(ricc): remove this when you can
        p[:riccardo][:parent_id] = parent_id
        #p[:riccardo][:project_id] = project_id # delteme redundant once you know it works
        p[:riccardo][:level] = level
        
        #puts p 
        $projects[project_id]=p
    }

end

#TODO(ricc): refactor into accepting a single folder... thats how it works anyway recurively, with exception of
# 
# given a list of folder_ids, goes deep into those...
def recurse_folders(folder_ids, level, opts=nil)
    opts[:maxlevel] ||= 100
    return if opts[:maxlevel] < level 
    #opts[:maxlevel] = 100 unless opts.maxlevel if exists?(maxlevel)
    print "DEB recurse_folders(folders, level, opts) = (#{folder_ids}, #{level}, #{opts})\n"
    folder_ids.each do |folder_id| 
        org_print level, "Folder/#{folder_id}\t#{$folders["folders/#{folder_id}"]['displayName']}"
        find_projects_by_org_or_folder(level+1, folder_id)
        #nth_level_folders = `gcloud resource-manager folders list --folder=#{folder_id} --format=json`
        #folders = JSON.parse(nth_level_folders)
        folders = return_hash_from_cached_json_results($org_id, "folder-l#{level}-#{folder_id}-list", "gcloud resource-manager folders list --folder=#{folder_id} --format=json", opts)
        folders.each { |f| 
            f['org'] = $org_id # i already know by defitiono but you never know.
            f['level'] = 1
            f['folder_id'] = f['name'].split('/')[1]
            f['parent_folder_id'] = folder_id # father by construction
            if $folders.key?( f['name'] )
                #puts "Folder found twice: '#{  f['name'] }' - ouch! Exiting - but first let me tell you all about her.."
                #puts "Old one (existing):", $folders[ f['name'] ]
                #puts "New one:", f
                $folders[f['name']]['dupes'] +=1
                raise  "Folder found twice: '#{  f['name'] }'" if $stop_un_duplicates
            else
                f['dupes'] = 0
                $folders[ f['name'] ] = f
            end
            #puts f
            recurse_folders([f['folder_id']], level+1, opts)
        }
        #puts nth_level_folders
    end
end

def recurse_org(orgid, opts={})
    fill_org_domain(orgid)
    find_projects_by_org_or_folder(1, orgid)
    first_level_folders = `gcloud resource-manager folders list --organization="#{orgid}" --format=json`  
    folders = JSON.parse(first_level_folders)
    folders.each { |f| 
        f['org'] = $org_id # i already know by defitiono but you never know.
        f['level'] = 1
        f['folder_id'] = f['name'].split('/')[1]
        $folders[ f['name'] ] = f
        #puts f
    }
    folder_ids = folders.map{|f| f['folder_id'] }
    recurse_folders(folder_ids, 1, opts)
end

def pluralize(str)
    str + "s"
end

def print_and_graph_folders()
    #1. print tree in string (manually made)
    puts "== Org Print =="
    print $org_print
    
    #2. now .dot and .png
    puts "Now Graphviz-ing..."
    digraph do
        # in DOT for consistency I'll have all objects named like this:
        # - organizations/12345
        # - folders/1234
        # - projects/123456
        node_attribs << lightblue << filled

        # 1. Manage Org: I define the node as I'm sure it'll catch up in some folder relationship
        org_domain = $orgs[$org_id]['displayName']
        org_label = "Org #{$org_id}\n'#{org_domain}'"
        triangle << node("organizations/#{$org_id}").label(org_label)

        # 2. Manage folders
        puts "Folders: #{$folders}"
        $folders.each do |k, f|
            #puts "Name:", f['name']
            folder_label = "#{f['displayName']}/" # alternative: "[F] #{f['displayName']}"
            rectangle << node("#{f['name']}").label(folder_label) 
            #print f['parent'], " >> " , f['name'], "\n" 
            #square << 
            edge f['parent'], f['name']  # .label( f['displayName'])
            #self[f['parent']][f['name']] # .label( f['displayName'])
        end
        # 3. Manage projects
        $projects.each do |k,v|
            puts v['parent']
            project_node =  "projects/#{v['projectNumber']}"
            #  "parent": {
            #    "id": "824879804362",
            #    "type": "organization"
            #  },
            # Same with Folders ;)
            project_parent =  pluralize(v['parent']['type']) + '/' + v['parent']['id']
            #project_label = "[P] #{v['projectId']}" - in case you want to be more verbose on whats a project (or for color blind people)
            project_label = "#{v['projectId']}"
            red << node(project_node).label(project_label)
            red << edge(project_parent, project_node)
        end

        # End of all
        save "out/recursive-#{$org_id}", "png"
    end

    print "# Generated dot file..\n"
    print File.read("out/recursive-#{$org_id}.dot")

end

def utilizatio()
    puts "'Organizatio non petita, sed organizatio necesida' (Yes its a mix of Latin and Spanish)"
    puts "Consuetudo: #{$0} <organization_id> [--folder-recursion=11] [--skip-projects] [--no-cache-content]"
    puts "Pick `organization_id` from the second column of: `gcloud organizations list`. Let me call that for you, slacker:"
    puts `gcloud organizations list`
    exit 43
end
def main()
    $org_id = ARGV[0] rescue nil
    if $org_id.nil?
        utilizatio()
    end
    if $org_id =~ /\./ 
        puts "Seriously? Are you seriously so lazy you cant provide me with org id and want me to commute it for you? All right I will"
        puts "Not implemented yet: gcloud organizations list --format json and look for string -> number mapping"
        list = JSON.parse(`gcloud organizations list --format json`)
        # {
        #     "creationTime": "2020-04-30T17:38:59.058Z",
        #     "displayName": "sredemo.dev",
        #     "lifecycleState": "ACTIVE",
        #     "name": "organizations/791852209422",
        #     "owner": {
        #       "directoryCustomerId": "C03xewd61"
        #     }
        #   },
        org_names = list.map{|buridone| buridone['displayName']}
        org_ids = list.map{|buridone| buridone['name']}
        if (org_names.include?($org_id)) # note you provided a string (name) in org id so we try to rectify it..
            ix = org_names.index($org_id)
            puts "Ok, found! Index: #{ix}"
            puts "I presume the org you found is... #{ org_ids[ix]}"
            $org_id = org_ids[ix].split('/')[1]
            # Fixed org id!!!
            #exit 403
        else
            puts "Sorry, you provided unknown org. I only knows these: #{org_names}"
            exit 500
        end

    end
    print "Parsed OrgId: #{$org_id}\n"
    recurse_org($org_id, :maxlevel => 11)
    print_and_graph_folders()
end

main()
