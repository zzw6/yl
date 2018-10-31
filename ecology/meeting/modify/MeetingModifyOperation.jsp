<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="weaver.meeting.defined.MeetingFieldManager"%>
<%@page import="weaver.meeting.remind.MeetingRemindUtil"%>
<%@page import="weaver.meeting.defined.MeetingWFUtil"%>
<%@page import="weaver.meeting.defined.MeetingCreateWFUtil"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ page import="weaver.email.MailSend" %>
<%@page import="weaver.general.StaticObj"%>
<%@ page import="weaver.file.FileUpload" %>
<%@ page import="weaver.docs.docs.DocExtUtil" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="weaver.meeting.Maint.MeetingInterval" %>
<jsp:useBean id="MeetingRoomComInfo" class="weaver.meeting.Maint.MeetingRoomComInfo" scope="page"/>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet2" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSetDB" class="weaver.conn.RecordSet" scope="page" />
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
String method = Util.null2String(fu.getParameter("method"));
String meetingid =Util.null2String(fu.getParameter("meetingid"));
String meetingnamestr =Util.null2String(fu.getParameter("meetingnamestr"));
String isChage =Util.null2String(fu.getParameter("isChage"));
String tempDesc=Util.htmlFilter4UTF8(Util.spacetoHtml(Util.null2String(fu.getParameter("tempDesc"))));

if(method.equals("edit"))//修改或者编辑页面直接提交  edit页面修改和提交
{	
	
	BaseBean.writeLog("SELECT approvedate FROM Meeting where id = " + meetingid);
	//原有基本信息
	RecordSet.executeProc("Meeting_SelectByID",meetingid);
	RecordSet.next();
	String contacter = RecordSet.getString("contacter");
	
	
	String meetingtype = RecordSet.getString("meetingtype");
	String oldapprovedate = RecordSet.getString("approvedate");
	String oldbegindate = RecordSet.getString("begindate");
	String oldbegintime = RecordSet.getString("begintime");
	String oldenddate = RecordSet.getString("enddate");
	String oldendtime = RecordSet.getString("endtime");
	String oldaddress = RecordSet.getString("address");
	String oldcustomizeAddress = RecordSet.getString("customizeaddress");
	String oldhrmmembers = RecordSet.getString("hrmmembers");
	String oldccmeetingnotice=Util.null2String(RecordSet.getString("ccmeetingnotice"));
	int oldtotalmember = RecordSet.getInt("totalmember");
	String oldothermembers = RecordSet.getString("othermembers");
	int oldaddressselect = RecordSet.getInt("addressselect");
	String olddesc = RecordSet.getString("desc_n");

	
	//会议相关人共享开始
	String recorder = RecordSet.getString("recorder");					//记录人
	String ccmeetingminutes = RecordSet.getString("ccmeetingminutes");	//会议纪要抄送人
	String ccmeetingnotice = RecordSet.getString("ccmeetingnotice");	//会议通知抄送人
	//会议相关人共享结束
	
	String isAppraise = Util.null2String(RecordSet.getString("isAppraise"));	//会议通知抄送人
	
	//基本信息
	int roomType = 1;
	int addressselect = Util.getIntValue(fu.getParameter("addressselect"),0);
	String address=Util.null2String(fu.getParameter("address"));//会议地点
	String customizeAddress = Util.null2String(fu.getParameter("customizeAddress"));
	if(addressselect == 1){
		address = "";
		roomType=2;
	}else if(addressselect == 0){
		customizeAddress = "";
		roomType = 1;
	}
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
	
	//参会人员
    String hrmmembers=Util.null2String(fu.getParameter("hrmmembers"));//参会人员
  	//描述,可为空
	String desc=Util.htmlFilter4UTF8(Util.spacetoHtml(Util.null2String(fu.getParameter("desc_n"))));
    
	String ccMeetingNoticeNew = Util.null2String(fu.getParameter("ccmeetingnotice"));
	//获取会议纪要抄送人 id
	String ccMeetingMinutesNew = Util.null2String(fu.getParameter("ccmeetingminutes"));	

    
    //add by cjl 2017-02-23 添加会议时长变更导致审批流程的问题
    boolean istrigger = false;
    
	int issettime = meetingSetInfo.getIssettime();
	if(issettime>0){
		int maintimes = meetingSetInfo.getMaintimes() * 60;
		int subtimes = meetingSetInfo.getSubtimes() * 60;
		//计算会议时长
		weaver.conn.RecordSet rs2 = new weaver.conn.RecordSet();
		long times2 = com.weaver.formmodel.util.DateHelper.getMinutesBetween(enddate+"/"+endtime+":00",begindate+"/"+begintime+":00");
		rs2.executeSql("select subcompanyid from MeetingRoom where id = '"+address+"'");
		String meetingRoom_subcompanyid2 = "";
		if(rs2.next()){
			meetingRoom_subcompanyid2 = Util.null2String(rs2.getString("subcompanyid"));
		}
			
		if(meetingRoom_subcompanyid2.equals(SubCompany)){
			if(times2 > maintimes){
				istrigger = true;
			}
		}else{
			if(times2 > subtimes){
				istrigger = true;
			}
		}
	}
	
	
	if(roomType == 1){
		if(!"".equals(oldapprovedate)){
			
			
			String oldFromDate = oldbegindate + "/" + oldbegintime+":00";
			String oldToDate = oldenddate + "/" + oldendtime+":00";
			
			String fromDate = begindate + "/" + begintime+":00";
			String toDate = enddate + "/" + endtime+":00";
			
			
			long times3 = com.weaver.formmodel.util.DateHelper.getMinutesBetween(oldFromDate,fromDate);
			
			long times4 = com.weaver.formmodel.util.DateHelper.getMinutesBetween(oldToDate,toDate);
			
			BaseBean.writeLog("times3 : " + times3);
			BaseBean.writeLog("times4 : " + times4);
			
			if(times3 > 0 || times4 < 0){
			
				//提示不可修改待审批的会议
			%>
			<script type="text/javascript">
			    parent.top.Dialog.alert("只能在开始日期，开始时间、结束日期，结束时间以内进行调整！");
			    parent.dataRfsh();
			    parent.closeDialog();
			    //parent.location.href="/meeting/modify/MeetingViewTab.jsp?meetingid=<%=meetingid%>&viewtype=viewpage&needRefresh=true";
			</script>
			<%
				return;
			}
		}else{
			String approvewfid = "";
			RecordSetDB.executeSql("Select approver From Meeting_Type t1 join workflow_base t2 on t1.approver=t2.id  where t1.approver>0 and t1.ID ="+meetingtype);
			if(RecordSetDB.next()){
				approvewfid = RecordSetDB.getString("approver");
			}
		    
	    
			if(istrigger && !"".equals(approvewfid)){
				//提示不可修改待审批的会议
				%>
				<script type="text/javascript">
				    parent.top.Dialog.alert("此会议时长超出范围，需要流程审批会议，故不能调整会议信息！请删除会议信息后重新创建会议信息！");
				    parent.dataRfsh();
				    parent.closeDialog();
				    //parent.location.href="/meeting/modify/MeetingViewTab.jsp?meetingid=<%=meetingid%>&viewtype=viewpage&needRefresh=true";
				</script>
				<%
				return;
			}
		}
	}
	String description= "您有会议: "+meetingnamestr+"   会议时间:"+begindate+" "+begintime+"  会议地点:"+MeetingRoomComInfo.getMeetingRoomInfoname(""+address)+customizeAddress;
	String updateSql1 =  "update Meeting set ";
	updateSql1 += "begindate='" + begindate+"' ";
	updateSql1 += ",begintime='" + begintime+"' ";
	updateSql1 += ",enddate='" + enddate+"' ";
	updateSql1 += ",endtime='" + endtime+"' ";
	updateSql1 += ",hrmmembers='" + hrmmembers+"' ";
	updateSql1 += ",description='" + description+"' ";
	updateSql1 += ",addressselect='" + addressselect+"' ";
	//if(addressselect==0){
		updateSql1 += ",address='"+address+"' ";
	//}else{
		updateSql1 += ",customizeAddress='" + customizeAddress+"' ";
	//}
	updateSql1 += " where id = " + meetingid;
    //System.out.println("updateSql1:"+updateSql1);	
	RecordSet.executeSql(updateSql1);
	
	String updateSql = "update Meeting set repeatType = " + repeatType 
					+" , repeatbegindate = '"+ begindate +"' "
					+" , repeatenddate = '"+ enddate +"' "
					+" , roomType = "+ roomType
					+" , hrmmembers = '"+ hrmmembers+"' ";
	
					if("1".equals(isChage)){
						updateSql += " , desc_n = '"+ desc +"'  ";
					}else{
						updateSql += " , desc_n = '"+ tempDesc +"'  ";
					}
	updateSql += " where id = " + meetingid;
	//System.out.println("updateSql22:"+updateSql);	
	
	RecordSet.executeSql(updateSql);
	
	String updateSqlDesc = "update Meeting set "
	+"  ccmeetingminutes = '"+ ccMeetingMinutesNew +"' "
	+" , ccmeetingnotice = '"+ ccMeetingNoticeNew +"' ";
	
	if("1".equals(isChage)){
		updateSql += " , desc_n = '"+ desc +"'  ";
	}else{
		updateSql += " , desc_n = '"+ tempDesc +"'  ";
	}
	updateSqlDesc += " where id = " + meetingid;
	
	
	
	RecordSet.executeSql(updateSqlDesc);
	
	if(addressselect==0){
		RecordSet.executeSql("update Meeting set customizeAddress = '' where id = " + meetingid);
	}else{
		RecordSet.executeSql("update Meeting set address = '' where id = " + meetingid);
	}
	
	//保存自定义字段
	//MeetingFieldManager mfm=new MeetingFieldManager(1);
	//mfm.editCustomData(fu,Util.getIntValue(meetingid));
	
	//删除会议人员
	RecordSet.executeProc("Meeting_Member2_Delete",meetingid);
		
	//删除会议中相关的标识是否查看的信息
	//StringBuffer stringBuffer = new StringBuffer();
	//stringBuffer.append("DELETE FROM Meeting_View_Status WHERE meetingId = ");
	//stringBuffer.append(meetingid);
	//RecordSet.executeSql(stringBuffer.toString());

	StringBuffer stringBf = new StringBuffer();
	
	ArrayList arrayhrmids02 = Util.TokenizerString(hrmmembers,",");
	for(int i=0;i<arrayhrmids02.size();i++){
		String ProcPara =  meetingid;
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
		int vsCount = 0;
		RecordSet.executeSql("select count(*) as vsCount from Meeting_View_Status where meetingId = "+ meetingid +" and userId = " +  arrayhrmids02.get(i));
		if(RecordSet.next()){
			vsCount = Util.getIntValue(RecordSet.getString("vsCount"), 0);
		}
		
		if(vsCount <= 0){
			StringBuffer stringBuffer = new StringBuffer();
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
		
		stringBf.append(arrayhrmids02.get(i) + ",");
	}
	
	String u_ids = TimeUtils.replaceRepStr(stringBf.toString());
	
	//删除会议中相关的标识是否查看的信息
	StringBuffer stringBuffer = new StringBuffer();
	stringBuffer.append("DELETE FROM Meeting_View_Status ");
	stringBuffer.append(" WHERE meetingId = " + meetingid );
	stringBuffer.append(" and userId not in ("+ u_ids +") ");
	RecordSet.executeSql(stringBuffer.toString());

	//会议议程
	int topicrows=Util.getIntValue(Util.null2String(fu.getParameter("topicrows")),0);
	
	int mtcount = 0;
	RecordSet.executeSql("select count(*) as mtcount from Meeting_Topic where meetingid = " + meetingid);
	if(RecordSet.next()){
		mtcount = Util.getIntValue(RecordSet.getString("mtcount"));
	}
	if(topicrows>0){
		String recordsetids="";
		for(int i=1;i<=topicrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topic_data_"+i));
			if(!recordsetid.equals("")) recordsetids+=","+recordsetid;
		}
		if(!recordsetids.equals("")){
			recordsetids=recordsetids.substring(1);
			String Sql = "delete from Meeting_Topic WHERE ( meetingid = "+meetingid+" and id not in ("+recordsetids+"))";
			RecordSet.executeSql(Sql);
		}else{
			String Sql = "delete from Meeting_Topic WHERE ( meetingid = "+meetingid+")";
			RecordSet.executeSql(Sql);
		}
		MeetingFieldManager mfm2=new MeetingFieldManager(2);
		for(int i=1;i<=topicrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topic_data_"+i));
			mfm2.editCustomDataDetail(fu,Util.getIntValue(recordsetid),i,Util.getIntValue(meetingid));
		}
	}
	
	
	
	//会议议程附件
	int topicAttachrows=Util.getIntValue(Util.null2String(fu.getParameter("topicAttachrows")),0);
	
	int mtaCount = 0;
	RecordSet.executeSql("select count(*) as mtaCount from Meeting_Topic_attach where meetingid = " + meetingid);
	if(RecordSet.next()){
		mtaCount = Util.getIntValue(RecordSet.getString("mtaCount"));
	}
	
	StringBuffer docsb = new StringBuffer();
	
	RecordSet.executeSql("select fujian from Meeting_Topic_Attach where meetingid = " + meetingid);
	while(RecordSet.next()){
		docsb.append(RecordSet.getString("fujian") + ",");
	}
	
	String lishiData = "," + TimeUtils.replaceRepStr(docsb.toString()) + ",";
	
	StringBuffer docall = new StringBuffer();
	
	if(topicAttachrows>0){
		String recordsetids="";
		for(int i=1;i<=topicAttachrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topicattach_data_"+i));
			if(!recordsetid.equals("")) recordsetids+=","+recordsetid;
		}
		if(!recordsetids.equals("")){
			recordsetids=recordsetids.substring(1);
			String Sql = "delete from Meeting_Topic_attach WHERE ( meetingid = "+meetingid+" and id not in ("+recordsetids+"))";
			RecordSet.executeSql(Sql);
		}else{
			String Sql = "delete from Meeting_Topic_attach WHERE ( meetingid = "+meetingid+")";
			RecordSet.executeSql(Sql);
		}
		MeetingFieldManager mfm4=new MeetingFieldManager(4);
		for(int i=1;i<=topicAttachrows;i++){
			String recordsetid=Util.null2String(fu.getParameter("topicattach_data_"+i));
			mfm4.editCustomDataDetail(fu,Util.getIntValue(recordsetid),i,Util.getIntValue(meetingid));
			//附件删除逻辑start
			int docFileNum = Util.getIntValue(request.getParameter("field37_" + i + "_idnum"), 0);
			if(docFileNum > 0){
				String fujian = "";
				RecordSet.executeSql("select fujian from Meeting_Topic_attach where id = " + recordsetid);
				while(RecordSet.next()){
					fujian = "," + TimeUtils.replaceRepStr(Util.null2String(RecordSet.getString("fujian"))) + ",";
				}
				for(int k = 0; k < docFileNum; k++){
					String fileDocId = Util.null2String(request.getParameter("field37_" + i + "_id_" + k));
					String isDelete = Util.null2String(request.getParameter("field37_" + i + "_del_" + k));
					if("1".equals(isDelete)){
						fujian = fujian.replace(","+fileDocId + ",", ",");
					}
				}
				String docIds = TimeUtils.replaceRepStr(fujian);
				if("".equals(docIds)){
					RecordSet.executeSql("delete from Meeting_Topic_attach where id = " + recordsetid);
				}else{
					RecordSet.executeSql("update Meeting_Topic_attach set fujian = '"+ docIds +"' where id = " + recordsetid);
				}
			}
			//附件删除逻辑end
			String t_docid = Util.null2String(request.getParameter("field37_" + i));
			
			if(!"".equals(t_docid)){
				String[] t_docidArr = t_docid.split(",");
				
				for(int j = 0; j < t_docidArr.length; j++){
					String m_id = Util.null2String(t_docidArr[j] + "");
					
					if(!"".equals(m_id)){
						if(!lishiData.contains(m_id)){
							docall.append(m_id  + ",");
						}
					}
				}
			}
		}
	}
	if(topicAttachrows != mtaCount || topicrows != mtcount){
		
		
	}
	
    MeetingViewer.setMeetingShareById(meetingid);
	//MeetingComInfo.removeMeetingInfoCache();
	StaticObj.getInstance().removeObject("MeetingComInfo");
	//会议相关人共享开始
	
	//String[] ccmeetingminutesArr = ccmeetingminutes.split(",");
	//for ( int i = 0 ; i< ccmeetingminutesArr.length ; i ++)  {
		//int t_userid = Util.getIntValue(ccmeetingminutesArr[i] + "", 0);
	//	if(t_userid > 0){
	//		char separator = Util.getSeparator() ;
	//		String para = meetingid + separator + t_userid + separator + "1" + separator + "3";
	//		rs.executeProc("MeetingShareDetail_Insert",""+para);
	//	}
    // }
	
	String[] ccmeetingnoticeArr = ccmeetingnotice.split(",");
	for ( int i = 0 ; i< ccmeetingnoticeArr.length ; i ++)  {
		int t_userid = Util.getIntValue(ccmeetingnoticeArr[i] + "", 0);
		if(t_userid > 0){
			char separator = Util.getSeparator() ;
			String para = meetingid + separator + t_userid + separator + "1" + separator + "103";
			rs.executeProc("MeetingShareDetail_Insert",""+para);
		}
    }
	
	String[] recorderArr = recorder.split(",");
	for ( int i = 0 ; i< recorderArr.length ; i ++)  {
		int t_userid = Util.getIntValue(recorderArr[i] + "", 0);
		if(t_userid > 0){
			char separator = Util.getSeparator() ;
			String para = meetingid + separator + t_userid + separator + "1" + separator + "2";
			rs.executeProc("MeetingShareDetail_Insert",""+para);
		}
    }
	//会议相关人共享结束
	
	
	
	//文档和附件的共享明细
	MeetingUtil.meetingDocShare(meetingid);
	
	//会议信息修改通知提醒（1，只有会议时间和会议地点变更 2，只有参会人员变更， 3，时间，地点和参会人员都变更）
	String MeetingNotice = "";
	String Remarks = "";
	String tzTitle = "";
	String addressStr = "";
	String oldAddressStr = "";
	String addressHtml = "";
	String oldAddressHtml = "";
	if(addressselect == 0){ //内部会议室
		addressStr = address;
		addressHtml = MeetingRoomComInfo.getMeetingRoomInfoname(""+address);
	}else{
		addressStr = customizeAddress;
		addressHtml = customizeAddress;
	}
	
	if(oldaddressselect == 0){
		oldAddressStr = oldaddress;
		oldAddressHtml = MeetingRoomComInfo.getMeetingRoomInfoname(""+oldaddress);
	}else{
		oldAddressStr = oldcustomizeAddress;
		oldAddressHtml = oldcustomizeAddress;
	}
	
	String tmpName = "";
	String tmpccmeetingnotice = "";
	RecordSet.executeSql("select name,ccmeetingnotice from meeting where id = " + meetingid);
	if(RecordSet.next()){
		tmpName = Util.null2String(RecordSet.getString("name"));
		tmpccmeetingnotice = Util.null2String(RecordSet.getString("ccmeetingnotice"));
	}
	if(!oldccmeetingnotice.equals(tmpccmeetingnotice)){
		String temp_hrm_add = "";
		ArrayList<String> hrmlist = Util.TokenizerString(tmpccmeetingnotice, ",");
		ArrayList<String> oldhrmlist = Util.TokenizerString(oldccmeetingnotice, ",");
		for (int index = 0; index < hrmlist.size(); index++) {
			String h = hrmlist.get(index);
			if (!oldhrmlist.contains(h)) {
				temp_hrm_add += "," + h;
			}
		}
		String tmpUser = TimeUtils.replaceRepStr(temp_hrm_add);
		
		String t_description = "会议抄送通知：";
		t_description+= tmpName + "会议";
		t_description += "会议时间："+begindate+" "+begintime+" — " + enddate+" "+endtime;
		t_description += "会议地点：" + addressHtml;
		String t_mailContent = "以下是提醒内容，请点击查看详情：<br>";
		t_mailContent += "<a style=\"color:red\" target=\"_blank\" href=\"/weavernorth/meeting/MeetingInfo.jsp?id="+meetingid+"\">"+tmpName+"</a><br>";
		MailSend t_Send = new MailSend();
		boolean bool = t_Send.sendSysInternalMail("1", tmpUser, null, t_description, t_mailContent);
	}
	/*人员没有变化，其他信息有调整*/
	if(oldhrmmembers.equals(hrmmembers) && (
			  !oldbegindate.equals(begindate) || 
			  !oldbegintime.equals(begintime) ||
			  !oldenddate.equals(enddate) ||
			  !oldendtime.equals(endtime) ||
			  !oldAddressStr.equals(addressStr) ||
			  "1".equals(isChage) )){
		
		MeetingNotice = hrmmembers+","+oldccmeetingnotice;
		
		
		Remarks = "会议信息变更前：";
		String Remarks1 = "<br>会议信息变更后：";
		
		if(!oldbegindate.equals(begindate) || !oldbegintime.equals(begintime)){
			Remarks += "  会议开始时间:"+oldbegindate+" "+oldbegintime;
			Remarks1 += "  会议开始时间:<font color=red>"+begindate+" "+begintime+"</font>";
		}else{
			Remarks += "  会议开始时间:"+oldbegindate+" "+oldbegintime;
			Remarks1 += "  会议开始时间:"+begindate+" "+begintime;
		}
		if(!oldenddate.equals(enddate) || !oldendtime.equals(endtime)){
			Remarks += "  会议结束时间："+oldenddate+" "+oldendtime;
			Remarks1 +="  会议结束时间：<font color=red>"+enddate+" "+endtime+"</font>";
		}else{
			Remarks += "  会议结束时间："+oldenddate+" "+oldendtime;
			Remarks1 +="  会议结束时间："+enddate+" "+endtime;
		}
		if(!oldAddressHtml.equals(addressHtml) ){
			Remarks += "  会议地点:"+oldAddressHtml;
			Remarks1 += "  会议地点:<font color=red>"+addressHtml+"</font>";
		}else{
			Remarks += "  会议地点:"+oldAddressHtml;
			Remarks1 += "  会议地点:"+addressHtml;
		}
		
		
		if("1".equals(isChage)){
			Remarks += "  会议要求:"+olddesc;
			Remarks1 += "  会议要求:<font color=red>"+desc+"</font>";
		}else{
			Remarks += "  会议要求:"+olddesc;
			Remarks1 += "  会议要求:"+desc;
		}
		
	    Remarks += Remarks1;     
	    tzTitle = "会议变更通知: "+meetingnamestr+"   ";
	    if(!oldbegindate.equals(begindate) || !oldbegintime.equals(begintime) ){ //时间变更了
	    	tzTitle += "会议的开始时间变更为:"+begindate+" "+begintime;
	    }else{//时间+会议地址都变更了 
	    	//tzTitle += "会议开始时间:"+begindate+" "+begintime;
	    }
	    if(!oldenddate.equals(enddate) || !oldendtime.equals(endtime) ){ //时间变更了
	    	tzTitle +="   会议的结束时间变更为:"+enddate+" "+endtime;
	    }else{//时间+会议地址都变更了 
	    	//tzTitle +="   会议结束时间:"+enddate+" "+endtime;
	    }
	    if(!oldAddressHtml.equals(addressHtml) ){
	    	tzTitle +="   会议的地点变更为:"+addressHtml;
	    }else{
	    	//tzTitle +="   会议地点:"+addressHtml;
	    }
	    
	    if("1".equals(isChage)){
	    	tzTitle +="   会议要求有调整，请点击链接查看调整后内容";
	    }
	    
		//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
		SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(meetingid),Util.getIntValue(contacter),TimeUtils.replaceRepStr(MeetingNotice),Remarks);
	
	}else if(!oldhrmmembers.equals(hrmmembers) && ( /*人员调整了，会议室时间，地址等未调整*/
			  oldbegindate.equals(begindate) &&  
			  oldbegintime.equals(begintime) && 
			  oldenddate.equals(enddate) && 
			  oldendtime.equals(endtime) && 
			  oldAddressStr.equals(addressStr) &&
			  "0".equals(isChage) )){
		//判断人员变动情况
		String temp_hrm_add = "";
		String temp_hrm_remove = "";
		ArrayList<String> hrmlist = Util.TokenizerString(hrmmembers,",");
		ArrayList<String> oldhrmlist = Util.TokenizerString(oldhrmmembers,",");
		for(int index =0; index < hrmlist.size(); index++){
			String h = hrmlist.get(index);
			if(!oldhrmlist.contains(h)){
				temp_hrm_add+=","+h;
			}
		}
		if(temp_hrm_add.length()>1){
			temp_hrm_add = temp_hrm_add.substring(1);
		}
		
		for(int index =0; index < oldhrmlist.size(); index++){
			String h = oldhrmlist.get(index);
			if(!hrmlist.contains(h)){
				temp_hrm_remove+=","+h;
			}
		}
		if(temp_hrm_remove.length()>1){
			temp_hrm_remove = temp_hrm_remove.substring(1);
		}
		
		/*减少人员发送邮件*/
		MeetingNotice = temp_hrm_remove;	
		Remarks = "您的"+meetingnamestr+"会议因议程作出调整，您无需再参加，请知晓！";
		tzTitle = "会议取消通知："+meetingnamestr;//+"   会议时间:"+begindate+" "+begintime+"  会议地点:"+addressHtml;
		//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
		if(!"".equals(MeetingNotice))
		SysRemindWorkflow.setMeetingSysRemind(false,tzTitle,Util.getIntValue(meetingid),Util.getIntValue(contacter),TimeUtils.replaceRepStr(MeetingNotice),Remarks);
		
		/*新增人员发送邮件*/
		MeetingNotice = temp_hrm_add;	
		tzTitle = "会议通知: "+meetingnamestr+"   会议时间:"+begindate+" "+begintime+"  会议地点:"+addressHtml;
		String Remarks1 = "";
		//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
		if(!"".equals(MeetingNotice)){
			SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(meetingid),Util.getIntValue(contacter),TimeUtils.replaceRepStr(MeetingNotice),Remarks1);
			createWP(meetingid,fu.getRemoteAddr());
		}
	
	}else if(!oldhrmmembers.equals(hrmmembers) && ( /*人员信息和会议时间地点信息都发生了变化*/
			  !oldbegindate.equals(begindate) || 
			  !oldbegintime.equals(begintime) ||
			  !oldenddate.equals(enddate) ||
			  !oldendtime.equals(endtime) ||
			  !oldAddressStr.equals(addressStr) ||
			  "1".equals(isChage) )){
		//判断人员变动情况
		String temp_hrm = "";
		String temp_hrm_add = "";
		String temp_hrm_remove = "";
		ArrayList<String> hrmlist = Util.TokenizerString(hrmmembers,",");
		ArrayList<String> oldhrmlist = Util.TokenizerString(oldhrmmembers,",");
		for(int index =0; index < hrmlist.size(); index++){
			String h = hrmlist.get(index);
			if(!oldhrmlist.contains(h)){
				temp_hrm_add += ","+h;
			}
		}
		if(temp_hrm_add.length()>1){
			temp_hrm_add = temp_hrm_add.substring(1);
		}
		
		for(int index =0; index < oldhrmlist.size(); index++){
			String h = oldhrmlist.get(index);
			if(!hrmlist.contains(h)){
				temp_hrm_remove+=","+h;
			}else{
				temp_hrm += ","+h;
			}
		}
		if(temp_hrm_remove.length()>1){
			temp_hrm_remove = temp_hrm_remove.substring(1);
		}
		
		if(temp_hrm.length()>1){
			temp_hrm = temp_hrm.substring(1);
		}
		MeetingNotice = temp_hrm+","+oldccmeetingnotice;
		
		Remarks = "会议信息变更前：";
		String Remarks1 = "<br>会议信息变更后：";
		
		if(!oldbegindate.equals(begindate) || !oldbegintime.equals(begintime)){
			Remarks += "  会议开始时间:"+oldbegindate+" "+oldbegintime;
			Remarks1 += "  会议开始时间:<font color=red>"+begindate+" "+begintime+"</font>";
		}else{
			Remarks += "  会议开始时间:"+oldbegindate+" "+oldbegintime;
			Remarks1 += "  会议开始时间:"+begindate+" "+begintime;
		}
		if(!oldenddate.equals(enddate) || !oldendtime.equals(endtime)){
			Remarks += "  会议结束时间："+oldenddate+" "+oldendtime;
			Remarks1 +="  会议结束时间：<font color=red>"+enddate+" "+endtime+"</font>";
		}else{
			Remarks += "  会议结束时间："+oldenddate+" "+oldendtime;
			Remarks1 +="  会议结束时间："+enddate+" "+endtime;
		}
		if(!oldAddressHtml.equals(addressHtml) ){
			Remarks += "  会议地点:"+oldAddressHtml;
			Remarks1 += "  会议地点:<font color=red>"+addressHtml+"</font>";
		}else{
			Remarks += "  会议地点:"+oldAddressHtml;
			Remarks1 += "  会议地点:"+addressHtml;
		}
		
		if("1".equals(isChage)){
			Remarks += "  会议要求:"+olddesc;
			Remarks1 += "  会议要求:<font color=red>"+desc+"</font>";
		}else{
			Remarks += "  会议要求:"+olddesc;
			Remarks1 += "  会议要求:"+desc;
		}
		
		Remarks += Remarks1;
		tzTitle = "会议变更通知: "+meetingnamestr+"   ";
	    if(!oldbegindate.equals(begindate) || !oldbegintime.equals(begintime) ){ //时间变更了
	    	tzTitle += "会议的开始时间变更为:"+begindate+" "+begintime;
	    }else{//时间+会议地址都变更了 
	    	//tzTitle += "会议开始时间:"+begindate+" "+begintime;
	    }
	    if(!oldenddate.equals(enddate) || !oldendtime.equals(endtime) ){ //时间变更了
	    	tzTitle +="   会议的结束时间变更为:"+enddate+" "+endtime;
	    }else{//时间+会议地址都变更了 
	    	//tzTitle +="   会议结束时间:"+enddate+" "+endtime;
	    }
	    if(!oldAddressHtml.equals(addressHtml) ){
	    	tzTitle +="   会议的地点变更为:"+addressHtml;
	    }else{
	    	//tzTitle +="   会议地点:"+addressHtml;
	    }
	    
	    if("1".equals(isChage)){
	    	tzTitle +="   会议要求有调整，请点击链接查看调整后内容";
	    }
	    
		//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
		if(!"".equals(MeetingNotice))
		SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(meetingid),Util.getIntValue(contacter),TimeUtils.replaceRepStr(MeetingNotice),Remarks);
		
		/*减少人员发送邮件*/
		MeetingNotice = temp_hrm_remove;	
		Remarks = "您的"+meetingnamestr+"会议因议程作出调整，您无需再参加，请知晓！";
		tzTitle = "会议取消通知："+meetingnamestr;//+"   会议时间:"+begindate+" "+begintime+"  会议地点:"+addressHtml;
		//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
		if(!"".equals(MeetingNotice))
		SysRemindWorkflow.setMeetingSysRemind(false,tzTitle,Util.getIntValue(meetingid),Util.getIntValue(contacter),TimeUtils.replaceRepStr(MeetingNotice),Remarks);
		
		/*新增人员发送邮件*/
		MeetingNotice = temp_hrm_add;	
		tzTitle = "会议通知: "+meetingnamestr+"   会议时间:"+begindate+" "+begintime+"  会议地点:"+addressHtml;
		Remarks1 = "";
		//发送系统提醒流程：参数 标题、会议id、流程创建人、流程接收人、备注
		if(!"".equals(MeetingNotice)){
			SysRemindWorkflow.setMeetingSysRemind(tzTitle,Util.getIntValue(meetingid),Util.getIntValue(contacter),TimeUtils.replaceRepStr(MeetingNotice),Remarks1);
			createWP(meetingid,fu.getRemoteAddr());
		}
	}
	
	if("3".equals(isAppraise)){
		RecordSet.executeSql("update meeting set isAppraise = 3 where id = " + meetingid);
	}else{
		RecordSet.executeSql("update meeting set isAppraise = 2 where id = " + meetingid);
	}
	String tp_meetingtype = "";
	RecordSet.executeSql("select meetingtype from meeting where id = " + meetingid);
	if(RecordSet.next()){
		tp_meetingtype = Util.null2String(RecordSet.getString("meetingtype"));
	}
	RecordSet.executeProc("Meeting_Type_SelectByID",tp_meetingtype);
	RecordSet.next();
	String isTickling = Util.null2String(RecordSet.getString("isTickling")) ;
	if("1".equals(isTickling)){
		RecordSet.executeSql("update meeting set isAppraise = 3 where id = " + meetingid);
	}
	//重新计算会议成本
	if(!"".equals(hrmmembers)){
		
		String totalmember = Util.null2String(fu.getParameter("totalmember"));
		
		RecordSet rs3 = new RecordSet();
		rs3.executeSql("select begindate,begintime,enddate,endtime from Meeting where id="+meetingid);
		//查询标准计算费用
		String m_begindate = "";
		String m_begintime = "";
		String m_enddate = "";
		String m_endtime = "";
		if(rs3.next()){
			m_begindate = Util.null2String(rs3.getString("begindate"));
			m_begintime = Util.null2String(rs3.getString("begintime"));
			m_enddate = Util.null2String(rs3.getString("enddate"));
			m_endtime = Util.null2String(rs3.getString("endtime"));
		}
		
		String tvalue = TimeUtils.computeMeetingCost(hrmmembers,m_begindate,m_begintime,m_enddate,m_endtime);
		
		String[] tvalueArr = tvalue.split(",");
		double cost = Util.getDoubleValue(tvalueArr[0]);
		double hour = Util.getDoubleValue(tvalueArr[1]);
		
		
		String countAttendSql = "update Meeting  set cost='"+cost+"',xiaoshi='"+hour+"',totalmember="+totalmember+" where id = "+meetingid;	
		
		RecordSet.executeSql(countAttendSql);
	}
	
	meetingLog.resetParameter();
	meetingLog.insSysLogInfo(user,Util.getIntValue(meetingid),meetingnamestr,"修改会议信息"+(repeatType>0?"模板":""),"303","2",1,Util.getIpAddr(request));
	//日程操作  start 
	//删除日程
	RecordSet.execute("select id from workplan where meetingid = '"+meetingid+"'");
	while(RecordSet.next()){
		RecordSetDB.execute("DELETE FROM WorkPlanShareDetail where workid="+RecordSet.getString(1));
	}
	RecordSet.executeSql("DELETE FROM WorkPlan WHERE meetingid = '"+meetingid+"'");
	//重新生成新的提醒和日程
	//MeetingInterval.createWPAndRemind(meetingid,null,Util.getIpAddr(request),false,true);
	createWP(meetingid,fu.getRemoteAddr());
	//日程操作  end
	%>
	<script type="text/javascript">
	    parent.dataRfsh();
	    parent.closeDialog();
	    //parent.location.href="/meeting/modify/MeetingViewTab.jsp?meetingid=<%=meetingid%>&viewtype=viewpage&needRefresh=true";
	</script>
	<%
}

%>
<%!
//创建日程
private void  createWP(String meetingid,String ip) throws Exception{
	RecordSet rs = new RecordSet();
	RecordSet recordSet = new RecordSet();
	rs.executeSql("select * from meeting where (cancel <> '1' or cancel is null) and meetingstatus = 2 and  id ="+meetingid);
	if(!rs.next()){
		rs.writeLog("会议id：["+meetingid+"]生成日程和相关提醒失败，会议不存在，或者没有审批通过，或者已经取消。");
	} else {
		weaver.meeting.Maint.MeetingRoomComInfo meetingRoomComInfo = new weaver.meeting.Maint.MeetingRoomComInfo();
		String name=Util.null2String(rs.getString("name"));
		String caller=Util.null2String(rs.getString("caller"));
		String contacter=Util.null2String(rs.getString("contacter"));
		String address=Util.null2String(rs.getString("address"));
		String creater=Util.null2String(rs.getString("creater"));
		String begindate=Util.null2String(rs.getString("begindate"));
		String begintime=Util.null2String(rs.getString("begintime"));
		String desc=Util.spacetoHtml(Util.null2String(rs.getString("desc")));
		String enddate=Util.null2String(rs.getString("enddate"));
		String endtime=Util.null2String(rs.getString("endtime"));
		String customizeAddress = Util.null2String(rs.getString("customizeAddress"));
	    String createdate=Util.null2String(rs.getString("createdate"));
        String createtime=Util.null2String(rs.getString("createtime"));
        String description= Util.toMultiLangScreen("84535,2103")+": "+name+"   "+Util.toMultiLangScreen("81901")+":"+begindate+" "+begintime+//您有会议  会议时间
	    " "+Util.toMultiLangScreen("2105")+":"+meetingRoomComInfo.getMeetingRoomInfoname(""+address)+customizeAddress;
	  
		//生成日程接收人和流程接收人的 接收者
	    String SWFAccepter = "";
	    String sql="select distinct membermanager from Meeting_Member2 where meetingid="+meetingid;
		recordSet.executeSql(sql);
		while(recordSet.next()){
			SWFAccepter+=","+recordSet.getString(1);
		}
	    if(!"".equals(SWFAccepter)){
	    	SWFAccepter=SWFAccepter.substring(1);
	    	//生成日程
	    	weaver.domain.workplan.WorkPlan workPlan = new weaver.domain.workplan.WorkPlan();
	    	weaver.WorkPlan.WorkPlanService workPlanService = new weaver.WorkPlan.WorkPlanService();
		    workPlan.setCreaterId(Integer.parseInt(creater));
		    workPlan.setWorkPlanType(Integer.parseInt(weaver.Constants.WorkPlan_Type_ConferenceCalendar));        
		    workPlan.setWorkPlanName(name);    
		    workPlan.setUrgentLevel(weaver.Constants.WorkPlan_Urgent_Normal);
		    workPlan.setResourceId(SWFAccepter);
		    workPlan.setBeginDate(begindate);
		    workPlan.setEndDate(enddate);
		    if(begintime!=null&&!"".equals(begintime)){
		        workPlan.setBeginTime(begintime);  //开始时间
		    } else{
		        workPlan.setBeginTime(weaver.Constants.WorkPlan_StartTime);  //开始时间
		    }
		    if(begintime!=null&&!"".equals(begintime)){//结束时间
		    	workPlan.setEndTime(endtime);  
		    } else{
		    	workPlan.setEndTime(weaver.Constants.WorkPlan_EndTime);  //结束时间
		    }	
		    //增加提醒
		    workPlan.setRemindType("1");  //提醒方式,会议不通过日程提醒
	        workPlan.setRemindBeforeStart("0");  //是否开始前提醒
	        workPlan.setRemindBeforeEnd("0");  //是否结束前提醒
		    workPlan.setRemindTimesBeforeStart(0);  //开始前提醒时间
		    workPlan.setRemindTimesBeforeEnd(0);  //结束前提醒时间
	    	workPlan.setRemindDateBeforeStart(begindate);  //开始前提醒日期
	    	workPlan.setRemindTimeBeforeStart(workPlan.getBeginTime());  //开始前提醒时间
	    	workPlan.setRemindDateBeforeEnd(begindate);  //结束前提醒日期
	    	workPlan.setRemindTimeBeforeEnd(workPlan.getEndTime());  //结束前提醒时间
	    	workPlan.setMeeting(meetingid);//关联会议ID 
	    	
		    workPlan.setDescription(description);
		    workPlanService.insertWorkPlan(workPlan);  //插入日程
		    
		    weaver.WorkPlan.WorkPlanLogMan logMan = new weaver.WorkPlan.WorkPlanLogMan();
		    //插入日志
			String[] logParams = new String[] {String.valueOf(workPlan.getWorkPlanID()), weaver.WorkPlan.WorkPlanLogMan.TP_CREATE, caller, ip};
		    logMan.writeViewLog(logParams);
	    }
	}
}
%>