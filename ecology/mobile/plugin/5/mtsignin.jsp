<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/page/maint/common/initNoCache.jsp"%>
<%@ page import="weaver.file.FileUpload"%>
<%@ page import="weaver.general.TimeUtil"%>
<%@ page import="weaver.general.BaseBean"%>
<%@ page import="weaver.meeting.MeetingShareUtil"%>
<%@ page import="weaver.conn.RecordSet"%>
<%@ page import="java.text.SimpleDateFormat"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page"/>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta http-equiv="Cache-Control" content="no-cache,must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<meta name="viewport" content="width=device-width,minimum-scale=1.0, maximum-scale=1.0" />
	<script src='/mobile/plugin/5/js/jquery.js'></script>
	<script type='text/javascript' src='/mobile/plugin/5/js/meeting.js'></script>
	<script src="/mobile/plugin/5/js/jquery-weui.js"></script>
	<link rel="stylesheet" href="/mobile/plugin/5/css/weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/jquery-weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/icon.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/meeting.css?v=2017111501" />
	<title>会议签到</title>
</head>
<% 
		response.setHeader("Cache-Control", "no-store");
		response.setHeader("Pragrma", "no-cache");
		response.setDateHeader("Expires", 0);
		FileUpload fu = new FileUpload(request);
		String clienttype = Util.null2String(fu.getParameter("clienttype"));
		String clientlevel = Util.null2String(fu.getParameter("clientlevel"));
		String module = Util.null2String(fu.getParameter("module"));
		String scope = Util.null2String(fu.getParameter("scope"));
		String param = "clienttype=" + clienttype + "&clientlevel="+ clientlevel + "&module=" + module + "&scope=" + scope;
		String addressId = Util.null2String(fu.getParameter("addressId"));
		String addressName = Util.null2String(fu.getParameter("addressName"));
		String currentDate = TimeUtil.getCurrentDateString();
		StringBuffer sb = new StringBuffer();
		sb.append(getSql(user,currentDate));
		if(!"".equals(addressId)){
			sb.append(" and ','||address||','  like '%,"+addressId+",%'");
		}else if(!"".equals(addressName)){
			sb.append(" and customizeAddress = '"+addressName+"'");
		}
		sb.append(" order by t1.beginDate,t1.begintime,t1.id");
%>
<body>
	<div id="container">
	<div class="mt-detail-content" id="mt-change-div">
		<%
			BaseBean bb = new BaseBean();
			bb.writeLog("签到的SQL===========\n"+sb.toString());
			rs.executeSql(sb.toString());
			//System.out.println(sb.toString());
			int count = rs.getCounts();
			if(count==0){
		%>
		<div style="background:#f0f0f0;overflow:hidden;">
		   <div class="weui-loadmore weui-loadmore_line">
		   	<span class="weui-loadmore__tips" style="background:#f0f0f0;">您没有可参加的会议</span>
		   </div>
		</div>
		<%}else if(count==1){%>
		<div style="background:#f0f0f0;overflow:hidden;">
			<div class="weui-loadmore">
				<i class="weui-loading"></i>
				<span class="weui-loadmore__tips" style="background:#f0f0f0;">正在加载中...</span>
			</div>
		</div>
		<%
			if(rs.next()){
				String id = Util.null2String(rs.getString("id"));
		%>	
		<script>
			location = "/mobile/plugin/5/signDetail.jsp?id=<%=id%>&<%=param%>";
		</script>			
		<%return;}
		}else{
			while(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				String name = Util.null2String(rs.getString("name"));
				String begindate = Util.null2String(rs.getString("begindate"));
				String begintime = Util.null2String(rs.getString("begintime"));
				String roomname = Util.null2String(rs.getString("roomname"));
				String customizeAddress = Util.null2String(rs.getString("customizeAddress"));
				if("".equals(roomname)){
					roomname = customizeAddress;
				}
		%>
		<a class="weui-cell weui-cell_access" href="/mobile/plugin/5/signDetail.jsp?id=<%=id%>&<%=param%>">
			<div class="weui-cell__bd">
				<p><%=name %></p>
				<p class="mt-address"><%=roomname %></p>
			</div>
			<div class="weui-cell__ft"><%=begindate %> <%=begintime %></div>
		</a>
		<%}} %>
	</div>
	</div>
	<script>
		var param = "<%=param%>";
		function getRequestTitle(){
			return "会议签到";
		}
		function doLeftButton(){
			window.location = "/mobile/plugin/5/meeting.jsp?"+param;
			return "1";
		}
	</script>
</body>
</html>	
<%!
private String getSql(User user,String beginDate){
	StringBuffer sb = new StringBuffer();
	sb.append(" select t1.*,t3.name as roomname");
	sb.append(" from Meeting t1 left join MeetingRoom t3 on t1.address = t3.id");
	sb.append(" where t1.repeatType = 0 and t1.meetingstatus = 2 and ");
	sb.append(" (caller="+user.getUID()+" or recorder = "+user.getUID());
	sb.append(" or exists (select 1 from Meeting_Member2 m where m.meetingid = t1.id and m.memberid = "+user.getUID()+")");
	sb.append(")");
	sb.append(" and (t1.beginDate <= '"+beginDate+"' and t1.endDate >= '"+beginDate+"')");
	
	RecordSet rs = new RecordSet();
	int qdsj = 20;//允许提前多少分钟签到
	rs.executeSql("select * from uf_hyqd");
	if(rs.next()){
		qdsj = Util.getIntValue(rs.getString("qdsj"),20);
	}
	long nowTime = System.currentTimeMillis();
	long timeLimit = nowTime+qdsj*60*1000;//当前系统时间+qdsj
	SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
	String compareTime = sdf.format(timeLimit);
	String nowTime2 = sdf.format(nowTime);
	sb.append(" and t1.begintime <='"+compareTime+"'");
	sb.append(" and t1.endtime >='"+nowTime2+"'");
	sb.append(" and (t1.cancel <> 1 or t1.cancel is null)");
	//System.out.println(sb.toString());
	return sb.toString();
}
%>