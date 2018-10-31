<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="weaver.general.Util" %>
<%@page import="weaver.file.FileUpload"%>
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page"/>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page"/>
<%
response.setHeader("cache-control", "no-cache");
response.setHeader("pragma", "no-cache");
response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
User user = HrmUserVarify.getUser (request , response) ;
if(user == null)  return ;
FileUpload fu = new FileUpload(request);
String id = Util.null2String(fu.getParameter("id"));
String message = "";
rs.executeSql("select * from meeting_Remark where id = " + id);
if(rs.next()){
	message = Util.null2String(rs.getString("msg"));
}
%>
<HTML>
<HEAD>
    <style>
        h1{
            text-align: center;
            margin-top: 400px;
        }

    </style>
</HEAD>
<body>
<h1><%=message %></h1>
</body>

</HTML>