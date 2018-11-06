<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="TimeUtils" class="com.weavernorth.util.TimeUtils" scope="page" />
<jsp:useBean id="SubCompanyComInfo" class="weaver.hrm.company.SubCompanyComInfo" scope="page" />
<jsp:useBean id="DepartmentComInfo" class="weaver.hrm.company.DepartmentComInfo" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page" />
<%	
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(17625, user.getLanguage());
String needfav ="1";
String needhelp ="";

String meetingid = Util.null2String(request.getParameter("meetingid"));
RecordSet.executeProc("Meeting_SelectByID",meetingid);
//RecordSet.executeSql("select * from meeting where id="+meetingid);
RecordSet.next();
String meetingname=RecordSet.getString("name");
String addressselect = RecordSet.getString("addressselect");
String address=RecordSet.getString("address");
	new weaver.general.BaseBean().writeLog(addressselect+"add");

	new weaver.general.BaseBean().writeLog(address+"address");
	new weaver.general.BaseBean().writeLog(meetingid+"meetingid");
	String customizeAddress = Util.null2String(RecordSet.getString("customizeAddress"));
String begindate=RecordSet.getString("begindate") + " " + RecordSet.getString("begintime");
String enddate=RecordSet.getString("enddate") + " " + RecordSet.getString("endtime");
String addressName = "";
if("0".equals(addressselect)){
	rs.executeSql("select name from MeetingRoom where id in ("+address+")");
	while (rs.next()){
		addressName += ","+Util.null2String(rs.getString("name"));
	}
	if(!"".equals(addressName))
	    addressName=addressName.substring(1);
}else{
	addressName = customizeAddress;
}

String depid = Util.null2String(request.getParameter("depid"));

%>
<HTML>
<HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<script src="/js/tabs/jquery.tabs.extend_wev8.js"></script>
<link type="text/css" href="/js/tabs/css/e8tabs1_wev8.css" rel="stylesheet" />
<link rel="stylesheet" href="/css/ecology8/request/searchInput_wev8.css" type="text/css" />
<script type="text/javascript" src="/js/ecology8/request/searchInput_wev8.js"></script>
<link rel="stylesheet" href="/css/ecology8/request/seachBody_wev8.css" type="text/css" />
<link rel="stylesheet" href="/css/ecology8/request/hoverBtn_wev8.css" type="text/css" />
<script type="text/javascript" src="/js/ecology8/request/hoverBtn_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
</HEAD>
<BODY >
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align:right; width:400px!important">
			<input type="button" value="PDF导出" class="e8_btn_top middle" onclick="exportPDF()"/>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(197,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doSearch()"/>
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage()) %>" class="cornerMenu middle"></span>
		</td>
	</tr>
</table>
<div style="text-align: left;margin: 5px;">
<span style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;">
会议名称：<%=meetingname %>
</span>
<br>
<span style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
开始时间：<%=begindate %>
</span>
<span style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
结束时间：<%=enddate %>
</span>
<br>
<span style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
会议地点：<%=addressName %>
</span>
</div> 
<FORM id="weaverA" name="weaverA" action="MeetingStatList.jsp" method="post"  >
<input name="meetingid" id="meetingid" value="<%=meetingid %>" type="hidden">
<wea:layout type="4col">
	<wea:group context='查询条件'>
		<wea:item>部门</wea:item>
		<wea:item>
			<brow:browser viewType="0" name="depid" browserValue="<%=depid %>" 
				browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/company/DepartmentBrowser.jsp" 
				hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='1'  width="250px"
				completeUrl="/data.jsp?type=4" linkUrl="/hrm/company/HrmDepartmentDsp.jsp?id=" 
				browserSpanValue="<%=DepartmentComInfo.getDepartmentname(depid) %>" ></brow:browser>
		</wea:item>
		<wea:item>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(30947,user.getLanguage())%>" class="e8_btn_submit" onclick="doSearch();"/>
		</wea:item>
	</wea:group>
</wea:layout>
</FORM>
<%
String backfields = "a.departmentid, b.meetingid";
String fromSql  = " hrmresource a, Meeting_Member2 b   ";
String sqlWhere = " where a.id = b.memberid and b.meetingid = " + meetingid;
if(!"".equals(depid)){
	sqlWhere += " and a.departmentid = " + depid;
}
String groupby = " a.departmentid, b.meetingid ";
String orderby = " a.departmentid " ;
String tableString = "";
tableString =" <table instanceid=\"MeetingViewStatusTable\" tabletype=\"none\" pagesize=\"10\" >"+
             "	   <sql backfields=\""+backfields+"\" sqlform=\""+fromSql+"\" sqlwhere=\""+Util.toHtmlForSplitPage(sqlWhere)+"\"  sqlorderby=\""+orderby+"\" sqlgroupby=\""+groupby+"\"  sqlprimarykey=\"a.departmentid\" sqlsortway=\"asc\" sqlisdistinct=\"false\"/>"+
             "			<head>"+
             "				<col width=\"20%\"   text=\"部门\" 				column=\"departmentid\" 	transmethod=\"weaver.meeting.MeetingSign.getDeptmentName\" />"+
             "				<col width=\"10%\"   text=\"部门参会人员/已签到人员\" 	column=\"departmentid\" 	otherpara=\"column:meetingid\"  	transmethod=\"weaver.meeting.MeetingSign.getMeetingNumber\" />"+
             "				<col width=\"30%\"   text=\"已签到人员\" 			column=\"departmentid\" 	otherpara=\"column:meetingid\"		transmethod=\"weaver.meeting.MeetingSign.getMeetingSign\" />"+
             "				<col width=\"30%\"   text=\"未签到人员\" 			column=\"departmentid\" 	otherpara=\"column:meetingid\"		transmethod=\"weaver.meeting.MeetingSign.getMeetingNoSign\" />"+
             "			</head>"+
     		 "		</table>";
%>
<wea:SplitPageTag  tableString="<%=tableString%>"  mode="run" />
</BODY>
</HTML>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<SCRIPT LANGUAGE="JavaScript">

function doSearch() {
	jQuery("#weaverA").submit();
}

function doExcel(){
    _xtable_getAllExcel();
}

//导出会议基本信息pdf
function exportPDF(){
	window.location.href ="/weaver/weaver.meeting.pdf.MeetingSignDownLoad?meetingid=<%=meetingid%>&depid=<%=depid%>&downType=2";
}
</SCRIPT>