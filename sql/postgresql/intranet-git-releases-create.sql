-- /packages/intranet-git-releases/sql/postgresql/intranet-git-releases-create.sql
--
-- Copyright (c) 2024 ]project-open[
--
-- All rights including reserved. To inquire license terms please 
-- refer to http://www.project-open.com/modules/<module-key>


-- GIT status
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'GIT Releases',				-- plugin_name
	'intranet-git-releases',		-- package_name
	'bottom',				-- location
	'/intranet/index',			-- page_url
	null,					-- view_name
	1900,					-- sort_order
	'im_git_releases_component'		-- component_tcl
);
