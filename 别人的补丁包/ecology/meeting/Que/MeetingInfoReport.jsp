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

String userDep = ""+user.getUserDepartment();

int currUser = user.getUID();

int t_rsCount = 0;
RecordSet.executeSql("select count(*) as rsCount from MeetingAppraiseShare where userid = " + currUser);
if(RecordSet.next()){
	t_rsCount = Util.getIntValue(RecordSet.getString("rsCount"), 0);
}
Date newdate = new Date() ;
long datetime = newdate.getTime() ;
Timestamp timestamp = new Timestamp(datetime) ;
String currentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
String currentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16);

String meetingName = Util.null2String(request.getParameter("meetingName"));
String meetingtype = TimeUtils.replaceStr(request.getParameter("meetingtype"));
String userids = Util.null2String(request.getParameter("userids"));
String depid = TimeUtils.replaceRepStr(Util.null2String(request.getParameter("depid"))) ;
StringBuffer depNameApp = new StringBuffer();
ArrayList departmentlist = Util.TokenizerString(depid,",");
for(int i=0;i<departmentlist.size();i++){
	int departmentid = Util.getIntValue(departmentlist.get(i) + "", 0);
	if(departmentid > 0){
		depNameApp.append(DepartmentComInfo.getDepartmentname(departmentid + "") + "&nbsp;");
	}
}
String depName = depNameApp.toString();

String subid = TimeUtils.replaceRepStr(Util.null2String(request.getParameter("subid")));
String subName = Util.toScreen(SubCompanyComInfo.getSubcompanynames(subid+""),user.getLanguage());

int timeSag = Util.getIntValue(request.getParameter("timeSag"),0);
String createSdate = Util.null2String(request.getParameter("createSdate"));
String createEdate = Util.null2String(request.getParameter("createEdate"));

String meetingTypename = "";
if(!"".equals(meetingtype)){
	RecordSet.executeSql("select name from Meeting_Type where id in ("+ meetingtype +")");
	while(RecordSet.next()){
		meetingTypename += Util.null2String(RecordSet.getString("name"))+",";
	}
	if(!"".equals(meetingTypename)){
		meetingTypename = meetingTypename.substring(0,meetingTypename.length() - 1);
	}
}

StringBuffer lastNameApp = new StringBuffer();
if(!"".equals(userids)){
	ArrayList hrmidlist = Util.TokenizerString(userids,",");
	for(int i=0;i<hrmidlist.size();i++){
		int userid = Util.getIntValue(hrmidlist.get(i) + "", 0);
		if(userid > 0){
			lastNameApp.append(ResourceComInfo.getResourcename(userid + "") + "&nbsp;");
		}
	}
}
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
			<input type="button" value="Excel导出" class="e8_btn_top middle" onclick="doExcel()"/>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(197,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doSearch()"/>
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage()) %>" class="cornerMenu middle"></span>
		</td>
	</tr>
</table>

	<FORM id="weaverA" name="weaverA" action="MeetingInfoReport.jsp" method="post"  >
	<wea:layout type="4col">
		<wea:group context="查询条件" >
	    <wea:item>会议名称</wea:item>
	    <wea:item>
	        <input class="InputStyle" type="text" id=meetingName name="meetingName" value="<%=meetingName %>" style="width:60%">
		</wea:item>
		  
	    <wea:item>会议类型</wea:item>
	    <wea:item>
	        <brow:browser viewType="0" name="meetingtype" browserValue="<%=meetingtype %>" 
		  	browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/meeting/Maint/MutiMeetingTypeBrowser.jsp?forall=1&resourceids="
		  	hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='1' width="300px"
		   	completeUrl="/data.jsp?type=89" linkUrl="/meeting/Maint/ListMeetingType.jsp?id=#id#" 
		 	browserSpanValue="<%=meetingTypename %>"></brow:browser>
		</wea:item>
	
	    <wea:item>创建人</wea:item>
		<wea:item>
			<brow:browser viewType="0" name="userids" browserValue='<%=userids %>' 
				browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/resource/MutiResourceBrowser.jsp?resourceids=" 
				hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='1'  width="300px"
				completeUrl="/data.jsp" linkUrl="javascript:openhrm($id$)" 
				browserSpanValue='<%=lastNameApp.toString() %>'></brow:browser>
		</wea:item>
		
	    <wea:item>创建人部门</wea:item>
	    <wea:item>
			<brow:browser viewType="0" name="depid" browserValue="<%=depid %>" 
			browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/company/MutiDepartmentBrowser.jsp?selectedids=" 
			hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='1'  width="340px"
			completeUrl="/data.jsp?type=4" linkUrl="/hrm/company/HrmDepartmentDsp.jsp?id=" 
			browserSpanValue="<%=depName %>"></brow:browser>
		</wea:item>
		
	    <wea:item>创建人分部</wea:item>
	    <wea:item>
			<brow:browser viewType="0" name="subid" browserValue="<%=subid %>" 
			browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/company/SubcompanyBrowser3.jsp?selectedids=" 
			hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='1'  width="340px"
			completeUrl="/data.jsp?type=164" linkUrl="/hrm/company/HrmSubCompanyDsp.jsp?id=" 
			browserSpanValue="<%=subName %>"></brow:browser>
		</wea:item>
		
		<wea:item>创建时间</wea:item> 
	    <wea:item>
            <span>
            	<select name="timeSag" id="timeSag" onchange="changeDate(this,'meetingStartdate');" style="width:100px;">
            		<option value="0" <%=timeSag==0?"selected":"" %>><%=SystemEnv.getHtmlLabelName(332,user.getLanguage())%></option>
            		<option value="1" <%=timeSag==1?"selected":"" %>><%=SystemEnv.getHtmlLabelName(15537,user.getLanguage())%></option><!-- 今天 -->
            		<option value="2" <%=timeSag==2?"selected":"" %>><%=SystemEnv.getHtmlLabelName(15539,user.getLanguage())%></option><!-- 本周 -->
            		<option value="3" <%=timeSag==3?"selected":"" %>><%=SystemEnv.getHtmlLabelName(15541,user.getLanguage())%></option><!-- 本月 -->
            		<option value="4" <%=timeSag==4?"selected":"" %>><%=SystemEnv.getHtmlLabelName(21904,user.getLanguage())%></option><!-- 本季 -->
            		<option value="5" <%=timeSag==5?"selected":"" %>><%=SystemEnv.getHtmlLabelName(15384,user.getLanguage())%></option><!-- 本年 -->
            		<option value="6" <%=timeSag==6?"selected":"" %>><%=SystemEnv.getHtmlLabelName(32530,user.getLanguage())%></option><!-- 指定日期范围 -->
            	</select>
            </span>
            
            <span id="meetingStartdate"  style="<%=timeSag==6?"":"display:none;" %>">
           		<button type="button" class=calendar id=SelectDate onClick="getDate(createSdateSpan,createSdate)"></button>&nbsp;
               	<span id=createSdateSpan><%=createSdate %></span>
               	<input type="hidden" name="createSdate" id="createSdate" value="<%=createSdate %>">
             	-&nbsp;&nbsp;
             	<button type="button" class=calendar id=SelectDate2 onClick="getDate(createEdateSpan,createEdate)"></button>&nbsp;
              	<span id="createEdateSpan" ><%=createEdate %></span>
             	<input type="hidden" name="createEdate" id="createEdate" value="<%=createEdate %>"> 
			</span>
         </wea:item>
	</wea:group>
	</wea:layout>
	</FORM>
<%
String backfields = "a.id,a.name,a.meetingstatus,a.creater,(a.begindate || ' ' || a.begintime) as begindate,(a.enddate || ' ' || a.endtime) as enddate,b.name as meetingtypename,c.departmentid,a.createdate,a.createtime,a.decisiondate,a.decisiontime ";
String fromSql  = " meeting a, Meeting_Type b, HrmResource c  ";
String sqlWhere = " where a.meetingtype = b.id  and a.creater = c.id and (a.meetingstatus = 5 or a.meetingstatus = 2) ";

if(t_rsCount > 0) {
	int rsCount = 0;
	RecordSet.executeSql("select count(*) as rsCount from MeetingAppraiseShare where shareType = '1' and userid = " + currUser);
	if(RecordSet.next()){
		rsCount = Util.getIntValue(RecordSet.getString("rsCount"), 0);
	}
	if(rsCount <= 0){
		StringBuffer subids = new StringBuffer();
		RecordSet.executeSql("select content from MeetingAppraiseShare where shareType = '2' and userid = " + currUser);
		while(RecordSet.next()){
			subids.append(Util.null2String(RecordSet.getString("content")) + ",");
		}
		String tempSubids = TimeUtils.replaceStr(subids.toString());
		
		StringBuffer depids = new StringBuffer();
		RecordSet.executeSql("select content from MeetingAppraiseShare where shareType = '3' and userid = " + currUser);
		while(RecordSet.next()){
			depids.append(Util.null2String(RecordSet.getString("content")) + ",");
		}
		String tempDepids = TimeUtils.replaceStr(depids.toString());
		
		if(!"".equals(tempSubids) && !"".equals(tempDepids)){
			sqlWhere += " and (c.subcompanyid1 in ("+ tempSubids +") or c.departmentid in ("+ tempDepids +") or a.creater = " + currUser + " or a.caller = "+ currUser +") ";
		}else if(!"".equals(tempSubids)){
			sqlWhere += " and (c.subcompanyid1 in ("+ tempSubids +") or a.creater = " + currUser + " or a.caller = "+ currUser +") ";
		}else if(!"".equals(tempDepids)){
			sqlWhere += " and (c.departmentid in ("+ tempDepids +") or a.creater = " + currUser + " or a.caller = "+ currUser +") ";
		}
	}
}else{
	sqlWhere += " and (a.creater = " + currUser + " or a.caller = "+ currUser +") ";
}

if(!"".equals(meetingName)){
	sqlWhere += " and a.name like '%"+ meetingName +"%'";
}

if(!"".equals(meetingtype)){
	sqlWhere += " and b.id in ("+ meetingtype +") ";
}

if(!"".equals(userids)){
	sqlWhere += " and a.creater in ("+ userids +") ";
}

if(!"".equals(depid)){
	sqlWhere += " and c.departmentid in ("+ depid +") ";
}

if(!"".equals(subid)){
	sqlWhere += " and c.subcompanyid1 in ("+ subid +") ";
}

if (timeSag > 0 && timeSag < 6) {
	createSdate = TimeUtil.getDateByOption("" + timeSag, "0");
	createEdate = TimeUtil.getDateByOption("" + timeSag, "1");
	sqlWhere += " and ('"+ createSdate +"' <= a.createdate and '"+ createEdate +"' >= a.createdate) ";
} else if (timeSag == 6) {
	if(!"".equals(createSdate)){
		sqlWhere += " and a.createdate >= '"+ createSdate +"'";
	}
	if(!"".equals(createSdate)){
		sqlWhere += " and a.createdate <= '"+ createEdate +"'";
	}
}

String orderby = " a.createdate,a.createtime " ;

//out.println("select " + backfields + " from " + fromSql + sqlWhere + "order by " + orderby);

String tableString = "";
tableString =" <table instanceid=\"MeetingTicklingListTable\" tabletype=\"none\" pagesize=\"20\" >"+
             "	   <sql backfields=\""+backfields+"\" sqlform=\""+fromSql+"\" sqlwhere=\""+Util.toHtmlForSplitPage(sqlWhere)+"\"  sqlorderby=\""+orderby+"\"  sqlprimarykey=\"a.id\" sqlsortway=\"Desc\" sqlisdistinct=\"true\"/>"+
             "			<head>"+
             "				<col width=\"7%\"   text=\"会议类型\" 			column=\"meetingtypename\" 	orderkey=\"meetingtypename\"/>"+
             "				<col width=\"12%\"  text=\""+SystemEnv.getHtmlLabelName(2151,user.getLanguage())+"\" column=\"name\" orderkey=\"name\" transmethod=\"weaver.meeting.Maint.MeetingTransMethod.getMeetingName\" otherpara=\"column:id+column:status\" />"+
             "				<col width=\"6%\"    text=\"创建人\" 			column=\"creater\" 			orderkey=\"creater\" 		transmethod=\"weaver.meeting.Maint.MeetingTransMethod.getMeetingResource\" />"+
             "				<col width=\"7%\"    text=\"创建部门\" 			column=\"departmentid\" 	orderkey=\"departmentid\"  	transmethod=\"weaver.hrm.company.DepartmentComInfo.getDepartmentname\" />"+
           	 "				<col width=\"7%\"    text=\"会议开始时间\" 		column=\"begindate\" 		orderkey=\"begindate\"/>"+
		 	 "				<col width=\"7%\"    text=\"会议结束时间\" 		column=\"enddate\"  		orderkey=\"enddate\"/>"+
             "				<col width=\"7%\"    text=\"会议通知下发时间\" 	column=\"id\"  				transmethod=\"weaver.meeting.info.MeetingInfoService.getNotifyDate\"/>"+
             "				<col width=\"7%\"    text=\"通知提前下发天数\" 	column=\"id\"  				orderkey=\"datetime_ks\" transmethod=\"weaver.meeting.info.MeetingInfoService.getNotifydays\"/>"+
             "				<col width=\"8%\"    text=\"会议材料下发时间\" 	column=\"id\"				transmethod=\"weaver.meeting.info.MeetingInfoService.getAttachNotifyDate\"/>"+
             "				<col width=\"8%\"    text=\"会议纪要下发时间\" 	column=\"decisiondate\"		otherpara=\"column:decisiontime\" orderkey=\"decisiondate,decisiontime\" transmethod=\"weaver.meeting.info.MeetingInfoService.getMeetingDecisionDate\" />"+
             "				<col width=\"8%\"    text=\"会议纪要下发逾期天数\"  column=\"id\"				transmethod=\"weaver.meeting.info.MeetingInfoService.getMeetingOverdueDays\"/>"+
             "				<col width=\"8%\"    text=\"会议签到记录\" 		column=\"id\"				transmethod=\"weaver.meeting.info.MeetingInfoService.getMeetingSign\" />"+
             "				<col width=\"7%\"    text=\"会议评估结果\" 		column=\"id\"				transmethod=\"weaver.meeting.info.MeetingInfoService.getMeetingEvaluate\" />"+
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

function view(id)
{
	if(id!="0" && id !=""){
		if(window.top.Dialog){
			diag_vote = new window.top.Dialog();
		} else {
			diag_vote = new Dialog();
		}
		diag_vote.currentWindow = window;
		diag_vote.Width = 800;
		diag_vote.Height = 550;
		diag_vote.Modal = true;
		diag_vote.maxiumnable = true;
		diag_vote.checkDataChange = false;
		diag_vote.Title = "<%=SystemEnv.getHtmlLabelName(367,user.getLanguage())%><%=SystemEnv.getHtmlLabelName(2103,user.getLanguage())%>";
		diag_vote.URL = "/meeting/data/ViewMeetingTab.jsp?meetingid="+id;
		diag_vote.show();
	}
}

function meetingEvaluate(id){
	if(id!="0" && id !=""){
		if(window.top.Dialog){
			diag_vote = new window.top.Dialog();
		} else {
			diag_vote = new Dialog();
		}
		diag_vote.currentWindow = window;
		diag_vote.Width = 1200;
		diag_vote.Height = 600;
		diag_vote.Modal = true;
		diag_vote.maxiumnable = true;
		diag_vote.Title = "会议效果评估综合得分";
		diag_vote.URL = "/meeting/Que/MeetingEvaluateTab.jsp?_fromURL=MeetingEvaluateManager&isShow=view&meetingid="+id;
		diag_vote.show();
	}
}

function onShowSignIn(id){
	if(id!="0" && id !=""){
		if(window.top.Dialog){
			diag_vote = new window.top.Dialog();
		} else {
			diag_vote = new Dialog();
		}
		diag_vote.currentWindow = window;
		diag_vote.Width = 850;
		diag_vote.Height = 600;
		diag_vote.Modal = true;
		diag_vote.maxiumnable = true;
		diag_vote.Title = "会议签到情况";
		diag_vote.URL = "/meeting/data/MeetingParticipants.jsp?toflag=MeetingSign&meetingid="+id;
		diag_vote.show();
	}
}

function closeDialog(){
	diag_vote.close();
}

function doSearch() {
	jQuery("#weaverA").submit();
}

function doExcel(){
    _xtable_getAllExcel();
}
</SCRIPT>