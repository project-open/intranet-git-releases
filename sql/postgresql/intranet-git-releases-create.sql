-- /packages/intranet-cust-cosine/sql/postgresql/intranet-cust-cosine-create.sql
--
-- Copyright (c) 2010 ]project-open[
--
-- All rights including reserved. To inquire license terms please 
-- refer to http://www.project-open.com/modules/<module-key>

-- ----------------------------------------------------------------
-- intranet-cust-cosine
-- ----------------------------------------------------------------


alter table im_projects add column cost_timesheet_budget_planned numeric(12,2);
alter table im_projects add column cosine_weighted_average_sales_rate_cache numeric;
alter table im_projects add column cosine_project_value_cache numeric;
-- alter table im_projects add column cosine_wip_cache numeric;

alter table im_projects add column cosine_wip_margin_factor numeric;
alter table im_projects alter column cosine_wip_margin_factor drop default;
drop trigger if exists im_project_cosine_wip_margin_factor_tr on im_projects;



alter table im_costs add column anticipated_delivery_date date;
alter table im_costs add column placement_date date;


-- Job Profile for employees
alter table persons add column cosine_job_profile_id integer
constraint persons_cosine_job_profile_fk references im_materials;
SELECT im_dynfield_attribute_new ('person', 'cosine_job_profile_id', 'Job Profile', 'materials', 'integer', 'f');


delete from im_view_columns where column_id in (1000, 1001);
delete from im_view_columns where column_id between 91040 and 91059;

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91040,910,NULL,'"cosine Task Value (EUR)"',
'"<div align=right style=''background-color:lightblue''>[lc_numeric [im_cosine_task_value -task_id $task_id] "" nl_NL]&nbsp;</div>"','','',1000,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91041,910,NULL,'"cosine Weighted Average Sales Rate (EUR)"',
'"<div align=right>[lc_numeric [im_cosine_weighted_average_sales_rate -show_error_p 1 -task_id $project_id] "" nl_NL]</div>"','','',1010,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91042,910,NULL,'"cosine Material Budget (EUR)"',
'"<div align=right>[lc_numeric [im_cosine_material_budget -task_id $task_id] "" nl_NL]</div>"','','',1020,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91043,910,NULL,'"cosine Material Realized (EUR)"',
'"<div align=right>[lc_numeric [im_cosine_material_realized -task_id $task_id] "" nl_NL]</div>"','','',1030,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91044,910,NULL,'"cosine Material to Complete (EUR)"',
'"<div align=right>[lc_numeric [im_cosine_material_to_complete -task_id $task_id] "" nl_NL]</div>"','','',1040,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91045,910,NULL,'"cosine Material Prognosis"',
'"<div align=right>[lc_numeric [expr [im_cosine_material_realized -task_id $task_id] + [im_cosine_material_to_complete -task_id $task_id]] "" nl_NL]</div>"','','',1050,'im_permission $user_id view_finance');


insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91046,910,NULL,'"cosine Material Deviation"',
'"<div align=right>[lc_numeric [expr [im_cosine_material_realized -task_id $task_id] + [im_cosine_material_to_complete -task_id $task_id] - [im_cosine_material_budget -task_id $task_id]] "" nl_NL]</div>"','','',1053,'im_permission $user_id view_finance');


insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91047,910,NULL,'" | &nbsp; "',
'" | "','','',1055,'im_permission $user_id view_finance');




insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91048,910,NULL,'"cosine Hours Budget"',
'"<div align=right>[lc_numeric [im_cosine_hours_budget -task_id $task_id] "" nl_NL]</div>"','','',1060,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91049,910,NULL,'"cosine Hours Realized"',
'"<div align=right>[lc_numeric [im_cosine_hours_realized -task_id $task_id] "" nl_NL]</div>"','','',1070,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91050,910,NULL,'"cosine Hours to Complete"',
'"<div align=right>[lc_numeric [im_cosine_hours_to_complete -task_id $task_id] "" nl_NL]</div>"','','',1080,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91051,910,NULL,'"cosine Hours Prognosis"',
'"<div align=right>[lc_numeric [expr [im_cosine_hours_realized -task_id $task_id] + [im_cosine_hours_to_complete -task_id $task_id]] "" nl_NL]</div>"','','',1090,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91052,910,NULL,'"cosine Hours Deviation"',
'"<div align=right>[lc_numeric [expr [im_cosine_hours_realized -task_id $task_id] + [im_cosine_hours_to_complete -task_id $task_id] - [im_cosine_hours_budget -task_id $task_id]] "" nl_NL]</div>"','','',1095,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91053,910,NULL,'" | &nbsp;  "',
'" | "','','',1096,'im_permission $user_id view_finance');



insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91055,910,NULL,'"cosine WIP Part 1 (EUR)"',
'"<div align=right>[lc_numeric [im_cosine_wip_part_1 -task_id $task_id] "" nl_NL]</div>"','','',1100,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91056,910,NULL,'"cosine WIP Part 2 (EUR)"',
'"<div align=right>[lc_numeric [im_cosine_wip_part_2 -task_id $task_id] "" nl_NL]</div>"','','',1110,'im_permission $user_id view_finance');

insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (91057,910,NULL,'"cosine WIP (EUR)"',
'"<div align=right>[lc_numeric [im_cosine_wip -task_id $task_id] "" nl_NL]</div>"','','',1120,'im_permission $user_id view_finance');


-- insert into im_view_columns (column_id, view_id, group_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (9104,910,NULL,'""',
-- '""','','',10,'');



update apm_parameter_values
set attr_value = 93
where parameter_id in (
	select	parameter_id
	from	apm_parameters
	where	package_key = 'intranet-cost' and
		parameter_name = 'DefaultTimesheetHourlyCost'
);





-----------------------------------------------------------
-- Project cosine Profit & Loss Portlet
--
SELECT im_component_plugin__new (
	null,'im_component_plugin',now(),null,'0.0.0.0',null,
	'cosine Profit & Loss',			-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'right',				-- location
	'/intranet/projects/view',		-- page_url
	null,					-- view_name
	200,					-- sort_order
	'im_cosine_profit_loss_component -project_id $project_id',
	'lang::message::lookup "" intranet-cust-cosine.Profit_Loss "Profit & Loss"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine Profit & Loss'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);



-----------------------------------------------------------
-- Provider Status
--
SELECT im_component_plugin__new (
	null,'im_component_plugin',now(),null,'0.0.0.0',null,
	'cosine Provider Financial Status',			-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'right',				-- location
	'/intranet/projects/view',		-- page_url
	null,					-- view_name
	210,					-- sort_order
	'im_cosine_provider_financial_status -project_id $project_id',
	'lang::message::lookup "" intranet-cust-cosine.Provider_Financial_Status "cosine Provider Financial Status"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine Provider Financial Status'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);


SELECT im_component_plugin__new (
	null,'im_component_plugin',now(),null,'0.0.0.0',null,
	'cosine Hours Status Summary',		-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'left',					-- location
	'/intranet/projects/view',		-- page_url
	null,					-- view_name
	211,					-- sort_order
	'im_cosine_hours_status_summary -project_id $project_id',
	'lang::message::lookup "" intranet-cust-cosine.Hours_Financial_Status_Summary "cosine Hours Status Summary"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine Hours Status Summary'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);





-----------------------------------------------------------
-- Provider Status
--
SELECT im_component_plugin__new (
	null,'im_component_plugin',now(),null,'0.0.0.0',null,
	'cosine Hours Status',			-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'right',				-- location
	'/intranet/projects/view',		-- page_url
	null,					-- view_name
	220,					-- sort_order
	'im_cosine_hours_status -project_id $project_id',
	'lang::message::lookup "" intranet-cust-cosine.Hours_Status "cosine Hours Status"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine Hours Status'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);





-----------------------------------------------------------
-- Hour Budget - Convert hours to percentages
--
SELECT im_component_plugin__new (
	null,'im_component_plugin',now(),null,'0.0.0.0',null,
	'cosine Hour Budget',			-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'right',				-- location
	'/intranet/projects/view',		-- page_url
	null,					-- view_name
	220,					-- sort_order
	'im_cosine_hour_budget -project_id $project_id',
	'lang::message::lookup "" intranet-cust-cosine.cosin_Hour_Budget "cosine Hour Budget"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine Hour Budget'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);






SELECT im_menu__new (
	null, 'im_menu', now(), null, null, null,
	'intranet-reporting-finance',				-- package_name
	'reporting-finance-cash-flow',			-- label
	'Finance - Cash Flow',				-- name
	'/intranet-reporting-finance/finance-cash-flow', -- url
	50,						-- sort_order
	(select menu_id from im_menus where label='reporting-finance'),
	null						-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'reporting-finance-cash-flow'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'reporting-finance-cash-flow'),
	(select group_id from groups where group_name = 'Accounting'),
	'read'
);








SELECT im_menu__new (
	null, 'im_menu', now(), null, null, null,
	'intranet-cust-cosine',				-- package_name
	'cosine-project-financial-report',		-- label
	'Cosine - Projects Financial Report',		-- name
	'/intranet-cust-cosine/reports/projects-financial-report', -- url
	10,						-- sort_order
	(select menu_id from im_menus where label='reporting-finance'),
	null						-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'cosine-project-financial-report'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);


SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'cosine-project-financial-report'),
	(select group_id from groups where group_name = 'Accounting'),
	'read'
);





-----------------------------------------------------------
-- cosine "Request Approval" button
--
SELECT im_component_plugin__new (
	null,'im_component_plugin',now(),null,'0.0.0.0',null,
	'cosine PO Approval',			-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'left',					-- location
	'/intranet-invoices/view',		-- page_url
	null,					-- view_name
	10,					-- sort_order
	'im_cosine_po_approval_component -invoice_id $invoice_id',
	'lang::message::lookup "" intranet-cust-cosine.PO_Approval "PO Approval"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine PO Approval'),
	(select group_id from groups where group_name = 'Senior Managers'),
	'read'
);


-----------------------------------------------------------
-- cosine "Request Approval" button
--
-- SELECT im_component_plugin__new (
-- 	null,'im_component_plugin',now(),null,'0.0.0.0',null,
-- 	'cosine All PO Approval',		-- plugin_name
-- 	'intranet-cust-cosine',			-- package_name
-- 	'left',					-- location
-- 	'/intranet/projects/view',		-- page_url
-- 	null,					-- view_name
-- 	10,					-- sort_order
-- 	'im_cosine_po_approval_component -project_id $project_id',
-- 	'lang::message::lookup "" intranet-cust-cosine.PO_Approval "PO Approval"'
-- );
-- 
-- SELECT acs_permission__grant_permission(
-- 	(select plugin_id from im_component_plugins where plugin_name = 'cosine PO Approval'),
-- 	(select group_id from groups where group_name = 'Senior Managers'),
-- 	'read'
-- );


-----------------------------------------------------------
-- 
--

SELECT im_menu__new (
		null,			   -- menu_id
		'im_menu',		 -- object_type
		now(),			  -- creation_date
		null,			   -- creation_user
		null,			   -- creation_ip
		null,			   -- context_id
		'intranet-invoices',		-- package_name
		'invoices_provider_new_purchase_order_from_planned_purchase',	-- label
		'New Provider Purchase Order from Planned Purchase',	-- name
		'/intranet-invoices/new-copy?target_cost_type_id=3706&source_cost_type_id=3738',
		335,						-- sort_order
		(select menu_id from im_menus where label='invoices_providers'), -- parent_menu_id
		null						-- visible_tcl
);

update im_menus set url = '/intranet-invoices/new-copy?target_cost_type_id=3706&source_cost_type_id=3738' 
where label = 'invoices_provider_new_purchase_order_from_planned_purchase';


SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'invoices_provider_new_purchase_order_from_planned_purchase'),
	(select group_id from groups where group_name = 'Accounting'),
	'read'
);



SELECT im_menu__new (
		null,					-- menu_id
		'im_menu',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		'intranet-invoices',			-- package_name
		'invoices_providers_new_planned_purchase',  	-- label
		'New Planned Purchase from scratch',	-- name
		'/intranet-invoices/new?cost_type_id=3738', -- url
		31,					-- sort_order
		(select menu_id from im_menus where label='invoices_providers'),-- parent_menu_id
		null					-- visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'invoices_providers_new_planned_purchase'),
	(select group_id from groups where group_name = 'Accounting'),
	'read'
);







-----------------------------------------------------------
-- 
--

-- SELECT im_component_plugin__new (
-- 	null, 'im_component_plugin', now(), null, null, null,
-- 	'cosine Hour Budget',	-- plugin_name - shown in menu
-- 	'intranet-cust-cosine',		-- package_name
-- 	'left',				-- location
-- 	'/intranet/projects/view',	-- page_url
-- 	null,				-- view_name
-- 	120,				-- sort_order
-- 	'im_cosine_hour_budget_component -project_id $project_id'	-- component_tcl
-- );
-- 
-- SELECT acs_permission__grant_permission(
-- 	(select plugin_id from im_component_plugins where plugin_name = 'cosine Hour Budget'), 
-- 	(select group_id from groups where group_name = 'Employees'),
-- 	'read'
-- );





-- Create a Planning plugin for the ProjectViewPage.
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'cosine Hour Budget',	-- plugin_name
	'intranet-cust-cosine',		-- package_name
	'right',			-- location
	'/intranet/projects/view',	-- page_url
	null,				-- view_name
	100,				-- sort_order
	'im_planning_component -object_id $project_id -planning_type_id 73102 -left_dimension "project_phase" -top_dimension "resource"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine Hour Budget'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);





-----------------------------------------------------------
-- Trigger to handle cosine ETC hours
--

-- Calculate percent complete depending on the number of hours
-- specified by the PM still necessary to complete the task.
--
create or replace function cosine_etc_hours_trigger ()
returns trigger as $$
declare
	v_done	numeric;
	v_log	numeric;
begin
	IF new.cosine_etc_hours is not null AND coalesce(new.cosine_etc_hours,0) != coalesce(old.cosine_etc_hours,0) THEN
		select	p.reported_hours_cache into v_log
		from	im_projects p, 	im_timesheet_tasks t
		where	p.project_id = t.task_id and p.project_id = new.task_id;

		v_done := round(100.0 * v_log / (new.cosine_etc_hours + v_log + 0.000000001),1);

		RAISE NOTICE 'cosine_etc_hours_trigger task_id=%: new.etc=%, log=% => done=%', 
		      new.task_id, new.cosine_etc_hours, v_log, v_done;

		update im_projects set percent_completed = v_done where project_id = new.task_id;
	END IF;

	return new;
end;$$ language 'plpgsql';


CREATE TRIGGER im_timesheet_tasks_cosine_etc_hours_tr
AFTER INSERT or UPDATE ON im_timesheet_tasks
FOR EACH ROW EXECUTE PROCEDURE cosine_etc_hours_trigger();



-----------------------------------------------------------
-- Widget to show only part of the materials
--


SELECT im_dynfield_widget__new (
		null, 'im_dynfield_widget', now(), null, null, null,
	
		'cosine_job_profiles',		-- widget_name
		'Job Profile',			-- pretty_name
		'Job Profiles',			-- pretty_plural
		10007,				-- storage_type_id
		'integer',			-- acs_datatype
		'generic_sql',			-- widget
		'integer',			-- sql_datatype
		'
{custom {sql {
	select	m.material_id,
		m.material_name
	from	im_materials m
	where	m.material_status_id not in (select * from im_sub_categories(9102)) and
		m.material_type_id = 9020
	order by 
		lower(material_name) 
}}}
'
);


update im_dynfield_attributes
set widget_name = 'cosine_job_profiles'
where attribute_id in (
	select	da.attribute_id
	from	im_dynfield_attributes da, 
		acs_attributes aa
	where	da.acs_attribute_id = aa.attribute_id and
		aa.attribute_name = 'cosine_job_profile_id'
);







-- Returns a real[] for each day between start and end 
-- with 100 for working days and 0 for weekend + (any!) holidays
create or replace function im_resource_mgmt_work_days_cosine (integer, date, date)
returns float[] as $body$
DECLARE
	p_user_id	alias for $1;	p_start_date	alias for $2;	p_end_date	alias for $3;

	v_weekday			integer;	v_date				date;
	v_work_days			float[];	v_date_difference		integer;
	v_perc				float;		v				float;
	row				record;
BEGIN
	v_work_days = im_resource_mgmt_weekend(p_user_id, p_start_date, p_end_date);
	-- RAISE NOTICE 'status: %', v_work_days;
	FOR row IN
		select	a.*
		from	im_user_absences a
		where	(a.owner_id = p_user_id OR a.group_id = p_user_id OR a.group_id in (select group_id from group_distinct_member_map where member_id = p_user_id)) and
			a.end_date::date >= p_start_date and a.start_date::date <= p_end_date and
			a.absence_status_id not in (select * from im_sub_categories(16002) union select * from im_sub_categories(16006)) -- exclude deleted and rejected
	LOOP
		v_date_difference = 1 + row.end_date::date - row.start_date::date;
		v_perc = 100.0 * row.duration_days / v_date_difference;
		RAISE NOTICE 'im_resource_mgmt_work_days(%,%,%): Bank Holiday %', p_user_id, p_start_date, p_end_date, row.absence_name;
		v_date := row.start_date;
		WHILE (v_date <= row.end_date) LOOP
		        v := v_work_days[v_date - p_start_date];
			IF v is null THEN exit; END IF;
			v := v - v_perc;
			if v < 0.0 THEN v := 0.0; END IF;
			v_work_days[v_date - p_start_date] := v;
			v_date := v_date + 1;
		END LOOP;
		-- RAISE NOTICE 'status: %', v_work_days;
	END LOOP;

	return v_work_days;
END;$body$ language 'plpgsql';
select * from im_resource_mgmt_work_days_cosine(55815, '2020-01-01'::date, '2020-01-31'::date);
-- select im_resource_mgmt_work_days(624, '2019-12-23', '2019-12-30');
-- select im_resource_mgmt_work_days(463, '2018-12-01'::date, '2019-01-01');





-----------------------------------------------------------
-- Project cosine Profit & Loss Portlet
--
SELECT im_component_plugin__new (
	null,'im_component_plugin',now(),null,'0.0.0.0',null,
	'cosine Home Purchase Orders',		-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'left',					-- location
	'/intranet/index',			-- page_url
	null,					-- view_name
	200,					-- sort_order
	'im_cust_cosine_project_purchase_order_component',
	'lang::message::lookup "" intranet-cust-cosine.cosine_Home_Purchase_Orders "cosine Home Purchase Orders"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'cosine Home Purchase Orders'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);



-- Create a Rule plugin for the RiskViewPage.
SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Cosine FinDoc Rule Audit',			-- plugin_name
	'intranet-rule-engine',			-- package_name
	'left',					-- location
	'/intranet-cust-cosine/invoices/view',		-- page_url
	null,					-- view_name
	900,					-- sort_order
	'im_rule_audit_component -object_id $invoice_id'	-- component_tcl
);


-- GIT status
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'cosine GIT Status',			-- plugin_name
	'intranet-cust-cosine',			-- package_name
	'left',					-- location
	'/intranet/index',			-- page_url
	null,					-- view_name
	1900,					-- sort_order
	'im_cosine_git_status_component'	-- component_tcl
);
