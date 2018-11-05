<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.general.TimeUtil" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="java.util.*" %>
<%@ page import="weaver.hrm.*" %>
<jsp:useBean id="TimeUtils" class="com.weavernorth.util.TimeUtils" scope="page" />
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<%
User user = HrmUserVarify.getUser (request , response) ;

if(user == null){
	response.sendRedirect("/login/Login.jsp");
}

if(!HrmUserVarify.checkUserRight("Meeting:EvalReport", user)) {
	response.sendRedirect("/notice/noright.jsp");
	return;
}

String operation = Util.fromScreen(request.getParameter("operation"),user.getLanguage());
String type = Util.fromScreen(request.getParameter("type"),user.getLanguage());
String queId = Util.fromScreen(request.getParameter("queId"),user.getLanguage());
String mark = Util.fromScreen(request.getParameter("mark"),user.getLanguage());

StringBuffer updateSql = new StringBuffer();
updateSql.append("update MeetingQueSeting ");
if("1".equals(type)){
	updateSql.append("set s_mark = " + mark);
}else{
	updateSql.append("set f_mark = " + mark);
}
updateSql.append(" where id = " + queId);
RecordSet.executeSql(updateSql.toString());

response.sendRedirect("/meeting/Tickling/MeetingMarkSeting.jsp?isClose=1&queId="+queId);
%>
