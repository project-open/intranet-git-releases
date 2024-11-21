# -------------------------------------------------------------
# /packages/intranet-git-releases/www/releases.tcl
#
# Copyright (c) 2024 ]project-open[
# All rights reserved.
#
# Author: frank.bergmann@project-open.com

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    New page is basic...
    @author all@devcon.project-open.com
} {
    release_hash
    { max_entries 999999}
}

set filter_hash $release_hash

set page_title "Release #$filter_hash"
set context_bar [im_context_bar $page_title]


set debug 0
set user_id [auth::require_login]
set release_url "/intranet-git-releases/release"

set root_dir [acs_root_dir]
set packages_dir "$root_dir/packages"; # no trailing /


# get a list of hash-lists for each release
set release_vars {commit_hash commit_hash_short commitdate_iso author author_quoted commit commitdate comment}
set releases_lohl [util_memoize [list im_git_parse_commit_log -repo_path $packages_dir -debug_p 0 -limit $max_entries]]
# ad_return_complaint 1 "releases_lohl:<br><pre>[join $releases_lohl "<br>"]</pre>"

set ctr 0
set continue 1
while {$ctr <= $max_entries} {

    # Get the current release and the next release
    set release [lindex $releases_lohl $ctr]
    if {0 == [llength $release]} { break }
    set next_release [lindex $releases_lohl [expr $ctr + 1]]
    incr ctr
    ns_log Notice "git-status: ctr=$ctr, release=$release, next_release=$next_release"

    array unset release_h
    array unset next_release_h
    array set release_h $release
    array set next_release_h $next_release

    # Write release variables to local variables
    set release_comment $release_h(comment)
    set release_hash $release_h(commit_hash)
    foreach var $release_vars {
	set val "undefined"
	if {[info exists release_h($var)]} { set val $release_h($var) }
	set $var $val
    }

    # Shows GIT details for debugging
    set details ""
    # foreach var $release_vars { append details "<li>$var: $release_h($var)\n" }

    # Get the difference between each two releases
    if {"" ne $next_release && $release_hash eq $filter_hash} {
	set next_release_hash $next_release_h(commit_hash)
	set next_release_comment $next_release_h(comment)
	# append details "<li>from_hash: $commit_hash</li><li>to_hash: $next_release_hash</li>\n"

	# Get a list of all packages modified, with from and to hash
	set packages_diffs [util_memoize [list im_git_parse_submodule_diff -repo_path $packages_dir -from_hash $next_release_hash -to_hash $commit_hash]]
	# ad_return_complaint 1 $packages_diffs

	foreach package_diff $packages_diffs {
	    set pack [lindex $package_diff 0]
	    set pack_from_hash [lindex $package_diff 1]
	    set pack_to_hash [lindex $package_diff 2]

	    set repo_path "$root_dir/packages/$pack";
	    ns_log Notice "git-status: im_git_parse_commit_log -repo_path $repo_path -from_hash $pack_from_hash -to_hash $pack_to_hash"
	    set pack_logs [util_memoize [list im_git_parse_commit_log -repo_path $repo_path -from_hash $pack_from_hash -to_hash $pack_to_hash]]
	    ns_log Notice "git-status: im_git_parse_commit_log: $pack_logs"
	    foreach pack_log $pack_logs {
		array unset log_hash
		array set log_hash $pack_log
		set comment $log_hash(comment)
		append details "<li>$pack: $comment\n"
		# append details "$comment"
	    }
	}

	set url [export_vars -base $release_url {release_hash}]
	ns_log Notice "release.tcl: release=$release, details=$details"
	break
    }
}

# ad_return_complaint 1 [array get release_h]

set commit_date $release_h(commitdate_iso)
set commit_hash $release_h(commit_hash)


