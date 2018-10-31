<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="pack" class="weaver.general.ParameterPackage" scope="page"/>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<HTML><HEAD>
<script src="/js/tabs/jquery.tabs.extend_wev8.js"></script>
<link type="text/css" href="/js/tabs/css/e8tabs1_wev8.css" rel="stylesheet" />
<link rel="stylesheet" href="/css/ecology8/request/searchInput_wev8.css" type="text/css" />
<script type="text/javascript" src="/js/ecology8/request/searchInput_wev8.js"></script>

<%
String url = "";
String _fromURL = Util.null2String(request.getParameter("_fromURL"));
String meetingid = Util.null2String(request.getParameter("meetingid"));
String isShow = Util.null2String(request.getParameter("isShow"));
String mouldID = "";
String title = "";
if("MeetingEvaluate".equals(_fromURL)){
	mouldID = MouldIDConst.getID("meeting");
	title = "会议效果评估";
	int mqeId = 0;
	RecordSet.executeSql("select id from MQEvaluate where meetingid = " + meetingid + " and userid = " + user.getUID());
	if(RecordSet.next()){
		mqeId = Util.getIntValue(RecordSet.getString("id"), 0);
	}
	if(mqeId > 0){
		url = "/meeting/Que/MeetingEvaluateView.jsp?meetingid="+meetingid+"&mqId="+mqeId+"&isShow="+isShow;
	}else{
		url = "/meeting/Que/MeetingEvaluate.jsp";
	}
}else if("MeetingEvaluateView".equals(_fromURL)){
	mouldID = MouldIDConst.getID("meeting");
	title = "会议效果评估";
	url = "/meeting/Que/MeetingEvaluateView.jsp";
}else if("MeetingEvaluateManager".equals(_fromURL)){
	mouldID = MouldIDConst.getID("meeting");
	title = "会议效果评估综合得分";
	url = "/meeting/Que/MeetingEvaluateManager.jsp";
}else if("MeetingInfoReport".equals(_fromURL)){
	mouldID = MouldIDConst.getID("meeting");
	title = "会议信息统计表";
	url = "/meeting/Que/MeetingInfoReport.jsp";
}else if("MeetingStayAppraise".equals(_fromURL)){
	mouldID = MouldIDConst.getID("meeting");
	title = "待评估的会议";
	url = "/meeting/Que/MeetingStayAppraise.jsp";
}
%>

<link rel="stylesheet" href="/css/ecology8/request/seachBody_wev8.css" type="text/css" />
<link rel="stylesheet" href="/css/ecology8/request/hoverBtn_wev8.css" type="text/css" />
<script type="text/javascript" src="/js/ecology8/request/hoverBtn_wev8.js"></script>
<script type="text/javascript" src="/js/ecology8/request/titleCommon_wev8.js"></script>
<script type="text/javascript">
$(function(){
    $('.e8_box').Tabs({
        getLine:1,
        iframe:"tabcontentframe",
         mouldID:"<%=mouldID %>",
        staticOnLoad:true,
        objName:"<%=title %>"
    });
});
</script>
<%
if(request.getQueryString() != null){
	if(url.contains("?")){
		url += "&"+request.getQueryString();
	}else{
		url += "?"+request.getQueryString();
	}
}
%>
</head>
<BODY scroll="no">
	<div class="e8_box demo2">
		<div class="e8_boxhead">
			<div class="div_e8_xtree" id="div_e8_xtree"></div>
			<div class="e8_tablogo" id="e8_tablogo"></div>
			<div class="e8_ultab">
				<div class="e8_navtab" id="e8_navtab">
					<span id="objName"></span>
				</div>
				<div>
					<ul class="tab_menu">
						<li class="defaultTab">
							<a href="#" target="tabcontentframe">
								<%=TimeUtil.getCurrentTimeString() %>
							</a>
						</li>
					</ul>
					<div id="rightBox" class="e8_rightBox">
					</div>
				</div>
			</div>
		</div>
	    <div class="tab_box">
	        <div>
	            <iframe src="<%=url %>" id="tabcontentframe" name="tabcontentframe" class="flowFrame" frameborder="0" height="100%" width="100%;" onload="update()"></iframe>
	        </div>
	    </div>
	</div>     
</body>
</html>

