<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ page import="java.util.*" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<%	
String imagefilename = "/images/hdCRMAccount_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(2211,user.getLanguage())+"-"+SystemEnv.getHtmlLabelName(2112,user.getLanguage()) ;
int needchange=0;
String needfav ="1";
String needhelp ="";

if(!HrmUserVarify.checkUserRight("Meeting:EvalReport", user)) {
	response.sendRedirect("/notice/noright.jsp");
	return;
}

int	pagesize=5; 
%>
<HTML>
<HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<link rel="stylesheet" href="/css/ecology8/request/requestTopMenu_wev8.css" type="text/css" />
<link rel="stylesheet" href="/wui/theme/ecology8/jquery/js/zDialog_e8_wev8.css" type="text/css" />
<BODY Scroll=no>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<FORM action="MeetingQueSeting.jsp" name="searchfrm" id="searchfrm" method=post  >
<!-- 统计 -->
<%
	String backFields = "id,title,s_mark,f_mark";
	String sqlForm = " MeetingQueSeting ";
	String sqlWhere = " where 1 = 1 ";
	
	String orderby = " id ";
	
	String tableString =" <table instanceid=\"devicelist\" tabletype=\"checkbox\" pagesize=\""+pagesize+"\" >"+
		" <sql backfields=\""+backFields+"\" sqlform=\""+Util.toHtmlForSplitPage(sqlForm)+"\" sqlwhere=\""+Util.toHtmlForSplitPage(sqlWhere)+"\"   sqlprimarykey=\"id\" sqlorderby=\"" + orderby + "\" sqlsortway=\"asc\" sqlisdistinct=\"true\"/>"+
		"<head>"+
		"<col width=\"20%\"  text=\"序号\" column=\"id\"  orderkey=\"id\"/>"+
	    "<col width=\"40%\"  text=\"问题\"  column=\"title\" orderkey=\"title\"/>"+
	    "<col width=\"20%\"  text=\"(是)分数\"  column=\"s_mark\" orderkey=\"s_mark\"/>"+
	    "<col width=\"20%\"  text=\"(否)分数\"  column=\"f_mark\" orderkey=\"f_mark\"/>"+
		"</head>"+
		"<operates>"+
		"<operate href=\"javascript:setingSMark();\" isalwaysshow=\"true\" text=\"设置是分数\" target=\"_self\" index=\"0\"/>"+
		"<operate href=\"javascript:setingFMark();\" isalwaysshow=\"true\" text=\"设置否分数\" target=\"_self\" index=\"0\"/>"+
		"</operates>"+
		"</table>";
%>
<wea:SplitPageTag isShowTopInfo="false" tableString="<%=tableString%>" mode="run" />
</BODY>
</HTML>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<SCRIPT LANGUAGE="JavaScript">

function doSearch() {
	jQuery("#searchfrm").submit();
}

function setingSMark(id){
	if(window.top.Dialog){
		diag_vote = new window.top.Dialog();
	} else {
		diag_vote = new Dialog();
	}
	diag_vote.currentWindow = window;
	diag_vote.Width = 800;
	diag_vote.Height = 400;
	diag_vote.Modal = true;
	diag_vote.Title = "问题分数设置";
	diag_vote.URL = "/meeting/Tickling/MeetingQueSetingTab.jsp?_fromURL=MeetingMarkSeting&type=1&queId="+id;
	diag_vote.show();
}

function setingFMark(id){
	if(window.top.Dialog){
		diag_vote = new window.top.Dialog();
	} else {
		diag_vote = new Dialog();
	}
	diag_vote.currentWindow = window;
	diag_vote.Width = 800;
	diag_vote.Height = 400;
	diag_vote.Modal = true;
	diag_vote.Title = "问题分数设置";
	diag_vote.URL = "/meeting/Tickling/MeetingQueSetingTab.jsp?_fromURL=MeetingMarkSeting&type=0&queId="+id;
	diag_vote.show();
}
</SCRIPT>