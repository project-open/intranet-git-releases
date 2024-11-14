# -------------------------------------------------------------
# /packages/intranet-git-releases/lib/git-status.tcl
#
# Copyright (c) 2024 ]project-open[
# All rights reserved.
#
# Author: frank.bergmann@project-open.com

# -------------------------------------------------------------
# Shows the status of the system to all users.
# - Releases are commits to /packages/ which are created after
#   releasing a new "configuration" (list of package versions) 
#   to the server.
# - Versions are the specific versions of a package.

# Variables:
#	max_entries Maximum number of entries in portlet

set user_id [auth::require_login]
set release_url "/intranet-git-releases/releases"

set root_dir [acs_root_dir]
set packages_dir "$root_dir/packages"; # no trailing /
# No permissions here, set perms on portlet

# ----------------------------------------------------
# Create a "multirow" to show the results

multirow create releases_multirow date hash author notes view_url details

# get a list of hash-lists for each release
set release_vars {commit_hash commit_hash_short commitdate_iso author author_quoted commit commitdate comment}
set releases_lohl [im_git_parse_commit_log -repo_path $packages_dir -debug_p 0 -limit $max_entries]
# ad_return_complaint 1 "<pre>[join $releases_lohl "<br>"]</pre>"

set ctr 0
set continue 1
while {$ctr <= $max_entries} {

    # Get the current release and the next release
    set release [lindex $releases_lohl $ctr]
    if {0 == [llength $release]} { break }
    set next_release [lindex $releases_lohl [expr $ctr + 1]]
    incr ctr
    ns_log Notice "git-status: release=$release"

    array unset release_h
    array unset next_release_h
    array set release_h $release
    array set next_release_h $next_release


    # Write release variables to local variables
    foreach var $release_vars {
	set val "undefined"
	if {[info exists release_h($var)]} { set val $release_h($var) }
	set $var $val
    }

    # Shows GIT details for debugging
    # set details ""
    # foreach var $release_vars { append details "<li>$var: $release_h($var)\n" }

    # Get the difference between each two releases
    set details ""
    if {"" ne $next_release} {
	set next_release_hash $next_release_h(commit_hash)
	# Get a list of all packages modified, with from and to hash
	set packages_diffs [im_git_parse_submodule_diff -repo_path $packages_dir -from_hash $next_release_hash -to_hash $commit_hash]
	foreach package_diff $packages_diffs {
	    set pack [lindex $package_diff 0]
	    set pack_from_hash [lindex $package_diff 1]
	    set pack_to_hash [lindex $package_diff 2]

	    set repo_path "$root_dir/packages/$pack";
	    ns_log Notice "git-status: im_git_parse_commit_log -repo_path $repo_path -from_hash $pack_from_hash -to_hash $pack_to_hash"
	    set pack_logs [im_git_parse_commit_log -repo_path $repo_path -from_hash $pack_from_hash -to_hash $pack_to_hash]
	    ns_log Notice "git-status: im_git_parse_commit_log: $pack_logs"
	    foreach pack_log $pack_logs {
		array unset log_hash
		array set log_hash $pack_log
		set comment $log_hash(comment)
		append details "<li>$pack: $comment\n"
		# append details "$comment"
	    }
	}
    }

    set url [export_vars -base $release_url {}]
    multirow append releases_multirow $commitdate_iso $commit_hash_short $author $comment $url $details
}

# ad_return_complaint 1 [im_git_releases]
