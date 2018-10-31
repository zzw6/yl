<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="weaver.general.TimeUtil" %>
<%@ page import="weaver.email.MailSend" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="TimeUtils" class="com.weavernorth.util.TimeUtils" scope="page" />
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="MeetingUtilForYl" class="weaver.meeting.MeetingUtilForYl" scope="page" />

<%
User user = HrmUserVarify.getUser (request , response) ;
if(user == null){
	response.sendRedirect("/login/Login.jsp");
}
String operation = Util.null2String(request.getParameter("operation"));
String isShow = Util.null2String(request.getParameter("isShow"));
int meetingid = Util.getIntValue(request.getParameter("meetingid"), 0);
String[] mqIds = request.getParameterValues("mqId");
String remark = Util.fromScreen(request.getParameter("remark"),user.getLanguage());
if("add".equals(operation)){
	if(null != mqIds){
		rs.executeSql("select * from MQEvaluate where meetingid = "+ meetingid +" and userid = " + user.getUID());
		if(rs.getCounts() == 0){
			int mqeid = 0;
			RecordSet.executeProc("MQEvaluate_Get", "");
			if (RecordSet.next()) {
				mqeid = Util.getIntValue(RecordSet.getString(1), 0);
			}
			StringBuffer sqlStr = new StringBuffer();
			sqlStr.append("insert into MQEvaluate ");
			sqlStr.append("(id,meetingid,remark,userid,createDate,createTime)");
			sqlStr.append("values ("+ mqeid +","+ meetingid +",'"+ remark +"' ");
			sqlStr.append(","+ user.getUID() +", '"+ TimeUtil.getCurrentDateString() +"'");
			sqlStr.append(",'"+ TimeUtil.getOnlyCurrentTimeString() +"' )");
			boolean isSuccess = RecordSet.executeSql(sqlStr.toString());
			
			if(isSuccess){
				for(int i = 0; i < mqIds.length; i++){
					int mqId = Util.getIntValue(mqIds[i], 0);
					int meetingScore = Util.getIntValue(request.getParameter("h_meetingScore_" + mqId), 0);
					StringBuffer scoreSql = new StringBuffer();
					scoreSql.append("insert into MQEvaluateDet (meetingid,mqsid,mqeid,mqScore)");
					scoreSql.append(" values ( " + meetingid);
					scoreSql.append("," + mqId + ",");
					scoreSql.append(mqeid + ",");
					scoreSql.append(meetingScore + ")");
					RecordSet.executeSql(scoreSql.toString());
				}
				String isAppraise = "";
				String meetingName = "";
				String creater = "";
				String caller = "";
				RecordSet.executeSql("select isAppraise,name,creater,caller from meeting where id = " + meetingid);
				if(RecordSet.next()){
					isAppraise = Util.null2String(RecordSet.getString("isAppraise"));
				 	meetingName = Util.null2String(RecordSet.getString("name"));
				 	creater = Util.null2String(RecordSet.getString("creater"));
				 	caller = Util.null2String(RecordSet.getString("caller"));
				}
				if("3".equals(isAppraise)){
					int mqeCount = 0;
					RecordSet.executeSql("select count(*) as mqeCount from MQEvaluate where meetingid = " + meetingid);
					if(RecordSet.next()){
						mqeCount = Util.getIntValue(RecordSet.getString("mqeCount"), 0);
					}
					int meetCount = 0;
					RecordSet.executeSql("select count(*) as meetCount from meeting_member2 where meetingid = " + meetingid);
					if(RecordSet.next()){
						meetCount = Util.getIntValue(RecordSet.getString("meetCount"), 0);
					}
					if(meetCount == mqeCount){
						String meetingNotice = TimeUtils.replaceRepStr(creater + "," + caller);
						String description = "您的XXX会议的评估结果已出具，请您点击查阅";
						String mailTitle = description.replaceAll("XXX", meetingName);
						String mailContent = "以下是提醒内容，请点击查看详情：<br>";
						mailContent += "<a style=\"color:red\" target=\"_blank\" href=\"/mobile/plugin/5/appraiseJump.jsp?id=" + meetingid + "\">" + mailTitle + "</a><br>";
						MailSend send = new MailSend();
						boolean bool = send.sendSysInternalMail("1", meetingNotice, null, mailTitle, mailContent);
						if(bool){
							rs.executeSql("update meeting set istick = '1' where id = " + meetingid);
						}
					}
				}
			}
		}
		if("view".equals(isShow)){
			response.sendRedirect("/meeting/Que/MeetingEvaluate.jsp?isClose=1");
		}else{
			int mqeId = 0;
			RecordSet.executeSql("select id from MQEvaluate where meetingid = " + meetingid + " and userid = " + user.getUID());
			if(RecordSet.next()){
				mqeId = Util.getIntValue(RecordSet.getString("id"), 0);
			}
			response.sendRedirect("/meeting/Que/MeetingEvaluateView.jsp?meetingid="+meetingid+"&mqId="+mqeId);
		}
	}
}
%>
