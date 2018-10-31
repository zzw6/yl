<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ page import="java.util.*" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>
<jsp:useBean id="SubCompanyComInfo" class="weaver.hrm.company.SubCompanyComInfo" scope="page" />
<jsp:useBean id="DepartmentComInfo" class="weaver.hrm.company.DepartmentComInfo" scope="page" />
<%	
String imagefilename = "/images/hdCRMAccount_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(2211,user.getLanguage())+"-"+SystemEnv.getHtmlLabelName(2112,user.getLanguage()) ;
int needchange=0;
String needfav ="1";
String needhelp ="";

if(!HrmUserVarify.checkUserRight("Meeting:EvalReport", user)) {
	response.sendRedirect("/notice/noright.jsp");
	return;
}

int	pagesize=10; 

String isClose = Util.null2String(request.getParameter("isClose"));

String userid = Util.null2String(request.getParameter("userid"));
String shareType = Util.null2String(request.getParameter("shareType"));
%>
<HTML>
<HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<link rel="stylesheet" href="/css/ecology8/request/requestTopMenu_wev8.css" type="text/css" />
<link rel="stylesheet" href="/wui/theme/ecology8/jquery/js/zDialog_e8_wev8.css" type="text/css" />
<script type="text/javascript">
var parentWin = parent.getParentWindow(window);
var dialog = parent.getDialog(window);
<%
if("1".equals(isClose)){
%>
	dialog.closeByHand();
	doSearch();
<%}%>
</script>
</HEAD>
<BODY Scroll=no>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(611,user.getLanguage())+",javascript:doAdd(),_self} " ;
RCMenuHeight += RCMenuHeightStep;

RCMenu += "{"+SystemEnv.getHtmlLabelName(32136,user.getLanguage())+",javascript:batchDelShare(),_self} " ;
RCMenuHeight += RCMenuHeightStep;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align:right; ">
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(611,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doAdd()"/>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(32136,user.getLanguage()) %>" class="e8_btn_top middle" onclick="batchDelShare()"/>
			<span id="advancedSearch" class="advancedSearch"><%=SystemEnv.getHtmlLabelName(21995, user.getLanguage())%></span>
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage()) %>" class="cornerMenu middle"></span>
		</td>
	</tr>
</table>
<div class="advancedSearchDiv" id="advancedSearchDiv"> 
<FORM action="MeetingAppraiseShare.jsp" name="searchfrm" id="searchfrm" method=post  >
	<wea:layout type="4col">
		<wea:group context="<%=SystemEnv.getHtmlLabelName(20331, user.getLanguage())%>" >
			<wea:item>权限范围</wea:item>
			<wea:item>
				<SELECT style="width:150px;" class="InputStyle" name="shareType" id="shareType" style="float:left">
				  <option value="" 	<%if("".equals(shareType)){ %> selected="selected" <%} %>>全部</option>
				  <option value="1" <%if("1".equals(shareType)){ %> selected="selected" <%} %>>集团总部</option>
				  <option value="2" <%if("2".equals(shareType)){ %> selected="selected" <%} %>>分部</option>
				</SELECT>
			</wea:item>
			
			<wea:item>报表查看人</wea:item>
			<wea:item>
				<brow:browser viewType="0" name="userid" browserValue="<%=userid %>" 
					browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/resource/ResourceBrowser.jsp" 
					hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='1'  width="300px"
					completeUrl="/data.jsp" linkUrl="javascript:openhrm($id$)" 
					browserSpanValue="<%=ResourceComInfo.getLastname(userid) %>"></brow:browser>
			</wea:item>
		</wea:group>
		<wea:group context="">
			<wea:item type="toolbar">
				<input type="button" onclick="doSearch()" class="e8_btn_submit" value="<%=SystemEnv.getHtmlLabelName(197,user.getLanguage())%>"/>
				<input type="button" value="<%=SystemEnv.getHtmlLabelName(2022,user.getLanguage())%>" class="e8_btn_cancel" onclick="resetCondtionAVS();"/>
				<input type="button" value="<%=SystemEnv.getHtmlLabelName(201,user.getLanguage())%>" class="e8_btn_cancel" id="cancel"/>
			</wea:item>
		</wea:group>
	</wea:layout>
</FORM>
</div>
<!-- 统计 -->
<div id="absentDiv" style="position:relative; margin:0px auto; padding:0px; height:520px; overflow: hidden;">
	<%

		String backFields = "id,userid,shareType,content";
		String sqlForm = " MeetingAppraiseShare ";
		String sqlWhere = " where 1 = 1 ";
		
		if(!"".equals(userid)){
			sqlWhere += " and userid = " + userid;
		}
		if(!"".equals(shareType)){
			sqlWhere += " and shareType = '"+ shareType +"' ";
		}
		
		String orderby = " userid,id ";
		
		String tableString =" <table instanceid=\"devicelist\" tabletype=\"checkbox\" pagesize=\""+pagesize+"\" >"+
			" <sql backfields=\""+backFields+"\" sqlform=\""+Util.toHtmlForSplitPage(sqlForm)+"\" sqlwhere=\""+Util.toHtmlForSplitPage(sqlWhere)+"\"   sqlprimarykey=\"id\" sqlorderby=\"" + orderby + "\" sqlsortway=\"desc\" sqlisdistinct=\"true\"/>"+
			"<head>"+
			"<col width=\"10%\"  text=\"报表查看人\" column=\"userid\"     orderkey=\"userid\" transmethod=\"com.weavernorth.util.MeetingReportService.getUserNameLink\"/>"+
		    "<col width=\"15%\"  text=\"权限类型\"  column=\"shareType\"  transmethod=\"com.weavernorth.util.MeetingReportService.getShareType\"/>"+
		    "<col width=\"60%\"  text=\"权限范围\"  column=\"shareType\"  otherpara=\"column:content\" transmethod=\"com.weavernorth.util.MeetingReportService.getShareContent\" />"+
			"</head>"+
			"<operates>"+
			"<operate href=\"javascript:doDel();\" isalwaysshow=\"true\" text=\""+SystemEnv.getHtmlLabelName(91,user.getLanguage())+"\" target=\"_self\" index=\"0\"/>"+
			"</operates>"+
			"</table>";
	%>
	<wea:SplitPageTag isShowTopInfo="false" tableString="<%=tableString%>" mode="run" />
</div>
</BODY>
</HTML>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<SCRIPT LANGUAGE="JavaScript">
function doAdd(){
	if(window.top.Dialog){
		diag_vote = new window.top.Dialog();
	} else {
		diag_vote = new Dialog();
	}
	diag_vote.currentWindow = window;
	diag_vote.Width = 730;
	diag_vote.Height = 350;
	diag_vote.Modal = true;
	diag_vote.Title = "会议信息统计权限配置";
	diag_vote.URL = "/meeting/Tickling/share/MeetingAppraiseShareTab.jsp?_fromURL=MeetingAppraiseShareAdd";
	diag_vote.show();
}

function doSearch() {
	jQuery("#searchfrm").submit();
}

function onBtnSearchClick(){
	doSearch();
}
function doDel(id){
   window.top.Dialog.confirm("删除后,数据将不能恢复,您确认要删除吗？",function(){
	  var ajax=ajaxinit();
	  ajax.open("POST", "/meeting/Tickling/share/MeetingAppraiseShareOperator.jsp", true);
	  ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	  ajax.send("operation=delete&id="+id);
	  ajax.onreadystatechange = function() {
		if (ajax.readyState == 4 && ajax.status == 200) {
			try{
			  window.top.Dialog.alert("删除成功！");
			  onBtnSearchClick();
			}catch(e){
				return false;
			}
		}
	 }
   });
}

function batchDelShare(){
	var ids = _xtable_CheckedCheckboxId();
	if(!ids){
		window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(32568,user.getLanguage())%>");
		return;
	}
    window.top.Dialog.confirm("删除后,数据将不能恢复,您确认要删除吗？",function(){
	  var ajax=ajaxinit();
	  ajax.open("POST", "/meeting/Tickling/share/MeetingAppraiseShareOperator.jsp", true);
	  ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	  ajax.send("operation=batchDel&ids="+ids);
	  ajax.onreadystatechange = function() {
		 if (ajax.readyState == 4 && ajax.status == 200) {
			 try{
			   window.top.Dialog.alert("删除成功！");
			   onBtnSearchClick();
			}catch(e){
				return false;
			}
		 }
	  }
    });
}
</SCRIPT>