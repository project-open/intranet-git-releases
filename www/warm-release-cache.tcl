# -------------------------------------------------------------
# /packages/intranet-git-releases/www/warm-release-cache.tcl
#
# Copyright (c) 2024 ]project-open[
# All rights reserved.
#
# Author: frank.bergmann@project-open.com

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Load the GIT release data into the cache
} {
    {max_entries 8}
    {show_commits_p 0}
}

set timeout 36000
set command [list im_git_releases_component_helper -max_entries $max_entries -show_commits_p $show_commits_p]

ns_log Notice "warm-release-cache.tcl: about to util_memoize: $command"
set release_data [util_memoize $command $timeout]
ns_log Notice "warm-release-cache.tcl: finished to util_memoize: $command"

doc_return 200 "text/plain" "OK"

