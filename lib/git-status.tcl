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
#	show_commits_p Show the 4th column with detailed commit information?

set debug 0
set user_id [ad_conn untrusted_user_id]
set release_url "/intranet-git-releases/release"


# ----------------------------------------------------
# Get customer package version
# ----------------------------------------------------

set customer_package_key ""
set customer_package_version ""
set custom_package_version_sql "
	select	package_key as customer_package_key,
		version_name as customer_package_version
	from	apm_package_versions
	where	version_id in (
		    select max(version_id)
		    from   apm_package_versions
		    where  package_key like 'intranet-cust-%' and
		    	   enabled_p = 't'
        )
"
db_0or1row custom_packages $custom_package_version_sql


# ----------------------------------------------------
# Get release history
# ----------------------------------------------------

set root_dir [acs_root_dir]
set packages_dir "$root_dir/packages"; # no trailing /
# No permissions here, set perms on portlet

# Create a "multirow" to show the results
multirow create releases_multirow date hash cust_version author notes view_url details debug

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
    if {$debug} { ns_log Notice "git-status: ctr=$ctr, release=$release, next_release=$next_release" }

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
    set cust_version ""
    set included_versions [list]
    if {"" ne $next_release} {
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

	    set pack_version [im_git_parse_cust_package_version -package_key $pack -commit_hash $pack_to_hash]
	    if {$pack eq $customer_package_key} { set cust_version $pack_version }
	    lappend included_versions [list $pack $pack_version]

	    set repo_path "$root_dir/packages/$pack";
	    if {$debug} { ns_log Notice "git-status: im_git_parse_commit_log -repo_path $repo_path -from_hash $pack_from_hash -to_hash $pack_to_hash" }
	    set pack_logs [util_memoize [list im_git_parse_commit_log -repo_path $repo_path -from_hash $pack_from_hash -to_hash $pack_to_hash]]
	    if {$debug} { ns_log Notice "git-status: im_git_parse_commit_log: $pack_logs" }
	    foreach pack_log $pack_logs {
		array unset log_hash
		array set log_hash $pack_log
		set comment $log_hash(comment)
		append details "<li>$pack: $comment\n"
		# append details "$comment"
	    }
	}

	set version "$customer_package_key:$cust_version"
	if {"" eq $cust_version} {
	    set version_list [list]
	    foreach v $included_versions {
		lappend version_list "[lindex $v 0]:[lindex $v 1]"
	    }
	    set version [join $version_list ", "]
	}

	set url [export_vars -base $release_url {release_hash}]
	multirow append releases_multirow $commitdate_iso $commit_hash_short $version $author $release_comment $url $details $next_release
    }
}

# ad_return_complaint 1 [im_git_releases]
