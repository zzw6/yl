
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="org.json.JSONObject"%>
<%@page import="weaver.meeting.util.html.HtmlUtil"%>
<%@page import="weaver.meeting.MeetingShareUtil"%> 
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ page import="weaver.general.IsGovProj" %>
<%@ page import="weaver.file.FileUpload" %>
<%@page import="java.net.URLEncoder" %>
<%@page import="weaver.meeting.defined.MeetingFieldManager"%>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ page import="weaver.file.Prop"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>
<jsp:useBean id="meetingUtil" class="weaver.meeting.MeetingUtil" scope="page"/>
<jsp:useBean id="meetingSetInfo" class="weaver.meeting.Maint.MeetingSetInfo" scope="page"/>
<jsp:useBean id="ManageDetachComInfo" class="weaver.hrm.moduledetach.ManageDetachComInfo" scope="page" /> 
<jsp:useBean id="MeetingFieldComInfo" class="weaver.meeting.defined.MeetingFieldComInfo" scope="page"/>
<jsp:useBean id="MeetingFieldGroupComInfo" class="weaver.meeting.defined.MeetingFieldGroupComInfo" scope="page"/>
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page" />
<%
//获得当前的日期和时间
Calendar today = Calendar.getInstance();
String currentdate = Util.add0(today.get(Calendar.YEAR), 4) + "-" +
                     Util.add0(today.get(Calendar.MONTH) + 1, 2) + "-" +
                     Util.add0(today.get(Calendar.DAY_OF_MONTH), 2) ;
FileUpload fu = new FileUpload(request);
char flag=Util.getSeparator() ;
//获取外来人员显示页面id
String outHumShowPageId = BaseBean.getPropValue("meeting", "outHumShowPageId");
BaseBean.writeLog("outHumShowPageId:"+outHumShowPageId);
//是否新建周期会议
int isInterval = Util.getIntValue(fu.getParameter("isInterval"), 0);
String meetingtype = Util.null2String(fu.getParameter("meetingtype"));
//lq 检查会议类型 议程是否必填

int isagenda = 0;
String isTickling = "";
if(!"".equals(meetingtype)){
	RecordSet.executeSql("select isagenda,isTickling from Meeting_Type where id="+meetingtype);
	if(RecordSet.next()){
		isagenda = RecordSet.getInt("isagenda");
		isTickling = Util.null2String(RecordSet.getString("isTickling")) ;
	}
}


String address = Util.null2String(fu.getParameter("roomid"));
if("".equals(address)){
	address = Util.null2String(fu.getParameter("address"));
}
String begindate = Util.null2String(fu.getParameter("begindate"));
if("".equals(begindate)){
	begindate = Util.null2String(fu.getParameter("startdate"));
}
String enddate = Util.null2String(fu.getParameter("enddate"));
String begintime = Util.null2String(fu.getParameter("begintime"));
if("".equals(begintime)){
	begintime = Util.null2String(fu.getParameter("starttime"));
}
String endtime = Util.null2String(fu.getParameter("endtime"));
String repeatbegindate = Util.null2String(fu.getParameter("repeatbegindate"));
String repeatenddate = Util.null2String(fu.getParameter("repeatenddate"));

if(begindate.compareTo(currentdate)<0){
	begindate=currentdate;
}
if(enddate.compareTo(currentdate)<0){
	enddate=currentdate;
}
boolean isUseMtiManageDetach=ManageDetachComInfo.isUseMtiManageDetach();
if(isUseMtiManageDetach){
   session.setAttribute("detachable","1");
   session.setAttribute("meetingdetachable","1");
}else{
   session.setAttribute("detachable","0");
   session.setAttribute("meetingdetachable","0");
}
String f_weaver_belongto_userid=""+user.getUID();//操作用户
//上传目录和大小限制
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
String caller="";
//生成召集人的where子句
int ishead=0 ;
int isset=0;//是否有设置召集人标识，0没有，1有
String hrmids="";//参会人员
String crmids="";//参会客户
int hrmCnt=0;//参会人员数
int crmCnt=0;//参会客户数
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
	
	
	
	//参会人员
	String[] membersArry  = meetingUtil.getMeetingHrmMembers(meetingtype);
	if(membersArry != null && membersArry.length > 0){
		for(String memberid:membersArry){
			String status=ResourceComInfo.getStatus(memberid);
			if(!status.equals("0")&&!status.equals("1")&&!status.equals("2")&&!status.equals("3"))
				continue;
			hrmids +="".equals(hrmids)?memberid:","+memberid;
			hrmCnt++;
		}
	}
	//参会客户 	  
	RecordSet.executeProc("Meeting_Member_SelectByType",meetingtype+flag+"2");
	while(RecordSet.next()){
		crmCnt++;
		crmids +="".equals(crmids)?RecordSet.getString("memberid"):","+RecordSet.getString("memberid");
	}	
	
	//召集人查询条件
	if(!whereclause.equals("where ( ") && whereclause.length() > 5){  
		whereclause+=" )" ;
		qswhere=whereclause.substring(5) ;
		RecordSet.execute("select t1.id from hrmresource t1,hrmdepartment t2 where t1.departmentid = t2.id and (t1.status = 0 or t1.status = 1 or t1.status = 2 or t1.status = 3) and "+qswhere);
		if(RecordSet.getCounts()==1){
			if(RecordSet.next()){
				caller=RecordSet.getString("id");
			}
		}
	}
	
	//会议类型有创建权限的人
	f_weaver_belongto_userid=MeetingShareUtil.getTypeUserPermission(meetingtype,user);
}

//lq 判断 当前用户是否是可以创建 议会议程   开始
String isRuleManage = "0";
//判断当前人是否为有权限修改所有会议信息
if (HrmUserVarify.checkUserRight("RulesOfProcedure:Headquarters", user) ) { 

	//总部管理权限
	isRuleManage = "1";
//添加议事规则创建人员权限判断  by lq 2015-11-2	
}else if (HrmUserVarify.checkUserRight("RulesOfProcedure:Division", user) || HrmUserVarify.checkUserRight("RulesOfProcedure:Create", user) ) { 
	//分部管理权限
	isRuleManage = "2";
}else{
	isRuleManage = "0";
}

System.out.println("isRuleManage:"+isRuleManage);
//lq 判断 当前用户是否是可以创建 议会议程   结束
%>

<HTML><HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<script language="javascript" src="/wui/theme/ecology8/jquery/js/zDialog_wev8.js"></script>
<script language="javascript" src="/wui/theme/ecology8/jquery/js/zDrag_wev8.js"></script>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<link rel="stylesheet" href="/css/ecology8/request/requestTopMenu_wev8.css" type="text/css" />
<link rel="stylesheet" href="/wui/theme/ecology8/jquery/js/zDialog_e8_wev8.css" type="text/css" />
<script language=javascript src="/js/ecology8/request/e8.browser_wev8.js"></script>
<script language=javascript src="/js/weaver_wev8.js"></script>

<link href="/js/swfupload/default_wev8.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/js/swfupload/swfupload_wev8.js"></script>
<script type="text/javascript" src="/js/swfupload/swfupload.queue_wev8.js"></script>
<script type="text/javascript" src="/js/swfupload/fileprogressBywf_wev8.js"></script>
<script type="text/javascript" src="/js/swfupload/handlersBywf_wev8.js"></script>
<script type="text/javascript" src="/js/ecology8/meeting/meetingswfupload_wev8.js"></script>

</HEAD>
<%
int isgoveproj = Util.getIntValue(IsGovProj.getPath(),0);//0:非政务系统，1：政务系统
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(82,user.getLanguage())+":"+SystemEnv.getHtmlLabelName(2103,user.getLanguage());
String needfav ="1";
String needhelp ="";
int topicrows=0;
int servicerows=0;
int topicAttachrows=0;

String needcheck="";

%>
<BODY style="overflow: hidden;">
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(220,user.getLanguage())+",javascript:doSave(this),_self} " ;
RCMenuHeight += RCMenuHeightStep ;
RCMenu += "{"+SystemEnv.getHtmlLabelName(615,user.getLanguage())+",javascript:doSubmit(this),_self} " ;
RCMenuHeight += RCMenuHeightStep ;

%>	
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan"
			style="text-align: right; width: 400px !important">
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(220,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doSave(this)"/>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(615,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doSubmit(this)"/>
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

<FORM id=weaver name=weaver action="/meeting/data/MeetingOperation.jsp" method=post>
<input class=inputstyle type="hidden" name="method" value="add">
<input class=inputstyle type="hidden" name="topicrows" value="0">
<input class=inputstyle type="hidden" name="topicAttachrows" value="0">
<input class=inputstyle type="hidden" name="servicerows" value="0">
<input class=inputstyle type="hidden" name="isInterval" id="isInterval" value="<%=isInterval %>">
<INPUT type="hidden" id="f_weaver_belongto_userid" name="f_weaver_belongto_userid" value="">
<INPUT type="hidden" id="isagenda" name="isagenda" value="<%=isagenda %>"><!--标识  会议议程是否填写 -->
<INPUT type="hidden" id="rulesOfProcedure" name="rulesOfProcedure" value="0"><!--标识  是否是议会规则-->
<INPUT type="hidden" id="isRuleManage" name="isRuleManage" value="<%=isRuleManage %>"><!--标识  议会规则管理员类型-->

<%if(isInterval != 1) {%>
<input  type="hidden" name="repeatType" id="repeatType" value="0">
<%} %>
<div id="nomalDiv">
<wea:layout type="2col">
<%
//获取 补充参会人员 字段名称 
String fieldname1 = Util.null2String(Prop.getPropValue("meeting", "fieldname1"));
    
//遍历分组
MeetingFieldManager hfm = new MeetingFieldManager(1);
List<String> groupList=hfm.getLsGroup();
List<String> fieldList=null;
for(String groupid:groupList){
	fieldList= hfm.getUseField(groupid);
	if(fieldList!=null&&fieldList.size()>0){		
%>
<wea:group context="<%=SystemEnv.getHtmlLabelName(Util.getIntValue(MeetingFieldGroupComInfo.getLabel(groupid)), user.getLanguage()) %>" attributes="{'groupDisplay':''}">
	<%for(String fieldid:fieldList){
		if(isInterval == 1) {//周期会议
			if("0".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}else{//非周期会议
			if("1".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}
		
		String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
		int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
		int fieldhtmltype = Integer.parseInt(MeetingFieldComInfo.getFieldhtmltype(fieldid));
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
		String fieldVaule="";
		String extendHtml="";
		//上传附件,设置上次目录
		if(fieldhtmltype==6){
			cfg.put("mainId",mainId);
			cfg.put("subId",subId);
			cfg.put("secId",secId);
			cfg.put("maxsize",maxsize);
		}
		if("meetingtype".equalsIgnoreCase(fieldname)){//会议类型
			fieldVaule=meetingtype;
			if(!"".equals(meetingtype)){
				cfg.put("hasInput","false");  
			}
			cfg.put("getBrowserUrlFn","showMeetingType"); 
			cfg.put("callback","meetingReset");
		}else if("address".equalsIgnoreCase(fieldname)){//会议地点
			fieldVaule=address;
			cfg.put("getBrowserUrlFn","CheckOnShowAddress"); 
			cfg.put("width","60%");
			extendHtml="<div class=\"FieldDiv\" id=\"selectRoomdivb\" name=\"selectRoomdivb\" style=\"margin-left:10px;margin-top: 3px;float:left;\">"+
							"<A href=\"javascript:showRoomsWithDate();\" style=\"color:blue;\">"+SystemEnv.getHtmlLabelName(2193,user.getLanguage())+"</A>"+
						"</div>";
						
			extendHtml+="<div class=\"FieldDiv\" id=\"znpp\" name=\"znpp\" style=\"margin-left:10px;margin-top: 3px;float:left;\">"+
							"<A href=\"javascript:showMeetingRoom();\" style=\"color:blue;\">智能匹配</A>"+
						"</div>";	
			extendHtml+="<div class=\"FieldDiv\" id=\"znpp\" name=\"znpp\" style=\"margin-left:10px;margin-top: 3px;float:left;\">"+
							"<A href=\"javascript:showQRCode();\" style=\"color:blue;\">获取二维码</A>"+
						"</div>";	
						
			cfg.put("callback","addressCallBack");
		}else if("customizeAddress".equalsIgnoreCase(fieldname)){//会议地点
			 
		}else if("begindate".equalsIgnoreCase(fieldname)){//开始日期
			fieldVaule=begindate;
			cfg.put("minDate",currentdate);
		}else if("begintime".equalsIgnoreCase(fieldname)){//开始时间
			fieldVaule=begintime;
		}else if("enddate".equalsIgnoreCase(fieldname)){//结束日期
			fieldVaule=enddate;
			cfg.put("minDate",currentdate);
		}else if("endtime".equalsIgnoreCase(fieldname)){//结束时间
			fieldVaule=endtime;
		}else if("caller".equalsIgnoreCase(fieldname)){//召集人,添加查询条件
			fieldVaule=caller;
			if(isset==1){
				cfg.put("browserUrl","/systeminfo/BrowserMain.jsp?url=/meeting/data/CallerBrowser.jsp?meetingtype="+meetingtype);
				cfg.put("completeUrl","/data.jsp?type=meetingCaller&meetingtype="+meetingtype);
			}
			//人员链接修改 2017-1-14
			cfg.put("callback","getCallerHtml");
		}else if("repeatType".equalsIgnoreCase(fieldname)){//重复模式,添加change事件
			cfg.put("func","changeRepeatType()");
		}else if("hrmmembers".equalsIgnoreCase(fieldname)){//参会人员
			fieldVaule=hrmids;
			//cfg.put("callback","countAttend");
			cfg.put("callback","getHrmmembersHtml");
			
		}else if("cost".equalsIgnoreCase(fieldname)){//会议成本
			fieldVaule="0";
			cfg.put("width","60px");			
		}else if("totalmember".equalsIgnoreCase(fieldname)){//参会人员数
			fieldVaule=""+hrmCnt;
		}else if("crmmembers".equalsIgnoreCase(fieldname)){//参会客户
			fieldVaule=crmids;
			cfg.put("callback","countAttendCRM");
		}else if("crmtotalmember".equalsIgnoreCase(fieldname)){//参会客户数
			fieldVaule=""+crmCnt;
		}else if("remindTypeNew".equalsIgnoreCase(fieldname)){//默认提醒方式
			fieldVaule="";//"2,3,5";
			cfg.put("callback","onRemindType");
		}else if("contacter".equalsIgnoreCase(fieldname)){//联系人
			fieldVaule=""+user.getUID();
		}else if("repeatbegindate".equalsIgnoreCase(fieldname)){
			fieldVaule=repeatbegindate;
		}else if("repeatenddate".equalsIgnoreCase(fieldname)){
			fieldVaule=repeatenddate;
		}else if(fieldname1.equalsIgnoreCase(fieldname)){
			//过滤补充参会人员
			continue;
		}else if("recorder".equalsIgnoreCase(fieldname)){
			//记录人
			//人员链接修改 2017-1-14
			cfg.put("callback","getRecorderHtml");
		}else if("ccmeetingnotice".equalsIgnoreCase(fieldname)){
			//会议通知抄送人
			//人员链接修改 2017-1-14
			cfg.put("callback","getCcmeetingnoticeHtml");
		}else if("ccmeetingminutes".equalsIgnoreCase(fieldname)){
			//会议纪要抄送人
			//人员链接修改 2017-1-14
			cfg.put("callback","getCcmeetingminutesHtml");
		}
		
		if("remindHoursBeforeStart".equalsIgnoreCase(fieldname)||"remindTimesBeforeStart".equalsIgnoreCase(fieldname)
				||"remindHoursBeforeEnd".equalsIgnoreCase(fieldname)||"remindTimesBeforeEnd".equalsIgnoreCase(fieldname)
				||"repeatweeks".equalsIgnoreCase(fieldname)||"rptWeekDays".equalsIgnoreCase(fieldname)
				||"repeatmonths".equalsIgnoreCase(fieldname)||"repeatmonthdays".equalsIgnoreCase(fieldname))
			continue;
		
		//提醒时间特殊处理			
		if("remindBeforeStart".equals(fieldname)){
			if(!"".equals(meetingtype)){
	%>	
		<wea:item attributes="{'samePair':'remindtimetr'}">
		<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item attributes="{'samePair':'remindtimetr'}">
			<div style="float:left;">
				<%=HtmlUtil.getHtmlElementString(fieldVaule,cfg,user)%>
				&nbsp;&nbsp;<span><%=SystemEnv.getHtmlLabelName(19784,user.getLanguage())%></span>
				<%=HtmlUtil.getHtmlElementString("0",hfm.getFieldConf("25"),user)%>
				<span><%=SystemEnv.getHtmlLabelName(391,user.getLanguage())%></span>
				<%=HtmlUtil.getHtmlElementString("10",hfm.getFieldConf("26"),user)%>
				<span><%=SystemEnv.getHtmlLabelName(15049,user.getLanguage())%></span>
			</div>
		</wea:item>	
	<%		
			}
		}else if("remindBeforeEnd".equals(fieldname)){
			if(!"".equals(meetingtype)){
	%>	
		<wea:item attributes="{'samePair':'remindtimetr'}">
		<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item attributes="{'samePair':'remindtimetr'}">
			<div style="float:left;">
				<%=HtmlUtil.getHtmlElementString(fieldVaule,cfg,user)%>
				&nbsp;&nbsp;<span><%=SystemEnv.getHtmlLabelName(19785,user.getLanguage())%></span>
				<%=HtmlUtil.getHtmlElementString("0",hfm.getFieldConf("27"),user)%>
				<span><%=SystemEnv.getHtmlLabelName(391,user.getLanguage())%></span>
				<%=HtmlUtil.getHtmlElementString("10",hfm.getFieldConf("28"),user)%>
				<span><%=SystemEnv.getHtmlLabelName(15049,user.getLanguage())%></span>
			</div>
		</wea:item>	
	<%	
			}
		}else if("remindImmediately".equalsIgnoreCase(fieldname)){
			if(!"".equals(meetingtype)){
	%>	
		<wea:item attributes="{'samePair':'remindtimetr1'}">
		<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item attributes="{'samePair':'remindtimetr1'}">
			<%=HtmlUtil.getHtmlElementString(fieldVaule,cfg,user)%>
		</wea:item>	
	<%		 
			}
		}else if("repeatdays".equalsIgnoreCase(fieldname)){//重复会议时间处理
			if(!"".equals(meetingtype)){
	%>	
		<wea:item>
			<%=SystemEnv.getHtmlLabelName(25898,user.getLanguage())%>
		</wea:item> 
		<wea:item>
			<div id="repeatType1" style="display:none" name="repeatTypeDiv">
				<%=SystemEnv.getHtmlLabelName(21977,user.getLanguage())%>&nbsp;
			    <%=HtmlUtil.getHtmlElementString("1",cfg,user)%>
				 &nbsp;<%=SystemEnv.getHtmlLabelName(1925,user.getLanguage())%>
			</div>
			<div id="repeatType2" style="display:none"  name="repeatTypeDiv">
				<%=SystemEnv.getHtmlLabelName(21977,user.getLanguage())%>&nbsp;
			    <% out.println(HtmlUtil.getHtmlElementString("1",hfm.getFieldConf("10"),user));%>
			    &nbsp;<%=SystemEnv.getHtmlLabelName(1926,user.getLanguage())%><br>
			 	<%out.println(HtmlUtil.getHtmlElementString("",hfm.getFieldConf("11"),user));%>
			</div>
			<div id="repeatType3" style="display:none"  name="repeatTypeDiv">
				<%=SystemEnv.getHtmlLabelName(21977,user.getLanguage())%>&nbsp;
			    <%out.println(HtmlUtil.getHtmlElementString("1",hfm.getFieldConf("12"),user));%>
			    &nbsp;<%=SystemEnv.getHtmlLabelName(25901,user.getLanguage())%>&nbsp;
			 	<%out.println(HtmlUtil.getHtmlElementString("1",hfm.getFieldConf("13"),user));%>
			 	&nbsp;<%=SystemEnv.getHtmlLabelName(1925,user.getLanguage())%>
			</div>
		</wea:item>	
	<%	
			}
	}else{
		String htmElementString = "";
		
		if("meetingtype".equals(fieldname)){
			htmElementString = HtmlUtil.getHtmlElementString(fieldVaule,cfg,user);
		}else{
			if("".equals(meetingtype)){
				htmElementString = HtmlUtil.getHtmlElementString(fieldVaule,cfg,null);
			}else{
				htmElementString = HtmlUtil.getHtmlElementString(fieldVaule,cfg,user);
			}
		}
		
		//lq 议事规则
		if("meetingtype".equals(fieldname) && (isRuleManage.equals("1") || isRuleManage.equals("2"))){
			extendHtml = "<div>&nbsp;&nbsp;&nbsp;&nbsp;<input type='checkbox' id='isRulesOfProcedure' /> <span style=\"color:red\">议事规则</span></div>";
		}else
		if("hrmmembers".equals(fieldname)){
			extendHtml = extendHtml="<div class=\"FieldDiv\" id=\"hrmMeetingState\" name=\"hrmMeetingState\" style=\"margin-left:10px;margin-top: 3px;float:left;\">"+
							"<A href=\"javascript:showMeetingByHrm();\" style=\"color:blue;\">"+"相关会议"+"</A>"+
						"</div>";
		}else if("address".equals(fieldname)){
			htmElementString = "<span id=\"my_address\">"+htmElementString+"</span>";
			//address customizeAddress addressselect
		}else if("customizeAddress".equals(fieldname)){
			String extendHtml1 ="<div class=\"FieldDiv\" id=\"znpp\" name=\"znpp\" style=\"margin-left:10px;margin-top: 3px;float:left\">"+
							"<A href=\"javascript:showQRCode();\" style=\"color:blue;\">获取二维码</A>"+
						"</div>";
			//htmElementString = "<span id=\"my_customizeAddress\" style=\"float:left;width:70%\">"+htmElementString+extendHtml1+"</span>";
			//添加获取二维码
			htmElementString = "<table id=\"my_customizeAddress\" style=\"width:70%\"><tr style=\"width:100%\"><td style=\"width:80%\"><span >"+htmElementString+"</td><td>"+extendHtml1+"</td></tr></table>";				
		}
		//创建人只读 by lq 2015-11-2 start
		else if("contacter".equalsIgnoreCase(fieldname)){//创建人 为当前用户 不能编辑
			htmElementString = "<div style=\"display:none\">"+htmElementString+"</div>";
			//extendHtml = "<A href=\"/hrm/resource/HrmResource.jsp?id="+user.getUID()+"\" target=_blank>"+user.getLastname()+"</A>";	
			//点击链接修改 2017-1-17	
			extendHtml = "<a onclick=\"pointerXY(event);\" href=\"javaScript:openhrm("+user.getUID()+");\">"+user.getLastname()+"</a>";
		}
		//创建人只读 by lq 2015-11-2 end
		//成本统计为只读 by lq 2015-10-21 start
		else if("cost".equals(fieldname)){			
			
			//隐藏原成本统计的输入框
			htmElementString = "<div id=\"costDiv\" style=\"display:none\">"+htmElementString+"</div>";
			//添加span用来显示数字
			extendHtml = "<span id=\"costSpan\">0</span>";
		}else if("isAppraise".equals(fieldname)){	
			if("1".equals(isTickling)){
				//隐藏原成本统计的输入框
				htmElementString = "<div id=\"isAppraiseDiv\" style=\"display:none\">"+htmElementString+"</div>";
				//添加span用来显示数字
				extendHtml = "<span id=\"isAppraiseSpan\">是</span>";
			}
		}else if("othermembers".equalsIgnoreCase(fieldname)){//其他参会人员
		
			extendHtml+="<div class=\"FieldDiv\" id=\"znpp\" name=\"znpp\" style=\"margin-left:10px;margin-top: 3px;float:left;\">"+
							"<A href=\"javascript:addOtherHum();\" style=\"color:blue;\">外来人员录入</A>"+
						"</div>";
			String outHtml = "";
			
  outHtml += "<span id=\"my_othermembers\"><span id=\"othermembers_span\" class=\"browser\">"; 
  outHtml += "  <div style=\"WIDTH: 80%\" class=\"e8_os\"> ";
  outHtml += "   <div style=\"MAX-HEIGHT: 2200px\" class=\"e8_innerShow e8_innerShow_button\">";
  outHtml += "    <span class=\"e8_spanFloat\"><span class=\"e8_browserSpan\"><button id=\"othermembers_browserbtn\" class=\"e8_browflow\" onclick=\"selectOutHum();\" type=\"button\"></button></span></span>";
  outHtml += "   </div> ";
  //叹号图片
  outHtml += "   <div class=\"e8_innerShow e8_innerShowMust\">";
  //outHtml += "    <span id=\"othermembersspanimg\" class=\"e8_spanFloat\" name=\"othermembersspanimg\"><img align=\"absMiddle\" src=\"/images/BacoError_wev8.gif\" /></span>";
  outHtml += "   </div> ";
  outHtml += "   <div style=\"WIDTH: 100%; MARGIN-RIGHT: -30px\" id=\"outothermembersdiv\" class=\"e8_outScroll\" >"; 
  outHtml += "   <div hidefocus=\"\" style=\"OVERFLOW-Y: hidden; MAX-HEIGHT: 2200px; MARGIN-RIGHT: 30px\" id=\"innerContentothermembersdiv\" class=\"e8_innerShow e8_innerShowContent\" tabindex=\"5004\" >"; 
  outHtml += "     <div style=\"MARGIN-LEFT: 31px\" id=\"innerothermembersdiv\" hasbrowser=\"true\" hasadd=\"false\">";
  outHtml += "      <input onpropertychange=\"\" id=\"othermembers\" type=\"hidden\" name=\"othermembers\" temptitle=\"\" viewtype=\"0\" ismustinput=\"2\" issingle=\"true\" />";
  outHtml += "     <span style=\"FLOAT: none\" id=\"othermembersspan\" name=\"othermembersspan\"></span> ";
  outHtml += "     </div>";
  outHtml += "    </div>";
  outHtml += "   </div>";
  outHtml += "  </div>";
  outHtml += "</span> ";
  outHtml += "</span>";
			htmElementString = outHtml+extendHtml;
			
			extendHtml = "";
		}
		//成本统计为只读 by lq 2015-10-21 end
		
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
	
	<div id="agendaDiv" style="display:none;">
	   	<div id="topicRowSource" style="display:none;">
	   		<div name='topicRowSourceDiv' id="topicRowSource_0" fieldName="topicChk" fieldid="0">
	   			<input name="topicChk" type="checkbox" value="1" rowIndex='#rowIndex#'>
	   		</div>
	   		<%
			//序号 排序  lq 2016-1-15 start
			
			//获取序号字段名称
			String orderNumberName = Util.null2String(Prop.getPropValue("meeting", "orderNumberName"));
			//获取序号字段名称宽度
			int orderNumberWidth = Util.getIntValue(Prop.getPropValue("meeting", "orderNumberWidth"), 0);					
			
			//序号 排序  lq 2016-1-15 end
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
	        			if("isopen".equals(fieldname)){
	        				fieldVaule = "1";
	        			}
	        			ht=HtmlUtil.getHtmlElementHashTable(fieldVaule,cfg,user);
						//排序  lq   2016-1-15  start
						//a.replace("value=\"\"", "value=\"#rowIndex#\"");
						if(orderNumberName.equals(fieldname) && !orderNumberName.equals("")){
							ht.put("inputStr",ht.get("inputStr").replace("value=\"\"", "value=\"#rowIndex#\""));
						}
						//排序  lq   2016-1-15  end 
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
            <Td class="Field" align=right>
            <%
            if(!"".equals(meetingtype)){
            %>
            	<input class="addbtn" accesskey="A" onclick="addNewRow('topic');" title="<%=SystemEnv.getHtmlLabelName(611,user.getLanguage())%>" type="button">
				<input class="delbtn" accesskey="E" onclick="deleteSelectedRow('topic');" title="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage())%>" type="button">
			<%} %>
			</Td>
          </TR>
        <TR class="Spacing" style="height:1px!important;">
          <TD class="Line1" colspan=2></TD></TR>
        <tr>
        	<td class="Field" colspan=2>
        	<%
			//从配置文件中获取 议题宽度 剩下宽度/余下列  by lq 2015-11-27 start
					
			int meetingIssueWidth = Util.getIntValue(Prop.getPropValue("meeting", "meetingIssueWidth"), 0);
			if(meetingIssueWidth ==0){
				meetingIssueWidth = 20;
			}
			//从配置文件中获取 议题宽度 剩下宽度/余下列  by lq 2015-11-27 end
			
        	for(String groupid:groupList){
        		fieldList= hfm2.getUseField(groupid);
        		
        		if(fieldList!=null&&fieldList.size()>0){
        			int colSize=fieldList.size();
					
					//减少数
					int subNum = 1;		
        			
        	%>		<table id="topicTabField" class=ListStyle  border=0 cellspacing=1>
        			  <colgroup>
        			  	<col width="3px">
						<%
						//序号 排序  lq 2016-1-15 start
						
						//判断字符名称是否存在 存在 设置序号列
						if(!orderNumberName.equals("")){
							subNum++;
							if(orderNumberWidth == 0){
								orderNumberWidth = 8;
							}	
						%>	
							<col>
						<%
						}
						
						//序号 排序  lq 2016-1-15 end
						%>
						<col width="110px">
						<col width="110px">
						<col width="110px">
        	<%		
					
					for(int i=0;i<(colSize - subNum-2);i++){
        				out.print("<col>\n");
						
        			}
        			out.println("</colgroup>\n");
        			out.println("<TR class=HeaderForXtalbe>\n");
        			out.println("<th><input name=\"topicChkAll\" tarObj=\"topicChk\" type=\"checkbox\" onclick=\"jsChkAll(this)\"></th>\n");
        		  	
        			for(String fieldid:fieldList){
        				int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
						//lq 2015-8-31 隐藏 "公开" 字段
						if(fieldlabel == 2161){
							out.println("<th style=\"display:none;\">"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
						}else{
							out.println("<th>"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
						}
        				
					
	   				}
        			out.print("</tr></table>\n"); 
        		}
        	}
        	%>         
        	</td>
        </tr>
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
        		fieldList4 = hfm4.getUseField(groupid);
        		int i=0;
        		if(fieldList4!=null&&fieldList4.size()>0){
        			topicAttachColSize = fieldList4.size()+1;
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
	        			if("isopen".equals(fieldname)){
	        				fieldVaule = "1";
	        			}
	        			ht4=HtmlUtil.getHtmlElementHashTable(fieldVaule,cfg,user);
						//排序  lq   2016-1-15  start
						//a.replace("value=\"\"", "value=\"#rowIndex#\"");
						if(orderNumberName.equals(fieldname) && !orderNumberName.equals("")){
							ht4.put("inputStr",ht4.get("inputStr").replace("value=\"\"", "value=\"#rowIndex#\""));
						}
						//排序  lq   2016-1-15  end 
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
            <Td class="Field" align=right>
            <%
            if(!"".equals(meetingtype)){
            %>
            	<input class="addbtn" accesskey="A" onclick="addNewRow('topicAttach');" title="<%=SystemEnv.getHtmlLabelName(611,user.getLanguage())%>" type="button">
				<input class="delbtn" accesskey="E" onclick="deleteSelectedRow('topicAttach');" title="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage())%>" type="button">
			<%} %>
			</Td>
          </TR>
        <TR class="Spacing" style="height:1px!important;">
          <TD class="Line1" colspan=2></TD></TR>
        <tr>
        	<td class="Field" colspan=2>
        	<%
        	for(String groupid:groupList4){
        		fieldList= hfm4.getUseField(groupid);
        		
        		if(fieldList!=null&&fieldList4.size()>0){
        			int colSize=fieldList4.size();
					
					//减少数
					int subNum = 1;		
        			
        	%>		<table id="topicAttachTabField" class=ListStyle  border=0 cellspacing=1>
        			  <colgroup>
        			  	<col width="3px">
						<%
						//序号 排序  lq 2016-1-15 start
						
						//判断字符名称是否存在 存在 设置序号列
						if(!orderNumberName.equals("")){
							subNum++;
							if(orderNumberWidth == 0){
								orderNumberWidth = 8;
							}	
						%>	
							<col>
						<%
						}
						
						//序号 排序  lq 2016-1-15 end
						%>
						<col>
        	<%		
					
					for(int i=0;i<(colSize - subNum);i++){
        				out.print("<col >\n");
        			}
        			out.println("</colgroup>\n");
        			out.println("<TR class=HeaderForXtalbe>\n");
        			out.println("<th><input name=\"topicAttachChkAll\" tarObj=\"topicAttachChk\" type=\"checkbox\" onclick=\"jsChkAll(this)\"></th>\n");
        		  	
        			for(String fieldid:fieldList4){
        				int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
						//lq 2015-8-31 隐藏 "公开" 字段
						if(fieldlabel == 2161){
							out.println("<th style=\"display:none;\">"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
						}else{
							out.println("<th>"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
						}
        				
					
	   				}
        			out.print("</tr></table>\n"); 
        		}
        	}
        	%>         
        	</td>
        </tr>
        </TBODY>
	  </TABLE>
	  <!-- end 会议议程附件 -->
	</div>
	
	<div id="serviceDiv" style="display:none;">
	   	<div id="serviceRowSource" style="display:none;">
	   		<div name='serviceRowSourceDiv' id="serviceRowSource_0" fieldName="serviceChk" fieldid="0">
	   			<input name="serviceChk" type="checkbox" value="1" rowIndex='#rowIndex#'>
	   		</div>
	   		<%
	   		int serviceColSize=1;
        	MeetingFieldManager hfm3 = new MeetingFieldManager(3);
        	groupList=hfm3.getLsGroup();
        	for(String groupid:groupList){
        		fieldList= hfm3.getUseField(groupid);
        		int i=0;
        		if(fieldList!=null&&fieldList.size()>0){
	        		serviceColSize=fieldList.size()+1;
        			for(String fieldid:fieldList){
        				i++;
						String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
	        			String fieldVaule="";
	        			String fieldhtmltype=MeetingFieldComInfo.getFieldhtmltype(fieldid);
	        			 
	        			JSONObject cfg= hfm3.getFieldConf(fieldid);
	        			cfg.put("isdetail", 1);//明细列表显示
	        			ht=HtmlUtil.getHtmlElementHashTable(fieldVaule,cfg,user);
	        %>
	       <div name='serviceRowSourceDiv' id="serviceRowSource_<%=i %>" fieldName="<%=fieldname %>" fieldid="<%=fieldid %>" fieldhtmltype="<%=fieldhtmltype %>">
	       		<%=ht.get("inputStr") %>
	       </div>
	       <%if(!"".equals(ht.get("jsStr"))){ %>
	       <div id="serviceRowSource_js_<%=i %>">
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
            <Td class="Field" align=right>
            <%
            if(!"".equals(meetingtype)){
            %>
            	<input class="addbtn" accesskey="A" onclick="addNewRow('service');" title="<%=SystemEnv.getHtmlLabelName(611,user.getLanguage())%>" type="button">
				<input class="delbtn" accesskey="E" onclick="deleteSelectedRow('service');" title="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage())%>" type="button">
			<%} %>
			</Td>
          </TR>
        <TR class="Spacing" style="height:1px!important;">
          <TD class="Line1" colspan=2></TD></TR>
        <tr>
        	<td class="Field" colspan=2>
        	<%
        	for(String groupid:groupList){
        		fieldList= hfm3.getUseField(groupid);
        		
        		if(fieldList!=null&&fieldList.size()>0){
        			int colSize=fieldList.size();
        			
        	%>		<table id="serviceTabField" class=ListStyle  border=0 cellspacing=1>
        			  <colgroup>
        			  	<col width="5%">
        	<%		for(int i=0;i<colSize;i++){
        				out.print("<col width='"+(95/colSize)+"%'>\n");
        			}
        			out.println("</colgroup>\n");
        			out.println("<TR class=HeaderForXtalbe>\n");
        			out.println("<th><input name=\"serviceChkAll\" tarObj=\"serivceChk\" type=\"checkbox\" onclick=\"jsChkAll(this)\"></th>\n");
        		  	
        			for(String fieldid:fieldList){
        				int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
        				out.println("<th>"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
	        
	   				}
        			out.print("</tr></table>\n"); 
        		}
        	}
        	%>         
        	</td>
        </tr>
        </TBODY>
	  </TABLE>
	</div>
	
	<!--会议共享 	lq  2015-10-13 开始-->
	<div id="shareDiv" style="display:none;">		
		<wea:layout type="2col" >
			<wea:group context="<%=SystemEnv.getHtmlLabelName(2112,user.getLanguage())%>">
				<wea:item>共享人员</wea:item>
				<wea:item>
					<span id="showButton" style="float:left;">
						<brow:browser viewType="1" name="relatedshareid" browserValue="" 
								browserUrl="#" getBrowserUrlFn="getBrowserUrlFn"
								hasInput="true" isSingle="false" hasBrowser = "true" isMustInput='1'
								completeUrl="/data.jsp" width="370px" _callback="setRelatedName">
						</brow:browser>
						<input type="hidden" name = "showrelatedsharename" id="showrelatedsharename"/>
					</span>
				</wea:item>
			</wea:group>
		</wea:layout>
	</div>
	<!--会议共享 	lq  2015-10-13 结束-->
</FORM>
</td>
</tr>
</TABLE>
</td>
</tr>
<tr>
<td height="10"></td>
</tr>
</table>
</div>
<div id="zDialog_div_bottom" class="zDialog_div_bottom">
	<wea:layout type="2col">
		<wea:group context="">
			<wea:item type="toolbar">

				<input type="button"
					value="<%=SystemEnv.getHtmlLabelName(309, user.getLanguage())%>"
					id="zd_btn_cancle" class="zd_btn_cancle" onclick="btn_cancle()">
			</wea:item>
		</wea:group>
	</wea:layout>
</div>
<script language="JavaScript" src="/js/addRowBg_wev8.js" >   
</script> 
<script language="JavaScript">  
$(document).ready(function(){

	countCost();
	
	//调用绑定的事件方法    
	bindchange("#begindate", countCost);
	bindchange("#begintime", countCost);
	bindchange("#enddate", countCost);
	bindchange("#endtime", countCost);
	
	$("#xiaoshi").attr("readonly",true).css("width","60px");

	setInterval(function() {
		jQuery.ajax({
			url : "/meeting/report/GetMeetingTmp.jsp",
			type : "post",
			async : false,
			processData : false,
			data : "",
			dataType : "html",
			success: function do4Success(msg){
				msg= msg.replace(/(^\s*)|(\s*$)/g, "");
				if(msg != "NoData"){
					var msgArr = msg.split("$");
					
					$('#address').val(msgArr[0]);
					$('#addressspan').html(msgArr[1]);
					countCost();
				}
			}
		});	
 	}, 1000);

	
 	
});

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

rowindex = "<%=topicrows%>";
serviceindex = "<%=servicerows%>";
attachindex = "<%=topicAttachrows%>";

function addNewRow(target){
	if(target=='service'){
		serviceindex = serviceindex*1 +1;
		var oRow;
		var oCell;
		oRow = jQuery("#serviceTabField")[0].insertRow(-1);
		oRow.className="DataLight";
		
		for(var i=0;i<<%=serviceColSize%>;i++){
			oCell = oRow.insertCell(-1);
			var filename=jQuery("#serviceRowSource_"+i).attr("fieldName");
			var fieldid=jQuery("#serviceRowSource_"+i).attr("fieldid");
			var ht=jQuery("#serviceRowSource_"+i).html();
			if(!!ht && ht.match(/#rowIndex#/)){
				ht=ht.replace(/#rowIndex#/g,serviceindex);
			}
			oCell.innerHTML =ht;
			if(i!=0){
				if(jQuery("#serviceRowSource_js_"+i)&&jQuery("#serviceRowSource_js_"+i).html()!=''){
					try{
						eval("cusFun_"+fieldid+"("+serviceindex+")");
					}catch(e){}
				}
			}
			
		}
		
		jQuery("#serviceTabField").jNice();
		jQuery("#serviceTabField").find("select").each(function(){
			jQuery(this).attr("notBeauty","");	
		})
		jQuery("#serviceTabField").find("select").selectbox();
		
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
			
			//lq 2015-8-31 隐藏"公开"列
			if(filename == 'isopen'){
				oCell.style.display = 'none';
			}
			
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
function checkLength(){
    var items = <%=servicerows%>;
    var tmpvalue;
    for(var i=0;i<items;i++){
        tmpvalue = document.getElementById("serviceother_"+i).value;
        if(realLength(tmpvalue)>255){
		Dialog.alert("<%=SystemEnv.getHtmlLabelName(20246,user.getLanguage())%>255(<%=SystemEnv.getHtmlLabelName(20247,user.getLanguage())%>)");
		while(true){
			tmpvalue = tmpvalue.substring(0,tmpvalue.length-1);
			if(realLength(tmpvalue)<=255){
				document.getElementById("serviceother_"+i).value = tmpvalue;
				return;
			}
		}
		break;
	   }
    }
}
</script>
<script language=javascript>
function doSave(obj){

	//lq 保存 验证是否勾选 议事规则
	if($('#isRulesOfProcedure').is(':checked')) {
		
		$('#rulesOfProcedure').val(1);
		
	}else{
		
		$('#rulesOfProcedure').val(0);		
		
	}
	
	var thisvalue=jQuery("#repeatType").val();
	var begindate="<%=isInterval%>" == "1"?$('#repeatbegindate').val():$('#begindate').val();
	var enddate="<%=isInterval%>" == "1"?$('#repeatenddate').val():$('#enddate').val();
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
			document.weaver.servicerows.value=serviceindex; 
			document.weaver.topicAttachrows.value=attachindex;
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
	var begindate="<%=isInterval%>" == "1"?$('#repeatbegindate').val():$('#begindate').val();
	var enddate="<%=isInterval%>" == "1"?$('#repeatenddate').val():$('#enddate').val();
	var needcheck='<%=needcheck%>'
	if(thisvalue==1){
		needcheck+=",repeatdays";
	}else if(thisvalue==2){
		needcheck+=",repeatweeks,rptWeekDays";
	}else if(thisvalue==3){
		needcheck+=",repeatmonths,repeatmonthdays";
	}
    if(check_form(document.weaver,needcheck)&&checkDateValidity(begindate,$('#begintime').val(),enddate,$('#endtime').val(),"<%=SystemEnv.getHtmlLabelName(16722,user.getLanguage())%>") && checkAgenda()){
			if(checkAddress()){
		 	   var thisvalue=jQuery("#repeatType").val();
		        //当选择重复会议时，不做会议室和人员冲突校验
		        if(thisvalue != 0){
		        	submitact();
					return;
		        }
		        //会议室冲突校验
		        if(<%=meetingSetInfo.getRoomConflictChk()%> == 1 ){
					forbiddenPage();
		        	$.post("/meeting/data/AjaxMeetingOperation.jsp?method=chkRoom",{
		        		address:$GetEle("address").value,
		        		begindate:begindate,begintime:$('#begintime').val(),
  						enddate:enddate,endtime:$('#endtime').val()},
		        	function(datas){
						if(datas != 0){
							if(datas == 2){
								releasePage();
								Dialog.alert("会议室已经被占用无法预约，请选择其他时间。");		
							}else{
								<%if(meetingSetInfo.getRoomConflict() == 1){ %>
									releasePage();
									window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(19095,user.getLanguage())%>", function (){
										submitChkMbr();
									});
								<%} else if(meetingSetInfo.getRoomConflict() == 2) {%>
									releasePage();
									Dialog.alert("<%=SystemEnv.getHtmlLabelName(32875,user.getLanguage())%>。");
								<%}%>
							}
						} else {
							submitChkMbr();
						}
					});
		        	
		        } else {
		        	submitChkMbr();
		        }
			}
	}
}

//lq 2015-9-4 会议议程 校验是否填写
function checkAgenda(){
	//判断是否需要 检查会议议程	
	if($("#isagenda").val()==1){
		var trLength = $("#topicTabField tr").length;
		if(trLength > 1){
			return true;
		}else{
			Dialog.alert("请填写会议议程。");
			return false;
		}
	}else{
		return true;
	}

}

//人员冲突校验
function submitChkMbr(){
	 if(<%=meetingSetInfo.getMemberConflictChk()%> == 1){
		forbiddenPage();
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
						releasePage();
			            window.top.Dialog.confirm(wuiUtil.getJsonValueByIndex(dataObj, 1)+"<%=SystemEnv.getHtmlLabelName(32873,user.getLanguage())%>?", function (){
			                submitact();
			            },null, null, 120);
		            <%} else if(meetingSetInfo.getMemberConflict() == 2) {%>
						releasePage();
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
	forbiddenPage();
	enableAllmenu();
	document.weaver.topicrows.value=rowindex;
	document.weaver.servicerows.value=serviceindex; 
	document.weaver.topicAttachrows.value=attachindex;
	document.weaver.method.value = "addSubmit";
	doUpload();
}

function doUpload(){
	$('#f_weaver_belongto_userid').val("<%=f_weaver_belongto_userid%>");
	//附件上传
    StartUploadAll();
    checkuploadcomplet();
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
//创建人员获取
function getCallerHtml(){
	var hrmIds = $('#caller').val();	
	var html = $('#callerspan').html();
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
						$('#callerspan').html(reHtml);
						getHrmmembersHtml();
					}							
				}
			});
		}
	//}
}
//记录人人员获取
function getRecorderHtml(){
	var hrmIds = $('#recorder').val();	
	var html = $('#recorderspan').html();
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
						$('#recorderspan').html(reHtml);
						getHrmmembersHtml();		
					}							
				}
			});
		}
	//}
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

//会议参会人
function getHrmmembersHtml(){
	//alert("hrmIds");
	//参会人ids
	var hrmIds = $('#hrmmembers').val();
	//主持人id
	var caller = $('#caller').val(); 
	//记录人id
	var recorder = $('#recorder').val();
	if(hrmIds){
		hrmIds = ","+hrmIds;
	}
	if(caller){
		hrmIds += ","+caller;
	}
	if(recorder){
		hrmIds += ","+recorder;
	}
	
	//alert("hrmIds");
	var html = $('#hrmmembersspan').html();
	//判断是否获取选择人员id
	if(hrmIds){
		//人员新选择，执行jsp替换相关内容			
		jQuery.ajax({ 
			url: "/weavernorth/meeting/AjaxGetHumHtml.jsp?hrmIds="+hrmIds, 
			context: document.body, 
			async: "true",
			dataType: "json",
			success: function(data){
				debugger;				
				if(data && data.result == "true"){
					
					var reHtml = data.msg;
					$('#hrmmembersspan').html(reHtml);
					var reHrmIds = data.reHrmIds;
					//从新赋值参会人员id
					$('#hrmmembers').val(reHrmIds);	
					//统计人数和统计成本
					countAttend();	
				}							
			}
		});
	}
}
//计算参会人数
function countAttend()
{
	//判断参会人员和外来参会人员是否都为空
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
		
		
		//计算参会人数
		if($('#totalmember').length>0){
			$('#totalmember').val(hrmmember+othermembers);
		}
		//统计成本
		countCost();	
		
	}
}
//获取新的链接字符串
function getHumHtml(hrmIds){
	var reHtml = "";
	jQuery.ajax({ 
			url: "/weavernorth/meeting/AjaxGetHumHtml.jsp?hrmIds="+hrmIds, 
			context: document.body, 
			async: "false",
			dataType: "json",
			success: function(data){
				debugger;				
				if(data && data.result == "true"){						
					reHtml = data.msg;						
				}							
			}
		});
	return reHtml;	
}

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
		}
	);
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

function ItemCount_KeyPress_Plus()
{
	if(!(window.event.keyCode >= 48 && window.event.keyCode <= 57))
	{
		window.event.keyCode = 0;
	}
}
</script>
</body>
</html>
<script language="javascript">

//会议选择框,判断是否存在自定义会议地点
function CheckOnShowAddress(){
	 if($('#customizeAddress').length>0&&$('#customizeAddress').val()!=""){
	 	window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(82885,user.getLanguage())%>",function(){
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
	  var address = $("#address").val();
	  if(address!=''){
	  	window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(82886,user.getLanguage())%>",function(){
	  		$("#address").val("");
	  		$("#addressspan").html("");
	  		$("#addressspanimg").html("<img src='/images/BacoError_wev8.gif' align='absmiddle'>");
	  		checkaddress();
	  		$('#customizeAddress').focus();
	  	});
	  }
       
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
		var roomid = "<%=address %>";
		var startdate = "<%=begindate %>";
		var starttime = "<%=begintime %>";
		var enddate = "<%=enddate %>";
		var endtime = "<%=endtime %>";
		callBackValue(datas,"meetingtypespan","meetingtype");
		$("#weaver").attr("action", "/meeting/data/NewMeeting.jsp?roomid="+ roomid +"&begindate="+ startdate +"&starttime="+ starttime +"&enddate="+ enddate +"&endtime="+endtime);
		$("#weaver").submit();
	}
}

//重置与会议类型相关的内容
function meetingReset(event,datas,name){
	if (datas != null) {
		$("#weaver").attr("action", "/meeting/data/NewMeeting.jsp");
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
	window.parent.closeDialog();
}

jQuery(document).ready(function(){
	resizeDialog(document);
	onRemindType();
	if("<%=isInterval%>" == "1"){
		changeRepeatType();
	}
	removeSourceCheck();
	checkaddress();
	//lq 2015-9-4 会议地点选择
	//隐藏指定文本框
	$('#my_customizeAddress').parent().parent().css('display','none');
	//绑定选择框 改变事件
	$('#addressselect').change(function(){ 
		//获取selected的值
		var p1=$(this).children('option:selected').val(); 
				
		if(p1 == 0){
			//选择 内部会议			
			//修改google来浏览器显隐 样式改变问题 by lq 2015-10-22
			$('#my_customizeAddress').parent().parent().hide();
			$('#my_address').parent().parent().show();
			
			//jQuery("#addressspan").html("");
			jQuery("#customizeAddress").val("");
			checkaddress();
			
		}else if(p1 == 1){
			//选择 外部会议
			//修改google来浏览器显隐 样式改变问题 by lq 2015-10-22
			$('#my_customizeAddress').parent().parent().show();
			$('#my_address').parent().parent().hide();
			jQuery("#addressspan").html("");
			jQuery("#address").val("");
			checkaddress();
		}
		
	}) 
});
//显示和隐藏 提醒时间控制
function onRemindType(){
	if($('#remindTypeNew').val()==''){
		hideEle("remindtimetr", true);
	}else{
		showEle("remindtimetr", true);
	}
	hideEle("remindtimetr1", true);
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
	diag.URL = "/meeting/report/MeetingRoomPlanTab.jsp?currentdate="+begindate;
	diag.show();
}
//智能匹配会议室
//智能匹配返回会议室值
var newReturnVal= "";
var oldReturnVal= "";
function showMeetingRoom(){
	//alert("123");
	var url = "/weavernorth/meeting/MeetingRoomBrowser.jsp?1=1"
	//caller 主持人
	var caller = jQuery("#caller").val();
	url +="&caller="
	if(caller){
		url += caller;		
	}
	//recorder 记录人
	var recorder = jQuery("#recorder").val();
	url +="&recorder="
	if(recorder){
		url += recorder;		
	}
	//hrmmembers 参会人员
	var hrmmembers = jQuery("#hrmmembers").val();
	url +="&hrmmembers="
	if(hrmmembers){
		url += hrmmembers;		
	}
	//othermembers 其他人员
	var othermembers = jQuery("#othermembers").val();
	url +="&othermembers="
	if(othermembers){
		var array = othermembers.split(",");		
		url += array.length;		
	}
	//begindate 开始日期
	var begindate = jQuery("#begindate").val();
	url +="&begindate="
	if(begindate){
		url += begindate;		
	}
	//begintime 开始时间
	var begintime = jQuery("#begintime").val();
	url +="&begintime="
	if(begintime){
		url += begintime;		
	}
	//enddate 结束日期
	var enddate = jQuery("#enddate").val();
	url +="&enddate="
	if(enddate){
		url += enddate;		
	}
	//endtime 结束时间
	var endtime = jQuery("#endtime").val();
	url +="&endtime="
	if(endtime){
		url += endtime;		
	}
	//alert(url);
	debugger;
	var id = null;
	//弹出选择框
	//id = window.showModalDialog(url, window, "dialogWidth:550px;dialogHeight:450px;");
	var dlg=new window.top.Dialog();//定义Dialog对象
    dlg.currentWindow = window;
	dlg.Model=true;
	dlg.Width=550;
	dlg.Height=450;
	dlg.URL=url;
	dlg.Title="推荐会议室";
	dlg.callbackfun = "testFunciton"; 
	dlg.show();
	
}

function showMeetingRoomCallBackFun(reMeetingVal){
	debugger;
	var addressObj = jQuery("#address");
	var addressSpanObj = jQuery("#addressspan");
	if(newReturnVal){
		debugger;
		var id = newReturnVal.id;
		var name = newReturnVal.name;
		//span显示内容
		var html = "";
		if(id){
			html +="<span class=\"e8_showNameClass\">";
			html +="<A title=\""+name+"\" href=\"/meeting/Maint/MeetingRoom_list.jsp?id="+id+"\" target=_new>"+name+"</A>";
			html +="<span class=\"e8_delClass\" id=\""+id+"\" style=\"filter:  alpha(opacity=100); ZOOM: 1; visibility: hidden;\" >x</span>";
			html +="</span>";
			//赋值会议室id
			addressObj.val(id);
			//赋值会议显示信息
			addressSpanObj.html(html);	
			//去掉必填叹号
			jQuery("#addressspanimg").html("");		
		}else{
			addressObj.val("");
			addressSpanObj.html("");
		}
	}else{
		addressObj.val("");
		addressSpanObj.html("");
	}
	
}
function ow(owurl){
	var iWidth=600;                          //弹出窗口的宽度;
    var iHeight=500;                        //弹出窗口的高度;
    var iTop = (window.screen.availHeight-30-iHeight)/2;       //获得窗口的垂直位置;
    var iLeft = (window.screen.availWidth-10-iWidth)/2;
    var tmp=window.open("about:blank","","fullscreen=1");
    //tmp.moveTo(iLeft,iTop);
    //tmp.resizeTo(iWidth,iHeight);
    //tmp.focus();
    tmp.location=owurl;
} 
//===================================添加外来人员========================================
//显示div
function showDiv(obj,id) {
	var objDiv = jQuery("#"+id+""); 
	jQuery(objDiv).css("display","block"); 
	jQuery(objDiv).html(jQuery(objDiv).html()+"event.clientX:"+event.clientX+";event.clientY + 10:"+event.clientY + 10);
	jQuery(objDiv).css("left", event.clientX); 
	jQuery(objDiv).css("top", event.clientY + 100); 
}
//隐藏
function hideDiv(obj,id) {
	var objDiv = jQuery("#"+id+""); 
	jQuery(objDiv).css("display", "none"); 
}
//添加外来人员
function addOtherHum(){

	var outHumShowPageId = "<%=outHumShowPageId%>";
	if(outHumShowPageId && outHumShowPageId != ""){
		ow("/formmode/search/CustomSearchBySimple.jsp?customid="+outHumShowPageId);
	}else{
		//获取id失败
	}
	
	//ow("/formmode/view/AddFormMode.jsp?type=0&modeId=3180&formId=-1494&billid=");
	
}
//外来人员选择框
var outHumVal= "";
function selectOutHum(){
	var otherMembersObj = jQuery("#othermembers");
	var otherMembersSpanObj = jQuery("#othermembersspan");
	var url = "/weavernorth/meeting/OutHumBrowser.jsp?1=1&outHumId="+otherMembersObj.val();
	openDialog("外来人员",url);
}

function openDialog(title,url) {
	var dlg=new window.top.Dialog();//定义Dialog对象
    dlg.currentWindow = window;
	dlg.Model=true;
	dlg.Width=550;
	dlg.Height=450;
	dlg.URL=url;
	dlg.Title=title;
	dlg.callbackfun = "testFunciton"; 
	dlg.show();
}

//弹出外来人员信息框
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

//外来人员选择后回调方法，赋值相关人员信息到input
function outHrmSelectCallBackFun(reOutHumVal){
	var otherMembersObj = jQuery("#othermembers");
	var otherMembersSpanObj = jQuery("#othermembersspan");
	debugger;
	if(reOutHumVal){
		debugger;
		var html = "";
		var outHumId= "";
		for(var key in reOutHumVal){
			if(key){
	            //alert(key);
	            var name = reOutHumVal[key];
	            if(name){
	            	if(html){
	            		html += ",<a onclick=\"javaScript:showOutHrmInfoById("+key+");\" href=\"#\">"+name+"</a>";
	            		outHumId += ","+key;
	            	}else{	            		
	            		html = "<a onclick=\"javaScript:showOutHrmInfoById("+key+");\" href=\"#\">"+name+"</a>";
	            		outHumId = key;
	            	}
	            }      
			}  
        }
		
		if(html){
			otherMembersObj.val(outHumId);
			otherMembersSpanObj.html(html);			
		}else{
			otherMembersObj.val("");
			otherMembersSpanObj.html("");
		}
	}else{
		otherMembersObj.val("");
		otherMembersSpanObj.html("");
	}
	//统计参会人数
	countAttend();
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


//lq 2015-9-6 相关会议查询
function showMeetingByHrm(){
	//获取参会人员id
	var hrmids = $('#hrmmembers').val();
	//判断是否有人员id是否为空
	//if(hrmids){
	if(hrmids){
		
		
		//跳转页面
		var begindate="<%=isInterval%>" == "1"?$('#repeatbegindate').val():$('#begindate').val();
		//window.top.Dialog.alert(hrmids+":"+begindate);
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
		//diag.Title = "<%=SystemEnv.getHtmlLabelName(15881,user.getLanguage())%>";
		diag.Title = "近一周情况";
		//diag.URL = "/meeting/blogattendancestatis.jsp";
		//http://localhost/meeting/data/ViewMeetingTab.jsp?meetingid=12
		diag.URL = "/weavernorth/meeting/MeetingHrmStatus.jsp?currentdate="+begindate+"&hrmmembers="+hrmids;
		//diag.URL = "/meeting/data/ViewMeetingTab.jsp?meetingid=12";
		diag.show();
	}else{
		window.top.Dialog.alert("请先填写参会人员！");
	}
		
}

//lq  弹出table 写法
function onShowAddress1(){
	var url = "/systeminfo/BrowserMain.jsp?url=/meeting/Maint/MeetingRoomBrowser.jsp";
	showBrwDlg(url, "", 500,570,"addressspan","address","addressChgCbk");
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
//人员处理
function showColse(id){
	//debugger;	
    jQuery("#"+id).css({
        "visibility":"visible",
        "opacity":1
    });
}
function hideColse(id){
	//debugger;	
    jQuery("#"+id).css({
        "visibility":"hidden"
    });
}
//关闭
function closeHrm(spanId,id){	
	
	debugger;
	id = ","+id+",";
	var ele = jQuery("#"+spanId).parent("span").attr("id");
	
	var targetinputobj = jQuery("#"+ele.replace("span",""));
	
	var ids = ","+targetinputobj.val()+",";
	var fieldid = ele.replace("span","");
	var newids = ids.replace(id,",");
	
	newids = newids.substring(1,newids.length-1);
	if(newids==","){
		newids="";
	}
	
	targetinputobj.val(newids);
	jQuery("#"+spanId).remove();
	//重新统计人数
	countAttend();
}

function bindchange(id, fun) {
    var old_val = jQuery(id).val();
    setInterval(function() {
		var new_val = jQuery(id).val();
		if(old_val != new_val) {
			old_val = new_val;            
			fun();        
		}    
	}, 50);
}

</script>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<SCRIPT language="javascript" src="/js/selectDateTime_wev8.js"></script>