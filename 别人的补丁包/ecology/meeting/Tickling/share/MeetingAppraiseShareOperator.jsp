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
String userid = Util.fromScreen(request.getParameter("userid"),user.getLanguage());
String shareType = Util.fromScreen(request.getParameter("shareType"),user.getLanguage());
String subids = Util.fromScreen(request.getParameter("subids"),user.getLanguage());
String departmentid = Util.fromScreen(request.getParameter("departmentid"),user.getLanguage());

if(operation.equals("addShare")){
	String orgId = "";
	if("1".equals(shareType)){
		orgId = "0";
	} else if("2".equals(shareType)){
		orgId = subids;
	} else if("3".equals(shareType)){
		orgId = departmentid;
	}
	
	String t_orgId = TimeUtils.replaceStr(orgId);
	
	StringBuffer InSql = new StringBuffer();
	InSql.append("insert into MeetingAppraiseShare ");
	InSql.append("(userid,shareType,content)");
	InSql.append(" values (");
	InSql.append(userid + ",");
	InSql.append("'"+ shareType +"',");
	InSql.append("'"+ t_orgId +"')");
	RecordSet.executeSql(InSql.toString());
 	response.sendRedirect("/meeting/Tickling/share/MeetingAppraiseShareAdd.jsp?isclose=1");
}else if(operation.equals("delete")){
	
	String id = Util.fromScreen(request.getParameter("id"),user.getLanguage());
	
	RecordSet.executeSql("delete from MeetingAppraiseShare where id = " + id);
	
	response.sendRedirect("/meeting/Tickling/share/MeetingAppraiseShare.jsp");
}else if(operation.equals("batchDel")){
	
	String ids = Util.fromScreen(request.getParameter("ids"),user.getLanguage());
	
	RecordSet.executeSql("delete from MeetingAppraiseShare where id in ("+ TimeUtils.replaceStr(ids) +")");
	
	response.sendRedirect("/meeting/Tickling/share/MeetingAppraiseShare.jsp");
}
%>
