<p>
<%= [lang::message::lookup "" intranet-git-releases.Portlet_shows_changes_to_core_and_cust "
This portlet shows the last released changes to \]project-open\[ together with 
release date and the included change tickets."] %>
<br>
<%= [lang::message::lookup "" intranet-git-releases.Currently_installed_versions "Currently installed versions"] %>:
</p>

<ul>
<li><%= [lang::message::lookup "" intranet-git-releases.PO_Core_version "\]po\[ Core Version"] %>: <%= [im_core_version] %></li>
<if @customer_package_key@ ne "">
<li>@customer_package_key@: @customer_package_version@</li>
</if>
</ul>
	<table class="table_list_page">
	<thead>	  
	  <tr class="rowtitle">
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_ID "ID"] %></td>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Date "Date"] %></td>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_New_Version "New Version"] %></td>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Release "Release"] %></td>

<if @show_commits_p@ eq 1>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Included_Commits "Included Commits"] %></td>
<if @debug@ eq 1>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Debug "Debug"] %></td>
</if>
</if>
	  </tr>
	</thead>	  
	<tbody>
	  <multiple name="releases_multirow">
	    <if @releases_multirow.rownum@ odd><tr class="roweven"></if>
	    <else><tr class="rowodd"></else>
		<td valign=top>@releases_multirow.hash@</td>
		<td valign=top style='white-space: nowrap;'><a href="@releases_multirow.view_url@">@releases_multirow.date@</a></td>
		<td valign=top>@releases_multirow.cust_version@</td>
		<td valign=top>@releases_multirow.notes;noquote@</td>
<if @show_commits_p@ eq 1>
		<td valign=top>@releases_multirow.details;noquote@</td>
<if @debug@ eq 1>
		<td valign=top>@releases_multirow.debug@</td>
</if>
</if>

	    </tr>
	  </multiple>

<if @releases_multirow:rowcount@ eq 0>
	<tr class="rowodd">
	    <td colspan="2">
		<%= [lang::message::lookup "" intranet-git-releases.No_Releases_Available "No releases available"] %>
	    </td>
	</tr>
</if>

	</tbody>
	</table>
