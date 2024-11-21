<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<property name="admin_navbar_label">admin_components</property>

<!--
im_git_parse_commit_log: output: commit e055c82f07db0de86dc161df6da1442f392a7e00                                                                 
im_git_parse_commit_log: output: Author:     Frank Bergmann <frank.bergmann@project-open.com>                                                    
im_git_parse_commit_log: output: AuthorDate: 2024-11-21 16:38:21 +0100                                                                           
im_git_parse_commit_log: output: Commit:     Frank Bergmann <frank.bergmann@project-open.com>                                                    
im_git_parse_commit_log: output: CommitDate: 2024-11-21 16:38:21 +0100                                                                           
im_git_parse_commit_log: output:                                                                                                                 
im_git_parse_commit_log: output:     cosine #5767: Send out reminder emails for purchase orders without workflow                                 
im_git_parse_commit_log: output:                                                                                                                 
-->

<TABLE border=0>
<TBODY>
  <tr><td class=rowtitle align=middle colSpan=2>Release</td></tr>
  <tr class=rowodd>  <td>Commit</td><td>@commit_hash@</td></tr>
  <tr class=roweven> <td>Author</td><td>@author@</td></tr>
  <tr class=roweven> <td>Date</td><td>@commit_date@</td></tr>
  <tr class=roweven> <td>Comment</td><td>@release_comment;noquote@</td></tr>
  <tr class=roweven> <td>Details</td><td>@details;noquote@</td></tr>
</TBODY>
</TABLE>
