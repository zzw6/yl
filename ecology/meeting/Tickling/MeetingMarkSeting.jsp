<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.email.EmailEncoder" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<HTML><HEAD>
<%
String imagefilename = "/images/hdHRMCard_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(357,user.getLanguage());
String needfav ="1";
String needhelp ="";
String type = Util.null2String(request.getParameter("type"));
String queId = Util.null2String(request.getParameter("queId"));
String isClose = Util.null2String(request.getParameter("isClose"));

if(!HrmUserVarify.checkUserRight("Meeting:EvalReport", user)) {
	response.sendRedirect("/notice/noright.jsp");
	return;
}

String mark = "";
RecordSet.executeSql("select s_mark,f_mark from MeetingQueSeting where id = " + queId);
if(RecordSet.next()){
	String s_mark = Util.null2String(RecordSet.getString("s_mark"));
	String f_mark = Util.null2String(RecordSet.getString("f_mark"));
	
	if("0".equals(type)){
		mark = f_mark;
	}else{
		mark = s_mark;
	}
}
%>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>

<SCRIPT language="javascript"  defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript"  src="/js/selectDateTime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src='/js/JSDateTime/WdatePicker_wev8.js?rnd="+Math.random()+"'></script>

<script type="text/javascript">
var parentWin = parent.parent.getParentWindow(parent);
var dialog = parent.parent.getDialog(parent);
if("<%=isClose%>"=="1"){
	parentWin.doSearch();
	dialog.closeByHand();	
}
</script>
</head>
<BODY>

<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(86,user.getLanguage())+",javascript:doSubmit();,_self} " ;
RCMenuHeight += RCMenuHeightStep ;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align:right;">
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(86,user.getLanguage())%>" class="e8_btn_top" onclick="doSubmit();">
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage())%>" class="cornerMenu"></span>
		</td>
	</tr>
</table>
<FORM id=frmMain name=frmMain action="MeetingMarkSetingOperator.jsp" method=post >
<input type="hidden" name=type id=type value=<%=type %>>
<input type="hidden" name=queId id=queId value=<%=queId %>>
<wea:layout type="2col">
	<wea:group context='<%=SystemEnv.getHtmlLabelName(1361,user.getLanguage()) %>'>
	
		<wea:item>分数</wea:item>
		<wea:item>
			<INPUT class=inputstyle type=text name="mark" id="mark" value="<%=mark %>" onchange='checkinput("mark","markSpan")'>
		</wea:item>
		
	</wea:group>
</wea:layout>  
</FORM>

<div id="zDialog_div_bottom" class="zDialog_div_bottom">
	<wea:layout type="2col">
		<wea:group context="">
			<wea:item type="toolbar">
				<input type="button" value="<%=SystemEnv.getHtmlLabelName(309, user.getLanguage())%>" id="zd_btn_cancle" class="zd_btn_cancle" onclick="dialog.closeByHand();">
			</wea:item>
		</wea:group>
	</wea:layout>
</div>

<script language=javascript>
function doSubmit() {
	if(check_form(frmMain,'mark,type,meetingQueId')){
	 	frmMain.submit();
	}
}
</script>
</BODY>
</HTML>
