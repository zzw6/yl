<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="weaver.meeting.defined.MeetingFieldManager"%>
<%@page import="weaver.meeting.remind.MeetingRemindUtil"%>
<%@page import="weaver.meeting.defined.MeetingWFUtil"%>
<%@page import="weaver.meeting.defined.MeetingCreateWFUtil"%>
<%@page import="weaver.general.StaticObj"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<%@ page import="weaver.file.FileUpload" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="weaver.meeting.Maint.MeetingInterval" %>
<%@ page import="weaver.file.Prop"%>
<%@ page import="weaver.email.MailSend" %>
<jsp:useBean id="MeetingRoomComInfo" class="weaver.meeting.Maint.MeetingRoomComInfo" scope="page"/>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSetDB" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet1" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="TimeUtils" class="com.weavernorth.util.TimeUtils" scope="page" />

<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page" />
<jsp:useBean id="SysRemindWorkflow" class="weaver.system.SysRemindWorkflow" scope="page" />
<jsp:useBean id="MeetingViewer" class="weaver.meeting.MeetingViewer" scope="page"/>
<jsp:useBean id="MeetingComInfo" class="weaver.meeting.Maint.MeetingComInfo" scope="page"/>
<jsp:useBean id="meetingSetInfo" class="weaver.meeting.Maint.MeetingSetInfo" scope="page"/>
<jsp:useBean id="meetingLog" class="weaver.meeting.MeetingLog" scope="page" />
<jsp:useBean id="MeetingUtil" class="weaver.meeting.MeetingUtil" scope="page" />

<jsp:useBean id="workPlan" class="weaver.domain.workplan.WorkPlan" scope="page" />
<jsp:useBean id="workPlanService" class="weaver.WorkPlan.WorkPlanService" scope="page" />
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page"/>
<jsp:useBean id="ComputeMeeting" class="com.weavernorth.util.ComputeMeeting" scope="page"/>

<%

FileUpload fu = new FileUpload(request);
String CurrentUser = ""+user.getUID();
String CurrentUserName = ""+user.getUsername();
String SubmiterType = ""+user.getLogintype();
String ClientIP = fu.getRemoteAddr();
// lq 议事规则  获取当前用户所在 分部id
String SubCompany = ""+user.getUserSubCompany1();




Date newdate = new Date() ;
long datetime = newdate.getTime() ;
Timestamp timestamp = new Timestamp(datetime) ;
String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16) + ":" +(timestamp.toString()).substring(17,19);

char flag = 2;
String ProcPara = "";
String Sql="";

String method = Util.null2String(fu.getParameter("method"));
String meetingtype=Util.null2String(fu.getParameter("meetingtype"));//会议类型

String meetingid=Util.null2String(fu.getParameter("meetingid"));

String approvewfid ="";
String formid="";

int days = meetingSetInfo.getDays();


if(method.equals("add") || method.equals("addSubmit"))//NewMeeting.jsp 新建页面保存和提交
{	
	//基本信息
	String name=Util.null2String(fu.getParameter("name"));//会议名称
	String caller=Util.null2String(fu.getParameter("caller"));//召集人,必填
	String contacter=Util.null2String(fu.getParameter("contacter"));//联系人,空值使用当前操作人
	if("".equals(contacter)) contacter=CurrentUser;
	//lq 议事规则 获取参数 是否为议事规则
	String rulesOfProcedure=Util.null2String(fu.getParameter("rulesOfProcedure")); 
	String isRuleManage=Util.null2String(fu.getParameter("isRuleManage")); 
	

	
	
	int roomType = 1;
	String address=Util.null2String(fu.getParameter("address"));//会议地点
	String customizeAddress = Util.null2String(fu.getParameter("customizeAddress"));
	if(!"".equals(address)){//优先选择会议室
		customizeAddress="";
	}else{//自定义会议室
		roomType=2;
	}
	String desc=Util.htmlFilter4UTF8(Util.spacetoHtml(Util.null2String(fu.getParameter("desc_n"))));//描述,可为空
	 
	//时间
	int repeatType = Util.getIntValue(fu.getParameter("repeatType"),0);//是否是重复会议,0 正常会议.
	String begindate=Util.null2String(fu.getParameter("begindate"));
	String enddate=Util.null2String(fu.getParameter("enddate"));
	if(repeatType>0){
		begindate=Util.null2String(fu.getParameter("repeatbegindate"));
		enddate=Util.null2String(fu.getParameter("repeatenddate"));
	}
	String begintime=Util.null2String(fu.getParameter("begintime"));
	String endtime=Util.null2String(fu.getParameter("endtime"));
	//提醒方式和时间
	String remindTypeNew=Util.null2String(fu.getParameter("remindTypeNew"));//新的提示方式
	int remindImmediately = Util.getIntValue(fu.getParameter("remindImmediately"),0);  //是否立即提醒 
	int remindBeforeStart = Util.getIntValue(fu.getParameter("remindBeforeStart"),0);  //是否开始前提醒
	int remindBeforeEnd = Util.getIntValue(fu.getParameter("remindBeforeEnd"),0);  //是否结束前提醒
	int remindHoursBeforeStart = Util.getIntValue(fu.getParameter("remindHoursBeforeStart"),0);//开始前提醒小时
	int remindTimesBeforeStart = Util.getIntValue(Util.null2String(fu.getParameter("remindTimesBeforeStart")),0);  //开始前提醒时间
    int remindHoursBeforeEnd = Util.getIntValue(fu.getParameter("remindHoursBeforeEnd"),0);//结束前提醒小时
    int remindTimesBeforeEnd = Util.getIntValue(Util.null2String(fu.getParameter("remindTimesBeforeEnd")),0);  //结束前提醒时间
	//参会人员
    String hrmmembers=Util.null2String(fu.getParameter("hrmmembers"));//参会人员
    int totalmember=Util.getIntValue(fu.getParameter("totalmember"),0);//参会人数
	String othermembers=Util.fromScreen(fu.getParameter("othermembers"),user.getLanguage());//其他参会人员
	String crmmembers=Util.null2String(fu.getParameter("crmmembers"));//参会客户
	int crmtotalmember=Util.getIntValue(fu.getParameter("crmtotalmember"),0);//参会人数
	//其他信息
	String projectid=Util.null2String(fu.getParameter("projectid"));	//加入了项目id
	String accessorys=Util.null2String(fu.getParameter("field35"));	//系统附件
	//自定义字段
	int remindType = 1;  //老的提醒方式,默认1不提醒
	
	//会议决议 记录人 保存  	by lq   2015-10-22 start
	String recorder=Util.null2String(fu.getParameter("recorder")); 
	//判断记录人id不为空
	if(!"".equals(recorder)){
		//判断参会人员不为空
		if(!"".equals(hrmmembers)){
			//拼装临时参会人员字符串
			String tempHrmmembers = ","+hrmmembers+",";
			//判断参会人员中是否已经包含 记录人id
			if(tempHrmmembers.indexOf(","+recorder+",") > -1){
			
			}else{
				//添加记录人id
				hrmmembers += ","+recorder;
			}			
		}else{
			hrmmembers = recorder;
		}		
	}
	//会议决议 记录人 保存  	by lq   2015-10-22 end
    
	//重复策略字段
	int repeatdays = Util.getIntValue(fu.getParameter("repeatdays"),0);
	int repeatweeks = Util.getIntValue(fu.getParameter("repeatweeks"),0);
	String rptWeekDays=Util.null2String(fu.getParameter("rptWeekDays"));
	int repeatmonths = Util.getIntValue(fu.getParameter("repeatmonths"),0);
	int repeatmonthdays = Util.getIntValue(fu.getParameter("repeatmonthdays"),0);
	int repeatStrategy = Util.getIntValue(fu.getParameter("repeatStrategy"),0);
	
	int hrmmembersCount = 0;
	if(!"".equals(hrmmembers.trim())){
		String[] hrmmembersArr = TimeUtils.replaceRepStr(hrmmembers).split(",");
		hrmmembersCount = hrmmembersArr.length;
	}
	
	int othermembersCount = 0;
	if(!"".equals(othermembers.trim())){
		String[] othermembersArr = TimeUtils.replaceRepStr(othermembers).split(",");
		othermembersCount = othermembersArr.length;
	}
	
	int membersCount = hrmmembersCount + othermembersCount;
	totalmember = membersCount;
	
	
    String description = "您有会议: "+name+"   会议时间:"+begindate+" "+begintime+" 会议地点:"+MeetingRoomComInfo.getMeetingRoomInfoname(""+address)+customizeAddress;
    ProcPara =  meetingtype;
	ProcPara += flag + name;
	ProcPara += flag + caller;
	ProcPara += flag + contacter;
	ProcPara += flag + projectid; //加入项目id
	ProcPara += flag + address;
	ProcPara += flag + begindate;
	ProcPara += flag + begintime;
	ProcPara += flag + enddate;
	ProcPara += flag + endtime;
	ProcPara += flag + desc;
	ProcPara += flag + CurrentUser;
	ProcPara += flag + CurrentDate;
	ProcPara += flag + CurrentTime;
    ProcPara += flag + ""+totalmember;
    ProcPara += flag + othermembers;
    ProcPara += flag + "";
    ProcPara += flag + description;
    ProcPara += flag + ""+remindType;
    ProcPara += flag + ""+remindBeforeStart;
    ProcPara += flag + ""+remindBeforeEnd;
    ProcPara += flag + ""+remindTimesBeforeStart;
    ProcPara += flag + ""+remindTimesBeforeEnd;
    ProcPara += flag + customizeAddress;
    if (RecordSet.getDBType().equals("oracle"))
	{
		RecordSet.executeProc("Meeting_Insert",ProcPara);
    
		RecordSet.executeSql("SELECT max(id) FROM Meeting where creater = "+CurrentUser);
	}
	else
	{
		RecordSet.executeProc("Meeting_Insert",ProcPara);
	}
	RecordSet.next();
	String MaxID = RecordSet.getString(1);

	String updateSql = "update Meeting set repeatType = " + repeatType 
					+" , repeatdays = "+ repeatdays 
					+" , repeatweeks = "+ repeatweeks 
					+" , rptWeekDays = '"+ rptWeekDays +"' "
					+" , repeatbegindate = '"+ begindate +"' "
					+" , repeatenddate = '"+ enddate +"' "
					+" , repeatmonths = "+ repeatmonths 
					+" , repeatmonthdays = "+ repeatmonthdays
					+" , repeatStrategy = "+ repeatStrategy
					+" , roomType = "+ roomType
					+" , remindTypeNew = '"+ remindTypeNew+"' "
					+" , remindImmediately = "+ remindImmediately
					+" , remindHoursBeforeStart = "+ remindHoursBeforeStart
					+" , remindHoursBeforeEnd = "+ remindHoursBeforeEnd
					+" , hrmmembers = '"+ hrmmembers+"' "
					+" , crmmembers = '"+ crmmembers+"' "
					+" , crmtotalmember = "+ crmtotalmember
					+" , accessorys = '"+ accessorys+"' ";
	//lq 议事规则 添加 更新字段				
	if("1".equals(rulesOfProcedure.trim())){
		if(!"".equals(isRuleManage.trim())){
			updateSql += " ,isparliament = "+isRuleManage;
			if(!"".equals(SubCompany.trim())){
				updateSql += " ,subcompanyid = "+SubCompany;
			}
		}		
	}				
	updateSql += " where id = " + MaxID;
	
	//System.out.println("updateSql:"+updateSql);
	RecordSet.executeSql(updateSql);
	//保存自定义字段
	MeetingFieldManager mfm=new MeetingFieldManager(1);
	mfm.editCustomData(fu,Util.getIntValue(MaxID));
	
    //System.out.print(MaxID);
	ArrayList arrayhrmids02 = Util.TokenizerString(hrmmembers,",");
	for(int i=0;i<arrayhrmids02.size();i++){
		ProcPara =  MaxID;
		ProcPara += flag + "1";
		ProcPara += flag + "" + arrayhrmids02.get(i);
		ProcPara += flag + "" + arrayhrmids02.get(i);
		
		int memberCount = 0;
		RecordSet.executeSql("select count(*) as memberCount from Meeting_Member2 where meetingid = "+MaxID+" and membertype = 1 and memberid = "+arrayhrmids02.get(i)+" and membermanager = " + arrayhrmids02.get(i));
		if(RecordSet.next()){
			memberCount = Util.getIntValue(RecordSet.getString("memberCount"), 0);
		}
		if(memberCount <= 0){
			RecordSet.executeProc("Meeting_Member2_Insert",ProcPara);
		}
		
		//标识会议是否查看过
		StringBuffer stringBuffer = new StringBuffer();
		stringBuffer.append("INSERT INTO Meeting_View_Status(meetingId, userId, userType, status) VALUES(");
		stringBuffer.append(MaxID);
		stringBuffer.append(", ");
		stringBuffer.append(arrayhrmids02.get(i));
		stringBuffer.append(", '");
		stringBuffer.append("1");
		stringBuffer.append("', '");
		if(CurrentUser.equals(arrayhrmids02.get(i)))
		//当前操作用户表示已看
		{
		    stringBuffer.append("1");
		}
		else
		{
		    stringBuffer.append("0");
		}
		stringBuffer.append("')");
		RecordSet.executeSql(stringBuffer.toString());
	}

	ArrayList arraycrmids02 = Util.TokenizerString(crmmembers,",");
	for(int i=0;i<arraycrmids02.size();i++){
		String membermanager="";
		RecordSet.executeProc("CRM_CustomerInfo_SelectByID",""+arraycrmids02.get(i));
		if(RecordSet.next()) membermanager=RecordSet.getString("manager");
		ProcPara =  MaxID;
		ProcPara += flag + "2";
		ProcPara += flag + "" + arraycrmids02.get(i);
		ProcPara += flag + membermanager;
		
		int memberCount = 0;
		RecordSet.executeSql("select count(*) as memberCount from Meeting_Member2 where meetingid = "+MaxID+" and membertype = 2 and memberid = "+arraycrmids02.get(i)+" and membermanager = " + membermanager);
		if(RecordSet.next()){
			memberCount = Util.getIntValue(RecordSet.getString("memberCount"), 0);
		}
		if(memberCount <= 0){
			RecordSet.executeProc("Meeting_Member2_Insert",ProcPara);
		}
	}
	//会议议程
	int topicrows=Util.getIntValue(Util.null2String(fu.getParameter("topicrows")),0);
	if(topicrows>0){
		MeetingFieldManager mfm2=new MeetingFieldManager(2);
		for(int i=1;i<=topicrows;i++){
			mfm2.editCustomDataDetail(fu,0,i,Util.getIntValue(MaxID));
		}
	}
	//会议服务
	int servicerows=Util.getIntValue(Util.null2String(fu.getParameter("servicerows")),0);
	if(servicerows>0){
		MeetingFieldManager mfm3=new MeetingFieldManager(3);
		for(int i=1;i<=servicerows;i++){
			mfm3.editCustomDataDetail(fu,0,i,Util.getIntValue(MaxID));
		}
	}
	//会议议程附件
	int topicAttachrows=Util.getIntValue(Util.null2String(fu.getParameter("topicAttachrows")),0);
	
	
	if(topicAttachrows>0){
		MeetingFieldManager mfm4=new MeetingFieldManager(4);
		for(int i=1;i<=topicAttachrows;i++){
			mfm4.editCustomDataDetail(fu,0,i,Util.getIntValue(MaxID));
		}
	}
	
	
	MeetingViewer.setMeetingShareById(""+MaxID);
	 StaticObj.getInstance().removeObject("MeetingComInfo");
	//文档和附件的共享明细
	MeetingUtil.meetingDocShare(MaxID);
	
	if(method.equals("add")){
		meetingLog.resetParameter();
    	meetingLog.insSysLogInfo(user,Util.getIntValue(MaxID),name,"新建草稿会议"+(repeatType>0?"模板":""),"303","1",1,Util.getIpAddr(request));
	}
	
	
	RecordSet.executeProc("Meeting_Type_SelectByID",meetingtype);
    RecordSet.next();
    String isTickling = Util.null2String(RecordSet.getString("isTickling")) ;
	if("1".equals(isTickling)){
		RecordSet.executeSql("update meeting set isAppraise = 3 where id = " + MaxID);
	}
	
	//2004年4月17日，根据会议类型所对应的工作流判断是否需要触发审批工作流
    if(method.equals("addSubmit")){
    	//新建会议日志
    	
        if(!meetingtype.equals("")){
        	if(repeatType>0){//周期会议,查看周期会议审批流程
        		RecordSet.executeSql("Select approver1,formid From Meeting_Type t1 join workflow_base t2 on t1.approver1=t2.id  where t1.approver1>0 and t1.ID ="+meetingtype);
        	}else{
        		RecordSet.executeSql("Select approver,formid From Meeting_Type t1 join workflow_base t2 on t1.approver=t2.id  where t1.approver>0 and t1.ID ="+meetingtype);
        	}
            RecordSet.next();
            approvewfid = RecordSet.getString(1);
            formid=RecordSet.getString(2);
        }
        //流程触发时间设置判断（只判断有审批流程会议类型）
        boolean istrigger = true;
    	if(!approvewfid.equals("0")&&!approvewfid.equals("")){
    		int issettime = meetingSetInfo.getIssettime();
    		if(issettime > 0){
    			int maintimes = meetingSetInfo.getMaintimes() * 60;	//借用本分部触发时间
    			int subtimes = meetingSetInfo.getSubtimes() * 60;	//借用夸分部触发时间
    			//计算会议时长
    			long times = com.weaver.formmodel.util.DateHelper.getMinutesBetween(enddate+"/"+endtime+":00",begindate+"/"+begintime+":00");
				RecordSet.executeSql("select subcompanyid from MeetingRoom where id = '"+address+"'");
				String meetingRoom_subcompanyid = "";
				if(RecordSet.next()){
					meetingRoom_subcompanyid = Util.null2String(RecordSet.getString("subcompanyid"));
				}
				
				if(meetingRoom_subcompanyid.equals(SubCompany)){
					if(maintimes >= times){
						istrigger = false;
					}
				}else{
					if(subtimes >= times){
    					istrigger = false;
    				}
				}
    		}
    	}
    	
    	
        if(!approvewfid.equals("0")&&!approvewfid.equals("") && istrigger && roomType == 1){ //设置了会议触发审批流程
        	meetingLog.resetParameter();
        	meetingLog.insSysLogInfo(user,Util.getIntValue(MaxID),name,"新建审批会议","303","1",1,Util.getIpAddr(request));
        	
        	//RecordSet1.executeSql("Update Meeting Set approvedate='"+TimeUtil.getCurrentDateString()+"',approvetime='"+TimeUtil.getOnlyCurrentTimeString()+"' WHERE id="+MaxID);//更新会议状态为正常
        	
        	//BaseBean.writeLog("111111" + "Update Meeting Set approvedate='"+TimeUtil.getCurrentDateString()+"',approvetime='"+TimeUtil.getOnlyCurrentTimeString()+"' WHERE id="+MaxID);
        	
        	if("85".equals(formid)){//原系统表单
	            response.sendRedirect("/workflow/request/BillMeetingOperation.jsp?src=submit&iscreate=1&MeetingID="+MaxID+"&approvewfid="+approvewfid+"&viewmeeting=1");
	            return;
        	}else{//新表单,通过Action统一处理
        		MeetingCreateWFUtil.createWF(MaxID,user,approvewfid,ClientIP);
        		response.sendRedirect("/meeting/data/ViewMeeting.jsp?remind=yes&meetingid="+MaxID);
        		return;
        	}
        }else{
        	
        	String createdate = "";
    		String t_begindate = "";
    		
        	RecordSet.executeSql("select createdate,begindate from meeting  where id=" + MaxID);
        	if(RecordSet.next()){
        		createdate = Util.null2String(RecordSet.getString("createdate"));
        		t_begindate = Util.null2String(RecordSet.getString("begindate"));
        	}
        	
    		int result = Util.getIntValue(com.weaver.formmodel.util.DateHelper.getDaysBetween(t_begindate,createdate)+"",0);
    		
    		RecordSet.executeSql("update meeting set datetime_ks = "+ result +" where id = " + MaxID);
			
	        RecordSet.executeSql("Update Meeting Set meetingstatus = 2 WHERE id="+MaxID);//更新会议状态为正常
	        if(repeatType == 0){
	        	meetingLog.resetParameter();
	        	meetingLog.insSysLogInfo(user,Util.getIntValue(MaxID),name,"新建正常会议","303","1",1,Util.getIpAddr(request));
	        	//生成会议日程和会议提醒
	            //MeetingInterval.createWPAndRemind(MaxID,null,fu.getRemoteAddr());
				
				//生成会议日程和邮件提醒  2017-1-17
				MeetingInterval.createWPAndEmail(MaxID,null,fu.getRemoteAddr());
				
	            //系统提醒流程 发送给主持人  by lq 2015-11-2 start					
				
				String tzTitle = description.replaceAll("您有会议:","会议通知:");
				
				//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
				//SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(MaxID),Util.getIntValue(contacter),caller,"");
				
				//系统提醒流程 发送给主持人  by lq 2015-11-2 end
				//系统提醒流程 会议通知抄送人 (ccmeetingnotice) 与 会议纪要抄送人 (ccmeetingminutes) by lq 2015-11-5 start

					//获取会议通知抄送人 id
					
					String ccMeetingNotice = Util.null2String(fu.getParameter("ccmeetingnotice"));
					
					//获取会议纪要抄送人 id
					String ccMeetingMinutes = Util.null2String(fu.getParameter("ccmeetingminutes"));						
					//备注
					String Remarks = "";
					//通过 address 查询 会议室名称
					String meetingRoomName = "";
					if(roomType == 1){
						String getMeetingRoomSql = "select * from MeetingRoom where id = "+address;
						RecordSet.executeSql(getMeetingRoomSql);
						if(RecordSet.next()){
							meetingRoomName = RecordSet.getString("name");
						}
					
					
					}				
					String ccMeetingNoticeTitle = description.replaceAll("您有会议:","会议通知:");
					String ccMeetingMinutesTitle = description.replaceAll("您有会议:","会议纪要通知:");
					
					//判断会议通知抄送人 id 是否为空
					
					if(!"".equals(ccMeetingNotice)){
						//2016年8月4日，会议通知抄送人可以通过链接查看会议信息  start
						//添加共享给会议通知抄送人						
						//查询已经有通知的人员id
						String getHrmSql = " select id,caller,contacter,hrmmembers from Meeting where id = "+MaxID;
						String oldhrmids = "";
						RecordSet.executeSql(getHrmSql);
						while(RecordSet.next()){
							String callerId = RecordSet.getString("caller");
							String contacterId = RecordSet.getString("contacter");
							String hrmmembersId = RecordSet.getString("hrmmembers");
							if(!callerId.equals("")){
								oldhrmids +=","+ callerId +",";
							}
							if(!contacterId.equals("")){
								oldhrmids +=","+ contacterId +",";
							}
							if(!hrmmembersId.equals("")){
								oldhrmids +=","+ hrmmembersId +",";
							}
						}
						String ccMeetingNoticeArray[] = ccMeetingNotice.split(",");						
						for(int i=0;i<ccMeetingNoticeArray.length;i++){
							String tempId = ccMeetingNoticeArray[i];
							if(!"".equals(tempId) && !oldhrmids.equals("") && oldhrmids.indexOf(","+tempId+",")<0){
								//共享类型 103 为 会议通知抄送人
								String setMeetingShareSql = "insert into Meeting_ShareDetail(meetingid,userid,usertype,sharelevel) values("+MaxID+","+tempId+",1,103)";
								if(RecordSet.executeSql(setMeetingShareSql)){
									
								}else{
									BaseBean.writeLog("添加共享给会议通知抄送人失败！(userId=" + tempId +")");
								}
							}
						
						}
						//2016年8月4日，会议通知抄送人可以通过链接查看会议信息  end
						
						//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
						//SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(MaxID),Util.getIntValue(contacter),ccMeetingNotice,Remarks);
						
						//邮件发送  2017-1-17 start
						BaseBean.writeLog("===========================MeetingOperation.jsp(会议通知抄送人提醒邮件发送) start===========================");
						String mailTitle = description.replaceAll("您有会议:","会议通知:");
						String mailContent = "以下是提醒内容，请点击查看详情：<br>";
						mailContent += "<a style=\"color:red\" target=\"_blank\" href=\"/weavernorth/meeting/MeetingInfo.jsp?id="+MaxID+"\">"+mailTitle+"</a><br>";
						
						MailSend localMailSend = new MailSend();
						boolean bool = localMailSend.sendSysInternalMail("1", ccMeetingNotice, null, mailTitle, mailContent);
						BaseBean.writeLog("发送通知邮件是否成功："+bool);
						BaseBean.writeLog("===========================MeetingOperation.jsp(会议通知抄送人提醒邮件发送) end===========================");
						//邮件发送  2017-1-17 end
						
					}
					
					//判断会议纪要抄送人 id 是否为空
					if(!"".equals(ccMeetingMinutes)){
						
						//添加共享给纪要抄送人
						String ccMeetingMinutesArray[] = ccMeetingMinutes.split(",");
						String tempCcMeetingMinutes = "";
						for(int i=0;i<ccMeetingMinutesArray.length;i++){
							String tempId = ccMeetingMinutesArray[i];
							if(!"".equals(tempId)){
								//共享类型 102 为 会议纪要抄送人
								String setMeetingShareSql = "insert into Meeting_ShareDetail(meetingid,userid,usertype,sharelevel) values("+MaxID+","+tempId+",1,102)";
								if(RecordSet.executeSql(setMeetingShareSql)){
									
								}
							}
						
						}
						
						
						//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
						//SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(MaxID),Util.getIntValue(contacter),ccMeetingMinutes,Remarks);
					}
				//系统提醒流程 会议通知抄送人 与 会议纪要抄送人  by lq 2015-11-5 end
				
				//主持人日程 创建  by lq 2015-11-6 start
				/*				
				workPlan.setCreaterId(Integer.parseInt(contacter));	//创建人id
				workPlan.setWorkPlanType(Integer.parseInt("1"));	//日程类型
				workPlan.setWorkPlanName(name);						//日程名称 - 会议名称			
				workPlan.setUrgentLevel("1");		
				workPlan.setResourceId(caller);						//接收人id
				workPlan.setBeginDate(begindate);					//开始日期
				workPlan.setEndDate(enddate);						//结束日期
				if ((begintime != null) && (!"".equals(begintime))){		
					workPlan.setBeginTime(begintime);				//开始时时间
					if ((endtime != null) && (!"".equals(endtime))){
					  workPlan.setEndTime(endtime);					//结束时间
					}else {
					  workPlan.setEndTime("17:00");
					}				  
				}else {
				  workPlan.setBeginTime("09:00");	
				}
				
			
				workPlan.setRemindType("1");
				workPlan.setRemindBeforeStart("0");
				workPlan.setRemindBeforeEnd("0");
				workPlan.setRemindTimesBeforeStart(0);
				workPlan.setRemindTimesBeforeEnd(0);
				workPlan.setRemindDateBeforeStart(begindate);
				workPlan.setRemindTimeBeforeStart(workPlan.getBeginTime());
				workPlan.setRemindDateBeforeEnd(begindate);
				workPlan.setRemindTimeBeforeEnd(workPlan.getEndTime());
				workPlan.setMeeting(MaxID);//会议id

				workPlan.setDescription(description);
				
				workPlanService.insertWorkPlan(workPlan);
				
				*/
				//主持人日程 创建  by lq 2015-11-6 end				
	
	            response.sendRedirect("/meeting/data/ViewMeeting.jsp?meetingid="+MaxID);
				/*%>
				<script type="text/javascript">
					window.parent.closeWinAFrsh();
				</script>
				<%*/
	            return;
            } else {
            	meetingLog.resetParameter();
            	meetingLog.insSysLogInfo(user,Util.getIntValue(MaxID),name,"新建会议模板","303","1",1,Util.getIpAddr(request));
				int intervaltime = 0;
				String otherinfo = "";
				if(repeatType == 1){
					intervaltime = repeatdays;
				} else if(repeatType == 2){
					intervaltime = repeatweeks;
					otherinfo = rptWeekDays;
				}else if(repeatType == 3){
					intervaltime = repeatmonths;
					otherinfo = "" + repeatmonthdays;
				}
            	MeetingInterval.updateMeetingRepeat(days,MaxID,begindate,enddate,""+repeatType,intervaltime,otherinfo,repeatStrategy);
            }
        }
    }
    response.sendRedirect("/meeting/data/ViewMeeting.jsp?meetingid="+MaxID);
    /*%>
	<script type="text/javascript">
		window.parent.closeWinAFrsh();
	</script>
	<%*/
    return;
}else if(method.equals("submit")) {//ViewMeeting.jsp 页面直接提交
    if(!meetingid.equals("")) {
        RecordSet rs = new RecordSet();
        rs.executeSql("Update Meeting Set meetingstatus = 2 WHERE id="+meetingid);//更新会议状态为正常
        
        
        //二次开发内容 start
        String t_createdate = "";
		String t_begindate = "";
		
    	RecordSet.executeSql("select createdate,begindate from meeting  where id=" + meetingid);
    	if(RecordSet.next()){
    		t_createdate = Util.null2String(RecordSet.getString("createdate"));
    		t_begindate = Util.null2String(RecordSet.getString("begindate"));
    	}
    	
		int result = Util.getIntValue(com.weaver.formmodel.util.DateHelper.getDaysBetween(t_begindate,t_createdate)+"",0);
		
		RecordSet.executeSql("update meeting set datetime_ks = "+ result +" where id = " + meetingid);
		
		//二次开发内容 end
        
        
        rs.executeProc("Meeting_SelectByID",meetingid);
	    rs.next();
	    String name=rs.getString("name");
	    String begindate=rs.getString("begindate");
	    String enddate=rs.getString("enddate");
		//获取会议开始结束时间 
		String begintime=rs.getString("begintime");
		String endtime=rs.getString("endtime");
	    
	    int repeatType = Util.getIntValue(rs.getString("repeatType"),0);
		int repeatdays = Util.getIntValue(rs.getString("repeatdays"),0);
		int repeatweeks = Util.getIntValue(rs.getString("repeatweeks"),0);
		int repeatmonths = Util.getIntValue(rs.getString("repeatmonths"),0);
		int repeatmonthdays = Util.getIntValue(rs.getString("repeatmonthdays"),0);
		int repeatStrategy = Util.getIntValue(rs.getString("repeatStrategy"),0);
		String rptWeekDays = rs.getString("rptWeekDays");
	
		if(repeatType == 0){
			meetingLog.resetParameter();
			meetingLog.insSysLogInfo(user,Util.getIntValue(meetingid),name,"提交会议","303","2",1,Util.getIpAddr(request));
			//生成会议日程和会议提醒
			//MeetingInterval.createWPAndRemind(meetingid,null,fu.getRemoteAddr());
			//生成会议日程和邮件提醒  2017-1-17
			MeetingInterval.createWPAndEmail(meetingid,null,fu.getRemoteAddr());
			//系统提醒流程 发送给主持人  by lq 2015-11-2 start
			
			String caller = rs.getString("caller");	
			int contacter = rs.getInt("contacter");	
						
			String tzTitle = Util.null2String(rs.getString("description"));
			tzTitle = tzTitle.replaceAll("您有会议:","会议通知:");
				
			//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
			//SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(meetingid),contacter,caller,"");
			
			//系统提醒流程 发送给主持人  by lq 2015-11-2 end
			
			//主持人日程 创建  by lq 2015-11-6 start
								
				workPlan.setCreaterId(contacter);	//创建人id
				workPlan.setWorkPlanType(Integer.parseInt("1"));	//日程类型
				workPlan.setWorkPlanName(name);						//日程名称 - 会议名称			
				workPlan.setUrgentLevel("1");		
				workPlan.setResourceId(caller);						//接收人id
				workPlan.setBeginDate(begindate);					//开始日期
				workPlan.setEndDate(enddate);						//结束日期
				if ((begintime != null) && (!"".equals(begintime))){		
					workPlan.setBeginTime(begintime);				//开始时时间
					if ((endtime != null) && (!"".equals(endtime))){
					  workPlan.setEndTime(endtime);					//结束时间
					}else {
					  workPlan.setEndTime("17:00");
					}				  
				}else {
				  workPlan.setBeginTime("09:00");	
				}
				
			
				workPlan.setRemindType("1");
				workPlan.setRemindBeforeStart("0");
				workPlan.setRemindBeforeEnd("0");
				workPlan.setRemindTimesBeforeStart(0);
				workPlan.setRemindTimesBeforeEnd(0);
				workPlan.setRemindDateBeforeStart(begindate);
				workPlan.setRemindTimeBeforeStart(workPlan.getBeginTime());
				workPlan.setRemindDateBeforeEnd(begindate);
				workPlan.setRemindTimeBeforeEnd(workPlan.getEndTime());
				workPlan.setMeeting(meetingid);//会议id

				workPlan.setDescription(Util.null2String(rs.getString("description")));
				
				workPlanService.insertWorkPlan(workPlan);
				
				
			//主持人日程 创建  by lq 2015-11-6 end		
			
					
			
			
		 } else {
			int intervaltime = 0;
			String otherinfo = "";
			if(repeatType == 1){
				intervaltime = repeatdays;
			} else if(repeatType == 2){
				intervaltime = repeatweeks;
				otherinfo = rptWeekDays;
			}else if(repeatType == 3){
				intervaltime = repeatmonths;
				otherinfo = "" + repeatmonthdays;
			}
			meetingLog.resetParameter();
			meetingLog.insSysLogInfo(user,Util.getIntValue(meetingid),name,"提交会议模板","303","2",1,Util.getIpAddr(request));
			MeetingInterval.updateMeetingRepeat(days,meetingid,begindate,enddate,""+repeatType,intervaltime,otherinfo,repeatStrategy);
		}
        MeetingViewer.setMeetingShareById(meetingid);
		 StaticObj.getInstance().removeObject("MeetingComInfo");
		
		if(repeatType == 0){
		//系统提醒流程 会议通知抄送人 (ccmeetingnotice) 与 会议纪要抄送人 (ccmeetingminutes) by lq 2015-11-5 start

			//获取会议通知抄送人 id
			String ccMeetingNotice = rs.getString("ccmeetingnotice");		
			
			//获取会议纪要抄送人 id
			String ccMeetingMinutes = rs.getString("ccmeetingminutes");			
			int contacter1 = rs.getInt("contacter");	
			//备注
			String Remarks = "";	
			
			String tzTitle1 = Util.null2String(rs.getString("description"));
			String ccMeetingNoticeTitle = tzTitle1.replaceAll("您有会议:","会议通知:");
			String ccMeetingMinutesTitle = tzTitle1.replaceAll("您有会议:","会议纪要通知:");
			
			//判断会议通知抄送人 id 是否为空
			if(!"".equals(ccMeetingNotice)){
				//2016年8月4日，会议通知抄送人可以通过链接查看会议信息  start
				//添加共享给会议通知抄送人
				//查询已经有通知的人员id
				String getHrmSql = " select id,caller,contacter,hrmmembers from Meeting where id = "+meetingid;
				String oldhrmids = "";
				RecordSet.executeSql(getHrmSql);
				while(RecordSet.next()){
					String callerId = RecordSet.getString("caller");
					String contacterId = RecordSet.getString("contacter");
					String hrmmembersId = RecordSet.getString("hrmmembers");
					if(!callerId.equals("")){
						oldhrmids +=","+ callerId +",";
					}
					if(!contacterId.equals("")){
						oldhrmids +=","+ contacterId +",";
					}
					if(!hrmmembersId.equals("")){
						oldhrmids +=","+ hrmmembersId +",";
					}
				}
				String ccMeetingNoticeArray[] = ccMeetingNotice.split(",");						
				for(int i=0;i<ccMeetingNoticeArray.length;i++){
					String tempId = ccMeetingNoticeArray[i];
					//判断通知人id是否为空且唯一 lqlq
					if(!"".equals(tempId) && !oldhrmids.equals("") && oldhrmids.indexOf(","+tempId+",")<0){
						//共享类型 103 为 会议通知抄送人
						String setMeetingShareSql = "insert into Meeting_ShareDetail(meetingid,userid,usertype,sharelevel) values("+meetingid+","+tempId+",1,103)";
						if(RecordSet.executeSql(setMeetingShareSql)){
							
						}else{
							BaseBean.writeLog("添加共享给会议通知抄送人失败！(userId=" + tempId +")");
						}
					}
				
				}
				//2016年8月4日，会议通知抄送人可以通过链接查看会议信息  end				
				//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
				//SysRemindWorkflow.setMeetingSysRemind(ccMeetingNoticeTitle,Util.getIntValue(meetingid),contacter1,ccMeetingNotice,Remarks);
				
				//邮件发送  2017-1-17 start
				BaseBean.writeLog("===========================MeetingOperation.jsp(会议通知抄送人提醒邮件发送) start===========================");
				String mailTitle = tzTitle1.replaceAll("您有会议:","会议通知:");
				String mailContent = "以下是提醒内容，请点击查看详情：<br>";
				mailContent += "<a style=\"color:red\" target=\"_blank\" href=\"/weavernorth/meeting/MeetingInfo.jsp?id="+meetingid+"\">"+mailTitle+"</a><br>";
				
				MailSend localMailSend = new MailSend();
				boolean bool = localMailSend.sendSysInternalMail("1", ccMeetingNotice, null, mailTitle, mailContent);
				BaseBean.writeLog("发送通知邮件是否成功："+bool);
				BaseBean.writeLog("===========================MeetingOperation.jsp(会议通知抄送人提醒邮件发送) end===========================");
				//邮件发送  2017-1-17 end
			}
			
			//判断会议纪要抄送人 id 是否为空
			if(!"".equals(ccMeetingMinutes)){
			
				//添加共享给纪要抄送人
				String ccMeetingMinutesArray[] = ccMeetingMinutes.split(",");
				String tempCcMeetingMinutes = "";
				for(int i=0;i<ccMeetingMinutesArray.length;i++){
				//System.out.println("i:"+i);	
					String tempId = ccMeetingMinutesArray[i];
					
					if(!"".equals(tempId)){
						//共享类型 102 为 会议纪要抄送人
						
						String setMeetingShareSql = " insert into Meeting_ShareDetail(meetingid,userid,usertype,sharelevel) values("+meetingid+","+tempId+",1,102)";
					
						if(RecordSet.executeSql(setMeetingShareSql)){						
							
						}
					}
				
				}
				
				//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
				//SysRemindWorkflow.setMeetingSysRemind(ccMeetingMinutesTitle,Util.getIntValue(meetingid),contacter1,ccMeetingMinutes,Remarks);
			}
		//系统提醒流程 会议通知抄送人 与 会议纪要抄送人  by lq 2015-11-5 end
		}
    }
    response.sendRedirect("/meeting/data/ViewMeeting.jsp?tab=1&meetingid="+meetingid);
    /* %>
	<script type="text/javascript">
		window.parent.closeWinAFrsh();
	</script>
	<%*/
    return;
}else if(method.equals("edit"))//修改或者编辑页面直接提交  edit页面修改和提交
{	
	
	//基本信息
	String name=Util.null2String(fu.getParameter("name"));//会议名称
	String caller=Util.null2String(fu.getParameter("caller"));//召集人,必填
	String contacter=Util.null2String(fu.getParameter("contacter"));//联系人,空值使用当前操作人
	if("".equals(contacter)) contacter=CurrentUser;
	//lq 议事规则 获取参数 是否为议事规则
	String rulesOfProcedure=Util.null2String(fu.getParameter("rulesOfProcedure")); 
	String isRuleManage=Util.null2String(fu.getParameter("isRuleManage")); 
	

	
	int roomType = 1;
	String address=Util.null2String(fu.getParameter("address"));//会议地点
	String customizeAddress = Util.null2String(fu.getParameter("customizeAddress"));
	if(!"".equals(address)){//优先选择会议室
		customizeAddress="";
	}else{//自定义会议室
		roomType=2;
	}
	String desc=Util.htmlFilter4UTF8(Util.spacetoHtml(Util.null2String(fu.getParameter("desc_n"))));//描述,可为空
	//时间
	int repeatType = Util.getIntValue(fu.getParameter("repeatType"),0);//是否是重复会议,0 正常会议.
	String begindate=Util.null2String(fu.getParameter("begindate"));
	String enddate=Util.null2String(fu.getParameter("enddate"));
	if(repeatType>0){
		begindate=Util.null2String(fu.getParameter("repeatbegindate"));
		enddate=Util.null2String(fu.getParameter("repeatenddate"));
	}
	String begintime=Util.null2String(fu.getParameter("begintime"));
	String endtime=Util.null2String(fu.getParameter("endtime"));
	//提醒方式和时间
	String remindTypeNew=Util.null2String(fu.getParameter("remindTypeNew"));//新的提示方式
	int remindImmediately = Util.getIntValue(fu.getParameter("remindImmediately"),0);  //是否立即提醒 
	int remindBeforeStart = Util.getIntValue(fu.getParameter("remindBeforeStart"),0);  //是否开始前提醒
	int remindBeforeEnd = Util.getIntValue(fu.getParameter("remindBeforeEnd"),0);  //是否结束前提醒
	int remindHoursBeforeStart = Util.getIntValue(fu.getParameter("remindHoursBeforeStart"),0);//开始前提醒小时
	int remindTimesBeforeStart = Util.getIntValue(Util.null2String(fu.getParameter("remindTimesBeforeStart")),0);  //开始前提醒时间
    int remindHoursBeforeEnd = Util.getIntValue(fu.getParameter("remindHoursBeforeEnd"),0);//结束前提醒小时
    int remindTimesBeforeEnd = Util.getIntValue(Util.null2String(fu.getParameter("remindTimesBeforeEnd")),0);  //结束前提醒时间
	//参会人员
    String hrmmembers=Util.null2String(fu.getParameter("hrmmembers"));//参会人员
    int totalmember=Util.getIntValue(fu.getParameter("totalmember"),0);//参会人数
	String othermembers=Util.fromScreen(fu.getParameter("othermembers"),user.getLanguage());//其他参会人员
	String crmmembers=Util.null2String(fu.getParameter("crmmembers"));//参会客户
	int crmtotalmember=Util.getIntValue(fu.getParameter("crmtotalmember"),0);//参会人数
	//其他信息
	String projectid=Util.null2String(fu.getParameter("projectid"));	//加入了项目id
	String accessorys=Util.null2String(fu.getParameter("field35"));	//系统附件
	
	//自定义字段
	int remindType = 1;  //老的提醒方式,默认1不提醒
	
	//会议决议 记录人 保存  	by lq   2015-10-22 start
	String recorder=Util.null2String(fu.getParameter("recorder")); 
	//判断记录人id不为空
	if(!"".equals(recorder)){
		//判断参会人员不为空
		if(!"".equals(hrmmembers)){
			//拼装临时参会人员字符串
			String tempHrmmembers = ","+hrmmembers+",";
			//判断参会人员中是否已经包含 记录人id
			if(tempHrmmembers.indexOf(","+recorder+",") > -1){
			
			}else{
				//添加记录人id
				hrmmembers += ","+recorder;
			}			
		}else{
			hrmmembers = recorder;
		}		
	}
	//会议决议 记录人 保存  	by lq   2015-10-22 end
    
	//重复策略字段
	int repeatdays = Util.getIntValue(fu.getParameter("repeatdays"),0);
	int repeatweeks = Util.getIntValue(fu.getParameter("repeatweeks"),0);
	String rptWeekDays=Util.null2String(fu.getParameter("rptWeekDays"));
	int repeatmonths = Util.getIntValue(fu.getParameter("repeatmonths"),0);
	int repeatmonthdays = Util.getIntValue(fu.getParameter("repeatmonthdays"),0);
	int repeatStrategy = Util.getIntValue(fu.getParameter("repeatStrategy"),0);
	
	String[] hrmmembersArr = TimeUtils.replaceRepStr(hrmmembers).split(",");
	String[] othermembersArr = TimeUtils.replaceRepStr(othermembers).split(",");
	
	int membersCount = hrmmembersArr.length + othermembersArr.length;
	totalmember = membersCount;
	
	String description= "您有会议: "+name+"   会议时间:"+begindate+" "+begintime+" 会议地点:"+MeetingRoomComInfo.getMeetingRoomInfoname(""+address)+customizeAddress;
	ProcPara +=  meetingid;
	ProcPara += flag + name;
	ProcPara += flag + caller;
	ProcPara += flag + contacter;
	ProcPara += flag + projectid;	//加入修改字段
	ProcPara += flag + address;
	ProcPara += flag + begindate;
	ProcPara += flag + begintime;
	ProcPara += flag + enddate;
	ProcPara += flag + endtime;
	ProcPara += flag + desc;
    ProcPara += flag + ""+totalmember;
    ProcPara += flag + othermembers;
    ProcPara += flag + "";
    ProcPara += flag + description;
    ProcPara += flag + ""+remindType;
    ProcPara += flag + ""+remindBeforeStart;
    ProcPara += flag + ""+remindBeforeEnd;
    ProcPara += flag + ""+remindTimesBeforeStart;
    ProcPara += flag + ""+remindTimesBeforeEnd;
    ProcPara += flag + customizeAddress;
    
	RecordSet.executeProc("Meeting_Update",ProcPara);
	
	String updateSql = "update Meeting set repeatType = " + repeatType 
					+" , repeatdays = "+ repeatdays 
					+" , repeatweeks = "+ repeatweeks 
					+" , rptWeekDays = '"+ rptWeekDays +"' "
					+" , repeatbegindate = '"+ begindate +"' "
					+" , repeatenddate = '"+ enddate +"' "
					+" , repeatmonths = "+ repeatmonths 
					+" , repeatmonthdays = "+ repeatmonthdays
					+" , repeatStrategy = "+ repeatStrategy
					+" , roomType = "+ roomType
					+" , remindTypeNew = '"+ remindTypeNew+"' "
					+" , remindImmediately = "+ remindImmediately
					+" , remindHoursBeforeStart = "+ remindHoursBeforeStart
					+" , remindHoursBeforeEnd = "+ remindHoursBeforeEnd
					+" , hrmmembers = '"+ hrmmembers+"' "
					+" , crmmembers = '"+ crmmembers+"' "
					+" , crmtotalmember = "+ crmtotalmember
					+" , accessorys = '"+ accessorys+"' ";			
	
	//lq 议事规则 添加 更新字段				
	if("1".equals(rulesOfProcedure.trim())){
		if(!"".equals(isRuleManage.trim())){
			updateSql += " ,isparliament = "+isRuleManage;
			if(!"".equals(SubCompany.trim())){
				updateSql += " ,subcompanyid = "+SubCompany;
			}
		}		
	}
	//System.out.println("updateSql22:"+updateSql);	
	updateSql += " where id = " + meetingid;
	RecordSet.executeSql(updateSql);
	//保存自定义字段
	MeetingFieldManager mfm=new MeetingFieldManager(1);
	mfm.editCustomData(fu,Util.getIntValue(meetingid));
	
	//删除会议人员
	RecordSet.executeProc("Meeting_Member2_Delete",meetingid);
		
	//删除会议中相关的标识是否查看的信息
	StringBuffer stringBuffer = new StringBuffer();
	stringBuffer.append("DELETE FROM Meeting_View_Status WHERE meetingId = ");
	stringBuffer.append(meetingid);
	RecordSet.executeSql(stringBuffer.toString());
	

	ArrayList arrayhrmids02 = Util.TokenizerString(hrmmembers,",");
	for(int i=0;i<arrayhrmids02.size();i++){
		ProcPara =  meetingid;
		ProcPara += flag + "1";
		ProcPara += flag + "" + arrayhrmids02.get(i);
		ProcPara += flag + "" + arrayhrmids02.get(i);
		
		int memberCount = 0;
		RecordSet.executeSql("select count(*) as memberCount from Meeting_Member2 where meetingid = "+meetingid+" and membertype = 1 and memberid = "+arrayhrmids02.get(i)+" and membermanager = " + arrayhrmids02.get(i));
		if(RecordSet.next()){
			memberCount = Util.getIntValue(RecordSet.getString("memberCount"), 0);
		}
		if(memberCount <= 0){
			RecordSet.executeProc("Meeting_Member2_Insert",ProcPara);
		}
		
		//标识会议是否查看过
		stringBuffer = new StringBuffer();
		stringBuffer.append("INSERT INTO Meeting_View_Status(meetingId, userId, userType, status) VALUES(");
		stringBuffer.append(meetingid);
		stringBuffer.append(", ");
		stringBuffer.append(arrayhrmids02.get(i));
		stringBuffer.append(", '");
		stringBuffer.append("1");
		stringBuffer.append("', '");
		if(CurrentUser.equals(arrayhrmids02.get(i)))
		//当前操作用户表示已看
		{
		    stringBuffer.append("1");
		}
		else
		{
		    stringBuffer.append("0");
		}
		stringBuffer.append("')");
		RecordSet.executeSql(stringBuffer.toString());
	}

	ArrayList arraycrmids02 = Util.TokenizerString(crmmembers,",");
	for(int i=0;i<arraycrmids02.size();i++){
		String membermanager="";
		RecordSet.executeProc("CRM_CustomerInfo_SelectByID",""+arraycrmids02.get(i));
		if(RecordSet.next()) membermanager=RecordSet.getString("manager");
		ProcPara =  meetingid;
		ProcPara += flag + "2";
		ProcPara += flag + "" + arraycrmids02.get(i);
		ProcPara += flag + membermanager;
		
		int memberCount = 0;
		RecordSet.executeSql("select count(*) as memberCount from Meeting_Member2 where meetingid = "+meetingid+" and membertype = 2 and memberid = "+arraycrmids02.get(i)+" and membermanager = " + membermanager);
		if(RecordSet.next()){
			memberCount = Util.getIntValue(RecordSet.getString("memberCount"), 0);
		}
		if(memberCount <= 0){
			RecordSet.executeProc("Meeting_Member2_Insert",ProcPara);
		}
	}
	//会议议程
	int topicrows=Util.getIntValue(Util.null2String(fu.getParameter("topicrows")),0);
	if(topicrows>0){
		String recordsetids="";
		for(int i=1;i<=topicrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topic_data_"+i));
			if(!recordsetid.equals("")) recordsetids+=","+recordsetid;
		}
		if(!recordsetids.equals("")){
			recordsetids=recordsetids.substring(1);
			Sql = "delete from Meeting_Topic WHERE ( meetingid = "+meetingid+" and id not in ("+recordsetids+"))";
			RecordSet.executeSql(Sql);
		}else{
			Sql = "delete from Meeting_Topic WHERE ( meetingid = "+meetingid+")";
			RecordSet.executeSql(Sql);
		}
		MeetingFieldManager mfm2=new MeetingFieldManager(2);
		for(int i=1;i<=topicrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topic_data_"+i));
			mfm2.editCustomDataDetail(fu,Util.getIntValue(recordsetid),i,Util.getIntValue(meetingid));
		}
		
	}
	//会议服务
	int servicerows=Util.getIntValue(Util.null2String(fu.getParameter("servicerows")),0);
	if(servicerows>0){
		String recordsetids="";
		for(int i=1;i<=servicerows;i++){
			String recordsetid=Util.null2String(fu.getParameter("serivce_data_"+i));
			if(!recordsetid.equals("")) recordsetids+=","+recordsetid;
		}
		if(!recordsetids.equals("")){
			recordsetids=recordsetids.substring(1);
			Sql = "delete from Meeting_Service_New WHERE ( meetingid = "+meetingid+" and id not in ("+recordsetids+"))";
			RecordSet.executeSql(Sql);
		}else{
			Sql = "delete from Meeting_Service_New WHERE ( meetingid = "+meetingid+")";
			RecordSet.executeSql(Sql);
		}
		MeetingFieldManager mfm3=new MeetingFieldManager(3);
		for(int i=1;i<=servicerows;i++){
			String recordsetid=Util.null2String(fu.getParameter("serivce_data_"+i));
			mfm3.editCustomDataDetail(fu,Util.getIntValue(recordsetid),i,Util.getIntValue(meetingid));
		}
	}
	//会议议程附件
	int topicAttachrows=Util.getIntValue(Util.null2String(fu.getParameter("topicAttachrows")),0);
	if(topicAttachrows>0){
		String recordsetids="";
		for(int i=1;i<=topicAttachrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topicattach_data_"+i));
			if(!recordsetid.equals("")) recordsetids+=","+recordsetid;
		}
		if(!recordsetids.equals("")){
			recordsetids=recordsetids.substring(1);
			Sql = "delete from Meeting_Topic_attach WHERE ( meetingid = "+meetingid+" and id not in ("+recordsetids+"))";
			RecordSet.executeSql(Sql);
		}else{
			Sql = "delete from Meeting_Topic_attach WHERE ( meetingid = "+meetingid+")";
			RecordSet.executeSql(Sql);
		}
		MeetingFieldManager mfm4=new MeetingFieldManager(4);
		for(int i=1;i<=topicAttachrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topicattach_data_"+i));
			mfm4.editCustomDataDetail(fu,Util.getIntValue(recordsetid),i,Util.getIntValue(meetingid));
		}
	}
    MeetingViewer.setMeetingShareById(meetingid);
 StaticObj.getInstance().removeObject("MeetingComInfo");
	//文档和附件的共享明细
	MeetingUtil.meetingDocShare(meetingid);
	
	meetingLog.resetParameter();
	meetingLog.insSysLogInfo(user,Util.getIntValue(meetingid),name,"修改会议"+(repeatType>0?"模板":""),"303","2",1,Util.getIpAddr(request));

	
	String t_meetingtype = "";
	RecordSet.executeSql("select meetingtype from meeting where id = " + meetingid);
	if(RecordSet.next()){
		t_meetingtype = Util.null2String(RecordSet.getString("meetingtype"));
	}
	
	RecordSet.executeProc("Meeting_Type_SelectByID",t_meetingtype);
	RecordSet.next();
	String isTickling = Util.null2String(RecordSet.getString("isTickling")) ;
	
	if("1".equals(isTickling)){
		RecordSet.executeSql("update meeting set isAppraise = 3 where id = " + meetingid);
	}
	
	response.sendRedirect("/meeting/data/ViewMeeting.jsp?meetingid="+meetingid);
	/*%>
	<script type="text/javascript">
		window.parent.toView();
	</script>
	<%*/
	return;
}

if(method.equals("delete"))
{
    RecordSet.executeSql("select requestid,name,meetingtype,repeattype From meeting where id="+meetingid);
    int requestid=0;
    int meetingtype1=0;
    if(RecordSet.next()){
       requestid=Integer.valueOf(Util.null2String(RecordSet.getString("requestid"))).intValue();
       meetingtype1=RecordSet.getInt("meetingtype");
       meetingLog.resetParameter();
   	   meetingLog.insSysLogInfo(user,Util.getIntValue(meetingid),RecordSet.getString("name"),"删除会议","303","3",1,Util.getIpAddr(request));
   		if(RecordSet.getInt("repeattype")>0){//周期会议,查看周期会议审批流程
    		RecordSet.executeSql("Select formid From Meeting_Type t1 join workflow_base t2 on t1.approver1=t2.id  where t1.approver1>0 and t1.ID ="+meetingtype1);
    	}else{
    		RecordSet.executeSql("Select formid From Meeting_Type t1 join workflow_base t2 on t1.approver=t2.id  where t1.approver>0 and t1.ID ="+meetingtype1);
    	}
   		if(RecordSet.next()){
   			int fromid=RecordSet.getInt("formid");
   		    if(requestid>0){
	   			MeetingWFUtil.deleteWF(requestid,meetingid,fromid);
   		        RecordSet.executeSql("delete From workflow_currentoperator where requestid="+requestid);
   		    }
   		}
    }
    MeetingWFUtil.deleteMeeting(meetingid);
    
     StaticObj.getInstance().removeObject("MeetingComInfo");
	//response.sendRedirect("/meeting/data/AddMeeting.jsp");
	%>
	<script type="text/javascript">
		window.parent.closeWinAFrsh();
	</script>
	<%
	return;
}

//提交会议，此部分对于现在通过流程来审批会议已经无用处！ by charoes Huang ,July 23,2004
if(method.equals("submitapprove111"))
{
	String approver="";
	RecordSet.executeProc("Meeting_Type_SelectByID",meetingtype);
	if(RecordSet.next()){
		approver=RecordSet.getString("approver");
	}

	if(!approver.equals("0") && !approver.equals("") && !approver.equals(CurrentUser)){
		RecordSet.executeProc("Meeting_Submit",meetingid);

		RecordSet.executeProc("Meeting_SelectByID",meetingid);
		RecordSet.next();
		String contacter=RecordSet.getString("contacter");
		String SWFTitle=Util.toScreen("会议申请:",user.getLanguage(),"0"); //文字
		SWFTitle += RecordSet.getString("name");
		SWFTitle += "-"+ResourceComInfo.getResourcename(contacter);
		SWFTitle += "-"+CurrentDate;
		String SWFRemark="";
		SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(CurrentUser),approver,SWFRemark);
	}else{
	    RecordSet.executeProc("Meeting_Submit",meetingid);
        ProcPara =  meetingid;
		ProcPara += flag + CurrentUser;
		ProcPara += flag + CurrentDate;
		ProcPara += flag + CurrentTime;
		RecordSet.executeProc("Meeting_Approve",ProcPara);

		RecordSet.executeProc("Meeting_SelectByID",meetingid);
		RecordSet.next();
		String name=RecordSet.getString("name");
		String caller=RecordSet.getString("caller");
		String contacter=RecordSet.getString("contacter");
		approver=RecordSet.getString("approver");
		String address=RecordSet.getString("address");
		String begindate=RecordSet.getString("begindate");
		String begintime=RecordSet.getString("begintime");
		String enddate=RecordSet.getString("enddate");
		String endtime=RecordSet.getString("endtime");
		String desc=RecordSet.getString("desc_n");
		String customizeAddress = Util.null2String(RecordSet.getString("customizeAddress"));

		String SWFTitle="";
		String SWFRemark="";
		String SWFSubmiter="";
		String SWFAccepter="";

		
	    int repeatType = Util.getIntValue(RecordSet.getString("repeatType"),0);
		int repeatdays = Util.getIntValue(RecordSet.getString("repeatdays"),0);
		int repeatweeks = Util.getIntValue(RecordSet.getString("repeatweeks"),0);
		int repeatmonths = Util.getIntValue(RecordSet.getString("repeatmonths"),0);
		int repeatmonthdays = Util.getIntValue(RecordSet.getString("repeatmonthdays"),0);
		int repeatStrategy = Util.getIntValue(RecordSet.getString("repeatStrategy"),0);
		String rptWeekDays = RecordSet.getString("rptWeekDays");
	
		if(repeatType == 0){
			/*查询会议室管理员,并发出通知*/
			String roommanager="" ;
			RecordSet.executeSql("select resourceid from hrmrolemembers where roleid=11") ;
			while(RecordSet.next()){
			    roommanager+=","+ RecordSet.getString(1);
			}
			if(!roommanager.equals(""))
	        {
	            roommanager=roommanager.substring(1);
	            SWFTitle=Util.toScreen("会议室调配:",user.getLanguage(),"0");
	            SWFTitle += name;
	            SWFTitle += "-"+ResourceComInfo.getResourcename(contacter);
	            SWFTitle += "-"+CurrentDate;
	            SWFRemark="";
	            SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(CurrentUser),roommanager,SWFRemark);
	        }
		    /* end */
	
			//会议通知
			SWFAccepter="";
			SWFSubmiter="";
			RecordSet.executeProc("Meeting_Member2_SelectByType",meetingid+flag+"1");
			//Sql="select distinct membermanager from Meeting_Member2 where meetingid="+meetingid;
			//RecordSet.executeSql(Sql);
			while(RecordSet.next()){
				if(!RecordSet.getString("memberid").equals(caller) && !RecordSet.getString("memberid").equals(contacter) && !RecordSet.getString("memberid").equals(approver) ){
				SWFAccepter+=","+RecordSet.getString("memberid");
				}
			}
			RecordSet.executeProc("Meeting_Member2_SelectByType", meetingid+flag+"2");
    		while(RecordSet.next()){
    			SWFAccepter += "," + RecordSet.getString("membermanager");
    		}
			
    		//SWFAccepter += ","+caller + ","+ contacter;
			//会议通知
			if(!SWFAccepter.equals("")){
				SWFAccepter=SWFAccepter.substring(1);
				SWFTitle=Util.toScreen("会议通知:",7,"0"); //文字
				SWFTitle += name;
				SWFTitle += Util.toScreen(" 会议时间:",7,"0"); 
				SWFTitle += begindate+" "+begintime;
				SWFTitle +=" 会议地点:"+MeetingRoomComInfo.getMeetingRoomInfoname(""+address)+customizeAddress;
				SWFRemark="";
				SWFSubmiter=CurrentUser;
				SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
			}
	
			SWFAccepter="";
			Sql="select distinct hrmid from Meeting_Service2 where meetingid="+meetingid;
			RecordSet.executeSql(Sql);
			while(RecordSet.next()){
				SWFAccepter+=","+RecordSet.getString(1);
			}
			if(!SWFAccepter.equals("")){
				SWFAccepter=SWFAccepter.substring(1);
				SWFTitle=Util.toScreen("会议服务:",user.getLanguage(),"0"); //文字
				SWFTitle += name;
				SWFTitle += "-"+ResourceComInfo.getResourcename(contacter);
				SWFTitle += "-"+CurrentDate;
				SWFRemark="";
				SWFSubmiter=CurrentUser;
				SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
			}
	 	} else {
	            
			int intervaltime = 0;
			String otherinfo = "";
			if(repeatType == 1){
				intervaltime = repeatdays;
			} else if(repeatType == 2){
				intervaltime = repeatweeks;
				otherinfo = rptWeekDays;
			}else if(repeatType == 3){
				intervaltime = repeatmonths;
				otherinfo = "" + repeatmonthdays;
			}
	        MeetingInterval.updateMeetingRepeat(days,meetingid,begindate,enddate,""+repeatType,intervaltime,otherinfo,repeatStrategy);
	    }
	}
	response.sendRedirect("/meeting/data/ProcessMeeting.jsp?tab=1&meetingid="+meetingid);
	return;
}

//点批准后的操作，是做什么用的？
if(method.equals("approve111"))
{
		ProcPara =  meetingid;
		ProcPara += flag + CurrentUser;
		ProcPara += flag + CurrentDate;
		ProcPara += flag + CurrentTime;
		RecordSet.executeProc("Meeting_Approve",ProcPara);

		RecordSet.executeProc("Meeting_SelectByID",meetingid);
		RecordSet.next();
		String name=RecordSet.getString("name");
		String caller=RecordSet.getString("caller");
		String contacter=RecordSet.getString("contacter");
		String approver=RecordSet.getString("approver");
		String address=RecordSet.getString("address");
		String begindate=RecordSet.getString("begindate");
		String begintime=RecordSet.getString("begintime");
		String enddate=RecordSet.getString("enddate");
		String endtime=RecordSet.getString("endtime");
		String desc=RecordSet.getString("desc_n");
		String customizeAddress = Util.null2String(RecordSet.getString("customizeAddress"));

		String SWFTitle="";
		String SWFRemark="";
		String SWFSubmiter="";
		String SWFAccepter="";

	    int repeatType = Util.getIntValue(RecordSet.getString("repeatType"),0);
		int repeatdays = Util.getIntValue(RecordSet.getString("repeatdays"),0);
		int repeatweeks = Util.getIntValue(RecordSet.getString("repeatweeks"),0);
		int repeatmonths = Util.getIntValue(RecordSet.getString("repeatmonths"),0);
		int repeatmonthdays = Util.getIntValue(RecordSet.getString("repeatmonthdays"),0);
		int repeatStrategy = Util.getIntValue(RecordSet.getString("repeatStrategy"),0);
		String rptWeekDays = RecordSet.getString("rptWeekDays");
	
		if(repeatType == 0){
			if(!approver.equals(caller) && !approver.equals(contacter)){
	    		SWFTitle=Util.toScreen("会议批准:",user.getLanguage(),"0");  //文字
	    		SWFTitle += name;
	    		SWFTitle += "-"+ResourceComInfo.getResourcename(contacter);
	    		SWFTitle += "-"+CurrentDate;
	    		SWFRemark="";
	    		SWFSubmiter=approver;
	    		SWFAccepter=caller+","+contacter;
	    		SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
			}
	
			/*查询会议室管理员,并发出通知*/
			String roommanager="" ;
			RecordSet.executeSql("select resourceid from hrmrolemembers where roleid=11") ;
			while(RecordSet.next()){
			    roommanager+=","+ RecordSet.getString(1);
			}
			if(!roommanager.equals(""))
	        {
	            roommanager=roommanager.substring(1);
	            RecordSet.executeProc("Meeting_SelectByID",meetingid);
	            RecordSet.next();
	            SWFTitle=Util.toScreen("会议室调配:",user.getLanguage(),"0"); //文字
	            SWFTitle += RecordSet.getString("name");
	            SWFTitle += "-"+ResourceComInfo.getResourcename(contacter);
	            SWFTitle += "-"+CurrentDate;
	            SWFRemark="";
	            SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(CurrentUser),roommanager,SWFRemark);
	        }
		    /* end */
	
			//会议通知
			SWFAccepter="";
			//Sql="select distinct membermanager from Meeting_Member2 where meetingid="+meetingid;
			//RecordSet.executeSql(Sql);
			RecordSet.executeProc("Meeting_Member2_SelectByType",meetingid+flag+"1");
			while(RecordSet.next()){
				if(!RecordSet.getString("memberid").equals(caller) && !RecordSet.getString("memberid").equals(contacter) && !RecordSet.getString("memberid").equals(approver) ){
				SWFAccepter+=","+RecordSet.getString("memberid");
				}
			}
			RecordSet.executeProc("Meeting_Member2_SelectByType", meetingid+flag+"2");
    		while(RecordSet.next()){
    			SWFAccepter += "," + RecordSet.getString("membermanager");
    		}
			
    		//SWFAccepter += ","+caller + ","+ contacter;
			//会议通知
			if(!SWFAccepter.equals("")){
				SWFAccepter=SWFAccepter.substring(1);
				SWFTitle=Util.toScreen("会议通知:",7,"0"); //文字
				SWFTitle += name;
				SWFTitle += Util.toScreen(" 会议时间:",7,"0"); 
				SWFTitle += begindate+" "+begintime;
				SWFTitle +=" 会议地点:"+MeetingRoomComInfo.getMeetingRoomInfoname(""+address)+customizeAddress;
				SWFRemark="";
				SWFSubmiter=CurrentUser;
				SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
			}
	
			SWFAccepter="";
			Sql="select distinct hrmid from Meeting_Service2 where meetingid="+meetingid;
			RecordSet.executeSql(Sql);
			while(RecordSet.next()){
				SWFAccepter+=","+RecordSet.getString(1);
			}
			if(!SWFAccepter.equals("")){
				SWFAccepter=SWFAccepter.substring(1);
				SWFTitle=Util.toScreen("会议服务:",user.getLanguage(),"0"); //文字
				SWFTitle += name;
				SWFTitle += "-"+ResourceComInfo.getResourcename(contacter);
				SWFTitle += "-"+CurrentDate;
				SWFRemark="";
				SWFSubmiter=CurrentUser;
				SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
			}
	
			//会议查看权限？
	        MeetingViewer.setMeetingShareById(meetingid);
			 StaticObj.getInstance().removeObject("MeetingComInfo");
        } else {
	            
			int intervaltime = 0;
			String otherinfo = "";
			if(repeatType == 1){
				intervaltime = repeatdays;
			} else if(repeatType == 2){
				intervaltime = repeatweeks;
				otherinfo = rptWeekDays;
			}else if(repeatType == 3){
				intervaltime = repeatmonths;
				otherinfo = "" + repeatmonthdays;
			}
	        MeetingInterval.updateMeetingRepeat(days,meetingid,begindate,enddate,""+repeatType,intervaltime,otherinfo,repeatStrategy);
			MeetingViewer.setMeetingShareById(meetingid);
		 StaticObj.getInstance().removeObject("MeetingComInfo");
		}

	response.sendRedirect("/meeting/data/ProcessMeeting.jsp?tab=1&meetingid="+meetingid);
	return;
}

if(method.equals("schedule111"))
{
		String address1=Util.fromScreen(fu.getParameter("address"),user.getLanguage()) ;
		String begindate1=Util.fromScreen(fu.getParameter("begindate"),user.getLanguage()) ;
		String begintime1=Util.fromScreen(fu.getParameter("begintime"),user.getLanguage()) ;
		String enddate1=Util.fromScreen(fu.getParameter("enddate"),user.getLanguage()) ;
		String endtime1=Util.fromScreen(fu.getParameter("endtime"),user.getLanguage()) ;
		enddate1=begindate1 ;
		String updatesql="update meeting set address="+address1+",begindate='"+begindate1+"',begintime='"+begintime1+
		                "',enddate='"+enddate1+"',endtime='"+endtime1+"' where id="+meetingid ;
		RecordSet.executeSql(updatesql) ;

		RecordSet.executeProc("Meeting_Schedule",meetingid);

		RecordSet.executeProc("Meeting_SelectByID",meetingid);
		RecordSet.next();
		String name=RecordSet.getString("name");
		String caller=RecordSet.getString("caller");
		String contacter=RecordSet.getString("contacter");
		String approver=RecordSet.getString("approver");
		String address=RecordSet.getString("address");
		String begindate=RecordSet.getString("begindate");
		String begintime=RecordSet.getString("begintime");
		String enddate=RecordSet.getString("enddate");
		String endtime=RecordSet.getString("endtime");
		String desc=RecordSet.getString("desc_n");
		String customizeAddress = RecordSet.getString("customizeAddress");

		String SWFTitle="";
		String SWFRemark="";
		String SWFSubmiter="";
		String SWFAccepter="";

		SWFAccepter="";
		 int repeatType = Util.getIntValue(RecordSet.getString("repeatType"),0);
		int repeatdays = Util.getIntValue(RecordSet.getString("repeatdays"),0);
		int repeatweeks = Util.getIntValue(RecordSet.getString("repeatweeks"),0);
		int repeatmonths = Util.getIntValue(RecordSet.getString("repeatmonths"),0);
		int repeatmonthdays = Util.getIntValue(RecordSet.getString("repeatmonthdays"),0);
		int repeatStrategy = Util.getIntValue(RecordSet.getString("repeatStrategy"),0);
		String rptWeekDays = RecordSet.getString("rptWeekDays");
	
		if(repeatType == 0){
			//Sql="select distinct membermanager from Meeting_Member2 where meetingid="+meetingid;
			//RecordSet.executeSql(Sql);
			RecordSet.executeProc("Meeting_Member2_SelectByType",meetingid+flag+"1");
			while(RecordSet.next()){
				if(!RecordSet.getString("memberid").equals(caller) && !RecordSet.getString("memberid").equals(contacter) && !RecordSet.getString("memberid").equals(approver) ){
				SWFAccepter+=","+RecordSet.getString("memberid");
				}
			}
			RecordSet.executeProc("Meeting_Member2_SelectByType", meetingid+flag+"2");
    		while(RecordSet.next()){
    			SWFAccepter += "," + RecordSet.getString("membermanager");
    		}
			
    		//SWFAccepter += ","+caller + ","+ contacter;
			//会议通知
			if(!SWFAccepter.equals("")){
				SWFAccepter=SWFAccepter.substring(1);
				SWFTitle=Util.toScreen("会议通知:",7,"0"); //文字
				SWFTitle += name;
				SWFTitle += Util.toScreen(" 会议时间:",7,"0"); 
				SWFTitle += begindate+" "+begintime;
				SWFTitle +=" 会议地点:"+MeetingRoomComInfo.getMeetingRoomInfoname(""+address)+customizeAddress;
				SWFRemark="";
				SWFSubmiter=CurrentUser;
				SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
			}
	
			SWFAccepter="";
			Sql="select distinct hrmid from Meeting_Service2 where meetingid="+meetingid;
			RecordSet.executeSql(Sql);
			while(RecordSet.next()){
				SWFAccepter+=","+RecordSet.getString(1);
			}
			if(!SWFAccepter.equals("")){
				SWFAccepter=SWFAccepter.substring(1);
				SWFTitle=Util.toScreen("会议服务:",user.getLanguage(),"0"); //文字
				SWFTitle += name;
				SWFTitle += "-"+ResourceComInfo.getResourcename(contacter);
				SWFTitle += "-"+CurrentDate;
				SWFRemark="";
				SWFSubmiter=contacter;
				SysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
			}
		 } else {
			int intervaltime = 0;
			String otherinfo = "";
			if(repeatType == 1){
				intervaltime = repeatdays;
			} else if(repeatType == 2){
				intervaltime = repeatweeks;
				otherinfo = rptWeekDays;
			}else if(repeatType == 3){
				intervaltime = repeatmonths;
				otherinfo = "" + repeatmonthdays;
			}
	         MeetingInterval.updateMeetingRepeat(days,meetingid,begindate,enddate,""+repeatType,intervaltime,otherinfo,repeatStrategy);
	    }

	response.sendRedirect("/meeting/report/MeetingRoomPlan.jsp");
	return;
}

//取消会议
if(method.equals("cancelMeeting"))
{
	String meetingId = fu.getParameter("meetingId");
	String userId = "" + user.getUID();
	int meetingStatus = -1;
    
	String forwardFlag = Util.null2String(fu.getParameter("forward"));
	//会议详细中右键的取消会议后跳转界面
	String forward = "/meeting/data/NewMeetings.jsp";
	//会议室报表中的会议取消，跳转界面
	if(!"".equals(forwardFlag) && !"null".equals(forwardFlag)){
	     forward = "/meeting/report/MeetingRoomPlan.jsp";
	}
	
	//会议取消，触发系统提醒工作流
	String MeetingName="";
	String MeetingDate="";
	String MeetingContacter="";
	String callerN = "";
	String createrN = "";
	String remindTypeNew="";
	//总部议事管理员【编辑/取消】权限  议事规则类型 总部还是分部创建
	String isparliament = "";
	String subcompanyid = "";
	RecordSet.executeSql("select * from meeting where id = '"+meetingId+"'");
	while(RecordSet.next()){
	   MeetingName=RecordSet.getString("name");
	   MeetingDate=RecordSet.getString("begindate");
	   MeetingContacter=RecordSet.getString("contacter");
	   meetingStatus = RecordSet.getInt("meetingStatus");
	   callerN = RecordSet.getString("caller");
	   createrN = RecordSet.getString("creater");
	   remindTypeNew=RecordSet.getString("remindTypeNew");
	   isparliament = RecordSet.getString("isparliament");
	   subcompanyid = RecordSet.getString("subcompanyid");
	   
	}
	meetingLog.resetParameter();
	meetingLog.insSysLogInfo(user,Util.getIntValue(meetingId),MeetingName,"取消会议","303","2",1,Util.getIpAddr(request));
 
	String wfname="";
	String wfaccepter="";
	String wfremark="";
	
	wfname=Util.toMultiLangScreen("23269")+":"+MeetingName+"-"+ResourceComInfo.getLastname(user.getUID()+"")+"-"+CurrentDate;
	
	RecordSet.executeProc("Meeting_Member2_SelectByType",meetingId+flag+"1");
	//RecordSet.executeSql("select membermanager from Meeting_Member2 where meetingid = '"+meetingId+"'");
	while(RecordSet.next()){
	   wfaccepter+=","+RecordSet.getString("memberid");
	}
	
	//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
	//SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(MaxID),Util.getIntValue(contacter),caller,"");
	//会议取消  发送系统提醒流程  接收人员增加   by lq  2015-11-23 start
	//获取流程接收人员id
	String getHrmId = " select mt.caller,mt.contacter, mt.recorder,mt.hrmmembers,mt.otherpersonnel, mt.tempotherpersonnel "+
					  " , mt.ccmeetingminutes,mt.ccmeetingnotice  from meeting mt "+
					  " where id = "+meetingId;
	RecordSet.executeSql(getHrmId);
	if(RecordSet.next()){
		String rCaller = Util.null2String(RecordSet.getString("caller"));
		String rContacter = Util.null2String(RecordSet.getString("contacter"));
		String rRecorder = Util.null2String(RecordSet.getString("recorder"));
		String rHrmmembers = Util.null2String(RecordSet.getString("hrmmembers"));
		String rOtherpersonnel = Util.null2String(RecordSet.getString("otherpersonnel"));
		String rTempotherpersonnel = Util.null2String(RecordSet.getString("tempotherpersonnel"));
		String rCcmeetingminutes = Util.null2String(RecordSet.getString("ccmeetingminutes"));
		String rCcmeetingnotice = Util.null2String(RecordSet.getString("ccmeetingnotice"));
		
		//主持人
		if(!"".equals(rCaller) && (wfaccepter+",").indexOf(","+rCaller+",") == -1){
			wfaccepter += ","+rCaller;
		}
		//创建人
		if(!"".equals(rContacter) && (wfaccepter+",").indexOf(","+rContacter+",") == -1){
			wfaccepter += ","+rContacter;
		}
		
		//记录人
		if(!"".equals(rRecorder) ){
			String temp[] = rRecorder.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
		//其他参会人1
		if(!"".equals(rOtherpersonnel) ){
			String temp[] = rOtherpersonnel.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
		//其他参会人2
		if(!"".equals(rTempotherpersonnel) ){
			String temp[] = rTempotherpersonnel.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
		//会议纪要抄送人
		//if(!"".equals(rCcmeetingminutes) ){
		//	String temp[] = rCcmeetingminutes.split(",");
		//	if(temp.length>0){
		//		for(int i=0;i<temp.length;i++){
		//			String rHrmid = temp[i];
		//			
		//			if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
		//				wfaccepter += ","+rHrmid;
		//			}
		//		}			 
				
		//	}
			
		//}
		
		//会议通知抄送人
		if(!"".equals(rCcmeetingnotice) ){
			String temp[] = rCcmeetingnotice.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
	}
	 
	//System.out.println("wfaccepter:"+wfaccepter);
	//会议取消  发送系统提醒流程  接收人员增加   by lq  2015-11-23 end
	
	if(!"".equals(wfaccepter)){
		wfaccepter=wfaccepter.substring(1);
	}
	
	if(1!=meetingStatus){
	    SysRemindWorkflow.setMeetingSysRemind(wfname,Util.getIntValue(meetingId),Util.getIntValue(MeetingContacter),wfaccepter,wfremark);
	}
	
	int userPrm=1;

	if(userId.equals(MeetingContacter)&&!userId.equals(callerN)){
	   userPrm = meetingSetInfo.getContacterPrm();
	} else if(userId.equals(createrN)&&!userId.equals(callerN)){
	   userPrm = meetingSetInfo.getCreaterPrm();
	} else if(userId.equals(callerN)){
		userPrm = meetingSetInfo.getCallerPrm();
		if(userPrm != 3) userPrm = 3;
	}
	
	//更新状态
	RecordSet.executeSql("SELECT * FROM Meeting WHERE id = " + meetingId + " AND (meetingStatus = 1 OR meetingStatus = 2)");	
	boolean cancelRight = HrmUserVarify.checkUserRight("Canceledpermissions:Edit",user);
	//总部议事管理员【编辑/取消】权限    判断当前用户是否有议总部事管理员权限	by lq  2015-10-25
	boolean isPrivilege  = HrmUserVarify.checkUserRight("RulesOfProcedure:Headquarters", user);
	//分部议事管理员【编辑/取消】权限    判断当前用户是否有议分部议事管理员权限 by lq  2015-11-2
	boolean isSubcompanyPrivilege  = HrmUserVarify.checkUserRight("RulesOfProcedure:Division", user);
	 
	//总部议事管理员【编辑/取消】权限    修改判断条件，添加当前用户是否有议总部事管理员权限对分部创建 议事规则有取消权限
	if(RecordSet.next()  && ( userPrm == 3 || cancelRight || (isPrivilege && "2".equals(isparliament)) || (isSubcompanyPrivilege && "2".equals(isparliament)&&SubCompany.equals(subcompanyid)) ))
	{
		meetingStatus = RecordSet.getInt("meetingStatus");
		//RecordSetDB.executeSql("UPDATE Meeting SET meetingStatus = 4 WHERE id = " + meetingId);
		Calendar today = Calendar.getInstance();
		String nowdate = Util.add0(today.get(Calendar.YEAR), 4) +"-"+
                 Util.add0(today.get(Calendar.MONTH) + 1, 2) +"-"+
                 Util.add0(today.get(Calendar.DAY_OF_MONTH), 2) ;
        String nowtime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
                Util.add0(today.get(Calendar.MINUTE), 2) + ":" +
                Util.add0(today.get(Calendar.SECOND), 2); 
        RecordSetDB.executeSql("update meeting set cancel='1',meetingStatus=4,canceldate='"+nowdate+"',canceltime='"+nowtime+"' where id="+meetingId);
		//标识会议已经被取消
		StringBuffer stringBuffer = new StringBuffer();
		stringBuffer.append("UPDATE Meeting_View_Status SET status = '2'");		
		stringBuffer.append(" WHERE meetingId = ");
		stringBuffer.append(meetingId);
		stringBuffer.append(" AND userId <> ");
		stringBuffer.append(CurrentUser);
		
		RecordSetDB.executeSql(stringBuffer.toString());
		
		/** Add By Hqf for TD9970 Start**/
		//表示当日计划已经被删除
		//stringBuffer.setLength(0);	
		//stringBuffer.append("DELETE FROM  WorkPlan ");
		//stringBuffer.append(" WHERE meetingId = ");
		//stringBuffer.append("'");
		//stringBuffer.append(meetingId);
		//stringBuffer.append("'");
		//RecordSetDB.executeSql(stringBuffer.toString());
		/** Add By Hqf for TD9970 End**/
		RecordSet.execute("select id from workplan where meetingId='"+meetingId+"'");
		weaver.WorkPlan.WorkPlanHandler wph = new weaver.WorkPlan.WorkPlanHandler();
		while(RecordSet.next()){
			wph.delete(RecordSet.getString("id"));
		}
	

		//待审批则删除相关流程
		if(1 == meetingStatus)
		{	
			
	   	    
			int requestId = 0;	
	   	    int meetingtype1=0;
	 		RecordSet.executeSql("SELECT  requestid,name,meetingtype,repeattype FROM Meeting WHERE id = " + meetingId);
	    	if(RecordSet.next())
	    	{
	       		requestId = Integer.valueOf(Util.null2String(RecordSet.getString("requestId"))).intValue();
	       		if(RecordSet.getInt("repeattype")>0){//周期会议,查看周期会议审批流程
		    		RecordSet.executeSql("Select formid From Meeting_Type t1 join workflow_base t2 on t1.approver1=t2.id  where t1.approver1>0 and t1.ID ="+meetingtype1);
		    	}else{
		    		RecordSet.executeSql("Select formid From Meeting_Type t1 join workflow_base t2 on t1.approver=t2.id  where t1.approver>0 and t1.ID ="+meetingtype1);
		    	}
		   		if(RecordSet.next()){
		   			int fromid=RecordSet.getInt("formid");
		   		    if(requestId>0){
			   			MeetingWFUtil.deleteWF(requestId,meetingId,fromid);
		   		        RecordSet.executeSql("delete From workflow_currentoperator where requestid="+requestId);
		   		    }
		   		}
	       	}
		}
		
	    MeetingInterval.deleteMeetingRepeat(meetingId);
	    //之前是正常会议,被取消后进行取消会议提醒
	    if(meetingStatus==2&&!"".equals(remindTypeNew)){
		    MeetingRemindUtil.cancelMeeting(meetingId);
	    }
	}
	///response.sendRedirect(forward);
	%>
	<script type="text/javascript">
		window.parent.closeWinAFrsh();
	</script>
	<%
	return;
}else if(method.equals("overMeeting")){ //结束会议overMeeting
	System.out.println("method=="+method);
	String meetingId = fu.getParameter("meetingId");
	String userId = "" + user.getUID();
	int meetingStatus = -1;
    
	String forwardFlag = Util.null2String(fu.getParameter("forward"));
	//会议详细中右键的取消会议后跳转界面
	String forward = "/meeting/data/NewMeetings.jsp";
	//会议室报表中的会议取消，跳转界面
	if(!"".equals(forwardFlag) && !"null".equals(forwardFlag)){
	     forward = "/meeting/report/MeetingRoomPlan.jsp";
	}
	
	//会议取消，触发系统提醒工作流
	String MeetingName="";
	String MeetingDate="";
	String MeetingContacter="";
	String callerN = "";
	String createrN = "";
	String remindTypeNew="";
	//总部议事管理员【编辑/取消】权限  议事规则类型 总部还是分部创建
	String isparliament = "";
	String subcompanyid = "";
	String recorderN = "";
	RecordSet.executeSql("select * from meeting where id = '"+meetingId+"'");
	while(RecordSet.next()){
	   MeetingName=RecordSet.getString("name");
	   MeetingDate=RecordSet.getString("begindate");
	   MeetingContacter=RecordSet.getString("contacter");
	   meetingStatus = RecordSet.getInt("meetingStatus");
	   callerN = RecordSet.getString("caller");
	   createrN = RecordSet.getString("creater");
	   remindTypeNew=RecordSet.getString("remindTypeNew");
	   isparliament = RecordSet.getString("isparliament");
	   subcompanyid = RecordSet.getString("subcompanyid");
	   recorderN = Util.null2String(RecordSet.getString("recorder"));
	}
	meetingLog.resetParameter();
	meetingLog.insSysLogInfo(user,Util.getIntValue(meetingId),MeetingName,"结束会议","303","2",1,Util.getIpAddr(request));
 
	String wfname="";
	String wfaccepter="";
	String wfremark="";
	
	wfname="会议结束:"+MeetingName+"-"+ResourceComInfo.getLastname(user.getUID()+"")+"-"+CurrentDate;
	wfremark = wfname;
	
	RecordSet.executeProc("Meeting_Member2_SelectByType",meetingId+flag+"1");
	//RecordSet.executeSql("select membermanager from Meeting_Member2 where meetingid = '"+meetingId+"'");
	while(RecordSet.next()){
	   wfaccepter+=","+RecordSet.getString("memberid");
	}
	
	//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
	//SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(MaxID),Util.getIntValue(contacter),caller,"");
	//会议取消  发送系统提醒流程  接收人员增加   by lq  2015-11-23 start
	//获取流程接收人员id
	String getHrmId = " select mt.caller,mt.contacter, mt.recorder,mt.hrmmembers,mt.otherpersonnel, mt.tempotherpersonnel "+
					  " , mt.ccmeetingminutes,mt.ccmeetingnotice  from meeting mt "+
					  " where id = "+meetingId;
	RecordSet.executeSql(getHrmId);
	String rHrmmembers = "";
	if(RecordSet.next()){
		String rCaller = Util.null2String(RecordSet.getString("caller"));
		String rContacter = Util.null2String(RecordSet.getString("contacter"));
		String rRecorder = Util.null2String(RecordSet.getString("recorder"));
		rHrmmembers = Util.null2String(RecordSet.getString("hrmmembers"));
		String rOtherpersonnel = Util.null2String(RecordSet.getString("otherpersonnel"));
		String rTempotherpersonnel = Util.null2String(RecordSet.getString("tempotherpersonnel"));
		String rCcmeetingminutes = Util.null2String(RecordSet.getString("ccmeetingminutes"));
		String rCcmeetingnotice = Util.null2String(RecordSet.getString("ccmeetingnotice"));
		
		//主持人
		if(!"".equals(rCaller) && (wfaccepter+",").indexOf(","+rCaller+",") == -1){
			wfaccepter += ","+rCaller;
		}
		//创建人
		if(!"".equals(rContacter) && (wfaccepter+",").indexOf(","+rContacter+",") == -1){
			wfaccepter += ","+rContacter;
		}
		
		//记录人
		if(!"".equals(rRecorder) ){
			String temp[] = rRecorder.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
		//其他参会人1
		if(!"".equals(rOtherpersonnel) ){
			String temp[] = rOtherpersonnel.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
		//其他参会人2
		if(!"".equals(rTempotherpersonnel) ){
			String temp[] = rTempotherpersonnel.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
		//会议纪要抄送人
		if(!"".equals(rCcmeetingminutes) ){
			String temp[] = rCcmeetingminutes.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
		//会议通知抄送人
		if(!"".equals(rCcmeetingnotice) ){
			String temp[] = rCcmeetingnotice.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					
					if(!"".equals(rHrmid) && (wfaccepter+",").indexOf(","+rHrmid+",") == -1){
						wfaccepter += ","+rHrmid;
					}
				}			 
				
			}
			
		}
		
	}
	 
	//System.out.println("wfaccepter:"+wfaccepter);
	//会议取消  发送系统提醒流程  接收人员增加   by lq  2015-11-23 end
	
	if(!"".equals(wfaccepter)){
		wfaccepter=wfaccepter.substring(1);
	}
	
	if(1!=meetingStatus){
	    //SysRemindWorkflow.setMeetingSysRemind(wfname,Util.getIntValue(meetingId),Util.getIntValue(MeetingContacter),wfaccepter,wfremark);
	}
	
	int userPrm=1;

	if(userId.equals(MeetingContacter)&&!userId.equals(callerN)){
	   userPrm = meetingSetInfo.getContacterPrm();
	} else if(userId.equals(createrN)&&!userId.equals(callerN)){
	   userPrm = meetingSetInfo.getCreaterPrm();
	} else if(userId.equals(callerN)){
		userPrm = meetingSetInfo.getCallerPrm();
		if(userPrm != 3) userPrm = 3;
	} else if(userId.equals(recorderN)){
		userPrm = 3;
	}
	
	//更新状态
	RecordSet.executeSql("SELECT * FROM Meeting WHERE id = " + meetingId + " AND (meetingStatus = 1 OR meetingStatus = 2)");	
	boolean cancelRight = HrmUserVarify.checkUserRight("Canceledpermissions:Edit",user);
	//总部议事管理员【编辑/取消】权限    判断当前用户是否有议总部事管理员权限	by lq  2015-10-25
	boolean isPrivilege  = HrmUserVarify.checkUserRight("RulesOfProcedure:Headquarters", user);
	//分部议事管理员【编辑/取消】权限    判断当前用户是否有议分部议事管理员权限 by lq  2015-11-2
	boolean isSubcompanyPrivilege  = HrmUserVarify.checkUserRight("RulesOfProcedure:Division", user);
	 
	//总部议事管理员【编辑/取消】权限    修改判断条件，添加当前用户是否有议总部事管理员权限对分部创建 议事规则有取消权限
	if(RecordSet.next()  && ( userPrm == 3 || cancelRight || (isPrivilege && "2".equals(isparliament)) || (isSubcompanyPrivilege && "2".equals(isparliament)&&SubCompany.equals(subcompanyid)) ))
	{
		meetingStatus = RecordSet.getInt("meetingStatus");
		//RecordSetDB.executeSql("UPDATE Meeting SET meetingStatus = 4 WHERE id = " + meetingId);
		Calendar today = Calendar.getInstance();
		String nowdate = Util.add0(today.get(Calendar.YEAR), 4) +"-"+
                 Util.add0(today.get(Calendar.MONTH) + 1, 2) +"-"+
                 Util.add0(today.get(Calendar.DAY_OF_MONTH), 2) ;
        String nowtime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
                Util.add0(today.get(Calendar.MINUTE), 2);
        RecordSetDB.executeSql("update meeting set enddate='"+nowdate+"',endtime='"+nowtime+"' where id="+meetingId);
		//标识会议已经被取消
		//StringBuffer stringBuffer = new StringBuffer();
		//stringBuffer.append("UPDATE Meeting_View_Status SET status = '2'");		
		//stringBuffer.append(" WHERE meetingId = ");
		//stringBuffer.append(meetingId);
		//stringBuffer.append(" AND userId <> ");
		//stringBuffer.append(CurrentUser);
		
		//RecordSetDB.executeSql(stringBuffer.toString());
		
		/** Add By Hqf for TD9970 Start**/
		//表示当日计划已经被删除
		//stringBuffer.setLength(0);	
		//stringBuffer.append("DELETE FROM  WorkPlan ");
		//stringBuffer.append(" WHERE meetingId = ");
		//stringBuffer.append("'");
		//stringBuffer.append(meetingId);
		//stringBuffer.append("'");
		//RecordSetDB.executeSql(stringBuffer.toString());
		/** Add By Hqf for TD9970 End**/
		//RecordSet.execute("select id from workplan where meetingId='"+meetingId+"'");
		//weaver.WorkPlan.WorkPlanHandler wph = new weaver.WorkPlan.WorkPlanHandler();
		//while(RecordSet.next()){
		//	wph.delete(RecordSet.getString("id"));
		//}
		//待审批则删除相关流程
		
		
    	//重新计算会议成本
    	if(!"".equals(rHrmmembers)){
    		RecordSet rs = new RecordSet();
    		rs.executeSql("select begindate,begintime,enddate,endtime from Meeting where id="+meetingId);
    		//查询标准计算费用
    		String m_begindate = "";
   			String m_begintime = "";
   			String m_enddate = "";
   			String m_endtime = "";
    		if(rs.next()){
    			m_begindate = Util.null2String(rs.getString("begindate"));
    			m_begintime = Util.null2String(rs.getString("begintime"));
    			m_enddate = Util.null2String(rs.getString("enddate"));
    			m_endtime = Util.null2String(rs.getString("endtime"));
    		}
   			
    		String tvalue = TimeUtils.computeMeetingCost(rHrmmembers,m_begindate,m_begintime,m_enddate,m_endtime);
    		
    		String[] tvalueArr = tvalue.split(",");
    		double cost = Util.getDoubleValue(tvalueArr[0]);
    		double hour = Util.getDoubleValue(tvalueArr[1]);
   			String countAttendSql = "update Meeting  set cost='"+cost+"',xiaoshi='"+hour+"' where id = "+meetingId;	
   			RecordSet.executeSql(countAttendSql);
    	}
	}
	///response.sendRedirect(forward);
	%>
	<script type="text/javascript">
		window.parent.closeWinAFrsh();
	</script>
	<%
	return;
}
%>