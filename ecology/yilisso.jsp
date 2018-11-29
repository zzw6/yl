<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.Util" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>


<%
    int code =Util.getIntValue(Util.null2String(request.getParameter("code")));
    if(code==0){
        session.setAttribute("yilissoTK1129",System.currentTimeMillis());
    }else{
        new weaver.general.BaseBean().writeLog("-----code---"+code);
    }

%>

