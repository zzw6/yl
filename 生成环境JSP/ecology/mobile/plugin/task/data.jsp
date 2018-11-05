<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.*"%>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.file.FileUpload" %>
<%
    //api jsp 提供数据返回
    FileUpload fu = new FileUpload(request);
    String src=Util.null2String(fu.getParameter("src"));
    String id=Util.null2String(fu.getParameter("id"));
    RecordSet rszz=new RecordSet();
    String datas="";
    //根据上级任务带出描述
    new weaver.general.BaseBean().writeLog("src"+src);
    new weaver.general.BaseBean().writeLog("id"+id);
     if("getTaskRemark".equals(src)){
         rszz.executeSql("select remark from TM_TaskInfo where id=?",id);
         if(rszz.next()){
            datas=Util.null2String(rszz.getString(1)).trim();
        }
    }

    out.println(datas);


%>