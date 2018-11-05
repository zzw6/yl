<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/page/maint/common/initNoCache.jsp" %>
<%@ page import="weaver.general.*"%>
<%@ page import="weaver.conn.RecordSet" %>
<%
    //api jsp 提供数据返回

    String src=Util.null2String(request.getParameter("src"));
    String id=Util.null2String(request.getParameter("id"));
    RecordSet rs=new RecordSet();
    String datas="";
    //根据上级任务带出描述
    if("getTaskRemark".equals(src)){

        rs.executeQuery("select remark from TM_TaskInfo where id=?",id);
        if(rs.next()){
            datas=Util.null2String(rs.getString(1)).trim();
        }
    }

    out.print(datas);


%>