<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.*" %>
<%@ page import="weaver.general.TimeUtil" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page" />
<jsp:useBean id="MeetingTransMethod" class="weaver.meeting.Maint.MeetingTransMethod" scope="page" />
<jsp:useBean id="DepartmentComInfo" class="weaver.hrm.company.DepartmentComInfo" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page" />

<HTML><HEAD>
<%
String imagefilename = "/images/hdHRMCard_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(357,user.getLanguage());
String needfav ="1";
String needhelp ="";
String isClose = Util.null2String(request.getParameter("isClose"));
String isShow = Util.null2String(request.getParameter("isShow"));
int meetingid = Util.getIntValue(request.getParameter("meetingid"), 0);
RecordSet.executeProc("Meeting_SelectByID",meetingid+"");
RecordSet.next();
String meetingname=RecordSet.getString("name");
String begindate=RecordSet.getString("begindate") + " " + RecordSet.getString("begintime");
String enddate=RecordSet.getString("enddate") + " " + RecordSet.getString("endtime");
String caller=RecordSet.getString("caller");
String creater=RecordSet.getString("creater");
%>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<script type="text/javascript" src="/meeting/Que/js/meetingQue.js"></script>
<style type="text/css">   
.border-table {   
    border-collapse: collapse;   
    border: none;   
}   
.border-table td {
    border: solid #D0D0D0 2px;   
}
body,li,p,ul {
    margin: 0;
    padding: 0;
    font: 12px/1 Tahoma, Helvetica, Arial, "\5b8b\4f53";
}
.content{ width:90%; padding-top:5px;}
.title{ font-size:14px; background:#dfdfdf; margin-bottom:10px;}
.block{ width:90%; margin:0 0 5px 0;line-height:33px;}
.star_score{ float:left;}
.star_list{height:33px;margin:50px; line-height:33px;}
.block p,.block{ padding-left:20px; line-height:33px; display:inline-block;}
.star_score { background:url(/meeting/Que/images/stark2.png); width:160px; height:33px;  position:relative; }
.star_score a{ height:33px; display:block; text-indent:-999em; position:absolute;left:0;}
.star_score a:hover{ background:url(/meeting/Que/images/stars2.png);left:0;}
.star_score a.clibg{ background:url(/meeting/Que/images/stars2.png);left:0;}

/*星星样式*/
.show_number li{margin-bottom:20px;}
.atar_Show{background:url(/meeting/Que/images/stark2.png); text-align:center; width:168px; height:33px;position:relative;}
.atar_Show p{ background:url(/meeting/Que/images/stars2.png);left:0; height:33px; width:135px;}
.show_number li span{ display:inline-block; line-height:33px;}
ul{
	list-style-type:none;
}
</style>

<script type="text/javascript">
var parentWin = parent.parent.getParentWindow(parent);
var dialog = parent.parent.getDialog(parent);
if("<%=isClose%>"=="1"){
	parentWin.doSearch();
	dialog.closeByHand();	
}
</script>
</head>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(615,user.getLanguage())+",javascript:doSubmit();,_self} " ;
RCMenuHeight += RCMenuHeightStep ;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align:right;">
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(615,user.getLanguage())%>" class="e8_btn_top" onclick="doSubmit();">
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage())%>" class="cornerMenu"></span>
		</td>
	</tr>
</table>
<div style="text-align: left;margin: 5px;">
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议主持人：<%=MeetingTransMethod.getMeetingResource(caller) %>
	</div>
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议组织部门：<%=DepartmentComInfo.getDepartmentname(ResourceComInfo.getDepartmentID(creater)) %>
	</div>
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议名称：<%=meetingname %>
	</div>
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议开始时间：<%=begindate %>  —  <%=enddate %>
	</div>
</div> 
<FORM id=frmMain name=frmMain action="MeetingEvaluateOperator.jsp" method=post >
<input class="InputStyle" type="hidden" name="operation" id="operation" value="add" />
<input class="InputStyle" type="hidden" name="meetingid" id="meetingid" value="<%=meetingid %>" />
<input class="InputStyle" type="hidden" name="isShow" id="isShow" value="<%=isShow %>" />
<table style="margin: 0 auto;" width="98%" class="border-table">
	<tr height="40" style="">
		<td colspan="3" style="text-align: center;vertical-align: middle;border: none;">
			<span style="font-size: 16px;color: black;font-family: 微软雅黑;font-weight: 700;">会议效果评估表</span>
		</td>
	</tr>
	<tr height="40">
		<td style="background: #8db4e3;text-align: center;vertical-align: middle" width="6%">
			<span style="font-size: 14px;color: white;font-family: 微软雅黑;font-weight: 700;">序号</span>
		</td>
		<td style="background: #8db4e3;text-align: center;vertical-align: middle" width="54%">
			<span style="font-size: 14px;color: white;font-family: 微软雅黑;font-weight: 700;">评价问题</span>
		</td>
		<td style="background: #8db4e3; text-align: center;vertical-align: middle" width="40%">
			<span style="font-size: 14px;color: white;font-family: 微软雅黑;font-weight: 700;">评分</span>
		</td>
	</tr>
	<%
	int count = 1;
	String chenkFiled = "";
	RecordSet.executeSql("select id,remark from uf_MQSeting order by showorder ");
	while(RecordSet.next()){
		String id = Util.null2String(RecordSet.getString("id"));
		String remark = Util.null2String(RecordSet.getString("remark"));
		chenkFiled += "h_meetingScore_" + id + ",";
	%>
	<input class="InputStyle" type="hidden" name="mqId" id="mqId" value="<%=id %>" />
	<input class=inputstyle type="hidden" id="h_meetingScore_<%=id %>" name="h_meetingScore_<%=id %>" value="">
	<tr height="40">
		<td style="text-align: center;vertical-align: middle" >
			<span style="font-size: 12px;font-family: 微软雅黑;"><%=count %></span>
		</td>
		<td style=" text-align: left;vertical-align: middle">
			<span style="font-size: 12px;font-family: 微软雅黑;"><%=remark %></span>
		</td>
		<td style="vertical-align: middle">
			<div class="content">
			    <div id="meetingScore_<%=id %>" class="block clearfix" >
			          <div class="star_score"></div>
			          <p style="float:left;">您的评分：<span class="fenshu">0</span> 分</p>
			    </div>
			</div>
			<script type="text/javascript">
				var score = "meetingScore_<%=id %>";
				var h_score = "h_meetingScore_<%=id %>";
				scoreFun($("#" + score), null, $("#" + h_score));
			</script>
		</td>
	</tr>
	<%
		count++;
	}
	%>
	<tr height="40">
		<td style="text-align: center;vertical-align: middle" width="10%">
			<span style="font-size: 12px;font-family: 微软雅黑;"><%=count %></span>
		</td>
		<td style="vertical-align: middle" width="10%">
			<span style="font-size: 12px;font-family: 微软雅黑;">您觉得本次会议存在哪些不足？您有什么建议？</span>
		</td>
		<td style="vertical-align: middle;" width="40%">
			<textarea id="remark" name="remark" class="InputStyle"  style="width: 90%;margin-left: 7px;" rows="3"></textarea>
	 		<SPAN id="remarkSpan"></SPAN>
		</td>
	</tr>
</table>
</FORM>
<%
if("view".equals(isShow)){
%>
<div id="zDialog_div_bottom" class="zDialog_div_bottom">
	<wea:layout type="2col">
    	<wea:group context="">
	    	<wea:item type="toolbar">
	    		<input type="button" value="<%=SystemEnv.getHtmlLabelName(309,user.getLanguage())%>" class="e8_btn_cancel" onclick="dialog.closeByHand();">
	    	</wea:item>
	   	</wea:group>
  	</wea:layout>
</div>
<%} %>
<script language=javascript>
function doSubmit() {
	var chenkFiled = "<%=chenkFiled %>";
	if(check_form(frmMain, chenkFiled)){
	 	frmMain.submit();
	}
}
//显示分数
$(".show_number li p").each(function(index, element) {
    var num = $(this).attr("tip");
    var www = num * 2 * 17;
    $(this).css("width",www);
});
</script>
</BODY>
</HTML>
