<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.Timestamp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="TimeUtils" class="com.weavernorth.util.TimeUtils" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>
<jsp:useBean id="SubCompanyComInfo" class="weaver.hrm.company.SubCompanyComInfo" scope="page" />
<jsp:useBean id="DepartmentComInfo" class="weaver.hrm.company.DepartmentComInfo" scope="page" />
<%@ include file="/hrm/header.jsp" %>
<%
String imagefilename = "/images/hdCRMAccount_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(2211,user.getLanguage())+"-"+SystemEnv.getHtmlLabelName(2112,user.getLanguage()) ;
int needchange=0;
String needfav ="1";
String needhelp ="";

Date newdate = new Date() ;
long datetime = newdate.getTime() ;
Timestamp timestamp = new Timestamp(datetime) ;
String currentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
String currentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16);

//获取查询会议名称	
String meetingName = Util.null2String(request.getParameter("meetingName"));
String meetingtype = TimeUtils.replaceStr(request.getParameter("meetingtype"));
String userids = TimeUtils.replaceStr(request.getParameter("userids"));

int timeSag = Util.getIntValue(request.getParameter("timeSag"),0);
String createSdate = Util.null2String(request.getParameter("createSdate"));
String createEdate = Util.null2String(request.getParameter("createEdate"));

String depid = Util.null2String(request.getParameter("depid"));
String subid = Util.null2String(request.getParameter("subid"));

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
<HTML><HEAD>
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


<script type="text/javascript">
var parentWin = parent.getParentWindow(window);
var dialog = parent.getDialog(window);
</script>
</HEAD>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>

<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(197,user.getLanguage())+",javascript:doSearch(),_top} " ;
RCMenuHeight += RCMenuHeightStep ;
%>

<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
	   <td>
	    </td>
		<td class="rightSearchSpan" style="text-align:right; ">
			<input type="button" value="Excel导出" class="e8_btn_top middle" onclick="doExcel()"/>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(197,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doSearch()"/>
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage()) %>" class="cornerMenu middle"></span>
		</td>
	</tr>
</table>
<form action="StayAppraiseMeeting.jsp" name="searchfrm" id="searchfrm">
<wea:layout type="4col" >
	<wea:group context="<%=SystemEnv.getHtmlLabelName(20331, user.getLanguage())%>">
		<wea:item>会议名称</wea:item>
		<wea:item>
			<INPUT id="meetingName" name="meetingName" value="<%=meetingName %>" style="width:268px;"> 
		</wea:item>
		
		<wea:item>会议类型</wea:item>
		<wea:item>
			<brow:browser viewType="0" name="meetingtype" browserValue='<%=meetingtype %>' 
				browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/meeting/Maint/MutiMeetingTypeBrowser.jsp?forall=1&resourceids="
				hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='1' width="300px"
				completeUrl="/data.jsp?type=89&forall=1" linkUrl="/meeting/Maint/ListMeetingType.jsp?id=#id#" 
				browserSpanValue='<%=meetingTypename %>'></brow:browser>
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
			browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/company/DepartmentBrowser.jsp" 
			hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='1'  width="300px"
			completeUrl="/data.jsp?type=4" linkUrl="/hrm/company/HrmDepartmentDsp.jsp?id=" 
			browserSpanValue="<%=DepartmentComInfo.getDepartmentname(depid) %>"></brow:browser>
		</wea:item>
		
	    <wea:item>创建人分部</wea:item>
	    <wea:item>
	        <brow:browser viewType="0" name="subid" browserValue="<%=subid %>" 
			browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/company/SubcompanyBrowser.jsp?selectedids=" 
			hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='1'  width="300px"
			completeUrl="/data.jsp?type=164" linkUrl="/hrm/company/HrmSubCompanyDsp.jsp?id=" 
			browserSpanValue="<%=SubCompanyComInfo.getSubCompanyname(subid) %>"></brow:browser>
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
</form>

<%
	String backFields = "a.id,a.name as meetingname,a.creater,(a.begindate || ' ' || a.begintime) as begindate,(a.enddate || ' ' || a.endtime) as enddate,a.createdate,a.createtime,b.name as meetingtypename,c.departmentid";
	String sqlForm = " meeting a, Meeting_Type b, HrmResource c ";
	String sqlWhere = " where a.meetingtype = b.id  and a.creater = c.id and (a.meetingstatus = 5 or a.meetingstatus = 2)";
	sqlWhere += " and a.id in (select meetingId from MeetingUser where userid = "+ user.getUID() +") ";
	sqlWhere += " and a.id not in (select meetingId from MeetingAppraiseDetail where userid = "+ user.getUID() +") ";
	
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
		sqlWhere += " and c.departmentid = " + depid;
	}
	
	if(!"".equals(subid)){
		sqlWhere += " and c.subcompanyid1 = " + subid;
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
	
	String orderby = " a.createdate,a.createtime ";
	
	//out.println("select " + backFields + " from " + sqlForm + sqlWhere + "order by " + orderby);
	
	String tableString= "<table pagesize=\""+PageIdConst.getPageSize(PageIdConst.WP_WorkPlanShareSet,user.getUID())+"\" tabletype=\"none\">"+
		    "<sql backfields=\"" + backFields + "\" sqlform=\"" + sqlForm + "\" sqlprimarykey=\"a.id\" sqlorderby=\"" + orderby + "\"  sqlsortway=\"DESC\" sqlwhere=\""+Util.toHtmlForSplitPage(sqlWhere)+"\"/>"+
		    "<head>"+
		    "<col width=\"15%\"   text=\"会议类型\" column=\"meetingtypename\" />"+
			"<col width=\"25%\"   text=\"会议名称\" column=\"id\" 			orderkey=\"id\" transmethod=\"com.weavernorth.meeting.TablePageHtml.getMeetingName\" />"+
			"<col width=\"10%\"    text=\"创建人\"  column=\"creater\" 	orderkey=\"creater\"		transmethod=\"weaver.meeting.Maint.MeetingTransMethod.getMeetingResource\" />"+
			"<col width=\"15%\"   text=\"所属部门\" column=\"departmentid\" orderkey=\"departmentid\"	 transmethod=\"weaver.hrm.company.DepartmentComInfo.getDepartmentname\"/>"+
			"<col width=\"15%\"   text=\"开始时间\" column=\"begindate\" 	orderkey=\"begindate\"	/>"+
			"<col width=\"15%\"   text=\"结束时间\" column=\"enddate\" 		orderkey=\"enddate\"	/>"+
		    "</head>"+ 
		    "<operates>"+
			"<operate href=\"javascript:appraiseMeeting();\" isalwaysshow=\"true\" text=\"评估会议\" target=\"_self\" index=\"0\"/>"+
			"</operates>"+
		"</table>";
%>
<input type="hidden" name="pageId" id="pageId" value="<%=PageIdConst.WP_WorkPlanShareSet%>"/>
<wea:SplitPageTag tableString='<%=tableString%>'  mode="run" isShowTopInfo="true"/> 

<script language="javascript">
var diag_vote;
function closeDialog(){
	var dialog = parent.parent.getDialog(parent.window);	
	dialog.closeByHand();
}

function appraiseMeeting(id)
{
	if(id!="0" && id !=""){
		if(window.top.Dialog){
			diag_vote = new window.top.Dialog();
		} else {
			diag_vote = new Dialog();
		}
		diag_vote.currentWindow = window;
		diag_vote.Width = 800;
		diag_vote.Height = 400;
		diag_vote.Modal = true;
		diag_vote.maxiumnable = true;
		diag_vote.Title = "会议评估";
		diag_vote.URL = "/meeting/Tickling/Reply/MeetingTicklingTab.jsp?_fromURL=MeetingTicklingAdd&meetingId="+id;
		diag_vote.show();
	}
}

function doSearch() {
	jQuery("#searchfrm").submit();
}

function doExcel(){
    _xtable_getAllExcel();
}
</script>
</BODY>
</HTML>
