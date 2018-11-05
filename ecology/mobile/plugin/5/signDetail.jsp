<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/page/maint/common/initNoCache.jsp"%>
<%@ page import="weaver.file.FileUpload"%>
<%@ page import="weaver.general.TimeUtil"%>
<%@ page import="weaver.meeting.MeetingShareUtil"%>
<%@ page import="weaver.conn.RecordSet"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="weaver.general.BaseBean"%>
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
	<script type='text/javascript' src='/mobile/plugin/5/js/meeting.js?v=2017121810'></script>
	<script src="/mobile/plugin/5/js/jquery-weui.js"></script>
	<link rel="stylesheet" href="/mobile/plugin/5/css/weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/jquery-weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/icon.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/meeting.css?v=2018020801" />
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
		
		String id = Util.null2String(fu.getParameter("id"));
		if("".equals(id)){
			return;
		}
		String currentDate = TimeUtil.getCurrentDateString();
		String sql = getSql(user,currentDate,id);
		//System.out.println(sql);
		BaseBean bb = new BaseBean();
		bb.writeLog("签到详情页的SQL===========\n"+sql);
		rs.executeSql(sql);
		if(rs.getCounts()==0){
			out.print("您没有可参加的会议");
			return;
		}
		rs.next();
		String name = Util.null2String(rs.getString("name"));
		String roomname = Util.null2String(rs.getString("roomname"));//会议室名称
		String customizeAddress = rs.getString("customizeAddress");//自定义会议室地点
		if("".equals(roomname)){
			roomname = customizeAddress;
		}
		String begindate = rs.getString("begindate");
		String begintime = rs.getString("begintime");
		String enddate = rs.getString("enddate");
		String endtime = rs.getString("endtime");
		
		int signCount = 0;
		rs.executeSql("select count(1) from uf_meetingSignIn where meetingid = "+id+" and signindate = '"+currentDate+"'");
		if(rs.next()){
			signCount = Util.getIntValue(rs.getString(1),0);
		}
		String signdate = "",signtime = "",remark = "";
		rs.executeSql("select * from uf_meetingSignIn where meetingid = "+id+" and members="+user.getUID()+" and signindate = '"+currentDate+"'");
		if(rs.next()){
			signdate = Util.null2String(rs.getString("signindate"));
			signtime = Util.null2String(rs.getString("signintime"));
			remark = Util.null2String(rs.getString("remark"));
		}
	%>
<body>
	<div id="container">
		<div class="mt-detail-content" id="mt-signdetail-div">
			<div class="mt-sign-title"><%=name %></div>
			<div class="mt-sign-address">
				<font color="#999">会议地点:</font>
				<font color="#007afd"><%=roomname %></font>
			</div>
			<div class="mt-sign-bg"></div>
			<div class="mt-sign-detail">
				<div class="mt-sign-count-div">
					<div class="mt-sign-count" onclick="showSignDetail()"><%=signCount %></div>
					<div class="mt-sign-text">签到人数</div>
				</div>
				<div class="mt-sign-time-div">
					<div class="mt-sign-image">
						<i class="icon icon-51"></i>
					</div>
					<div class="mt-sign-time-text">会议开始时间</div>
					<div class="mt-sign-time"><%=begindate %>&nbsp;<%=begintime %></div>
				</div>
				<div class="mt-sign-time-div">
					<div class="mt-sign-image">
						<i class="icon icon-51"></i>
					</div>
					<div class="mt-sign-time-text" style="border-top:1px solid #ddd;margin-left:110px;">会议结束时间</div>
					<div class="mt-sign-time"><%=enddate %>&nbsp;<%=endtime %></div>
				</div>
				<div class="mt-signed-image" <%if("".equals(signdate)){ %>style="display:none;"<%} %>>
					<img src="/mobile/plugin/5/images/qd.jpg"/>
				</div>
			</div>
			<%if(!"".equals(signdate)){ %>
			<div class="line-height"></div>
			<div class="mt-signed-detail">
				<i class="icon icon-67"></i><font color="#999">签到时间&nbsp;&nbsp;:&nbsp;&nbsp;</font><%=signdate %>&nbsp;<%=signtime %>
			</div>
			<%}else{ %>
			<div id="mt-sign-action-div">
				<div class="mt-sign-btn2" onclick="signMeeting()"></div>
			</div>
			<%} %>
		</div>
	</div>
	<script>
		var param = "<%=param%>";
		var meetingid = "<%=id%>";
		var signCount = "<%=signCount%>";
		function signMeeting(){
			$.confirm("确定进行会议签到?",function(){
				$.showLoading();
				$.ajax({
					type:"post",
					url:"/mobile/plugin/5/meetingOperation.jsp",
					data:{"meetingid":meetingid,"operation":"signMeeting"},
					dataType:"json",
					success:function(data){
						$.hideLoading();
						if(data.status==0){
							$.alert("温馨提示：为保证会议质量，请将手机调成静音或震动，全程注意会议纪律，谢谢合作！");
							$(".mt-sign-count").html(parseInt(signCount)+1);
							$("#mt-sign-action-div").html('<div class="line-height"></div>'+
									'<div class="mt-signed-detail">'+
									'<i class="icon icon-67"></i>'+
									'<font color="#999">签到时间&nbsp;&nbsp;:&nbsp;&nbsp;</font>'+
									data.signindate+'&nbsp;'+data.signintime+
									'</div>');
							$(".mt-signed-image").show();
						}else{
							$.alert(data.msg);
						}
					},
					error:function(){
						$.hideLoading();
					}
				});
			});
		}
		function showSignDetail(){
			window.location = "/mobile/plugin/5/detail.jsp?id="+meetingid+"&operation=showSign&"+param;
		}
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
private String getSql(User user,String beginDate,String id){
	StringBuffer sb = new StringBuffer();
	sb.append(" select t1.*,t3.name as roomname");
	//
	sb.append(" from Meeting t1 ,MeetingRoom t3  where  ','||t1.address||','  like '%,'||to_char(t3.id)||',%'");
	sb.append(" and  t1.repeatType = 0 and t1.meetingstatus = 2 and ");
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
	sb.append(" and t1.id ="+id);
	//System.out.println(sb.toString());
	return sb.toString();
}
%>