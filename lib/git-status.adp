	<table class="table_list_page">
	<thead>	  
	  <tr class="rowtitle">
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Date "Date"] %></td>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Hash "Hash"] %></td>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Release "Release"] %></td>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Included_Commits "Included Commits"] %></td>
<if @debug@ eq 1>
	    <td><%= [lang::message::lookup "" intranet-git-releases.Git_Debug "Debug"] %></td>
</if>
	  </tr>
	</thead>	  
	<tbody>
	  <multiple name="releases_multirow">
	    <if @releases_multirow.rownum@ odd><tr class="roweven"></if>
	    <else><tr class="rowodd"></else>
		<td valign=top style='white-space: nowrap;'><a href="@releases_multirow.view_url@">@releases_multirow.date@</a></td>
		<td valign=top>@releases_multirow.hash@</td>
		<td valign=top>@releases_multirow.notes;noquote@</td>
		<td valign=top>@releases_multirow.details;noquote@</td>

<if @debug@ eq 1>
		<td valign=top>@releases_multirow.debug@</td>
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
