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
String isShow = Util.null2String(request.getParameter("isShow"));
int meetingid = Util.getIntValue(request.getParameter("meetingid"), 0);
int mqId = Util.getIntValue(request.getParameter("mqId"), 0);
String remark1 = "";
RecordSet.executeSql("select remark from MQEvaluate where id = " + mqId);
if(RecordSet.next()){
	remark1 = Util.null2String(RecordSet.getString("remark"));
}
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
.content{ width:90%; margin:0 auto; padding-top:5px;}
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
</script>
</head>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align:right;">
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage())%>" class="cornerMenu"></span>
		</td>
	</tr>
</table>
<div style="text-align: left;margin: 5px;">
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议主持人：<%=MeetingTransMethod.getMeetingResource(caller) %>
	</div>
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议组织部门：<%=DepartmentComInfo.getDepartmentname(ResourceComInfo.getDepartmentID(creater))  %>
	</div>
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议名称：<%=meetingname %>
	</div>
	<div style="font-size:14px;font-family:微软雅黑, sans-serif;margin-left: 8px;margin-top: 8px;">
	会议开始时间：<%=begindate %>  —  <%=enddate %>
	</div>
</div> 
<table style="margin: 0 auto;" width="98%" class="border-table">
	<tr height="40" style="">
		<td colspan="3" style="text-align: center;vertical-align: middle;border: none;">
			<span style="font-size: 16px;color: black;font-family: 微软雅黑;font-weight: 700;">会议效果评估表</span>
		</td>
	</tr>
	<tr height="40">
		<td style="background: #8db4e3;text-align: center;vertical-align: middle" width="10%">
			<span style="font-size: 14px;color: white;font-family: 微软雅黑;font-weight: 700;">序号</span>
		</td>
		<td style="background: #8db4e3;text-align: center;vertical-align: middle" width="40%">
			<span style="font-size: 14px;color: white;font-family: 微软雅黑;font-weight: 700;">评价问题</span>
		</td>
		<td style="background: #8db4e3; text-align: center;vertical-align: middle" width="10%">
			<span style="font-size: 14px;color: white;font-family: 微软雅黑;font-weight: 700;">评分</span>
		</td>
	</tr>
	<%
	int count = 1;
	RecordSet.executeSql("select id,remark from uf_MQSeting order by showorder " );
	while(RecordSet.next()){
		String id = Util.null2String(RecordSet.getString("id"));
		String remark = Util.null2String(RecordSet.getString("remark"));
		int mqScore = 0;
		StringBuffer sqlStr = new StringBuffer();
		sqlStr.append("select mqScore from MQEvaluateDet");
		sqlStr.append(" where meetingid = " + meetingid);
		sqlStr.append(" and mqsid = " + id);
		sqlStr.append(" and mqeid = " + mqId);
		rs.executeSql(sqlStr.toString());
		if(rs.next()){
			mqScore = Util.getIntValue(rs.getString("mqScore"));
		}
	%>
	<tr height="40">
		<td style="text-align: center;vertical-align: middle" >
			<span style="font-size: 12px;font-family: 微软雅黑;"><%=count %></span>
		</td>
		<td style=" text-align: left;vertical-align: middle">
			<span style="font-size: 12px;font-family: 微软雅黑;"><%=remark %></span>
		</td>
		<td style="text-align: center;vertical-align: middle">
	       	<div style="float: left;width:40%;text-align: center;margin-bottom: -10px;margin-left: 5px;margin-top: 8px;">
			  	<ul class="show_number">
			       <li>
				        <div class="atar_Show">
				          	<p tip="<%=mqScore %>"></p>
				        </div>
			       </li>
			  	</ul>
	       	</div>
	       	<div style="float: left;width:30%;margin-bottom: -10px;margin-top: 18px;margin-left: -60px;">
		 	    您的评分：<%=mqScore %> 分
		  	</div>
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
		<td style="vertical-align: middle" width="40%">
	 		<SPAN id="remarkSpan" style="margin-left: 7px;"><%=remark1 %></SPAN>
		</td>
	</tr>
</table>
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
$(".show_number li p").each(function(index, element) {
    var num = $(this).attr("tip");
    var www = num * 2 * 17;
    $(this).css("width",www);
});
</script>
</BODY>
</HTML>
