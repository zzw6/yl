<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="org.json.JSONObject"%>
<%@page import="weaver.splitepage.transform.SptmForMeeting"%>
<%@page import="weaver.meeting.MeetingShareUtil"%> 
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ page import="weaver.general.IsGovProj" %>
<%@page import="weaver.meeting.util.html.HtmlUtil"%>
<%@page import="weaver.meeting.defined.MeetingFieldManager"%> 
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ page import="java.sql.Timestamp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet2" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet3" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RequestComInfo" class="weaver.workflow.request.RequestComInfo" scope="page"/>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>
<jsp:useBean id="CustomerInfoComInfo" class="weaver.crm.Maint.CustomerInfoComInfo" scope="page" />
<jsp:useBean id="DocComInfo" class="weaver.docs.docs.DocComInfo" scope="page" />
<jsp:useBean id="ProjectInfoComInfo" class="weaver.proj.Maint.ProjectInfoComInfo" scope="page" />
<jsp:useBean id="DocImageManager" class="weaver.docs.docs.DocImageManager" scope="page" />
<jsp:useBean id="meetingSetInfo" class="weaver.meeting.Maint.MeetingSetInfo" scope="page"/>
<jsp:useBean id="ProjectTaskApprovalDetail" class="weaver.proj.Maint.ProjectTaskApprovalDetail" scope="page" />
<jsp:useBean id="MeetingFieldComInfo" class="weaver.meeting.defined.MeetingFieldComInfo" scope="page"/>
<jsp:useBean id="MeetingFieldGroupComInfo" class="weaver.meeting.defined.MeetingFieldGroupComInfo" scope="page"/>
<%@ include file="/cowork/uploader.jsp" %>
<%@ page import="weaver.conn.RecordSet"%>
<%@ page import="weaver.general.BaseBean"%>
<%@ page import="weaver.general.Util"%>
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page" />

<%! 
//图片数据html获取方法
private String getHtml(String hrmIds){
	String htmlStr = "";
	BaseBean baseBean = new BaseBean();
	RecordSet recordSet = new RecordSet();
	String tableName = "uf_meeting_out_hum";
	
	if(!hrmIds.equals("")){
		//String sqlHrmIds = "'"+hrmIds.replace(",","','")+"'";
		String sqlHrmIdArray[] = hrmIds.split(",");
		for(int i=0;i<sqlHrmIdArray.length;i++){
			String hrmid = sqlHrmIdArray[i];
			//BaseBean.writeLog("hrmid:"+hrmid);
			if(!hrmid.equals("")){
				String  sql = "";
				sql += " select t1.*,t2.departmentmark from hrmresource t1,hrmdepartment t2 where t1.id = '"+ hrmid +"' and t1.departmentid = t2.id ";
				//日志输出sql语句
				baseBean.writeLog("查询外来信息sql:"+sql);		
				recordSet.executeSql(sql);
				while(recordSet.next()){
					String id = Util.null2String(recordSet.getString("id"));			
					//姓名
					String lastname = Util.null2String(recordSet.getString("lastname"));
					
					if(!lastname.equals("")){
						if(htmlStr.equals("")){
							htmlStr += "<a onclick=\"pointerXY(event);\" href=\"javaScript:openhrm("+id+");\">"+lastname+"</a>";
						}else{
							htmlStr += ",<a onclick=\"pointerXY(event);\" href=\"javaScript:openhrm("+id+");\">"+lastname+"</a>";
						}
					}
								
				}
			}
		}		
	}
	return htmlStr;
}	
%>  
<%
int isgoveproj = Util.getIntValue(IsGovProj.getPath(),0);//0:非政务系统，1：政务系统
String userid = ""+user.getUID();
String logintype = ""+user.getLogintype();
// lq 议事规则  获取当前用户所在 分部id
String SubCompany = ""+user.getUserSubCompany1();


char flag=Util.getSeparator() ;
String ProcPara = "";
String showDiv = Util.null2String(request.getParameter("showdiv"));
String meetingid = Util.null2String(request.getParameter("meetingid"));
String tab = Util.null2String(request.getParameter("tab"));
String needRefresh = Util.null2String(request.getParameter("needRefresh"));
String onlyDecision = Util.null2String(request.getParameter("onlyDecision"));

	if(Util.null2String(meetingid).indexOf(",")>-1){
	    new BaseBean().writeLog(meetingid);
		String[] split = meetingid.split(",");
		meetingid=split[0];
	}
if(!"1".equals(tab)){
	//response.sendRedirect("/meeting/data/ViewMeetingTab.jsp?meetingid="+meetingid) ;
	out.println("<script>wfforward(\"/meeting/data/ViewMeetingTab.jsp?meetingid="+meetingid+"\");</script>");
	return;
}
RecordSet.executeProc("Meeting_SelectByID",meetingid);
RecordSet.next();

String meetingtype=RecordSet.getString("meetingtype");
String meetingname=RecordSet.getString("name");
String caller=RecordSet.getString("caller");
String contacter=RecordSet.getString("contacter");
//获取会议记录人id  lq  2015-10-22
String recorder=RecordSet.getString("recorder");

String addressselect = RecordSet.getString("addressselect");
if("".equals(addressselect)||addressselect==null){
	addressselect="0";
}

String address=RecordSet.getString("address");
String begindate=RecordSet.getString("begindate");
String begintime=RecordSet.getString("begintime");
String enddate=RecordSet.getString("enddate");

String endtime=RecordSet.getString("endtime");
//下面一行为原代码
//String desc=RecordSet.getString("desc_n");
//下面三行代码为处理会议要求无法跳行问题
String desc = Util.null2String(RecordSet.getString("desc_n")).replaceAll("'","\\'");
		if(desc.indexOf("<br>")==-1)
			desc = Util.forHtml(desc);
		RecordSet.writeLog("-------desc------"+desc);
String creater=RecordSet.getString("creater");
String createdate=RecordSet.getString("createdate");

String createtime=RecordSet.getString("createtime");
String approver=RecordSet.getString("approver");
String approvedate=RecordSet.getString("approvedate");
String approvetime=RecordSet.getString("approvetime");

String isapproved=RecordSet.getString("isapproved");
String isdecision=RecordSet.getString("isdecision");
String decision=RecordSet.getString("decision");
String shareuser=RecordSet.getString("shareuser"); 
String decisiondocid=RecordSet.getString("decisiondocid");

String decisionwfids=RecordSet.getString("decisionwfids");
String decisioncrmids=RecordSet.getString("decisioncrmids");
String decisionprjids=RecordSet.getString("decisionprjids");
String decisiontskids=RecordSet.getString("decisiontskids");
String decisionatchids=RecordSet.getString("decisionatchids");

String totalmember=RecordSet.getString("totalmember");
String othermembers=RecordSet.getString("othermembers");
String othersremark=RecordSet.getString("othersremark");
String addressdesc=RecordSet.getString("addressdesc");
String remindTypeNew=RecordSet.getString("remindTypeNew");
String meetingstatus=RecordSet.getString("meetingstatus");
boolean isrecorder = Util.null2o(RecordSet.getString("recorder")).equals(userid)?true:false;

//lq  议事规则  获取 议事规则标识 和 分部id
String isparliament = RecordSet.getString("isparliament");
String subcompanyid = RecordSet.getString("subcompanyid");
//链接修改
String ccmeetingnotice = RecordSet.getString("ccmeetingnotice");
String ccmeetingminutes = RecordSet.getString("ccmeetingminutes");
String hrmmembers = RecordSet.getString("hrmmembers");



int requestid = RecordSet.getInt("requestid");
int roomType = Util.getIntValue(RecordSet.getString("roomType"),-1);
if(roomType == -1){
	if(!"".equals(address)) roomType = 1;
	else roomType = 2;
}

int repeatType = Util.getIntValue(RecordSet.getString("repeatType"),0);
	
String customizeAddress = Util.null2String(RecordSet.getString("customizeAddress"));

boolean hideAddress=true;//是否隐藏会议室
if("".equals(address)&&"".equals(customizeAddress)){
	hideAddress=false;
}	


String sqlStr="Select approveby,approvedate from bill_meeting where ApproveID="+meetingid;
rs.executeSql(sqlStr);
if(rs.next()){
approver = rs.getString("approveby");
approvedate = rs.getString("approvedate");
}
//System.out.println("approver =="+approver) ;
//System.out.println("approvedate =="+approvedate);
/*如果会议状态不为正常*/
if(!meetingstatus.equals("2")){
	//response.sendRedirect("/meeting/data/ViewMeeting.jsp?tab=1&meetingid="+meetingid+"&showdiv="+showDiv) ;
    out.println("<script>wfforward(\"/meeting/data/ViewMeetingTab.jsp?needRefresh="+needRefresh+"&meetingid="+meetingid+"&showdiv="+showDiv+"\");</script>");
	return;
}
String allUser=MeetingShareUtil.getAllUser(user);
//标识会议已看
StringBuffer stringBuffer = new StringBuffer();
stringBuffer.append("UPDATE Meeting_View_Status SET status = '1'");		
stringBuffer.append(" WHERE meetingId = ");
stringBuffer.append(meetingid);
stringBuffer.append(" AND userId in("+allUser+" )");
RecordSet.executeSql(stringBuffer.toString());

String Sql="";
boolean canview=false;
boolean ismanager=false;
boolean canJueyi = false;
boolean iscontacter=false;
boolean ismember=false;
boolean isdecisioner=false;
int userPrm=1;
String f_weaver_belongto_userid=user.getUID()+"";
if( MeetingShareUtil.containUser(allUser,contacter)&&! MeetingShareUtil.containUser(allUser,caller)){
   userPrm = meetingSetInfo.getContacterPrm();
   if(userPrm==3){
	   if(!userid.equals(contacter)){
		   f_weaver_belongto_userid=contacter;
	   }
   }
} else if( MeetingShareUtil.containUser(allUser,creater)&&!MeetingShareUtil.containUser(allUser,caller)){
   userPrm = meetingSetInfo.getCreaterPrm();
   if(userPrm==3){
	   if(!userid.equals(creater)){
		   f_weaver_belongto_userid=creater;
	   }
   }
} else if(MeetingShareUtil.containUser(allUser,caller)){
	userPrm = meetingSetInfo.getCallerPrm();
	if(userPrm != 3) userPrm = 3;
	if(!userid.equals(caller)){
		f_weaver_belongto_userid=caller;
	}
}
 
if(userPrm == 3 || MeetingShareUtil.containUser(allUser,caller)|| MeetingShareUtil.containUser(allUser,approver)){
	canview=true;
   
}

if(userPrm == 3 || MeetingShareUtil.containUser(allUser,caller)){
 	ismanager=true;
    canJueyi = true;
}

//会议决议 权限判断 修改为 创建人和记录人可创建  lq  2015-10-22 start
//caller 主持人 contacter 创建人

//判断当前是否是主持人 如果是创建会议决议权限修改为false
if(caller.equals(userid)){
	canJueyi = false;	
}

//添加创建人和会议记录人 拥有创建会议决议权限
if(contacter.equals(userid) || recorder.equals(userid)){
	ismanager=true;
    canJueyi = true;	
}

//会议决议 权限判断 修改为 创建人和记录人可创建  lq  2015-10-22 end

//判断当前人是否为会议纪要抄送人 lq 2015-11-5 start
	String getShareLevelSql = "select * from Meeting_ShareDetail where sharelevel = 102 and meetingid = "+meetingid+" and userid = "+user.getUID();
	RecordSet.executeSql(getShareLevelSql);
	//System.out.println("getShareLevelSql:"+getShareLevelSql);
	boolean isHyjy = false;
	
	if(RecordSet.next()){
		isHyjy = true;	
	}
//判断当前人是否为会议纪要抄送人 lq 2015-11-5 end

if(MeetingShareUtil.containUser(allUser,contacter)||MeetingShareUtil.containUser(allUser,creater)){
    canview=true;
}
//modified by Charoes Huang On July 23,2004
if(meetingstatus.equals("2")){
	if(RecordSet.getDBType().equals("oracle")){
		Sql="select memberid from Meeting_Member2 where meetingid="+meetingid+" and ( membermanager in ("+allUser+") " ;
		String[] belongs=allUser.split(",");
		for(int i=0;i<belongs.length;i++){
			if("".equals(belongs[i])) continue;
			Sql+=" or ','|| othermember|| ',' like '%,"+belongs[i]+",%' ";
		}
		Sql+=")";
	}else{
		Sql="select memberid from Meeting_Member2 where meetingid="+meetingid+" and ( membermanager in ("+allUser+" )";
		String[] belongs=allUser.split(",");
		for(int i=0;i<belongs.length;i++){
			if("".equals(belongs[i])) continue;
			Sql+=" or ','+othermember+',' like '%,"+belongs[i]+",%' ";
		}
		Sql+=")";
	}
	//System.out.println("sql = "+Sql);
	RecordSet.executeSql(Sql);
	if(RecordSet.next()) {
		canview=true;
		ismember=true;
	}
}
 

/***检查通过审批流程查看会议***/
rs.executeSql("select userid from workflow_currentoperator where requestid = "+requestid+" and userid in ("+allUser+")" ) ;
if(rs.next()){
	canview=true;
}

if(!canview && (isapproved.equals("3")||isapproved.equals("4"))){
	if(RecordSet.getDBType().equals("oracle")){
		Sql="select * from Meeting_Decision where meetingid="+meetingid+" and ( hrmid02 in ("+allUser+")  ";
		String[] belongs=allUser.split(",");
		for(int i=0;i<belongs.length;i++){
			if("".equals(belongs[i])) continue;
			Sql+=" or ','|| hrmid01|| ',' like '%,"+belongs[i]+",%' ";
		}
		Sql+=")";
	}else if(RecordSet.getDBType().equals("db2")){
        Sql="select * from Meeting_Decision where meetingid="+meetingid+" and ( hrmid02 in ("+allUser+") ";
        String[] belongs=allUser.split(",");
		for(int i=0;i<belongs.length;i++){
			if("".equals(belongs[i])) continue;
			Sql+=" or concat(concat(',',hrmid01),',') like '%,"+belongs[i]+",%' ";
		}
		Sql+=")";
	}else{
		Sql="select * from Meeting_Decision where meetingid="+meetingid+" and ( hrmid02 in ("+allUser+") ";
		String[] belongs=allUser.split(",");
		for(int i=0;i<belongs.length;i++){
			if("".equals(belongs[i])) continue;
			Sql+=" or ','+hrmid01+',' like '%,"+belongs[i]+",%' ";
		}
		Sql+=")";
	}
	
	RecordSet.executeSql(Sql);
	if(RecordSet.next()) {
		canview=true;
		isdecisioner=true;
	}
}

if(MeetingShareUtil.containUser(allUser,contacter) || (userPrm==2&&(!ismember||!isdecisioner)))
    iscontacter=true;

// 议事规则 共享添加 级别101 会议纪要抄送人 级别102 会议通知人 级别103
RecordSet.executeSql("Select * From Meeting_ShareDetail WHERE meetingid="+meetingid+" and userid in ("+allUser+") and sharelevel in (1,2,3,4,101,102,103)");
	if(RecordSet.next()) canview = true;

//代理人在提醒流程和会议室报表中有查看会议的权限 MYQ 2007.12.10 开始
RecordSet.executeSql("Select * From workflow_agentConditionSet Where workflowid=1 and agenttype=1 and agentuid in ("+allUser+") and bagentuid in (select memberid from Meeting_Member2 where meetingid="+meetingid+")");
if(RecordSet.next()) canview = true;
//代理人在提醒流程和会议室报表中有查看会议的权限 MYQ 2007.12.10 结束


//总部议事管理员【编辑/取消】权限  权限变量  bylq 2015-10-25
String privilegeLeve = "0";
boolean canedit = false;
//lq 议事规则判断 开始
//没有查看权限 但是议事规则
if(!canview && ("1".equals(isparliament) || "2".equals(isparliament))){


	//判断当前人是否是议事规则管理员
	if (HrmUserVarify.checkUserRight("RulesOfProcedure:Headquarters", user) ) { 		
		//总部管理权限
		privilegeLeve = "1";
		canview = true;
	}else if (HrmUserVarify.checkUserRight("RulesOfProcedure:Division", user) ) { 
		//分部管理权限
		privilegeLeve = "2";
		//去掉分部管理员可以查看 总部传教的议事规则
		
		if("2".equals(isparliament)){
			//判断是否在同一分部下
			if(SubCompany.trim().equals(subcompanyid.trim())){
				canview = true;	
			}			
		}		
	}
}
//lq 议事规则判断 结束

//总部议事管理员与分部管理员【编辑/取消】权限 判断是否有编辑权限   2015-11-2
if(canview && (HrmUserVarify.checkUserRight("RulesOfProcedure:Headquarters", user) || HrmUserVarify.checkUserRight("RulesOfProcedure:Division", user))&&"2".equals(isparliament)){
	privilegeLeve = "1";
	canedit = true;
}


if(!canview){
	//response.sendRedirect("/notice/noright.jsp") ;
	out.println("<script>wfforward(\"/notice/noright.jsp\");</script>");
	return;
}
%>

<HTML><HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<script language=javascript src="/js/weaver_wev8.js"></script>
</HEAD>
<%
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(2103,user.getLanguage())+":"+Util.forHtml(meetingname);
String needfav ="1";
String needhelp ="";

titlename += "<B>"+SystemEnv.getHtmlLabelName(401,user.getLanguage())+":</B>"+createdate+"<B> "+SystemEnv.getHtmlLabelName(623,user.getLanguage())+":</B>";
if(user.getLogintype().equals("1"))
titlename +=Util.toScreen(ResourceComInfo.getResourcename(creater),user.getLanguage());
titlename +="<B>"+SystemEnv.getHtmlLabelName(142,user.getLanguage())+":</B>"+approvedate+"<B> "+SystemEnv.getHtmlLabelName(623,user.getLanguage())+":</B>" ;
if(user.getLogintype().equals("1"))
titlename +=Util.toScreen(ResourceComInfo.getResourcename(approver),user.getLanguage());

%>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
//结束的会议不允许取消 modify by MYQ 2008.3.4 start
Date newdate = new Date() ;
long datetime = newdate.getTime() ;
Timestamp timestamp = new Timestamp(datetime) ;
String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16);
boolean isover = false;//会议是否结束
//该会议的meetingstatus=2,并且结束时间不在当前时间之后或者该会议已产生会议决议，该会议即为结束
if((enddate+":"+endtime).compareTo(CurrentDate+":"+CurrentTime)<=0 || isdecision.equals("2")) isover=true;

//System.out.println("ismember ="+ismember);
if((canJueyi) && (!isdecision.equals("2")) && repeatType == 0 && isover ){  
RCMenu += "{"+SystemEnv.getHtmlLabelName(2194,user.getLanguage())+",javascript:onShowDecision("+meetingid+"),_self} " ;
RCMenuHeight += RCMenuHeightStep ;
}

if(MeetingShareUtil.containUser(allUser,creater) && isover){  
RCMenu += "{"+SystemEnv.getHtmlLabelName(77,user.getLanguage())+",javascript:copyNewMeeting("+meetingid+"),_self} " ;
RCMenuHeight += RCMenuHeightStep ;
}

//当状态为待审批、正常，召集人可取消会议
if(isrecorder || (("1".equals(meetingstatus) || ("2".equals(meetingstatus) && !isover)) && (userPrm == 3 ||MeetingShareUtil.containUser(allUser,caller) || ("1".equals(privilegeLeve) && "2".equals(isparliament))) && repeatType == 0))
{
	//判断会议开始时间是否小于等于当前时间
	long datenum = com.weaver.formmodel.util.DateHelper.getMinutesBetween(enddate+"/"+endtime+":00",CurrentDate+"/"+CurrentTime+":00");
	if(datenum>0){
	    datenum = com.weaver.formmodel.util.DateHelper.getMinutesBetween(begindate+"/"+begintime+":00",CurrentDate+"/"+CurrentTime+":00");
		if(datenum<=0){
			RCMenu += "{结束会议,javascript:overMeeting(this),_self}";
			RCMenuHeight += RCMenuHeightStep;
		}
	}
}

if((("1".equals(meetingstatus) || ("2".equals(meetingstatus) && !isover)) && (userPrm == 3 ||MeetingShareUtil.containUser(allUser,caller) || ("1".equals(privilegeLeve) && "2".equals(isparliament))) && repeatType == 0)){
	long datenum = com.weaver.formmodel.util.DateHelper.getMinutesBetween(begindate+"/"+begintime+":00",CurrentDate+"/"+CurrentTime+":00");
	if(datenum > 0){
		RCMenu += "{" + SystemEnv.getHtmlLabelName(20115, user.getLanguage()) + ",javascript:cancelMeeting(this),_self}";
		RCMenuHeight += RCMenuHeightStep;
	}
}

//添加导出PDF 和 回执
if(meetingstatus.equals("2") || meetingstatus.equals("5")){ //0：草稿,1：待审批,2:正常,3:退回,4:取消,5:结束
	if(isdecision.equals("2")){
	RCMenu += "{PDF,javascript:exportPDF("+meetingid+"),_self} " ;  //PDF
	RCMenuHeight += RCMenuHeightStep ;
	}
	if((!isdecision.equals("1") && !isdecision.equals("2"))){
		String hrmSql = "select id from Meeting_Member2 where meetingid='"+meetingid+"' and membertype=1 and memberid='"+userid+"'";
		RecordSet.executeSql(hrmSql);
		if(RecordSet.next() && !isover){
			int hrmid  = RecordSet.getInt("id");
			RCMenu += "{"+SystemEnv.getHtmlLabelName(2108,user.getLanguage())+",javascript:onShowReHrm("+hrmid+","+meetingid+"),_self} " ; //回执
			RCMenuHeight += RCMenuHeightStep ;
		}
	}
}
//结束的会议不允许取消 modify by MYQ 2008.3.4 end
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
			<%
			//System.out.println("ismember ="+ismember);
			if((canJueyi) && (!isdecision.equals("2")) && repeatType == 0 && isover){  
			%>
				<input type="button" value="<%=SystemEnv.getHtmlLabelName(2194,user.getLanguage()) %>" class="e8_btn_top middle" onclick="onShowDecision('<%=meetingid%>')"/>
			<%
			}
			//总部议事管理员【编辑/取消】权限   by lq 2015-10-25 start	
			//编辑
			if(canedit&&!meetingstatus.equals("1") && !meetingstatus.equals("4"))
			{
			%>
				<input type="button" value="<%=SystemEnv.getHtmlLabelName(93,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doEdit()"/>
			<%
			}			
			//总部议事管理员【编辑/取消】权限   by lq 2015-10-25 end
			
			if(MeetingShareUtil.containUser(allUser,creater) && isover){  
			%>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(77,user.getLanguage()) %>" class="e8_btn_top middle" onclick="copyNewMeeting('<%=meetingid%>')"/>
			<%
			}

			//当状态为待审批、正常，召集人可取消会议
			//总部议事管理员【编辑/取消】权限  修改【取消】按钮判断条件  by lq 2015-10-25
			if(isrecorder || (("1".equals(meetingstatus) || ("2".equals(meetingstatus) && !isover)) && (userPrm == 3 ||MeetingShareUtil.containUser(allUser,caller) || ("1".equals(privilegeLeve) && "2".equals(isparliament))) && repeatType == 0))
			{
				//判断会议开始时间是否小于等于当前时间
				long datenum = com.weaver.formmodel.util.DateHelper.getMinutesBetween(enddate+"/"+endtime+":00",CurrentDate+"/"+CurrentTime+":00");
				if(datenum>0){
				    datenum = com.weaver.formmodel.util.DateHelper.getMinutesBetween(begindate+"/"+begintime+":00",CurrentDate+"/"+CurrentTime+":00");
					if(datenum <= 0){
				%>
					<input type="button" value="结束会议" class="e8_btn_top middle" onclick="overMeeting(this)"/>
				<%		
					}
				}
			}
			
			if((("1".equals(meetingstatus) || ("2".equals(meetingstatus) && !isover)) && (userPrm == 3 ||MeetingShareUtil.containUser(allUser,caller) || ("1".equals(privilegeLeve) && "2".equals(isparliament))) && repeatType == 0))
			{
				//判断会议开始时间是否小于等于当前时间
				long datenum = com.weaver.formmodel.util.DateHelper.getMinutesBetween(begindate+"/"+begintime+":00",CurrentDate+"/"+CurrentTime+":00");
				if(datenum > 0){
				%>
					<input type="button" value="<%=SystemEnv.getHtmlLabelName(20115,user.getLanguage()) %>" class="e8_btn_top middle" onclick="cancelMeeting(this)"/>
				<%
				}
			}
			
			
			if(meetingstatus.equals("2") || meetingstatus.equals("5")){
				if(isdecision.equals("2")){
				%>
				<input type="button" value="PDF" class="e8_btn_top middle" onclick="exportPDF(<%=meetingid %>)"/>
				<%
				}
				canJueyi = false;
		    	if(userPrm == 3 || MeetingShareUtil.containUser(allUser,caller)){
		    	 	ismanager=true;
		    	    canJueyi = true;
		    	}
		    	//会议决议 权限判断 修改为 创建人和记录人可创建  lq  2015-10-22 start
		    	//caller 主持人 contacter 创建人
		    	//判断当前是否是主持人 如果是创建会议决议权限修改为false
		    	if(caller.equals(userid)){
		    		canJueyi = false;	
		    	}
		    	//添加创建人和会议记录人 拥有创建会议决议权限
		    	if(contacter.equals(userid) || recorder.equals(userid)){
		    		ismanager=true;
		    	    canJueyi = true;	
		    	}
		    	if((!isdecision.equals("1") && !isdecision.equals("2"))){

				String hrmSql = "select id from Meeting_Member2 where meetingid='"+meetingid+"' and membertype=1 and memberid='"+userid+"'";
				RecordSet.executeSql(hrmSql);
				if(RecordSet.next() && !isover){
					int hrmid  = RecordSet.getInt("id");
				
				%>
			    <input type="button" value="<%=SystemEnv.getHtmlLabelName(2108,user.getLanguage()) %>" class="e8_btn_top middle" onclick="onShowReHrm(<%=hrmid%>,<%=meetingid%>)"/>	
				<%
				}
		    	}
			}
			%>
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
<div class="zDialog_div_content" >
<div id="nomalDiv">
<wea:layout type="2col">
<%    
//遍历分组
MeetingFieldManager hfm = new MeetingFieldManager(1);
hfm.getCustomData(Util.getIntValue(meetingid));
List<String> groupList=hfm.getLsGroup();
List<String> fieldList=null;
for(String groupid:groupList){
	//参会人员情况,需要回执处理,不显示
	fieldList= hfm.getUseField(groupid);

	if(fieldList!=null&&fieldList.size()>0){	
%>
<wea:group context="<%=SystemEnv.getHtmlLabelName(Util.getIntValue(MeetingFieldGroupComInfo.getLabel(groupid)), user.getLanguage()) %>" attributes="{'groupDisplay':''}">
	<%for(String fieldid:fieldList){
		if(repeatType > 0) {//周期会议
			if("0".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}else{//非周期会议
			if("1".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}
		if("0".equals(MeetingFieldComInfo.getIsused(fieldid))) continue;//没有启用,隐藏处理
		
		String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
		int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
		int fieldhtmltype = Integer.parseInt(MeetingFieldComInfo.getFieldhtmltype(fieldid));
		int type = Integer.parseInt(MeetingFieldComInfo.getFieldType(fieldid));
		boolean issystem ="1".equals(MeetingFieldComInfo.getIssystem(fieldid))||"0".equals(MeetingFieldComInfo.getIssystem(fieldid));
		boolean ismand="1".equals(MeetingFieldComInfo.getIsmand(fieldid));
		String weekStr="";
		JSONObject cfg= hfm.getFieldConf(fieldid);
		String fieldValue = hfm.getData(fieldname);
		
		String extendHtml="";	
		if("address".equalsIgnoreCase(fieldname)){//会议地点
			extendHtml="<div class=\"FieldDiv\" id=\"selectRoomdivb\" name=\"selectRoomdivb\" style=\"margin-right:200px;float:right;\">"+
							"<A href=\"javascript:showRooms('"+begindate+"');\" style=\"color:blue;\">"+SystemEnv.getHtmlLabelName(2193,user.getLanguage())+"</A>"+
							"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A href=\"javascript:showQRCode();\" style=\"color:blue;\">获取二维码</A>"+
						"</div>";
			if(("".equals(fieldValue)||"0".equals(fieldValue))&&hideAddress) continue;
		}else if("customizeAddress".equalsIgnoreCase(fieldname)){
			String extendHtml1 ="<div class=\"FieldDiv\" id=\"znpp\" name=\"znpp\" style=\"margin-left:10px;margin-top: 3px;float:left\">"+
            	         "<A href=\"javascript:showQRCode();\" style=\"color:blue;\">获取二维码</A>"+
				    "</div>";
			//添加获取二维码
			extendHtml = "<table id=\"my_customizeAddress\" style=\"width:70%\"><tr style=\"width:100%\"><td style=\"width:80%\"><span >"+extendHtml+"</td><td>"+extendHtml1+"</td></tr></table>";
			if("".equals(fieldValue)) continue;
		}else if("name".equalsIgnoreCase(fieldname)){
			extendHtml=new SptmForMeeting().getMeetingStatus(meetingstatus,user.getLanguage()+"+"+enddate+"+"+endtime+"+"+isdecision);
			extendHtml="".equals(extendHtml)?"":"&nbsp;&nbsp;&nbsp;("+extendHtml+")";
		}
		
		//转成html显示
		if(fieldhtmltype==4){//check框,变成disabled
			cfg.put("disabled","disabled");
			fieldValue=HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
		}else if(fieldhtmltype==6){
			cfg.put("canDelAcc",false);//是否有删除按钮
			cfg.put("canupload",false);//是否可以上传
			cfg.put("candownload",true);//是否有下载按钮
			fieldValue=HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
		}else if(fieldhtmltype==3){
			fieldValue=hfm.getHtmlBrowserFieldvalue(user,Integer.parseInt(fieldid),fieldhtmltype,type,fieldValue);
		}else{
			fieldValue=hfm.getFieldvalue(user, Integer.parseInt(fieldid), fieldhtmltype, type, fieldValue, 0);
		}
		
		if("remindTypeNew".equalsIgnoreCase(fieldname)){
			fieldValue="".equals(fieldValue)?SystemEnv.getHtmlLabelName(19782,user.getLanguage()):fieldValue;
		}else if("rptWeekDays".equalsIgnoreCase(fieldname)){
			weekStr=fieldValue;
		}
		
		//特殊处理字段,需要合并处理
		if("remindHoursBeforeStart".equalsIgnoreCase(fieldname)||"remindTimesBeforeStart".equalsIgnoreCase(fieldname)
				||"remindHoursBeforeEnd".equalsIgnoreCase(fieldname)||"remindTimesBeforeEnd".equalsIgnoreCase(fieldname)
				|"repeatweeks".equalsIgnoreCase(fieldname)||"rptWeekDays".equalsIgnoreCase(fieldname)
				||"repeatmonths".equalsIgnoreCase(fieldname)||"repeatmonthdays".equalsIgnoreCase(fieldname))
			continue;

		//提醒时间特殊处理		
		if("remindBeforeStart".equals(fieldname)){
	%>	
		<wea:item attributes="{'samePair':'remindtimetr'}">
		<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item attributes="{'samePair':'remindtimetr'}">
			<div style="float:left;">
				<%=fieldValue%>
				&nbsp;&nbsp;<span><%=SystemEnv.getHtmlLabelName(19784,user.getLanguage())%></span>
				&nbsp;<%=hfm.getData("remindHoursBeforeStart")%>&nbsp;
				<span><%=SystemEnv.getHtmlLabelName(391,user.getLanguage())%></span>
				&nbsp;<%=hfm.getData("remindTimesBeforeStart")%>&nbsp;
				<span><%=SystemEnv.getHtmlLabelName(15049,user.getLanguage())%></span>
			</div>
		</wea:item>	
	<%		
		}else if("remindBeforeEnd".equals(fieldname)){
	%>	
		<wea:item attributes="{'samePair':'remindtimetr'}">
		<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item attributes="{'samePair':'remindtimetr'}">
			<div style="float:left;">
				<%=fieldValue%>
				&nbsp;&nbsp;<span><%=SystemEnv.getHtmlLabelName(19785,user.getLanguage())%></span>
				&nbsp;<%=hfm.getData("remindHoursBeforeEnd")%>&nbsp;
				<span><%=SystemEnv.getHtmlLabelName(391,user.getLanguage())%></span>
				&nbsp;<%=hfm.getData("remindTimesBeforeEnd")%>&nbsp;
				<span><%=SystemEnv.getHtmlLabelName(15049,user.getLanguage())%></span>
			</div>
		</wea:item>	
	<%		
		}else if("remindImmediately".equalsIgnoreCase(fieldname)){
	%>	
		<wea:item attributes="{'samePair':'remindtimetr1'}">
			<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item attributes="{'samePair':'remindtimetr1'}">
			<%=fieldValue%>
		</wea:item>	
	<%		
		}else if("repeatdays".equalsIgnoreCase(fieldname)){//重复会议时间处理
		
	%>	
		<wea:item>
			<%=SystemEnv.getHtmlLabelName(25898,user.getLanguage())%>
		</wea:item> 
		<wea:item>
			<%if(repeatType==1){
				out.println(hfm.getData("repeatdays")+SystemEnv.getHtmlLabelName(1925,user.getLanguage()));
			}else if(repeatType==2){
				if("".equals(weekStr)){
					weekStr=hfm.getHtmlBrowserFieldvalue(user,11,3,268,hfm.getData("rptWeekDays"));
				}
				out.println(SystemEnv.getHtmlLabelName(21977,user.getLanguage())+"&nbsp;"+hfm.getData("repeatweeks")+
						"&nbsp;"+SystemEnv.getHtmlLabelName(1926,user.getLanguage())+"&nbsp;&nbsp;&nbsp;&nbsp;"+weekStr);
			}else if(repeatType==3){
				out.println(SystemEnv.getHtmlLabelName(21977,user.getLanguage())+"&nbsp;"+hfm.getData("repeatmonths")+"&nbsp;"+
						SystemEnv.getHtmlLabelName(25901,user.getLanguage())+"&nbsp;"+hfm.getData("repeatmonthdays")+"&nbsp;"+
						SystemEnv.getHtmlLabelName(1925,user.getLanguage()));
			} %>
		</wea:item>	
	<%	
	}else{
		//外来人员 判断是否为其他人员，重新生成其他人员生成显示框 start
		if("othermembers".equalsIgnoreCase(fieldname)){			
			System.out.println("fieldValue:"+fieldValue);
			System.out.println("extendHtml:"+extendHtml);
			extendHtml ="<input type=\"hidden\" name = \"othermembers\" id=\"othermembers\" value=\""+fieldValue+"\"/><span id=\"othermembersspan\" name=\"othermembersspan\">"+fieldValue+"</span>"	;		
			fieldValue = "";
			
		}
		//外来人员 判断是否为其他人员，重新生成其他人员生成显示框 end
		//人员链接修改 start
		if("caller".equalsIgnoreCase(fieldname)){			
			System.out.println("fieldValue:"+fieldValue);
			System.out.println("extendHtml:"+extendHtml);
			System.out.println("caller:"+caller);
			extendHtml = getHtml(caller)	;		
			fieldValue = "";			
		}if("recorder".equalsIgnoreCase(fieldname)){
			//记录人
			extendHtml = getHtml(recorder);		
			fieldValue = "";	
		}else if("ccmeetingnotice".equalsIgnoreCase(fieldname)){
			//会议通知抄送人
			extendHtml = getHtml(ccmeetingnotice)	;		
			fieldValue = "";	
		}else if("ccmeetingminutes".equalsIgnoreCase(fieldname)){
			//会议纪要抄送人
			extendHtml = getHtml(ccmeetingminutes)	;		
			fieldValue = "";
		}else if("hrmmembers".equalsIgnoreCase(fieldname)){//参会人员
			extendHtml = getHtml(hrmmembers)	;		
			fieldValue = "";						
		}else if("contacter".equalsIgnoreCase(fieldname)){
			//创建人
			//点击链接修改 2017-1-17	
			extendHtml = "<a onclick=\"pointerXY(event);\" href=\"javaScript:openhrm("+contacter+");\">"+ResourceComInfo.getLastname(contacter)+"</a>";
			fieldValue = "";						
		}else if("desc_n".equalsIgnoreCase(fieldname)){	
			fieldValue = desc;	
			RecordSet.writeLog("-------fieldValue------"+fieldValue);
		}
		//人员链接修改 end
		%>		
		<wea:item>
			<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item>
			<%=fieldValue%>
			<%=extendHtml%>
		</wea:item>	
	<%	}
	}%>
</wea:group>
<%}
}%>

</wea:layout>

</div>
<div id="serviceDiv" style="display:none;">
	<%
		
     %>   		
	<TABLE class="ViewForm">
        <TBODY>
        <TR class="Spacing" style="height:1px!important;">
          <TD class="Line1" colspan=2></TD></TR>
        <tr>
        	<td class="Field" colspan=2>
        	<%
        	RecordSet3.execute("select * from Meeting_Service_New where meetingid="+meetingid);
        	MeetingFieldManager hfm3 = new MeetingFieldManager(3);
        	List<String> groupList=hfm3.getLsGroup();
        	List<String> fieldList=null;
        	for(String groupid:groupList){
        		fieldList= hfm3.getUseField(groupid);
        		
        		if(fieldList!=null&&fieldList.size()>0){
        			int colSize=fieldList.size();
        			
        	%>		<table id="serviceTabField" class=ListStyle  border=0 cellspacing=1>
        			  <colgroup>
        	<%		for(int i=0;i<colSize;i++){
        				out.print("<col width='"+(95/colSize)+"%'>\n");
        			}
        			out.println("</colgroup>\n");
        			out.println("<TR class=HeaderForXtalbe>\n");
        		  	
        			for(String fieldid:fieldList){
        				int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
        				out.println("<th>"+SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())+"</th>\n");
	        
	   				}
        			out.print("</tr>\n"); 
        			
        			
        			while(RecordSet3.next()){
        				out.print("<tr class='DataLight'>\n"); 
        				for(String fieldid:fieldList){
            				String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
            				int fieldhtmltype = Integer.parseInt(MeetingFieldComInfo.getFieldhtmltype(fieldid));
            				int type = Integer.parseInt(MeetingFieldComInfo.getFieldType(fieldid));
            				JSONObject cfg= hfm3.getFieldConf(fieldid);
            				String fieldValue = RecordSet3.getString(fieldname);
            				//转成html显示
            				if(fieldhtmltype==4){//check框,变成disabled
            					cfg.put("disabled","disabled");
            					fieldValue=HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
            				}else if(fieldhtmltype==3){
            					fieldValue=hfm3.getHtmlBrowserFieldvalue(user,Integer.parseInt(fieldid),fieldhtmltype,type,fieldValue);
            				}else{
            					fieldValue=hfm3.getFieldvalue(user, Integer.parseInt(fieldid), fieldhtmltype, type, fieldValue, 0);
            				}
            				
            				out.println("<td>"+fieldValue+"</td>\n");
    	        
    	   				}
        				out.print("</tr>\n"); 
        			}
        			out.print("</table>\n"); 
        		}
        	}
        	%>         
        </td></tr>

        </TBODY>
	  </TABLE>
</div>
 <% if( repeatType == 0){ %>
<!--相关交流-->
<div id="discussDiv" style="display:none">
<% String types = "MP";
   String sortid =  meetingid;
 %>
<%@ include file="/meeting/data/MeetingDiscuss.jsp" %>
</div>
<%} %>
<!--议程 -->
<div id="agendaDiv" style="display:none">
	<%@ include file="/meeting/data/MeetingTopicList.jsp" %>
</div>
<% if( repeatType == 0){ %>
<!--参会情况 -->
<div id="memberDiv" style="display:none">
	<%@ include file="/meeting/data/MeetingMemberList.jsp" %>
</div>
<!--会议共享 	lq  2015-10-13 开始-->
	<div id="shareDiv" style="display:none;">		
		<wea:layout type="2col" >
			<wea:group context="<%=SystemEnv.getHtmlLabelName(2112,user.getLanguage())%>">
				<wea:item>共享人员</wea:item>
				<wea:item>
					<%
						//获取原共享人员id 
						String hrmNames = "";
						String hrmids = "";
						String selSql = "select hr.id,hr.lastname from Meeting_ShareDetail msd,HrmResource hr where msd.meetingid = "+meetingid+" and msd.sharelevel = 101 and hr.id = msd.userid";
						RecordSet3.executeSql(selSql);
						while(RecordSet3.next()){
							String hrmid = RecordSet3.getString("id");
							String hrmName = RecordSet3.getString("lastname");
							if(!"".equals(hrmid) && !"".equals(hrmName)){
								hrmids += hrmid+",";
								hrmNames += hrmName+",";								
							}
						}
						
						if(!"".equals(hrmids) && !"".equals(hrmNames)){
							hrmids = hrmids.substring(0, hrmids.lastIndexOf(","));
							hrmNames = hrmNames.substring(0, hrmNames.lastIndexOf(","));
						}else{
							hrmids = "";
							hrmNames = "";
						}
						
												
					%>
					<span id="showButton" style="float:left;">
						<brow:browser viewType="1" name="relatedshareid" browserValue="<%=hrmids%>" 
								browserUrl="#" getBrowserUrlFn="getBrowserUrlFn"
								hasInput="true" isSingle="false" hasBrowser = "true" isMustInput='1'
								completeUrl="/data.jsp" width="370px" _callback="setRelatedName" browserSpanValue="<%=hrmNames%>">
						</brow:browser>
						<input type="hidden" name = "showrelatedsharename" id="showrelatedsharename"/>
					</span>
				</wea:item>
				<wea:item>
				<DIV style="FLOAT: left" align=center>
					<INPUT id=btnSubmit class=e8_btn_submit onclick="shareSubmit()" value=保存设置 type=button> 
				</DIV>
				</wea:item>
			</wea:group>
		</wea:layout>
	</div>
<!--会议共享 	lq  2015-10-13 结束-->

<!--会议决议 -->
<div id="dicisionDiv" style="display:none">
	<%if(((isdecision.equals("1") || isdecision.equals("2")) && (ismanager || ismember || isdecisioner )) || isHyjy ){%>
		  <TABLE class="ViewForm">
			<TBODY>
			<TR>
			  <TD colspan=2> 
		  <TABLE class="ListStyle" cellspacing=1 cellpadding=1  cols=4 id="oTable">
			<COLGROUP>
			<COL width="6%">
			<COL>
			<COL>
			<COL width="12%">
			<COL width="10%">
			<TBODY>
			
			<TR class="DataDark">
			  <TD class="Field" nowrap><%=SystemEnv.getHtmlLabelName(2170,user.getLanguage())%>：</TD>
			  <TD class="Field" colspan=5><%=Util.toScreen(decision,user.getLanguage())%></TD></TR>
			<%if(meetingSetInfo.getTpcDoc() == 1) {%>
			<TR class="DataDark" style="display:none">
			  <TD class="Field"><%=SystemEnv.getHtmlLabelName(857,user.getLanguage())%>：</TD>
			  <TD class="Field" colspan=5>
			  	<a style="cursor: pointer" onclick="opendoc1('<%=decisiondocid%>')"><%=Util.toScreen(DocComInfo.getDocname(decisiondocid),user.getLanguage())%>&nbsp;
			  </TR>
			  <%} %>
			  <TR class="DataDark">
			  	<TD class="Field">共享人：</TD>
			  	<TD class="Field" colspan=5>
			  	    <%
					ArrayList shareuserList = Util.TokenizerString(shareuser,",");
					for(int i=0;i<shareuserList.size();i++){
					%>
					<a href=javaScript:openhrm(<%=shareuserList.get(i)%>); onclick='pointerXY(event);'><%=ResourceComInfo.getResourcename(String.valueOf(shareuserList.get(i)))%></a>&nbsp;
					<%}%>
			  	</TD>
			  </TR>
			  <%if(meetingSetInfo.getTpcWf() == 1) {%>
			<!-- 相关流程 -->
				  <tr class="DataDark" style="display:none">
			                    <td class="Field"><%=SystemEnv.getHtmlLabelName(1044,user.getLanguage())%>：</td>
			                    <td class="Field" colspan=5>
			           <%
			       			 if(!decisionwfids.equals("")){
			       			 ArrayList wfids_muti = Util.TokenizerString(decisionwfids,",");
			            %>
			            
			                       <%for(int i=0;i<wfids_muti.size();i++){%>
										<a href="javascript:void(0)" onclick="openFullWindowForXtable('/workflow/request/ViewRequest.jsp?requestid=<%=wfids_muti.get(i).toString()%>');return false" class="relatedLink">
											<%=RequestComInfo.getRequestname(wfids_muti.get(i).toString())%>
										</a>
								   <%}%>	
			                    
			           <%}%>
			       		</td>
			       </tr class="DataDark">
			      <%}%>
			      <%if(meetingSetInfo.getTpcCrm() == 1) {%>
			           <!-- 相关客户 -->
			            <tr class="DataDark" style="display: none;" >
			                    <td class="Field"><%=SystemEnv.getHtmlLabelName(783,user.getLanguage())%>：</td>
			                    <td class="Field" colspan=5>
			            <%
			       			 if(isgoveproj==0&&!decisioncrmids.equals("")){
			       			 	String name="";
			       			 	ArrayList arrs = Util.TokenizerString(decisioncrmids,",");
			            %>
			             
			                       <%for(int i=0;i<arrs.size();i++){%>
										<a href="javascript:void(0)" onclick="openFullWindowForXtable('/CRM/data/ViewCustomer.jsp?CustomerID=<%=arrs.get(i).toString()%>');return false" class="relatedLink">
											<%=CustomerInfoComInfo.getCustomerInfoname(arrs.get(i).toString())%>
										</a>
								   <%}%>	
			                    
			           <%} %>
			           		</td>
			           </tr>
	            	<%} %>
	            	<%if(meetingSetInfo.getTpcPrj() == 1) {%>
	            		<tr class="DataDark" style="display: none;" >
			                    <td class="Field"><%=SystemEnv.getHtmlLabelName(782,user.getLanguage())%>：</td>
			                    <td class="Field" colspan=5>
			           <!-- 相关项目 -->
			           <%
			       			 if(isgoveproj==0&&!decisionprjids.equals("")){
			       			 	String name="";
			       			 	ArrayList arrs = Util.TokenizerString(decisionprjids,",");
			            %>
			              
			                       <%for(int i=0;i<arrs.size();i++){%>
										<a href="javascript:void(0)" onclick="openFullWindowForXtable('/proj/data/ViewProject.jsp?ProjID=<%=arrs.get(i).toString()%>');return false" class="relatedLink">
											<%=ProjectInfoComInfo.getProjectInfoname(arrs.get(i).toString())%>
										</a>
								   <%}%>
			           <%}%>	
			           		 </td>
			           </tr>
	           		<%}%>
	           		<%if(meetingSetInfo.getTpcTsk() == 1) {%>
	           			 <tr class="DataDark">
			                    <td class="Field"><%=SystemEnv.getHtmlLabelName(522,user.getLanguage())%><%=SystemEnv.getHtmlLabelName(1332,user.getLanguage())%>：</td>
			                    <td class="Field" colspan=5>
			           <!-- 相关任务 -->
			            <%
			       			 if(isgoveproj==0&&!decisiontskids.equals("")){
			       			 	String name="";
			       			 	ArrayList arrs = Util.TokenizerString(decisiontskids,",");
			            %>
			             
			                       <%for(int i=0;i<arrs.size();i++){%>
										<a href="javascript:void(0)" onclick="openFullWindowForXtable('/proj/process/ViewTask.jsp?taskrecordid=<%=arrs.get(i).toString()%>');return false" class="relatedLink">
											<%=Util.toScreen(ProjectTaskApprovalDetail.getTaskSuject(arrs.get(i).toString()),user.getLanguage())%>
										</a>
								   <%}%>
			           <%}%>	
			                    </td>
			               </tr>
	           		  <%}%>
	           		  <%if(meetingSetInfo.getTpcAttch() == 1) {%>
			           <!-- 相关附件 -->  
			           <tr class="DataDark">
			                	<td class="Field"><%=SystemEnv.getHtmlLabelName(22194,user.getLanguage())%>：</td>
			                    <td class="Field" colspan=5>
			            <%
			       			 if(isgoveproj==0&&!decisionatchids.equals("")){
			       		%>
			             
											<%
											ArrayList darrayaccessorys = Util.TokenizerString(decisionatchids,",");
											for(int i=0;i<darrayaccessorys.size();i++)
											{
												String accessoryid = (String)darrayaccessorys.get(i);
												//System.out.println("accessoryid : "+accessoryid);
												if(accessoryid.equals(""))
												{
													continue;
												}
												rs.executeSql("select id,docsubject,accessorycount from docdetail where id="+accessoryid);
												int linknum=-1;
												if(rs.next())
												{
										  %>
										  <%
													linknum++;
													String showid = Util.null2String(rs.getString(1)) ;
													String tempshowname= Util.toScreen(rs.getString(2),user.getLanguage()) ;
													int accessoryCount=rs.getInt(3);
									
													DocImageManager.resetParameter();
													DocImageManager.setDocid(Integer.parseInt(showid));
													DocImageManager.selectDocImageInfo();
									
													String docImagefileid = "";
													long docImagefileSize = 0;
													String docImagefilename = "";
													String fileExtendName = "";
													int versionId = 0;
									
													if(DocImageManager.next())
													{
														//DocImageManager会得到doc第一个附件的最新版本
														docImagefileid = DocImageManager.getImagefileid();
														docImagefileSize = DocImageManager.getImageFileSize(Util.getIntValue(docImagefileid));
														docImagefilename = DocImageManager.getImagefilename();
														fileExtendName = docImagefilename.substring(docImagefilename.lastIndexOf(".")+1).toLowerCase();
														versionId = DocImageManager.getVersionId();
													}
													if(accessoryCount>1)
													{
														fileExtendName ="htm";
													}
													//String imgSrc=AttachFileUtil.getImgStrbyExtendName(fileExtendName,20);
											%>
													
													<%if(accessoryCount==1 && (fileExtendName.equalsIgnoreCase("ppt")||fileExtendName.equalsIgnoreCase("pptx")||fileExtendName.equalsIgnoreCase("xls")||fileExtendName.equalsIgnoreCase("doc")||fileExtendName.equalsIgnoreCase("xlsx")||fileExtendName.equalsIgnoreCase("docx")))
													{
													%>
													<a style="cursor: pointer" onclick="opendoc('<%=showid%>','<%=versionId%>','<%=docImagefileid%>')"><%=docImagefilename%></a>&nbsp;
										  <%
													}
													else
													{
										  %>
													<a style="cursor: pointer" onclick="opendoc1('<%=showid%>')"><%=tempshowname%></a>&nbsp;
										  <%
													}
													if(accessoryCount==1)
													{
										  %>
										  		   &nbsp;<a href='javascript:void(0)'  onclick="downloads('<%=docImagefileid%>');return false;" class='relatedLink'><%=SystemEnv.getHtmlLabelName(258,user.getLanguage())%>(<%=(docImagefileSize/1000)%>K)</a></br>
											
										<%
													}
												}
											}
										%>
			           		<%}%>
			                    </td>
			               </tr>
			               <%}%>
			<TR class="header">
			  <TH  align=left><%=SystemEnv.getHtmlLabelName(714,user.getLanguage())%></TH>
			  <TH  align=left><%=SystemEnv.getHtmlLabelName(229,user.getLanguage())%></TH>
			  
			  <!--列名称修改  by lq 2015-10-21 start-->
			  <th align=left>责任人 </th>
			  <!--列名称修改  by lq 2015-10-21 end-->
			  
			  <TH  align=left>决议描述</TH>
			  <TH  align=left><%=SystemEnv.getHtmlLabelName(602,user.getLanguage())%></TH>
			  <TH  align=left><%=SystemEnv.getHtmlLabelName(104,user.getLanguage())%></TH>
			</TR>
	<%
	RecordSet.executeProc("Meeting_Decision_SelectAll",meetingid);
	while(RecordSet.next()){
	if(ismanager || ismember || (","+RecordSet.getString("hrmid01")+",").indexOf(","+userid+",")!=-1 || RecordSet.getString("hrmid02").equals(userid) || isHyjy ){
		String decisionview = "";
		String decisionrealizedate = "";
		String decisionrealizetime = "";
		String decisionid = RecordSet.getString("id");
		System.out.println("decisionid:"+decisionid);
		if(!RecordSet.getString("requestid").equals("0")){
			String sqlview="select * from workflow_requestviewlog where id = "+RecordSet.getString("requestid");
			if(!RecordSet.getString("hrmid01").equals("")){
				sqlview += " and viewer = "+RecordSet.getString("hrmid01");
			}
			//System.out.println("sqlview = " + sqlview);
			String sqlrealize="select customizestr1,customizestr2 from bill_HrmTime where requestid ="+RecordSet.getString("requestid");
			RecordSet2.executeSql(sqlview);
			if(RecordSet2.next()){
				decisionview = SystemEnv.getHtmlLabelName(82900,user.getLanguage());//"已查阅" ; //文字
			}
			RecordSet2.executeSql(sqlrealize);
			if(RecordSet2.next()){
				decisionrealizedate=RecordSet2.getString("customizestr1");
				decisionrealizetime=RecordSet2.getString("customizestr2");
			}
		}

	%>
			<tr class="DataDark">
				<td class="Field"><%=RecordSet.getString("coding")%></td>
				<td class="Field"><%=RecordSet.getString("subject")%></td>
				<td class="Field">
				<!--//会议批量转任务  显示多人员  by lq 2015-10-23 start -->
				<%
				ArrayList hrms02 = Util.TokenizerString(RecordSet.getString("hrmid02"),",");
				for(int i=0;i<hrms02.size();i++){
				
				%>
				<a href=javaScript:openhrm(<%=hrms02.get(i)%>); onclick='pointerXY(event);'><%=ResourceComInfo.getResourcename(String.valueOf(hrms02.get(i)))%></a>&nbsp;
				<%}%>
				
				<!--
				<a href=javaScript:openhrm(<%=RecordSet.getString("hrmid02")%>); onclick='pointerXY(event);'><%=ResourceComInfo.getResourcename(RecordSet.getString("hrmid02"))%></a>
				-->
				
				<!--//会议批量转任务  显示多人员  by lq 2015-10-23 end -->
				
				</td>
				<td class="Field"><%=RecordSet.getString("remark")%></td>
				<td class="Field">
					<a href="/workflow/request/ViewRequest.jsp?requestid=<%=RecordSet.getString("requestid")%>" target=\'_blank\'><%if(!decisionrealizedate.equals("")){%><%=SystemEnv.getHtmlLabelName(2213,user.getLanguage())%><%}else{%><%=Util.toScreen(decisionview,user.getLanguage(),"0")%><%}%></a>
				</td>
				<td class="Field">
					<a href="#" onclick = "addtask(<%=decisionid%>,'<%=RecordSet.getString("remark")%>')" >创建任务</a>
					
				</td>
			</tr>
	<%
	}
	}
	%>
			</TBODY>
		  </TABLE>		  
			  
			  </TD>
			</TR>
			</TBODY>
		  </TABLE>
	<%}%>
</div>
<%} %>
</td>
</tr>
</TABLE>
</td>
</tr>
<tr style="height:0px">
<td height="0"></td>
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
<script language="javascript">
var diag_vote;
function showDialog(url, title, w,h){
	if(window.top.Dialog){
		diag_vote = new window.top.Dialog();
	} else {
		diag_vote = new Dialog();
	}
	diag_vote.currentWindow = window;
	diag_vote.Width = w;
	diag_vote.Height = h;
	diag_vote.Modal = true;
	diag_vote.Title = title;
	diag_vote.URL = url;
	diag_vote.show();
}



function onShowDecision(meetingid){
	//showDialog("/meeting/data/MeetingDecision.jsp?meetingid="+meetingid,"<%=SystemEnv.getHtmlLabelName(2194,user.getLanguage())%>", 750, 550);
	showDialog("/meeting/data/MeetingOthTab.jsp?toflag=Decision&f_weaver_belongto_userid=<%=f_weaver_belongto_userid%>&meetingid="+meetingid,"<%=SystemEnv.getHtmlLabelName(2194,user.getLanguage())%>", 750, 550);
}

function opendoc(showid,versionid,docImagefileid)
{	
	openFullWindowHaveBar("/docs/docs/DocDspExt.jsp?id="+showid+"&imagefileId="+docImagefileid+"&meetingid=<%=meetingid%>&isFromAccessory=true");
}
function opendoc1(showid)
{
	openFullWindowHaveBar("/docs/docs/DocDsp.jsp?id="+showid+"&isOpenFirstAss=1&meetingid=<%=meetingid%>");
}
function downloads(files)
{
	document.location.href="/weaver/weaver.file.FileDownload?fileid="+files+"&download=1&meetingid=<%=meetingid%>";
}
function submitData() {
window.history.back();
}
 function doSave1(){
	if(check_form(document.Exchange,"ExchangeInfo")){
		document.Exchange.submit();
	}
}
function displaydiv_1()
	{
		if(WorkFlowDiv.style.display == ""){
			WorkFlowDiv.style.display = "none";
			WorkFlowspan.innerHTML = "<a href='#' onClick=displaydiv_1()>全部</a>";
		}
		else{
			WorkFlowspan.innerHTML = "<a href='#' onClick=displaydiv_1()>部分</a>";
			WorkFlowDiv.style.display = "";
		}
	}

function cancelMeeting(obj)
{
	window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(20117,user.getLanguage())%>", function (){
		obj.disabled = true;
        document.cancelMeeting.submit();
	});
}

function overMeeting(obj)
{
	window.top.Dialog.confirm("是否结束会议？", function (){
		obj.disabled = true;
        document.overMeeting.submit();
	});
}

function btn_cancle(){
	window.parent.closeDialog();
}

//导出会议基本信息pdf
function exportPDF(meetingid){
	window.location.href ="/weaver/weaver.meeting.pdf.FileDownload?meetingid=<%=meetingid%>";
}
//首页直接回执
function onShowReHrm(recorderid,meetingid){
	showDialog("/meeting/data/MeetingOthTab.jsp?toflag=ReHrm&recorderid="+recorderid+"&meetingid="+meetingid,"<%=SystemEnv.getHtmlLabelName(2103, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(430, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(2108, user.getLanguage())%>", 600, 500);
}

function copyNewMeeting(id){
	$.post("/meeting/data/AjaxMeetingOperation.jsp",{method:"copyMeeting",meetingid:id,f_weaver_belongto_userid:"<%=creater%>"},function(datas){
		if(datas != "-1"){
			window.parent.dataRfsh();
			window.parent.doCopyEdit(datas);
			//wfforward("/meeting/data/EditMeetingTab.jsp?meetingid="+datas);
		} else {
			Dialog.alert("<%=SystemEnv.getHtmlLabelName(83357,user.getLanguage())%>");
		}
	});
}

jQuery(document).ready(function(){
	window.parent.showMember();
	<%	
	if(((isdecision.equals("1") || isdecision.equals("2")) && (ismanager || ismember || isdecisioner )) || isHyjy ){
	%>
	window.parent.showDicision();
	<%} else {%>
	window.parent.hideDicision();
	<%}%>

	<%if(!"".equals(showDiv)){%>
		jQuery("#nomalDiv").css("display","none");
		jQuery("#agendaDiv").css("display","none");
		jQuery("#discussDiv").css("display","none");
		jQuery("#memberDiv").css("display","none");
		jQuery("#dicisionDiv").css("display","none");
		jQuery("#<%=showDiv%>").css("display","");
	<%}%>
	<%if("dicisionDiv".equals(showDiv)){%>
		window.parent.selectDicision();
	<%}%>
	<% if( repeatType != 0){ %>
	    window.parent.hideDicision();
		window.parent.hideMember();
		window.parent.hideDiscuss();
	<%} else {%>
		window.parent.showDiscuss();
    <%}%>
    resizeDialog(document);
    
    //是否隐藏提醒
    if("<%=remindTypeNew%>"==''){
		hideEle("remindtimetr", true);
	}else{
		showEle("remindtimetr", true);
	}
    hideEle("remindtimetr1", true);
		//判断外来人员是否有人员，查询人员信息 start
		var outHumIds = "<%=othermembers %>";

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
//lq 2015-9-17
function addtask(decisionid,remark){
	//alert(decisionid);
	showDialog("/workrelate/task/data/Add.jsp?saveType=2&sorttype=2&decisionid="+decisionid+"&remark="+remark,"新建任务",800,650);
}

</script>

<FORM id=cancelMeeting name=cancelMeeting action="/meeting/data/MeetingOperation.jsp" method=post enctype="multipart/form-data">
	<INPUT type="hidden" name="method" value="cancelMeeting"/>
	<INPUT type="hidden" name="meetingId" value="<%=meetingid%>"/>
	<INPUT type="hidden" name="f_weaver_belongto_userid" value="<%=f_weaver_belongto_userid %>">
</FORM>

<FORM id=overMeeting name=overMeeting action="/meeting/data/MeetingOperation.jsp" method=post enctype="multipart/form-data">
	<INPUT type="hidden" name="method" value="overMeeting"/>
	<INPUT type="hidden" name="meetingId" value="<%=meetingid%>"/>
	<INPUT type="hidden" name="f_weaver_belongto_userid" value="<%=f_weaver_belongto_userid %>">
</FORM>
</body>
</html>

<script language="javascript">
//lq  会议共享  选择共享人员browser地址 2015-10-13
function getBrowserUrlFn(){
	return "/systeminfo/BrowserMain.jsp?url=/hrm/resource/MutiResourceBrowser.jsp?resourceids="+jQuery("#relatedshareid").val();
}

//共享人员选择回调函数
function setRelatedName(e,datas,name,params){
	if(datas){
		jQuery("#showrelatedsharename").val(datas.name);
	}
}
//共享人员 保存 lq 2015-10-15
function shareSubmit(){
	//获取共享人员id
	var shareHrmId = jQuery("#relatedshareid").val();	
	//执行保存操作页面
	jQuery.post("/weavernorth/meeting/share/MeetingShareOperation.jsp?meetingid=<%=meetingid%>",{shareHrmId:shareHrmId},function(data){			
      if(jQuery.trim(data)!=""){
			var jsonStr = $.parseJSON(data);
			window.top.Dialog.alert(jsonStr.message);
		}
      
   });
	
}
//总部议事管理员【编辑/取消】权限    by lq 2015-10-25 start
//编辑方法
function doEdit(){
  
   window.parent.doParliamentEdit(<%=meetingid%>);
}
//总部议事管理员【编辑/取消】权限    by lq 2015-10-25 end

</script>

<script language=javascript>
//弹出外来人员信息框 2017-1-15
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

//获取二维码
function showQRCode(){
	//判断当前选择的是内部会议室还是外部会议室
	var selectVal = "<%=addressselect %>";
	//alert(selectVal);
	var inputVal = "";
	if(selectVal){
		if(selectVal == "0"){
			//内部会议室
			inputVal = "<%=address %>";
			//inputVal = jQuery("#addressspan span a").attr('title');
		}else if(selectVal == "1"){
			//外部会议室			
			inputVal = "<%=customizeAddress %>";
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
</script>