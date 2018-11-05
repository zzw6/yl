<%@ page import="weaver.general.Util" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />

<HTML><HEAD>
<%
String imagefilename = "/images/hdHRMCard_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(357,user.getLanguage());
String needfav ="1";
String needhelp ="";
String meetingId = Util.null2String(request.getParameter("meetingId"));
String isClose = Util.null2String(request.getParameter("isClose"));

%>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<LINK href="/wui/theme/ecology8/jquery/js/e8_zDialog_btn_wev8.css" type=text/css rel=STYLESHEET>
<script type="text/javascript">
var parentWin = parent.parent.getParentWindow(parent);
var dialog = parent.parent.getDialog(parent);

if("<%=isClose%>"=="1"){
	parentWin.doSearch();
	dialog.closeByHand();	
}

</script>
<style type="text/css">   
.border-table {   
    border-collapse: collapse;   
    border: none;   
}   
</style>
</head>
<BODY>

<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(86,user.getLanguage())+",javascript:doSubmit();,_self} " ;
RCMenuHeight += RCMenuHeightStep ;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align:right;">
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(86,user.getLanguage())%>" class="e8_btn_top" onclick="doSubmit();">
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage())%>" class="cornerMenu"></span>
		</td>
	</tr>
</table>


<FORM id=frmMain name=frmMain action="MeetingTicklingOperator.jsp" method=post >
<input name="meetingId" name="meetingId" value="<%=meetingId %>" type="hidden"/>
<table border="0" cellspacing="0" cellpadding="0" width="100%" height="100%" class="border-table" style="margin: 5 auto;">
	<tbody>
		<tr height="60px">
			<td width="60%" style="border-bottom: solid #DADADA 1px; border-right: solid #DADADA 1px; ">
				<p class="MsoNormal" align="center" style="text-align:center;">
					<b><span style="font-size:14px;">问题</span></b>
				</p>
			</td>
			<td width="40%" style="border-bottom: solid #DADADA 1px;">
				<p class="MsoNormal" align="center" style="text-align:center;">
					<b><span style="font-size:14px;">是（20） / 否（0）</span></b>
				</p>
			</td>
		</tr>
		
		<%
		RecordSet.executeSql("select * from MeetingQueSeting");
		while(RecordSet.next()){
			String id = Util.null2String(RecordSet.getString("id"));
			String title = Util.null2String(RecordSet.getString("title"));
			String s_mark = Util.null2String(RecordSet.getString("s_mark")) + "_1";
			String f_mark = Util.null2String(RecordSet.getString("f_mark")) + "_0";

		%>	
			<tr height="50px">
				<td width="60%" style="border-bottom: solid #DADADA 1px; border-right: solid #DADADA 1px; ">
					<p class="MsoNormal" align="left">
						<input name="queId" name="queId" value="<%=id %>" type="hidden"/>
						<span style="font-size:12px;margin-left: 10px;"><%=title %></span>
					</p>
				</td>
				<td width="40%" style="border-bottom: solid #DADADA 1px;" align="center">
					<span style="font-size:12px;margin-left: 10px;">
						<select id="quemark_<%=id %>" name="quemark_<%=id %>" style="width: 100px;">
							<option value="<%=s_mark %>">是</option>
							<option value="<%=f_mark %>">否</option>
						</select>
					</span>
				</td>
			</tr>
		<%} %>
	</tbody>
</table>
</FORM>
<div id="zDialog_div_bottom" class="zDialog_div_bottom">
<wea:layout>
	<wea:group context="">
		<wea:item type="toolbar">
	    <input type="button" value="<%=SystemEnv.getHtmlLabelName(309,user.getLanguage())%>" id="zd_btn_cancle"  class="zd_btn_cancle" onclick="dialog.closeByHand();">
		</wea:item>
	</wea:group>
</wea:layout>
</div>
<script language=javascript>
function doSubmit() {
	frmMain.submit();
}
</script>
</BODY>
</HTML>
