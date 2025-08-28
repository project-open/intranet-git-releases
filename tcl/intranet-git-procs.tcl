# /packages/intranet-git-releases/tcl/intranet-git-procs.tcl
#
# Copyright (C) 1998-2023
#

ad_library {
    Library handling a "packages" GIT repo with releases of the
    included packages as GIT submodules
    @author frank.bergmann@project-open.com
}

# ----------------------------------------------------------------------
# Components
# ---------------------------------------------------------------------

ad_proc -public im_git_releases_component {
    {-max_entries 8}
    {-show_commits_p 0}
} {
    Cached version of im_git_releases_component_helper.
} {
    ns_log Notice "im_git_releases_component -max_entries $max_entries -show_commits_p $show_commits_p"
    set timeout 36000
    set cache_keys [ns_cache names util_memoize]
    set command [list im_git_releases_component_helper -max_entries $max_entries -show_commits_p $show_commits_p]
    set found_in_cache_p [util_memoize_cached_p $command $timeout]
    ns_log Notice "im_git_releases_component -max_entries $max_entries -show_commits_p $show_commits_p: found_in_cache_p=$found_in_cache_p"
    if {$found_in_cache_p} {
	return [util_memoize $command $timeout]
    } else {
	return "
	       <p>Processing data, please reload page to see version and change history</p>

		<script type='text/javascript' nonce='[im_csp_nonce]'>
		window.addEventListener('load', function() {
		    var xmlHttp1=new XMLHttpRequest();    
		    xmlHttp1.open('GET','/intranet-git-releases/warm-release-cache',true);
		    xmlHttp1.send(null);
		});
		</script>
	"
    }
}

ad_proc -public im_git_releases_component_helper {
    {-max_entries 8}
    {-show_commits_p 0}
} {
    Checks the GIT status of the current server.
    Assumes that the /packages/ folder is a GIT repo
    with the ]po[ packages as submodules.
    @param max_entries Limit the number of entries in the portlet
} {
    ns_log Notice "im_git_releases_component_helper -max_entries $max_entries -show_commits_p $show_commits_p"
    set params [list \
		    [list max_entries $max_entries] \
		    [list show_commits_p $show_commits_p] \
    ]
    set result [ad_parse_template -params $params "/packages/intranet-git-releases/lib/git-status"]
    return [string trim $result]
}


# ----------------------------------------------------------------------
# Procedures to process GIT
# ---------------------------------------------------------------------


ad_proc im_git_parse_cust_package_version {
    -package_key
    -commit_hash
    {-debug_p 0}
} {
    Runs git show $hash:$info_file, extracts the version line of the package
    <version name="5.1.0.0.3" url="http://www.project-open.net/download/apm/intranet-cust-cosine-5.1.0.0.3.apm">
    and returns the version.
} {
    if {$debug_p} { ns_log Notice "im_git_parse_cust_package_version -package_key $package_key -commit_hash $commit_hash" }

    set root_dir [acs_root_dir]
    set repo_path "$root_dir/packages/$package_key"
    set info_file "$package_key.info"

    set git_cmd "git show $commit_hash:$info_file"
    if {$debug_p} { ns_log Notice "im_git_parse_cust_package_version: git_cmd='cd $repo_path; $git_cmd'" }

    set output ""
    if {[catch {
	set output [im_exec bash -c "cd $repo_path; $git_cmd"]
    } err_msg]} {
	return $err_msg
    }

    set version ""
    set cnt 0
    foreach line [split $output "\n"] {
	if {$debug_p} { ns_log Notice "im_git_parse_cust_package_version: #$cnt: line=$line" }

	if {[regexp {version name=\"([0-9a-z\.]+)\"} $line match v]} {
	    set version $v
	    break
	}
	incr cnt
    }    

    return $version
}


ad_proc im_git_parse_commit_log {
    -repo_path
    {-from_hash ""}
    {-to_hash ""}
    {-limit 10}
    {-debug_p 0}
} {
    Runs "git log" in the repo_path and returns a list of hash-lists 
    with information about the commits in the repo. 
    The commits can be "releases" when running in the /packages/ folder
    or just commits in one of the packages.<br>
    Example input:
    <pre>
    commit 4fab079cc341d42bca3cc69c715885ce387caadc
    Author:     Frank Bergmann <frank.bergmann@project-open.com>
    AuthorDate: 2024-10-31 13:11:29 +0100
    Commit:     Frank Bergmann <frank.bergmann@project-open.com>
    CommitDate: 2024-10-31 13:11:29 +0100

        cosine #5973: Added new GIT status portlet.
        This is a test with a second line of the commit

    commit next commit
    </pre>
    Example output:
    {
	commit_hash "4fab079cc341d42bca3cc69c715885ce387caadc"
	author "Frank Bergmann <frank.bergmann@project-open.com>"
	authordate "2024-10-31 13:11:29 +0100"
	commit "Frank Bergmann <frank.bergmann@project-open.com>"
	commitdate "2024-10-31 13:11:29 +0100"
	comment "cosine #5973: Added new GIT status portlet.\nThis is a test with a second line of the commit"
    }
} {
    set cosine_tracker_url "https://int.cosine.nl/bugtracker/view.php"

    set commits [list]
    set commit [list]

    set limit_cmd ""; if {"" ne $limit} { set limit_cmd "-n $limit" }
    set from_cmd ""; if {"" ne $from_hash} { set from_cmd $from_hash }
    set to_cmd ""; if {"" ne $to_hash} { set to_cmd "..$to_hash" }

    if {$debug_p} { ns_log Notice "im_git_parse_commit_log: repo_path=$repo_path, from=$from_hash, to=$to_hash" }
    set git_cmd "git log $limit_cmd --format=fuller --no-merges --no-decorate --date=iso8601 $from_cmd$to_cmd"
    if {$debug_p} { ns_log Notice "im_git_parse_commit_log: git_cmd='cd $repo_path; $git_cmd'" }
    set output [im_exec bash -c "cd $repo_path; $git_cmd"]
    append output "\ncommit end"
    if {$debug_p} { ns_log Notice "im_git_parse_commit_log: output:\nim_git_parse_commit_log: output: [join [split $output "\n"] "\nim_git_parse_commit_log: output: "]" }
    if {$debug_p} { ns_log Notice "im_git_parse_commit_log: output=\n$output" }
    set release_hash_list [list]
    set release_comment ""
    set cnt 0
    foreach line [split $output "\n"] {
	incr cnt
	if {$debug_p} { ns_log Notice "im_git_parse_commit_log: #$cnt: line=$line" }

	# --------------------------------------------------------------------
	# Convert a stream of lines into a stream of tokens with $rest_of_line
	# A commit entry starts with a "commit xyz" line and ends with the "commit yzw" 
	# line of the next entry, or the end of the file
	set token "undefined"
	if {"" eq $line} {
	    # An empty line
	    set token "empty"
	    set rest_of_line ""
	} elseif {[regexp {^(\S{6,11})\s+(.*)} $line match token rest_of_line]} {
	    # A line starting with a keyword, followed by a space and the rest
	    if {[regexp {^(\w+)\:$} $token match word]} { 
		# The token had a ":" as the last character, just skip
		set token $word 
	    }
	} elseif {[regexp {^(\s{4})(.*)} $line match spaces rest_of_line]} {
	    # A comment line has four spaces followed by the comment
	    set token "comment"
	} else {
	    # These are lines that don't match any of the above types.
	    # This should never appear
	    set token "failed"
	    set rest_of_line $line
	}
	if {$debug_p} { ns_log Notice "im_git_parse_commit_log: #$cnt: token=$token, rol=$rest_of_line" }

	if {"empty" eq $token} { 
	    continue 
	}
	if {"comment" eq $token} { 
	    # We can have multi-line comments, so collect them here
	    if {[regexp {^\- (.*)$} $rest_of_line match line_without_dash]} { set rest_of_line $line_without_dash}
	    append release_comment "[ns_quotehtml $rest_of_line]<br>"
	    continue 
	}
	if {"commit" eq $token} {
	    if {$debug_p} { ns_log Notice "im_git_parse_commit_log: #$cnt: found commit: release_hash_list=$release_hash_list" }
	    set token "commit_hash"
	    # This is either the very first commit or something in between
	    # The first commit is empty, so ignore that one
	    if {[llength $release_hash_list] > 0} {
		if {$debug_p} { ns_log Notice "im_git_parse_commit_log: #$cnt: found 'commit' token and l>0" }
		# Add the old release to the list of results
		lappend release_hash_list "comment"

		# Check for (one) "cosine #1234:" reference and replace with reference to bug tracker
		if {[regexp {^(.*)cosine #?([0-9]{3,5}):?(.*)$} $release_comment match start bug_id end]} {
		    set tracker_url [export_vars -base $cosine_tracker_url {{id $bug_id}}]
		    set tracker_link "<a href='$tracker_url'>cosine issue #$bug_id:</a>"
		    set release_comment "${start}${tracker_link}${end}"
		}

		lappend release_hash_list $release_comment
		lappend commits $release_hash_list
	    } else {
		if {$debug_p} { ns_log Notice "im_git_parse_commit_log: #$cnt: found 'commit', but there are not data yet (first commit)" }
	    }

	    # Start a new release with an empty hash_list
	    set release_hash_list [list]
	    set release_comment ""
	} else {
	    if {$debug_p} { ns_log Notice "im_git_parse_commit_log: #$cnt: found some other token" }
	}

	# Add the current line to the next release
	lappend release_hash_list [string tolower $token]
	lappend release_hash_list $rest_of_line

	# --------------------------------------------------------------------
	# Process some of the entries
        if {$debug_p} { ns_log Notice "im_git_parse_commit_log: #$cnt: token=$token" }
	switch [string tolower $token] {
	    "commit_hash" {
		# Set short version of the hash
		set commit_hash_short [string toupper [string range $rest_of_line 0 6]]
		lappend release_hash_list "commit_hash_short" $commit_hash_short
	    }
	    "commitdate" {
		# Massage the date, take only the first 10 chars "2024-10-31"
		set commitdate_iso [string range $rest_of_line 0 15]
		lappend release_hash_list "commitdate_iso" $commitdate_iso
	    }
	    "author" {
		# Quote author, it contains <...>
		set author_quoted [ns_quotehtml $rest_of_line]
		lappend release_hash_list "author_quoted" $author_quoted
	    }
	}
    }

    # No need to add the last commit, because it was added manually above
    # After the end of the entire list, like a start of a new commit line
    # Add the last release to the list of results
    # lappend release_hash_list "comment"
    # lappend release_hash_list $release_comment
    # lappend commits $release_hash_list

    # Return a hash-list of commits
    return $commits
}


ad_proc im_git_parse_submodule_diff {
    -repo_path
    -from_hash
    -to_hash
    {-debug_p 0}
} {
    Gets the difference between two releases in terms of submodules.
    Runs "git diff $from_hash $to_hash" in the packages repo in order
    to get he old and new commit hashes for each submodule.
    
    The result of the diff looks like this:
    diff --git a/.gitignore b/.gitignore

    deleted file mode 100644
    index 51176e7..0000000
    --- a/.gitignore
    +++ /dev/null
    @@ -1,12 +0,0 @@
    -emacs.bash
    diff --git a/intranet-git-releases b/intranet-git-releases
    index a417e75..9183b8e 160000
    --- a/intranet-git-releases
    +++ b/intranet-git-releases
    @@ -1 +1 @@
    -Subproject commit a417e75cad2ea6e013aecade387c34d4e0ee2a5e
    +Subproject commit 9183b8ee134577d7242646466242f2f075155870

    However, we are only interested in the lines:
    diff --git a/intranet-git-releases b/intranet-git-releases
    -Subproject commit xyz
    +Subproject commit vwx

    Returns a list of tuples: { intranet-git-releases a417e75 9183b8e }
} {
    set results [list]
    set git_cmd "git diff $from_hash $to_hash"
    if {$debug_p} { ns_log Notice "im_git_parse_submodule_diff: git_cmd=$git_cmd" }
    set output [im_exec bash -c "cd $repo_path; $git_cmd"]
    if {$debug_p} { ns_log Notice "im_git_parse_submodule_diff: output=\n$output" }

    set pack ""
    set pack_from_hash ""
    set pack_to_hash ""
    foreach line [split $output "\n"] {
	if {$debug_p} { ns_log Notice "im_git_parse_submodule_diff: line=$line" }

	if {[regexp {^\+{3} [ab]\/([a-z0-9_\-]+)$} $line match p]} { set pack $p}
	if {[regexp {^\-Subproject commit ([a-z0-9]+)$} $line match s]} { set pack_from_hash $s}
	if {[regexp {^\+Subproject commit ([a-z0-9]+)$} $line match s]} { 
	    set pack_to_hash $s
	    lappend results [list $pack $pack_from_hash $pack_to_hash]
	    set pack ""
	    set pack_from_hash ""
	    set pack_to_hash ""
	}

	if {$debug_p} { ns_log Notice "im_git_parse_submodule_diff: pack=$pack, from=$pack_from_hash, to=$pack_to_hash" }
    }
    return $results
}

