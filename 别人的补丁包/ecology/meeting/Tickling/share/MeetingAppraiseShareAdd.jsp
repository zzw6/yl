<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page" />
<jsp:useBean id="SubCompanyComInfo" class="weaver.hrm.company.SubCompanyComInfo" scope="page" />
<jsp:useBean id="CheckSubCompanyRight" class="weaver.systeminfo.systemright.CheckSubCompanyRight" scope="page" />
<%
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(780, user.getLanguage());
String needfav = "1";
String needhelp = "";

if(!HrmUserVarify.checkUserRight("Meeting:EvalReport", user)) {
	response.sendRedirect("/notice/noright.jsp");
	return;
}

String dialog = Util.null2String(request.getParameter("dialog"));
String isclose = Util.null2String(request.getParameter("isclose"));
%>
<html>
<head>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<link rel="stylesheet" href="/css/ecology8/request/requestTopMenu_wev8.css" type="text/css" />
<link rel="stylesheet" href="/wui/theme/ecology8/jquery/js/zDialog_e8_wev8.css" type="text/css" />
<LINK href="/wui/theme/ecology8/jquery/js/e8_zDialog_btn_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/checkinput_wev8.js"></script>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>

<script type="text/javascript">

var parentWin = parent.parent.getParentWindow(parent);
var dialog = parent.parent.getDialog(parent);
if("<%=isclose%>"=="1"){
	parentWin.onBtnSearchClick();
	dialog.closeByHand();	
}

</script>
</head>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{" + SystemEnv.getHtmlLabelName(86, user.getLanguage()) + ",javascript:saveData(),_self} ";
RCMenuHeight += RCMenuHeightStep;

RCMenu += "{" + SystemEnv.getHtmlLabelName(309, user.getLanguage()) + ",javascript:btn_cancle(),_self} ";
RCMenuHeight += RCMenuHeightStep;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
<tr>
   <td>
	</td>
	<td class="rightSearchSpan" style="text-align:right; ">
		<input type="button" value="<%=SystemEnv.getHtmlLabelName(86, user.getLanguage())%>" class="e8_btn_top middle" onclick="saveData()">
		<span title="<%=SystemEnv.getHtmlLabelName(2104,user.getLanguage()) %>" class="cornerMenu middle"></span>
	</td>
</tr>
</table>
<FORM id=weaverA name=weaverA action="MeetingAppraiseShareOperator.jsp" method="post">
<input type="hidden" name="operation" id="operation" value="addShare" />
<input type="hidden" value="<%=dialog%>" name="dialog" id="dialog" />

<wea:layout type="2col">
	<wea:group context='<%=SystemEnv.getHtmlLabelName(1361, user.getLanguage())%>' >
		<!-- 对象 -->
		
		<wea:item>报表查看人</wea:item>
		<wea:item>
			<brow:browser viewType="0" name="userid" browserValue="" 
				browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/resource/ResourceBrowser.jsp" 
				hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='2'  width="300px"
				completeUrl="/data.jsp" linkUrl="javascript:openhrm($id$)" 
				browserSpanValue=""></brow:browser>
		</wea:item>
		
		<wea:item>权限范围</wea:item>
		<wea:item>
			<SELECT style="width:150px;" class="InputStyle" name="shareType" id="shareType" onchange="onChangeShareType()" style="float:left">
			  <option value="1">集团总部</option>
			  <option value="2">分部</option>
			  <option value="3">部门</option>
			</SELECT>
		</wea:item>
		
		<wea:item attributes="{'samePair':\"objtr\"}" ><%=SystemEnv.getHtmlLabelName(106, user.getLanguage())%></wea:item>
		<wea:item attributes="{'samePair':\"objtr\"}" >	
			<span id="subidsSP" style="float:left;">
			<brow:browser viewType="0" name="subids" browserValue="" 
			browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/company/MutiSubcompanyBrowser.jsp?selectedids=" 
			hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='2'  width="300px"
			completeUrl="/data.jsp?type=164" linkUrl="/hrm/company/HrmSubCompanyDsp.jsp?id=" 
			browserSpanValue=""></brow:browser>
			</span>
			
			<span id="departmentidSP" style="float:left;">
				<brow:browser viewType="0" name="departmentid" browserValue="" 
				browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/company/MutiDepartmentBrowser.jsp?selectedids=" 
				hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='2'  width="300px"
				completeUrl="/data.jsp?type=4" linkUrl="/hrm/company/HrmDepartmentDsp.jsp?id=" 
				browserSpanValue=""></brow:browser>
			</span>
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
</body>
</html>

<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<script type="text/javascript">

function onChangeShareType() {
	thisvalue=jQuery("#shareType").val();
	hideEle("objtr", true);
	if (thisvalue == 1) {
		jQuery($GetEle("subidsSP")).css("display","none");
		jQuery($GetEle("departmentidSP")).css("display","none");
    }else if (thisvalue == 2) {
		jQuery($GetEle("subidsSP")).css("display","");
		jQuery($GetEle("departmentidSP")).css("display","none");
		showEle("objtr");
	}else if (thisvalue == 3) {
		jQuery($GetEle("subidsSP")).css("display","none");
		jQuery($GetEle("departmentidSP")).css("display","");
		showEle("objtr");
	}
}

function check_by_permissiontype() {
    var thisvalue=jQuery("#shareType").val();
    if (thisvalue == 1) {
        return check_form(weaverA, "userid");
    } else if (thisvalue == 2) {
        return check_form(weaverA, "subids,userid");
    } else if (thisvalue == 3) {
        return check_form(weaverA, "departmentid,userid");
    }else {
        return false;
    }
}

function saveData(){
	if (check_by_permissiontype()) {
		$('#weaverA').submit();
	}
}

jQuery(document).ready(function(){
	onChangeShareType();
});
</script>
