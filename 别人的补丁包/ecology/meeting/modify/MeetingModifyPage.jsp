<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="weaver.meeting.MeetingShareUtil"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@page import="weaver.meeting.defined.MeetingFieldManager"%>
<%@page import="weaver.meeting.util.html.HtmlUtil"%> 
<%@page import="org.json.JSONObject"%> 
<%@ page import="weaver.general.IsGovProj" %>
<%@ page import="weaver.crm.Maint.CustomerInfoComInfo" %>
<%@ page import="weaver.file.FileUpload" %>
<%@page import="java.net.URLEncoder" %>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ page import="weaver.file.Prop"%>

<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet3" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="meetingSetInfo" class="weaver.meeting.Maint.MeetingSetInfo" scope="page"/>
<jsp:useBean id="ManageDetachComInfo" class="weaver.hrm.moduledetach.ManageDetachComInfo" scope="page" /> 
<jsp:useBean id="MeetingFieldComInfo" class="weaver.meeting.defined.MeetingFieldComInfo" scope="page"/>
<jsp:useBean id="MeetingFieldGroupComInfo" class="weaver.meeting.defined.MeetingFieldGroupComInfo" scope="page"/>
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page" />
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page" />
<%
FileUpload fu = new FileUpload(request);
String userid = ""+user.getUID();

char flag=Util.getSeparator() ;
String ProcPara = "";

String meetingid = Util.null2String(fu.getParameter("meetingid"));

RecordSet.executeProc("Meeting_SelectByID",meetingid);
RecordSet.next();
String meetingtype=RecordSet.getString("meetingtype");
String meetingname=RecordSet.getString("name");

String tempDesc = Util.toHtmltextarea(Util.encodeAnd(Util.spacetoHtml(RecordSet.getString("desc_n"))));

String caller=RecordSet.getString("caller");
String contacter=RecordSet.getString("contacter");
String creater=RecordSet.getString("creater");
//外部人员
String othermembers = Util.null2String(RecordSet.getString("othermembers"));
//成本统计为只读 获取参会人员统计成本  lq 2015-10-21
String costNum=RecordSet.getString("cost");
String xiaoshi=RecordSet.getString("xiaoshi");
String totalmember=RecordSet.getString("totalmember");

String address=RecordSet.getString("address");
String customizeAddress = Util.null2String(RecordSet.getString("customizeAddress"));
boolean hideAddress=true;//是否隐藏会议室
if("".equals(address)&&"".equals(customizeAddress)){
	hideAddress=false;
}	

//总部议事管理员【编辑/取消】权限  lq 2015-10-25 start
//议事规则 编辑权限
boolean isParliamentEdit = false;
//总部议事管理员【编辑/取消】权限  lq 2015-10-25 end

//lq 议事规则 获取是否是议事规则
String isRuleManageForSql = RecordSet.getString("isparliament");
//创建议事规人员所在分部id	by lq 2015-11-2
String subcompanyidForSql = RecordSet.getString("subcompanyid");
//当前操作人所在分部id	by lq 2015-11-2
String SubCompany = ""+user.getUserSubCompany1();
//lq 判断 当前用户是否是可以创建 议会议程
String isRuleManage = "0";
//判断当前人是否为有权限修改所有会议信息
if (HrmUserVarify.checkUserRight("RulesOfProcedure:Headquarters", user) ) { 
	isRuleManage = "1";
	//超级管理员可以【编辑/取消】所有议事规则  by lq 2015-11-2	

		isParliamentEdit = true;

	
	if("1".equals(Util.null2String(fu.getParameter("isParliamentEdit")))){
		isRuleManage = "2";
	}	
	
}else if (HrmUserVarify.checkUserRight("RulesOfProcedure:Division", user) ) { 
	//分部管理权限
	isRuleManage = "2";
	//判断议事规则是否为本分部创建  by lq 2015-11-2
	if("2".equals(isRuleManageForSql) && subcompanyidForSql.equals(SubCompany)){
		isParliamentEdit = true;
	}
}else if (HrmUserVarify.checkUserRight("RulesOfProcedure:Create", user) ) { 
	//分部议事规则创建权限
	isRuleManage = "2";	
}else{
	isRuleManage = "0";
}

//页面需要判断条件字段
int repeatType = Util.getIntValue(RecordSet.getString("repeatType"),0);
int isInterval=repeatType>0?1:0;

boolean isUseMtiManageDetach=ManageDetachComInfo.isUseMtiManageDetach();
if(isUseMtiManageDetach){
   session.setAttribute("detachable","1");
   session.setAttribute("meetingdetachable","1");
}else{
   session.setAttribute("detachable","0");
   session.setAttribute("meetingdetachable","0");
}

RecordSet.executeProc("Meeting_Type_SelectByID",meetingtype);
RecordSet.next();
String canapprover=RecordSet.getString("approver");

boolean canedit=false;
boolean cansubmit=false;
boolean candelete=false;
boolean canview=false;
boolean canapprove=false;
boolean canschedule=false;
String allUser=MeetingShareUtil.getAllUser(user);
//总部议事管理员【编辑/取消】权限 修改编辑判断权限
if( isParliamentEdit || (MeetingShareUtil.containUser(allUser,caller)|| MeetingShareUtil.containUser(allUser,contacter)||MeetingShareUtil.containUser(allUser,creater))){
	canedit=true;
	cansubmit=true;
	candelete=true;
}

if(!canedit){
	response.sendRedirect("/notice/noright.jsp") ;
}
String f_weaver_belongto_userid=user.getUID()+"";
if(!userid.equals(caller)&&!userid.equals(contacter)&&!userid.equals(creater)){//主账号都不是有权限的人
	if(MeetingShareUtil.containUser(allUser,caller)){
		f_weaver_belongto_userid=caller;
	}else if(MeetingShareUtil.containUser(allUser,contacter)) {
		f_weaver_belongto_userid=contacter;
	}else if(MeetingShareUtil.containUser(allUser,creater)) {
		f_weaver_belongto_userid=creater;
	}
}
//修改会议时,切换会议类型
String meetingtypeNew = Util.null2String(fu.getParameter("meetingtype"));
boolean isresetType=false;
if(!"".equals(meetingtypeNew)&&!meetingtype.equals(meetingtypeNew)){
	isresetType=true;
	meetingtype = meetingtypeNew;
}

//上传附件的目录和大小限制
String mainId = "";
String subId = "";
String secId = "";
String maxsize = "";
if(!meetingtype.equals(""))
{
	RecordSet.executeProc("Meeting_Type_SelectByID",meetingtype);
	if(RecordSet.next())
	{
		String category = Util.null2String(RecordSet.getString("catalogpath"));
	    if(!category.equals(""))
	    {
	    	String[] categoryArr = Util.TokenizerString2(category,",");
	    	mainId = categoryArr[0];
	    	subId = categoryArr[1];
	    	secId = categoryArr[2];
		}else {
			if(!meetingSetInfo.getMtngAttchCtgry().equals("")){//如果设置了目录，则取值
				String[] categoryArr = Util.TokenizerString2(meetingSetInfo.getMtngAttchCtgry(),",");
				mainId = categoryArr[0];
				subId = categoryArr[1];
				secId = categoryArr[2];
			}
		}
    }
	if(!secId.equals(""))
	{
		RecordSet.executeSql("select maxUploadFileSize from DocSecCategory where id="+secId);
		RecordSet.next();
	    maxsize = Util.null2String(RecordSet.getString(1));
	}
}
 


//召集人条件
String whereclause="";
String qswhere = "";
//生成召集人的where子句
int ishead=0 ;
int isset=0;//是否有设置召集人标识，0没有，1有
if(!meetingtype.equals("")) {
	//召集人
	RecordSet.executeProc("MeetingCaller_SByMeeting",meetingtype) ;
	whereclause="where ( " ;
	qswhere = "";
	while(RecordSet.next()){
		String callertype=RecordSet.getString("callertype") ;
		int seclevel=Util.getIntValue(RecordSet.getString("seclevel"), 0) ;
		String rolelevel=RecordSet.getString("rolelevel") ;
		String thisuserid=RecordSet.getString("userid") ;
		String departmentid=RecordSet.getString("departmentid") ;
		String roleid=RecordSet.getString("roleid") ;
		String foralluser=RecordSet.getString("foralluser") ;
		String subcompanyid=RecordSet.getString("subcompanyid") ;
		int seclevelMax=Util.getIntValue(RecordSet.getString("seclevelMax"), 0) ;
		isset=1;
	
		if(callertype.equals("1")){
			if(ishead==0){
				whereclause+=" t1.id="+thisuserid ;
				}
			if(ishead==1){
				whereclause+=" or t1.id="+thisuserid ;
				}
		}
		if(callertype.equals("2")){
			if(ishead==0){
				whereclause+=" t1.id in (select id from hrmresource where departmentid="+departmentid+" and seclevel >="+seclevel+" and seclevel <= "+seclevelMax+" )" ;
			}
			if(ishead==1){
				whereclause+=" or t1.id in (select id from hrmresource where departmentid="+departmentid+" and seclevel >="+seclevel+" and seclevel <= "+seclevelMax+" )" ;
			 }
		}
		if(callertype.equals("3")){
			if(ishead==0){
				whereclause+=" t1.id in (select resourceid from hrmrolemembers join hrmresource on  hrmrolemembers.resourceid=hrmresource.id where roleid="+roleid+" and rolelevel >="+rolelevel+" and seclevel >="+seclevel+" and seclevel <= "+seclevelMax+")" ;
			}
			if(ishead==1){
				whereclause+=" or t1.id in (select resourceid from hrmrolemembers join hrmresource on  hrmrolemembers.resourceid=hrmresource.id where roleid="+roleid+" and rolelevel >="+rolelevel+" and seclevel >="+seclevel+" and seclevel <= "+seclevelMax+")" ;
			}
		}
		if(callertype.equals("4")){
			if(ishead==0){
				whereclause+=" t1.id in (select id from hrmresource where seclevel >="+seclevel+" and seclevel <= "+seclevelMax+" )" ;
			}
			if(ishead==1){
				whereclause+=" or t1.id in (select id from hrmresource where seclevel >="+seclevel+" and seclevel <= "+seclevelMax+" )" ;
			}
		}
		if(callertype.equals("5")){
			if(ishead==0){
				whereclause+=" t1.id in (select id from hrmresource where subcompanyid1="+subcompanyid+" and seclevel >="+seclevel+" and seclevel <= "+seclevelMax+" )" ;
			}
			if(ishead==1){
				whereclause+=" or t1.id in (select id from hrmresource where subcompanyid1="+subcompanyid+" and seclevel >="+seclevel+" and seclevel <= "+seclevelMax+" )" ;
			}
		}
		if(ishead==0)   ishead=1;
	}
	
	//召集人查询条件
	if(!whereclause.equals("where ( ") && whereclause.length() > 5){  
		whereclause+=" )" ;
		qswhere=whereclause.substring(5) ;
		RecordSet.execute("select t1.id from hrmresource t1,hrmdepartment t2 where t1.departmentid = t2.id and (t1.status = 0 or t1.status = 1 or t1.status = 2 or t1.status = 3) and "+qswhere);
		if(RecordSet.getCounts()==1){//召集人就一个,自动带出
			if(RecordSet.next()){
				if(isresetType){
					caller=RecordSet.getString("id");
				}
			}
		}else{//清空召集人
			if(isresetType){
				caller="";
			}
		}
	}
}
	
%>

<HTML><HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<script language=javascript src="/js/weaver_wev8.js"></script>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<script language="javascript" src="/wui/theme/ecology8/jquery/js/zDialog_wev8.js"></script>
<script language="javascript" src="/wui/theme/ecology8/jquery/js/zDrag_wev8.js"></script>
<script language=javascript src="/js/weaverTable_wev8.js"></script>
<script language=javascript src="/js/ecology8/request/e8.browser_wev8.js"></script>

<link href="/js/swfupload/default_wev8.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/js/swfupload/swfupload_wev8.js"></script>
<script type="text/javascript" src="/js/swfupload/swfupload.queue_wev8.js"></script>
<script type="text/javascript" src="/js/swfupload/fileprogressBywf_wev8.js"></script>
<script type="text/javascript" src="/js/swfupload/handlersBywf_wev8.js"></script>
<script type="text/javascript" src="/js/ecology8/meeting/meetingswfupload_wev8.js"></script>
</HEAD>
<%
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(82,user.getLanguage())+":"+Util.forHtml(meetingname);
String needfav ="1";
String needhelp ="";

int topicrows=0;
int servicerows=0;
int topicAttachrows = 0;
String needcheck="";
%>
<BODY style="overflow-y:hidden">
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{提交,javascript:doSubmit(this),_self} " ;
RCMenuHeight += RCMenuHeightStep ;
 
RCMenu += "{"+SystemEnv.getHtmlLabelName(309,user.getLanguage())+",javascript:btn_cancle(),_self} " ;
RCMenuHeight += RCMenuHeightStep ;

%>	
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan"
			style="text-align: right; width: 400px !important">
			<input type="button" value="提交" class="e8_btn_top middle" onclick="doSubmit(this)"/>
			<span
				title="<%=SystemEnv.getHtmlLabelName(23036, user.getLanguage())%>"  class="cornerMenu middle"></span>
		</td>
	</tr>
</table>
<div id="tabDiv">
	<span style="width:10px"></span>
	<span id="hoverBtnSpan" class="hoverBtnSpan">
	</span>
</div>

<div class="zDialog_div_content" style="overflow:auto;">
<FORM id=weaver name=weaver action="/meeting/modify/MeetingModifyOperation.jsp" method=post>
<input class=inputstyle type="hidden" name="method" value="edit">
<input class=inputstyle type="hidden" name="meetingid" id="meetingid" value="<%=meetingid%>">
<input class=inputstyle type="hidden" name="meetingnamestr" value="<%=meetingname%>">
<input class=inputstyle type="hidden" id="tempDesc" name="tempDesc" value="<%=tempDesc%>">
<input class=inputstyle type="hidden" id="isChage" name="isChage" value="0">
<input class=inputstyle type="hidden" name="topicrows" value="0">
<input class=inputstyle type="hidden" name="topicAttachrows" value="0">
<input class=inputstyle type="hidden" name="servicerows" value="0">
<INPUT type="hidden" name="f_weaver_belongto_userid" value="<%=f_weaver_belongto_userid %>">
<INPUT type="hidden" id="rulesOfProcedure" name="rulesOfProcedure" value="0"><!--标识  是否是议会规则-->
<INPUT type="hidden" id="isRuleManage" name="isRuleManage" value="<%=isRuleManage %>"><!--标识  议会规则管理员类型-->

<% if(repeatType == 0) {%>
<input  type="hidden" name="repeatType" id="repeatType" value="0">
<%} %>
<div id="nomalDiv">
<wea:layout type="2col">
<%    
//遍历分组
MeetingFieldManager hfm = new MeetingFieldManager(1);
hfm.getCustomData(Util.getIntValue(meetingid));
List<String> groupList=hfm.getLsGroup();
List<String> fieldList=null;
for(String groupid:groupList){
	fieldList= hfm.getUseField(groupid);
	if(fieldList!=null&&fieldList.size()>0){		
%>
<wea:group context="<%=SystemEnv.getHtmlLabelName(Util.getIntValue(MeetingFieldGroupComInfo.getLabel(groupid)), user.getLanguage()) %>" attributes="{'groupDisplay':''}">
	<%for(String fieldid:fieldList){
		if(repeatType>0) {//周期会议
			if("0".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}else{//非周期会议
			if("1".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}
		
		String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
		int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
		int type = Integer.parseInt(MeetingFieldComInfo.getFieldType(fieldid));
		int fieldhtmltype = Integer.parseInt(MeetingFieldComInfo.getFieldhtmltype(fieldid));
		boolean issystem ="1".equals(MeetingFieldComInfo.getIssystem(fieldid))||"0".equals(MeetingFieldComInfo.getIssystem(fieldid));
		boolean ismand="1".equals(MeetingFieldComInfo.getIsmand(fieldid));
				
		
		//会议室单独处理,是否必填
		if(!"address".equalsIgnoreCase(fieldname)&&!"customizeAddress".equalsIgnoreCase(fieldname)
				&&!"repeatdays".equalsIgnoreCase(fieldname)&&!"repeatweeks".equalsIgnoreCase(fieldname)&&!"rptWeekDays".equalsIgnoreCase(fieldname)
				&&!"repeatmonths".equalsIgnoreCase(fieldname)&&!"repeatmonthdays".equalsIgnoreCase(fieldname)){
			if(ismand){
				if(fieldhtmltype==6){
					needcheck+="".equals(needcheck)?"field"+fieldid:",field"+fieldid;
				}else{
					needcheck+="".equals(needcheck)?fieldname:","+fieldname;
				}
			}
		}
		JSONObject cfg= hfm.getFieldConf(fieldid);
		String fieldValue = hfm.getData(fieldname);
		String extendHtml="";	
		//上传附件,设置上次目录
		if(fieldhtmltype==6){
			cfg.put("mainId",mainId);
			cfg.put("subId",subId);
			cfg.put("secId",secId);
			cfg.put("maxsize",maxsize);
		}
		
		if("meetingtype".equalsIgnoreCase(fieldname)){//会议类型
			fieldValue=meetingtype;
			if(!"".equals(meetingtype)){
				cfg.put("hasInput","false");  
			}
			cfg.put("getBrowserUrlFn","showMeetingType"); 
			cfg.put("callback","meetingReset");
		}else if("address".equalsIgnoreCase(fieldname)){//会议地点
			cfg.put("getBrowserUrlFn","CheckOnShowAddress"); 
			cfg.put("width","60%");
			extendHtml="<div class=\"FieldDiv\" id=\"selectRoomdivb\" name=\"selectRoomdivb\" style=\"margin-left:10px;margin-top: 3px;float:left;\">"+
							"<A href=\"javascript:showRoomsWithDate();\" style=\"color:blue;\">"+SystemEnv.getHtmlLabelName(2193,user.getLanguage())+"</A>"+
						"</div>";
			extendHtml+="<div class=\"FieldDiv\" id=\"znpp\" name=\"znpp\" style=\"margin-left:10px;margin-top: 3px;float:left;\">"+
							"<A href=\"javascript:showQRCode();\" style=\"color:blue;\">获取二维码</A>"+
						"</div>";	
			cfg.put("callback","addressCallBack");
			//if(("".equals(fieldValue)||"0".equals(fieldValue))&&hideAddress) continue;
		}else if("customizeAddress".equalsIgnoreCase(fieldname)){
			//if("".equals(fieldValue)) continue;
		}else if("caller".equalsIgnoreCase(fieldname)){//召集人,添加查询条件
			if(isresetType){//如果重新选择了会类型,更新召集人
				fieldValue=caller;
			}
			if(isset==1){
				cfg.put("browserUrl","/systeminfo/BrowserMain.jsp?url=/meeting/data/CallerBrowser.jsp?meetingtype="+meetingtype);
				cfg.put("completeUrl","/data.jsp?type=meetingCaller&meetingtype="+meetingtype);
			}
		}else if("repeatType".equalsIgnoreCase(fieldname)){//重复模式,添加change事件
			cfg.put("func","changeRepeatType()");
		}else if("hrmmembers".equalsIgnoreCase(fieldname)){//参会人员,不计算参会人数,需要计算,打开下面注释代码
			//编辑状态 重新计算参会人员成本  by lq 2015-10-22
			cfg.put("callback","countAttend");
		}else if("crmmembers".equalsIgnoreCase(fieldname)){//参会客户,不计算参会客户数,需要计算,打开下面注释代码
			//cfg.put("callback","countAttendCRM");
		}else if("remindTypeNew".equalsIgnoreCase(fieldname)){//默认提醒方式
			cfg.put("callback","onRemindType");
		}
		
		if("remindHoursBeforeStart".equalsIgnoreCase(fieldname)||"remindTimesBeforeStart".equalsIgnoreCase(fieldname)
				||"remindHoursBeforeEnd".equalsIgnoreCase(fieldname)||"remindTimesBeforeEnd".equalsIgnoreCase(fieldname)
				||"repeatweeks".equalsIgnoreCase(fieldname)||"rptWeekDays".equalsIgnoreCase(fieldname)
				||"repeatmonths".equalsIgnoreCase(fieldname)||"repeatmonthdays".equalsIgnoreCase(fieldname))
			continue;
		
		//提醒时间特殊处理			
		if("remindBeforeStart".equals(fieldname)){
			//
		}else if("remindBeforeEnd".equals(fieldname)){
			//
		}else if("remindImmediately".equalsIgnoreCase(fieldname)){
			//
		}else if("repeatdays".equalsIgnoreCase(fieldname)){
			//
		}else{
			String htmElementString = HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
			//lq 议事规则
			if("hrmmembers".equals(fieldname)){
				htmElementString += "&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"hidden\"  size=\"5\" value=\"\" id=\"cost\" name=\"cost\" />";
			}else if("addressselect".equals(fieldname)){//会议地点类型
				
			}else if("desc_n".equals(fieldname)){//会议要求
				
			}else if("address".equals(fieldname)){
				htmElementString = "<span id=\"my_address\">"+htmElementString+"</span>";
				//address customizeAddress addressselect
			}else if("customizeAddress".equalsIgnoreCase(fieldname)){
				//htmElementString = "<span id=\"my_customizeAddress\">"+htmElementString+"</span>";
				String extendHtml1 ="<div class=\"FieldDiv\" id=\"znpp\" name=\"znpp\" style=\"margin-left:10px;margin-top: 3px;float:left\">"+
			                     	         "<A href=\"javascript:showQRCode();\" style=\"color:blue;\">获取二维码</A>"+
						    "</div>";
				//添加获取二维码
				htmElementString = "<table id=\"my_customizeAddress\" style=\"width:70%\"><tr style=\"width:100%\"><td style=\"width:80%\"><span >"+htmElementString+"</td><td>"+extendHtml1+"</td></tr></table>";
			}else if("begindate".equals(fieldname)){
				cfg.put("callback","countCost");
			}else if("begintime".equals(fieldname)){
				cfg.put("callback","countCost");
			}else if("enddate".equals(fieldname)){
				cfg.put("callback","countCost");
			}else if("endtime".equals(fieldname)){
				cfg.put("callback","countCost");
			}else if("ccmeetingnotice".equalsIgnoreCase(fieldname)){
				//会议通知抄送人
				//人员链接修改 2017-1-14
				cfg.put("callback","getCcmeetingnoticeHtml");
			}else if("ccmeetingminutes".equalsIgnoreCase(fieldname)){
				//会议纪要抄送人
				//人员链接修改 2017-1-14
				cfg.put("callback","getCcmeetingminutesHtml");
			}
			//联系人只读 by lq 2015-11-2 start
			else if("contacter".equalsIgnoreCase(fieldname)){//联系人 为当前用户 不能编辑
				htmElementString = "<div style=\"display:none\">"+htmElementString+"</div>";
				extendHtml = "<A href=\"/hrm/resource/HrmResource.jsp?id="+contacter+"\" target=_blank>"+ResourceComInfo.getLastname(contacter)+"</A>";			
			}
			//联系人只读 by lq 2015-11-2 start		
			
			//成本统计为只读 by lq 2015-10-21 start
			else if("cost".equals(fieldname)){			
				//判断会议成本是否空
				if("".equals(costNum)){
					costNum = "0";
				}
				//隐藏原成本统计的输入框
				htmElementString = "<div id=\"costDiv\" style=\"display:none\">"+htmElementString+"</div>";
				//添加span用来显示数字
				extendHtml = "<span id=\"costSpan\">"+costNum+"</span>";
			}else if("totalmember".equals(fieldname)){			
				//判断会议成本是否空
				if("".equals(totalmember)){
					totalmember = "0";
				}
				//隐藏原成本统计的输入框
				htmElementString = "<div id=\"totalmemberDiv\" style=\"display:none\">"+htmElementString+"</div>";
				//添加span用来显示数字
				extendHtml = "<span id=\"totalmemberSpan\">"+totalmember+"</span>";
			}else if("xiaoshi".equals(fieldname)){			
				//判断会议成本是否空
				if("".equals(xiaoshi)){
					xiaoshi = "0";
				}
				//隐藏原成本统计的输入框
				htmElementString = "<div id=\"costDiv\" style=\"display:none\">"+htmElementString+"</div>";
				//添加span用来显示数字
				extendHtml = "<span id=\"xiaoshiSpan\">"+xiaoshi+"</span>";
			}else{
				//转成html显示
				if(fieldhtmltype==4){//check框,变成disabled
					cfg.put("disabled","disabled");
					fieldValue=HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
				}else if(fieldhtmltype==5){//check框,变成disabled
					if("addressselect".equalsIgnoreCase(fieldname)){
						extendHtml = "<input type=\"hidden\" name=\"addressselect\" id=\"addressselect\" value=\""+fieldValue+"\" >";
					}
					htmElementString=hfm.getFieldvalue(user, Integer.parseInt(fieldid), fieldhtmltype, type, fieldValue, 0);
				}else if(fieldhtmltype==6){
					cfg.put("canDelAcc",false);//是否有删除按钮
					cfg.put("canupload",false);//是否可以上传
					cfg.put("candownload",true);//是否有下载按钮
					htmElementString=HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
				}else if(fieldhtmltype==3){
					htmElementString=hfm.getHtmlBrowserFieldvalue(user,Integer.parseInt(fieldid),fieldhtmltype,type,fieldValue);
				}else{
					htmElementString=hfm.getFieldvalue(user, Integer.parseInt(fieldid), fieldhtmltype, type, fieldValue, 0);
				}
				if("remindTypeNew".equalsIgnoreCase(fieldname)){
					htmElementString="".equals(fieldValue)?SystemEnv.getHtmlLabelName(19782,user.getLanguage()):fieldValue;
				}
				//外来人员 判断是否为其他人员，重新生成其他人员生成显示框 start
				if("othermembers".equalsIgnoreCase(fieldname)){			
					System.out.println("fieldValue:"+fieldValue);
					System.out.println("extendHtml:"+extendHtml);
					//清除原来显示内容
					htmElementString = "";
					extendHtml = "<input type=\"hidden\" name = \"othermembers\" id=\"othermembers\" value=\""+fieldValue+"\"/><span id=\"othermembersspan\" name=\"othermembersspan\">"+fieldValue+"</span>"	;		
					fieldValue = "";					
				}
				//外来人员 判断是否为其他人员，重新生成其他人员生成显示框 end 
			}
		%>		
			<wea:item>
				<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
			</wea:item> 
			<wea:item>
				<%=htmElementString%>
				<%=extendHtml%>
			</wea:item>	
	<%	}
	}%>
</wea:group>
<%}
}%>		
	
</wea:layout>	
</div>
	<div id="agendaDiv" style="display:none">
		<div id="topicRowSource" style="display:none;">
	   		<div name='topicRowSourceDiv' id="topicRowSource_0" fieldName="topicChk" fieldid="0">
	   			<input name="topicChk" type="checkbox" value="1" rowIndex='#rowIndex#'>
	   		</div>
	   		<%
	   		
	   		String orderNumberName1 = Util.null2String(Prop.getPropValue("meeting", "orderNumberName"));
	   		
	   		int topicColSize=1;
        	MeetingFieldManager hfm2 = new MeetingFieldManager(2);
        	List<String> groupList=hfm2.getLsGroup();
        	List<String> fieldList=null;
        	Hashtable<String,String> ht=null;
        	for(String groupid:groupList){
        		fieldList= hfm2.getUseField(groupid);
        		int i=0;
        		if(fieldList!=null&&fieldList.size()>0){
	        		topicColSize=fieldList.size()+1;
        			for(String fieldid:fieldList){
        				i++;
						String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
	        			String fieldVaule="";
	        			String fieldhtmltype=MeetingFieldComInfo.getFieldhtmltype(fieldid);
	        			 
	        			JSONObject cfg= hfm2.getFieldConf(fieldid);
	        			cfg.put("isdetail", 1);//明细列表显示
	        			ht=HtmlUtil.getHtmlElementHashTable(fieldVaule,cfg,user);
	        			
	        			
	        			if(orderNumberName1.equals(fieldname) && !orderNumberName1.equals("")){
							ht.put("inputStr",ht.get("inputStr").replace("value=\"\"", "value=\"#rowIndex#\""));
						}
	        %>
	       <div name='topicRowSourceDiv' id="topicRowSource_<%=i %>" fieldName="<%=fieldname %>" fieldid="<%=fieldid %>" fieldhtmltype="<%=fieldhtmltype %>">
	       		<%=ht.get("inputStr") %>
	       </div>
	       <%if(!"".equals(ht.get("jsStr"))){ %>
	       <div id="topicRowSource_js_<%=i %>">
	       		<%=ht.get("jsStr") %>
	       </div> 
	        <%}
	        		}
        		}
        	}
        	%>
	   	</div>
	  <TABLE class="ViewForm">
        <TBODY>
        <TR class="Title">
            <TH>&nbsp;</TH>
            <Td class="Field"align=right>
            	<input class="addbtn" accesskey="A" onclick="addNewRow('topic');" title="<%=SystemEnv.getHtmlLabelName(611,user.getLanguage())%>" type="button">
				<input class="delbtn" accesskey="E" onclick="deleteSelectedRow('topic');" title="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage())%>" type="button">
			</Td>
          </TR>
        <TR class="Spacing" style="height:1px!important;">
          <TD class="Line1" colspan=2></TD></TR>
         <tr>
        	<td class="Field" colspan=2>
        	<%
        	//序号 排序  lq 2016-1-15 start
			
			//获取序号字段名称
			String orderNumberName = Util.null2String(Prop.getPropValue("meeting", "orderNumberName"));
							
			String sql = "select * from Meeting_Topic where meetingid="+meetingid;
			if(!orderNumberName.equals("")){
				sql +=" order by "+orderNumberName+" asc";
			}
		//序号 排序  lq 2016-1-15 end
			RecordSet3.execute(sql);
        	for(String groupid:groupList){
        		fieldList= hfm2.getUseField(groupid);
        		
        		if(fieldList!=null&&fieldList.size()>0){
        			int colSize=fieldList.size();
        			
        	%>		<table id="topicTabField" class=ListStyle  border=0 cellspacing=1>
        			  <colgroup>
        			  	<col width="5%">
        	<%		for(int i=0;i<colSize;i++){
        				out.print("<col width='"+(95/colSize)+"%'>\n");
        			}
        			out.println("</colgroup>\n");
        			out.println("<TR class=HeaderForXtalbe>\n");
        			out.println("<th><input name=\"topicChkAll\" tarObj=\"topicChk\" type=\"checkbox\" onclick=\"jsChkAll(this)\"></th>\n");
        		  	
        			for(String fieldid:fieldList){
        				int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
        				out.println("<th>"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
	        
	   				}
        			//展示历史数据
        			while(RecordSet3.next()){
        				topicrows++;
        				out.print("<tr class='DataLight'>\n"); 
        				out.print("<td><input name=\"topicChk\" type=\"checkbox\" value=\"1\" rowIndex='"+topicrows+"'><input name=\"topic_data_"+topicrows+"\" type=\"hidden\" value=\""+RecordSet3.getString("id")+"\" ></td>\n"); 
        				for(String fieldid:fieldList){
            				String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
            				int fieldhtmltype = Integer.parseInt(MeetingFieldComInfo.getFieldhtmltype(fieldid));
            				int type = Integer.parseInt(MeetingFieldComInfo.getFieldType(fieldid));
            				JSONObject cfg= hfm2.getFieldConf(fieldid);
            				cfg.put("rowindex",topicrows);
            				String fieldValue = RecordSet3.getString(fieldname);
            				 
            				out.println("<td>"+HtmlUtil.getHtmlElementString(fieldValue,cfg,user)+"</td>\n");
    	        
    	   				}
        				out.print("</tr>\n"); 
        			}
        			
        			
        			out.print("</tr></table>\n"); 
        		}
        	}
        	%>         
        	</td>
        </tr>
		  
		  </TD>
        </TR>
        </TBODY>
	  </TABLE>
	  <!-- begin 会议议程附件 -->
	  <div id="topicAttachRowSource" style="display:none;">
	   		<div name='topicAttachRowSourceDiv' id="topicAttachRowSource_0" fieldName="topicAttachChk" fieldid="0">
	   			<input name="topicAttachChk" type="checkbox" value="1" rowIndex='#rowIndex#'>
	   		</div>
	   		<%
	   		int topicAttachColSize=1;
        	MeetingFieldManager hfm4 = new MeetingFieldManager(4);
        	List<String> groupList4=hfm4.getLsGroup();
        	List<String> fieldList4=null;
        	Hashtable<String,String> ht4=null;
        	for(String groupid:groupList4){
        		fieldList4= hfm4.getUseField(groupid);
        		int i=0;
        		if(fieldList4!=null&&fieldList4.size()>0){
	        		topicAttachColSize=fieldList4.size()+1;
        			for(String fieldid:fieldList4){
        				i++;
						String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
	        			String fieldVaule="";
	        			String fieldhtmltype=MeetingFieldComInfo.getFieldhtmltype(fieldid);
	        			 
	        			JSONObject cfg= hfm4.getFieldConf(fieldid);
	        			cfg.put("isdetail", 1);//明细列表显示
	        			//上传附件,设置上次目录
	        			if("6".equals(fieldhtmltype)){
	        				cfg.put("mainId",mainId);
	        				cfg.put("subId",subId);
	        				cfg.put("secId",secId);
	        				cfg.put("maxsize",maxsize);
	        				cfg.put("rowindex","_rowIndex_");
	        			}
	        			ht4=HtmlUtil.getHtmlElementHashTable(fieldVaule,cfg,user);
	        %>
	       <div name='topicAttachRowSourceDiv' id="topicAttachRowSource_<%=i %>" fieldName="<%=fieldname %>" fieldid="<%=fieldid %>" fieldhtmltype="<%=fieldhtmltype %>">
	       		<%=ht4.get("inputStr") %>
	       </div>
	       <%if(!"".equals(ht4.get("jsStr"))){ %>
	       <div id="topicAttachRowSource_js_<%=i %>">
	       		<%=ht4.get("jsStr") %>
	       </div> 
	        <%}
	        		}
        		}
        	}
        	%>
	   	</div>
	  <TABLE class="ViewForm">
        <TBODY>
        <TR class="Title">
            <TH>&nbsp;</TH>
            <Td class="Field"align=right>
            	<input class="addbtn" accesskey="A" onclick="addNewRow('topicAttach');" title="<%=SystemEnv.getHtmlLabelName(611,user.getLanguage())%>" type="button">
				<input class="delbtn" accesskey="E" onclick="deleteSelectedRow('topicAttach');" title="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage())%>" type="button">
			</Td>
          </TR>
        <TR class="Spacing" style="height:1px!important;">
          <TD class="Line1" colspan=2></TD></TR>
         <tr>
        	<td class="Field" colspan=2>
        	<%
        	//序号 排序  lq 2016-1-15 start
			sql = "select * from Meeting_Topic_Attach where meetingid="+meetingid;
			if(!orderNumberName.equals("")){
				sql +=" order by "+orderNumberName+" asc";
			}
		//序号 排序  lq 2016-1-15 end
			RecordSet3.execute(sql);
        	for(String groupid:groupList4){
        		fieldList4= hfm4.getUseField(groupid);
        		
        		if(fieldList4!=null&&fieldList4.size()>0){
        			int colSize=fieldList4.size();
        			
        	%>		<table id="topicAttachTabField" class=ListStyle  border=0 cellspacing=1>
        			  <colgroup>
        			  	<col width="5%">
        	<%		for(int i=0;i<colSize;i++){
		        		if(i==0){
				        	out.print("<col width='5%'>\n");
				        }else{
        					out.print("<col width='"+(95/colSize)+"%'>\n");
		       			}
        			}
        			out.println("</colgroup>\n");
        			out.println("<TR class=HeaderForXtalbe>\n");
        			out.println("<th><input name=\"topicAttachChkAll\" tarObj=\"topicAttachChk\" type=\"checkbox\" onclick=\"jsChkAll(this)\"></th>\n");
        		  	
        			for(String fieldid:fieldList4){
        				int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
        				out.println("<th>"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
	        
	   				}
        			//展示历史数据
        			while(RecordSet3.next()){
        				topicAttachrows++;
        				out.print("<tr class='DataLight'>\n"); 
        				out.print("<td><input name=\"topicAttachChk\" type=\"checkbox\" value=\"1\" rowIndex='"+topicAttachrows+"'><input name=\"topicattach_data_"+topicAttachrows+"\" type=\"hidden\" value=\""+RecordSet3.getString("id")+"\" ></td>\n"); 
        				for(String fieldid:fieldList4){
            				String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
            				int fieldhtmltype = Integer.parseInt(MeetingFieldComInfo.getFieldhtmltype(fieldid));
            				int type = Integer.parseInt(MeetingFieldComInfo.getFieldType(fieldid));
            				JSONObject cfg= hfm4.getFieldConf(fieldid);
            				cfg.put("rowindex",topicAttachrows);
            				//上传附件,设置上次目录
    	        			if(fieldhtmltype == 6){
    	        				cfg.put("mainId",mainId);
    	        				cfg.put("subId",subId);
    	        				cfg.put("secId",secId);
    	        				cfg.put("maxsize",maxsize);
    	        				cfg.put("rowindex",topicAttachrows);
    	        			}
            				String fieldValue = RecordSet3.getString(fieldname);
            				out.println("<td>"+HtmlUtil.getHtmlElementString(fieldValue,cfg,user)+"</td>\n");
    	        
    	   				}
        				out.print("</tr>\n"); 
        			}
        			
        			
        			out.print("</tr></table>\n"); 
        		}
        	}
        	%>         
        	</td>
        </tr>
		  
		  </TD>
        </TR>
        </TBODY>
	  </TABLE>  
	  <!-- end 会议议程附件 -->
	</div>

</FORM>
</div>
<div id="zDialog_div_bottom" class="zDialog_div_bottom">
	<wea:layout type="2col">
		<wea:group context="">
			<wea:item type="toolbar">
				<input type="button"
					value="<%=SystemEnv.getHtmlLabelName(309, user.getLanguage())%>"
					 class="zd_btn_cancle" onclick="btn_cancle()">
			</wea:item>
		</wea:group>
	</wea:layout>
</div>

<script language="JavaScript" src="/js/addRowBg_wev8.js" >   </script>  
<script language=javascript>
$(document).ready(function(){
	setInterval(countCost,1000);
});

function countCost(){
	//计算参会人成本   lq  2015-9-1
	$.post("/weavernorth/meeting/AjaxCountCost.jsp?method=countcost",
			{"hrmmembers":$('#hrmmembers').val(),"begindate":$("#begindate").val(),
			 "begintime":$("#begintime").val(),"enddate":$("#enddate").val(),"endtime":$("#endtime").val()
			},
       	function(datas){
			var d = datas.split("|");
			$('#cost').val(d[0]);
			$('#costSpan').html(d[0]);
			$("#xiaoshi").val(d[1]);
			$("#xiaoshiSpan").html(d[1]);
		}
	);

	var hrmmember=$('#hrmmembers').val().split(",");
	if($('#totalmember').length>0){
		$("#totalmember").val(hrmmember.length);
		$('#totalmemberSpan').html(hrmmember.length);
	}else{
		$("#totalmember").val(0);
		$('#totalmemberSpan').html(0);
	}

	if($('#hrmmembers').val()=='' && $('#othermembers').val()=='' ){
		if($('#totalmember').length>0){
			$('#totalmember').val(0);
		}
	}else{
		//参会人员
		var hrmmember= 0;
		//外来参会人员
		var othermembers= 0;
		if($('#hrmmembers').val()){
			hrmmember = $('#hrmmembers').val().split(",").length;
		}
		if($('#othermembers').val()){
			othermembers = $('#othermembers').val().split(",").length;
		}
		
		if($('#totalmember').length>0){
			$('#totalmember').val(hrmmember+othermembers);
			$('#totalmemberSpan').html(hrmmember+othermembers);
		}
	}
}

function onChangeSharetype(delspan,delid,ismand,uploadobj){
	fieldid=delid.substr(0,delid.indexOf("_"));//fieldid值
	fieldidnum=fieldid+"_idnum_1";
    if($GetEle(delspan).style.visibility=='visible'){
    	$GetEle(delspan).style.visibility='hidden';
    	$GetEle(delid).value='0';
  		$GetEle(fieldidnum).value=parseInt($GetEle(fieldidnum).value)+1;
    }else{
    	$GetEle(delspan).style.visibility='visible';
    	$GetEle(delid).value='1';
  		$GetEle(fieldidnum).value=parseInt($GetEle(fieldidnum).value)-1;
   }
   var fieldid_value="";
   $("input[tarobj='"+fieldid+"']").each(function(){
   		var linknum=$(this).attr("linknum");
   		var linkvalue=$(this).val();
   		alert(linkvalue);
   		if($("#" + fieldid + "_del_" + linknum).val()=='0'){
   			fieldid_value+=fieldid_value==''?linkvalue:","+linkvalue;
   		}
   })
   $('#'+fieldid).val(fieldid_value);
   showmustinput(uploadobj);
}

function onChangeSharetypeAttach(delspan,delid,ismand,uploadobj,rowindex){
	fieldid=delid.substr(0,delid.indexOf("_"));//fieldid值
	fieldidnum=fieldid+"_"+rowindex+"_idnum_1";
    if($GetEle(delspan).style.visibility=='visible'){
    	$GetEle(delspan).style.visibility='hidden';
    	$GetEle(delid).value='0';
  		$GetEle(fieldidnum).value=parseInt($GetEle(fieldidnum).value)+1;
    }else{
    	$GetEle(delspan).style.visibility='visible';
    	$GetEle(delid).value='1';
  		$GetEle(fieldidnum).value=parseInt($GetEle(fieldidnum).value)-1;
   }
   var fieldid_value="";
   $("input[tarobj='"+fieldid+"']").each(function(){
   		var linknum=$(this).attr("linknum");
   		var linkvalue=$(this).val();
   		if($("#" + fieldid + "_del_" + linknum).val()=='0'){
   			fieldid_value+=fieldid_value==''?linkvalue:","+linkvalue;
   		}
   })
   
   $('#'+fieldid).val(fieldid_value);
   showmustinput(uploadobj);
}

function opendoc(showid,versionid,docImagefileid)
{
	openFullWindowHaveBar("/docs/docs/DocDspExt.jsp?id="+showid+"&imagefileId="+docImagefileid+"&from=accessory&wpflag=workplan&meetingid=<%=meetingid%>");
}
function opendoc1(showid)
{
	openFullWindowHaveBar("/docs/docs/DocDsp.jsp?id="+showid+"&isOpenFirstAss=1&wpflag=workplan&meetingid=<%=meetingid%>");
}
//计算参会人数
function countAttend()
{
	if($('#hrmmembers').val()==''){
		if($('#totalmember').length>0){
			$('#totalmember').val(0);
		}
	}else{
		var hrmmember=$('#hrmmembers').val().split(",");
		if($('#totalmember').length>0){
			$('#totalmember').val(hrmmember.length);
		}
		
		//计算参会人成本   lq  2015-9-1
		$.post("/weavernorth/meeting/AjaxCountCost.jsp?method=countcost",{
		        		hrmmembers:$('#hrmmembers').val()},
		        	function(datas){
						if(datas != 0){		
							$('#cost').val(datas);
							$('#costSpan').html(datas);
						} else {
							$('#cost').val("0");
							$('#costSpan').html(datas);
						}
					});
	}
}
//计算参会客户数
function countAttendCRM()
{	
	if($('#crmmembers').val()==''){
		if($('#crmtotalmember').length>0){
			$('#crmtotalmember').val(0);
		}
	}else{
		var crmmember=$('#crmmembers').val().split(",");
		if($('#crmtotalmember').length>0){
			$('#crmtotalmember').val(crmmember.length);
		}
	}
}
////以下是议程和服务 明细列表处理
function jsChkAll(obj)
{    
   var tar=$(obj).attr("tarObj");
   $("input[name='"+tar+"']").each(function(){
		changeCheckboxStatus(this,obj.checked);
	}); 
} 
//移除 checkbox初始美化值
function removeSourceCheck(){
	$('#serviceRowSource').find("input[type='checkbox']").each(function(){
		removeBeatyRadio(this);
	});
	$('#topicRowSource').find("input[type='checkbox']").each(function(){
		removeBeatyRadio(this);
	});
	$('#topicAttachRowSource').find("input[type='checkbox']").each(function(){
		removeBeatyRadio(this);
	});
}
serviceindex = "<%=servicerows%>";
rowindex = "<%=topicrows%>";
attachindex = "<%=topicAttachrows%>";
function addNewRow(target){
	if(target=='service'){
		
	}else if(target=='topic'){
		rowindex = rowindex*1 +1;
		var oRow;
		var oCell;
		oRow = jQuery("#topicTabField")[0].insertRow(-1);
		oRow.className="DataLight";
		
		for(var i=0;i<<%=topicColSize%>;i++){
			oCell = oRow.insertCell(-1);
			var filename=jQuery("#topicRowSource_"+i).attr("fieldName");
			var fieldid=jQuery("#topicRowSource_"+i).attr("fieldid");
			var ht=jQuery("#topicRowSource_"+i).html();
			if(!!ht && ht.match(/#rowIndex#/)){
				ht=ht.replace(/#rowIndex#/g,rowindex);
			}
			
			oCell.innerHTML =ht;
			if(i!=0){
				if(jQuery("#topicRowSource_js_"+i)&&jQuery("#topicRowSource_js_"+i).html()!=''){
					try{
						eval("cusFun_"+fieldid+"("+rowindex+")");
					}catch(e){}
				}
			}
		}
		jQuery("#topicTabField").jNice();
		jQuery("#topicTabField").find("select").each(function(){
			jQuery(this).attr("notBeauty","");
		})
		jQuery("#topicTabField").find("select").selectbox();
	}else if(target=='topicAttach'){
		attachindex = attachindex*1 +1;
		var oRow;
		var oCell;
		oRow = jQuery("#topicAttachTabField")[0].insertRow(-1);
		oRow.className="DataLight";
		var addRowjs ="";
		for(var i=0;i<<%=topicAttachColSize%>;i++){
			oCell = oRow.insertCell(-1);
			var filename=jQuery("#topicAttachRowSource_"+i).attr("fieldName");
			var fieldid=jQuery("#topicAttachRowSource_"+i).attr("fieldid");
			var ht=jQuery("#topicAttachRowSource_"+i).html();
			if(!!ht && ht.match(/#rowIndex#/)){
				ht = ht.replace(/#rowIndex#/g,attachindex);
			}
			if(!!ht && ht.match(/_rowIndex_/)){
				ht = ht.replace(/_rowIndex_/g,attachindex);
			}
			jQuery(oCell).html(ht);
			
			//lq 2015-8-31 隐藏"公开"列
			if(filename == 'isopen'){
				oCell.style.display = 'none';
			}
			if(i!=0){
				if(jQuery("#topicAttachRowSource_js_"+i)&&jQuery("#topicAttachRowSource_js_"+i).html()!=''){
					try{
						eval("cusFun_"+fieldid+"("+attachindex+")");
					}catch(e){}
					try{
						eval("fileupload"+fieldid+"_"+attachindex+"()");
					}catch(e){}
				}
			}
		}
		jQuery("#topicAttachTabField").jNice();
		jQuery("#topicAttachTabField").find("select").each(function(){
			jQuery(this).attr("notBeauty","");
		})
		jQuery("#topicAttachTabField").find("select").selectbox();
		
	}
}
	
function deleteSelectedRow(target){
	if(target=='service'){
		var table=$(jQuery("#serviceTabField")[0]);
		var selectedTrs=table.find("tr:has([name='serviceChk']:checked)");
		if(selectedTrs.size()==0){
			window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(82884,user.getLanguage())%>");
			return;
		}
		window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(82017,user.getLanguage())%>",function(){
			selectedTrs.each(function(){
				jQuery(this).remove();
			});
		});
	}else if(target=='topic'){
		var table=$(jQuery("#topicTabField")[0]);
		var selectedTrs=table.find("tr:has([name='topicChk']:checked)");
		if(selectedTrs.size()==0){
			window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(82884,user.getLanguage())%>");
			return;
		}
		window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(82017,user.getLanguage())%>",function(){
			selectedTrs.each(function(){
				jQuery(this).remove();
			});
		});
	}else if(target=='topicAttach'){
		var table=$(jQuery("#topicAttachTabField")[0]);
		var selectedTrs=table.find("tr:has([name='topicAttachChk']:checked)");
		if(selectedTrs.size()==0){
			window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(82884,user.getLanguage())%>");
			return;
		}
		window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(82017,user.getLanguage())%>",function(){
			selectedTrs.each(function(){
				jQuery(this).remove();
			});
		});
	}
}
////以上是议程和服务 明细列表处理

function doSave(obj){

	//lq 保存 验证是否勾选 议事规则
	if($('#isRulesOfProcedure').is(':checked')) {
		
		$('#rulesOfProcedure').val(1);
		
	}else{
		
		$('#rulesOfProcedure').val(0);		
		
	}

	var thisvalue=jQuery("#repeatType").val();
	var begindate=thisvalue!=0?$('#repeatbegindate').val():$('#begindate').val();
	var enddate=thisvalue!=0?$('#repeatenddate').val():$('#enddate').val();
	var needcheck='<%=needcheck%>'
	if(thisvalue==1){
		needcheck+=",repeatdays";
	}else if(thisvalue==2){
		needcheck+=",repeatweeks,rptWeekDays";
	}else if(thisvalue==3){
		needcheck+=",repeatmonths,repeatmonthdays";
	}
	if(check_form(document.weaver,needcheck)&&checkDateValidity(begindate,$('#begintime').val(),enddate,$('#endtime').val(),"<%=SystemEnv.getHtmlLabelName(16722,user.getLanguage())%>")){
		if(checkAddress()){
			document.weaver.topicrows.value=rowindex;
			document.weaver.topicAttachrows.value=attachindex;
			document.weaver.servicerows.value=serviceindex;
			//document.weaver.submit();
			doUpload();
		}
	}
}

function doSubmit(obj){

	//lq 提交 验证是否勾选 议事规则
	if($('#isRulesOfProcedure').is(':checked')) {
		$('#rulesOfProcedure').val(1);
	}else{
		$('#rulesOfProcedure').val(0);		
	}
	
	var thisvalue=jQuery("#repeatType").val();
	var begindate=thisvalue!=0?$('#repeatbegindate').val():$('#begindate').val();
	var enddate=thisvalue!=0?$('#repeatenddate').val():$('#enddate').val();
	var needcheck='<%=needcheck%>'
	if(thisvalue==1){
		needcheck+=",repeatdays";
	}else if(thisvalue==2){
		needcheck+=",repeatweeks,rptWeekDays";
	}else if(thisvalue==3){
		needcheck+=",repeatmonths,repeatmonthdays";
	}
	if(check_form(document.weaver,needcheck)&&checkDateValidity(begindate,$('#begintime').val(),enddate,$('#endtime').val(),"<%=SystemEnv.getHtmlLabelName(16722,user.getLanguage())%>")){
			if(checkAddress()){
		        //当选择重复会议时，不做会议室和人员冲突校验
		        if(thisvalue != 0){
		        	submitact();
					return;
		        }
		        //会议室冲突校验
		        if(<%=meetingSetInfo.getRoomConflictChk()%> == 1 ){
		        	$.post("/meeting/data/AjaxMeetingOperation.jsp?method=chkRoom",{
		        		address:$GetEle("address").value,
		        		begindate:begindate,begintime:$('#begintime').val(),
  						enddate:enddate,endtime:$('#endtime').val(),mid:$('#meetingid').val()},
		        	function(data){
						var datas = data.replace(/(^\s*)|(\s*$)/g, "");
						if(datas != 0){
							if(datas == 2){
								Dialog.alert("会议室已经被占用无法预约，请选择其他时间。");		
							}else{
								<%if(meetingSetInfo.getRoomConflict() == 1){ %>
									window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(19095,user.getLanguage())%>", function (){
										submitact();
									});
								<%} else if(meetingSetInfo.getRoomConflict() == 2) {%>
									Dialog.alert("<%=SystemEnv.getHtmlLabelName(32875,user.getLanguage())%>。");
								<%}%>
							}
						} else {
							submitact();
						}
					});
		        } else {
		        	submitact();
		        }
			}
	}
}
//人员冲突校验
function submitChkMbr(){
	 if(<%=meetingSetInfo.getMemberConflictChk()%> == 1){
  		$.post("/meeting/data/AjaxMeetingOperation.jsp?method=chkMember",
  			{hrmids:$("#hrmmembers").val(),crmids:$("#crmmembers").val(),
  			begindate:$('#begindate').val(),begintime:$('#begintime').val(),
  			enddate:$('#enddate').val(),endtime:$('#endtime').val()},
  			function(datas){
				var dataObj=null;
				if(datas != ''){
					dataObj=eval("("+datas+")");
				}
				if(wuiUtil.getJsonValueByIndex(dataObj, 0) == "0"){
					submitact();
				} else {
					<%if(meetingSetInfo.getMemberConflict() == 1){ %>
			            window.top.Dialog.confirm(wuiUtil.getJsonValueByIndex(dataObj, 1)+"<%=SystemEnv.getHtmlLabelName(32873,user.getLanguage())%>?", function (){
			                submitact();
			            },null, null, 120);
		            <%} else if(meetingSetInfo.getMemberConflict() == 2) {%>
		            	Dialog.alert(wuiUtil.getJsonValueByIndex(dataObj, 1)+"<%=SystemEnv.getHtmlLabelName(32874,user.getLanguage())%>" ,null ,400 ,150);
		            	return;
		            <%}%>
				} 
			});
       } else {
       		submitact();
       }
}

function submitact(){
	var desc_n = $('#desc_n').val();
	var tempDesc = $('#tempDesc').val();
	if(desc_n != tempDesc){
		$('#isChage').val("1");
	}
	document.weaver.topicrows.value=rowindex;
	document.weaver.topicAttachrows.value=attachindex;
	document.weaver.servicerows.value=serviceindex;
	//document.weaver.submit();
	doUpload();
}

function doUpload(){
	//附件上传
    StartUploadAll();
    checkuploadcomplet();
}

function doSaveAfterAccUpload(){
	document.weaver.submit();
}
//提交时校验会议室是否为空
function checkAddress()
{	
	if($("#customizeAddress").length>0){
		if($("#address").val()==''&&$("#customizeAddress").val()==''){
			Dialog.alert("<%=SystemEnv.getHtmlLabelName(20393, user.getLanguage())%>");
			return false;
		}
	}else{
		if($("#address").val()==''){
			Dialog.alert("<%=SystemEnv.getHtmlLabelName(20393, user.getLanguage())%>");
			return false;
		}
	}
	return true;
}

//检测开始时间和结束时间的前后
function checkDateValidity(begindate,begintime,enddate,endtime,errormsg){
	var isValid = true;
	if(compareDate(begindate,begintime,enddate,endtime) == 1){
		Dialog.alert(errormsg);
		isValid = false;
	}
	return isValid;
}

/*Check Date */
function compareDate(date1,time1,date2,time2){

	var ss1 = date1.split("-",3);
	var ss2 = date2.split("-",3);

	date1 = ss1[1]+"-"+ss1[2]+"-"+ss1[0] + " " +time1;
	date2 = ss2[1]+"-"+ss2[2]+"-"+ss2[0] + " " +time2;

	var t1,t2;
	t1 = Date.parse(date1);
	t2 = Date.parse(date2);
	if(t1==t2) return 0;
	if(t1>t2) return 1;
	if(t1<t2) return -1;

    return 0;
}

function ItemCount_KeyPress_Plus()
{
	if(!(window.event.keyCode >= 48 && window.event.keyCode <= 57))
	{
		window.event.keyCode = 0;
	}
}
</script>

</body>
<script language="javascript">

//会议选择框,判断是否存在自定义会议地点
function CheckOnShowAddress(){
	 if($('#customizeAddress').length>0&&$('#customizeAddress').val()!=""){
	 	window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(82885, user.getLanguage())%>",function(){
	 		onShowAddress();	
	 	});
	 }else{
	 	onShowAddress();	
	 }
}
//打开会议室选择框
function onShowAddress(){
	var url = "/systeminfo/BrowserMain.jsp?url=/meeting/Maint/MeetingRoomBrowser.jsp";
	showBrwDlg(url, "", 500,570,"addressspan","address","addressChgCbk");
}
//会议室回写处理
function addressChgCbk(datas){
	if (datas != null) {
		closeBrwDlg();
		if (wuiUtil.getJsonValueByIndex(datas, 0) != "" && wuiUtil.getJsonValueByIndex(datas, 0) != "0") {

			var resourceids = wuiUtil.getJsonValueByIndex(datas, 0);
			var resourcename = wuiUtil.getJsonValueByIndex(datas, 1);
			
			jQuery("#addressspan").html(resourcename);
			jQuery("#address").val(resourceids);
		} else {
 			jQuery("#addressspan").html("");
			jQuery("#address").val("");
		}
		_writeBackData("address",2,{id:jQuery("#address").val(),name:"<a href='/meeting/Maint/MeetingRoom_list.jsp?id="+jQuery("#address").val()+"' target='_new' > "+jQuery("#addressspan").html()+"</a>"},{
			hasInput:true,
			replace:true,
			isSingle:true,
			isedit:true
		});
	}
	addressCallBack();
}
//会议室选择和填写后方法处理
function addressCallBack(){
	if($("#address").val()!=''){
		if($('#customizeAddress').length>0){
			$('#customizeAddress').val("")
		}
	}
	checkaddress();
}
//填写自定义会议室时,检测是否选择了会议地点 
function omd(){
      /*
	  var address = $("#address").val();
	  if(address!=''){
	  	window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(82885, user.getLanguage())%>",function(){
	  		$("#address").val("");
	  		$("#addressspan").html("");
	  		$("#addressspanimg").html("<img src='/images/BacoError_wev8.gif' align='absmiddle'>");
	  		checkaddress();
	  		$('#customizeAddress').focus();
	  	});
	  }
      */
}

//改变会议地点和自定义会议地点的必填标识
function checkaddress(){
	var address = $("#address").val();
	var customizeAddress=$('#customizeAddress').length>0?$('#customizeAddress').val():'';
	if(address!=''||customizeAddress!=''){
		$("#addressspanimg").html("");
		if($('#customizeAddress').length>0){
			$("#customizeAddressspan").html("");
		}
	}else{
		$("#addressspanimg").html("<img src='/images/BacoError_wev8.gif' align='absmiddle'>");
		if($('#customizeAddress').length>0){
			$("#customizeAddressspan").html("<img src='/images/BacoError_wev8.gif' align='absmiddle'>");
		}
	}
}

//修改会议重复模式
function changeRepeatType(){
	var thisvalue=jQuery("#repeatType").val();
	$('div[name="repeatTypeDiv"]').hide();
	$('#repeatType'+thisvalue).show(); 
}

//会议类型变更
function showMeetingType(){
	var meetingtype = jQuery("#meetingtype").val();
	if(meetingtype != "" && meetingtype != null){
		window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(32143,user.getLanguage())%>", function (){
					meetingTypeChange();	
		});
	} else {
		meetingTypeChange();
	}
}

//重置与会议类型相关的内容
function meetingTypeChange(){
	onShowMeetingType("meetingtypespan","meetingtype",0,1,"meetingTypeChgCbk","<%=isInterval%>");
	
}
//回写会议类型,刷新页面
function meetingTypeChgCbk(datas){
	if (datas != null) {
		callBackValue(datas,"meetingtypespan","meetingtype");
		$("#weaver").attr("action", "/meeting/modify/MeetingModifyPage.jsp");
		$("#weaver").submit();
	}
}

//重置与会议类型相关的内容
function meetingReset(event,datas,name){
	if (datas != null) {
		$("#weaver").attr("action", "/meeting/modify/MeetingModifyPage.jsp");
		$("#weaver").submit();
	}
}

function forbiddenPage(){  
    window.parent.forbiddenPage();
}  

function releasePage(){  
    window.parent.releasePage();
}

function btn_cancle(){
	parent.closeDialog();
}

jQuery(document).ready(function(){
	onRemindType();
	if(jQuery("#repeatType").val() != "0"){
		changeRepeatType();
	}
	resizeDialog(document);
	checkaddress();
	removeSourceCheck();
	
	//lq 2015-9-4 会议地点选择
	//获取select值 隐藏文本框 
	var selval = $('#addressselect').val();	
	if(selval == 0){
		$('#my_customizeAddress').parent().parent().css('display','none');
	}else if(selval == 1){
		$('#my_address').parent().parent().css('display','none');
	}
	
	//绑定选择框 改变事件
	$('#addressselect').change(function(){ 
		//获取selected的值 
		var p1=$(this).children('option:selected').val();
		
		if(p1 == 0){
			//选择 内部会议
				
			//修改google来浏览器显隐 样式改变问题 by lq 2015-10-22
			$('#my_customizeAddress').parent().parent().hide();
			$('#my_address').parent().parent().show();
						
			//jQuery("#customizeAddress").val("");
			checkaddress();
			
		}else if(p1 == 1){
			//选择 外部会议
			
			//修改google来浏览器显隐 样式改变问题 by lq 2015-10-22
			$('#my_customizeAddress').parent().parent().show();
			$('#my_address').parent().parent().hide();
			//jQuery("#addressspan").html("");
			//jQuery("#address").val("");
			checkaddress();
		}
		
	}) 
	//判断外来人员是否有人员，查询人员信息 start
	var outHumIds = "<%=othermembers %>";
	debugger;
	if(outHumIds){		
		jQuery.ajax({ 
			url: "/weavernorth/meeting/AjaxOutHumInfo.jsp?outHumIds="+outHumIds, 
			context: document.body, 
			async: "false",
			dataType: "json",
			success: function(data){
				debugger;
				var otherMembers = jQuery("#othermembers");
				var otherMembersSpan = jQuery("#othermembersspan");
				if(data && data.result == "true"){						
					otherMembersSpan.html(data.msg);						
				}else{
					othermembers.html("");
				}							
			}
		});	
	}
	//判断外来人员是否有人员，查询人员信息 end
});
//显示和隐藏 提醒时间控制
function onRemindType(){
	if($('#remindTypeNew').val()==''){
		hideEle("remindtimetr", true);
	}else{
		showEle("remindtimetr", true);
	}
}
//查看会议室使用情况,传递开始日期
function showRoomsWithDate(){
	var begindate="<%=isInterval%>" == "1"?$('#repeatbegindate').val():$('#begindate').val();
	if(window.top.Dialog){
		var diag = new window.top.Dialog();
	} else {
		diag = new Dialog();
	}
	diag.currentWindow = window;
	diag.Width = 1100;
	diag.Height = 550;
	diag.Modal = true;
	diag.maxiumnable = true;
	diag.Title = "<%=SystemEnv.getHtmlLabelName(15881,user.getLanguage())%>";
	diag.URL = "/meeting/report/MeetingRoomPlan.jsp?currentdate="+begindate;
	diag.show();
}

//lq  会议共享  选择共享人员browser地址 2015-10-13
function getBrowserUrlFn(){
	return "/systeminfo/BrowserMain.jsp?url=/hrm/resource/MutiResourceBrowser.jsp?resourceids="+jQuery("#relatedshareid").val();
}
function setRelatedName(e,datas,name,params){
	if(datas){
		jQuery("#showrelatedsharename").val(datas.name);
	}
}
//获取二维码
function showQRCode(){
	//判断当前选择的是内部会议室还是外部会议室
	var selectVal = jQuery("#addressselect").val();
	//alert(selectVal);
	var inputVal = "";
	if(selectVal){
		if(selectVal == "0"){
			//内部会议室
			inputVal = jQuery("#address").val();
			//inputVal = jQuery("#addressspan span a").attr('title');
		}else if(selectVal == "1"){
			//外部会议室			
			inputVal = jQuery("#customizeAddress").val();
		}else{
			Dialog.alert("未获取会议室信息，请选择（填写）会议室！");
		}
		
	}else{
		Dialog.alert("未获取会议室信息，请选择（填写）会议室！");
	}
	
	if(inputVal && inputVal!=""){
		//获取相应文本内容	
		//Dialog.alert("inputVal:"+inputVal);		
		//传递参数到jsp页面生成jpg显示		
		if(window.top.Dialog){
			var diag = new window.top.Dialog();
		} else {
			diag = new Dialog();
		}
		diag.currentWindow = window;
		diag.Width = 800;
		diag.Height = 550;
		diag.Modal = true;
		diag.maxiumnable = true;
		diag.Title = "二维码";
		if(selectVal == "0"){
			//内部会议室
			diag.URL = "/weavernorth/meeting/AjaxQRCode.jsp?selectVal="+selectVal+"&meetingRoomId="+inputVal+"&meetingName=";
			//alert(diag.URL);
			diag.show();
		}else if(selectVal == "1"){
			//外部会议室
			diag.URL = "/weavernorth/meeting/AjaxQRCode.jsp?selectVal="+selectVal+"&meetingRoomId=&meetingName="+inputVal;
			//alert(diag.URL);
			diag.show();
		}else{
			Dialog.alert("获取会议室信息失败，请联系管理员！");
		}		
		
	}else{
		Dialog.alert("未获取会议室信息，请先选择（填写）会议室！");
	}
	
}

//会议通知抄送人
function getCcmeetingnoticeHtml(){
	var hrmIds = $('#ccmeetingnotice').val();	
	var html = $('#ccmeetingnoticespan').html();
	//if(html.indexOf("</span>")==-1){
		//判断是否获取选择人员id
		if(hrmIds){
			//人员新选择，执行jsp替换相关内容			
			jQuery.ajax({ 
				url: "/weavernorth/meeting/AjaxGetHumHtml.jsp?hrmIds="+hrmIds, 
				context: document.body, 
				async: "false",
				dataType: "json",
				success: function(data){
					debugger;				
					if(data && data.result == "true"){
						reHtml = data.msg;
						$('#ccmeetingnoticespan').html(reHtml);						
					}							
				}
			});
		}
	//}
}

//会议通知抄送人
function getCcmeetingminutesHtml(){
	var hrmIds = $('#ccmeetingminutes').val();	
	var html = $('#ccmeetingminutesspan').html();
	//if(html.indexOf("</span>")==-1){
		//判断是否获取选择人员id
		if(hrmIds){
			//人员新选择，执行jsp替换相关内容			
			jQuery.ajax({ 
				url: "/weavernorth/meeting/AjaxGetHumHtml.jsp?hrmIds="+hrmIds, 
				context: document.body, 
				async: "false",
				dataType: "json",
				success: function(data){
					debugger;				
					if(data && data.result == "true"){
						reHtml = data.msg;
						$('#ccmeetingminutesspan').html(reHtml);						
					}							
				}
			});
		}
	//}
}


function showOutHrmInfoById(hrmId) {
	//alert(hrmId);
	if(hrmId){
		var url = "/weavernorth/meeting/ShowOutHumInfo.jsp?1=1&outHrmId="+hrmId;	
		//openDialog("外来人员信息",url);
		var dlg=new window.top.Dialog();//定义Dialog对象
	    dlg.currentWindow = window;
		dlg.Model=true;
		dlg.Width=450;
		dlg.Height=100;
		dlg.URL=url;
		dlg.Title="外来人员信息";
		dlg.show();
	}
	
}
</script>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<SCRIPT language="javascript" src="/js/selectDateTime_wev8.js"></script>
</html>