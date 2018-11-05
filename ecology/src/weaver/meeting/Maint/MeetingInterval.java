package weaver.meeting.Maint;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;

import weaver.Constants;
import weaver.WorkPlan.WorkPlanLogMan;
import weaver.WorkPlan.WorkPlanService;
import weaver.conn.RecordSet;
import weaver.domain.workplan.WorkPlan;
import weaver.email.MailSend;
import weaver.general.BaseBean;
import weaver.general.StaticObj;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.hrm.report.schedulediff.HrmScheduleDiffUtil;
import weaver.hrm.resource.ResourceComInfo;
import weaver.meeting.MeetingViewer;
import weaver.meeting.defined.MeetingFieldManager;
import weaver.meeting.remind.MeetingRemindUtil;
import weaver.mobile.plugin.ecology.service.PushNotificationService;
import weaver.system.SysRemindWorkflow;
import weaver.systeminfo.SystemEnv;

/**
 * 周期会议生成普通会议
 * 复制会议等
 * @author HuangGuanGuan
 * Jan 15, 2015
 *
 */
public class MeetingInterval{

	/**
	 * 获取重复预订会议时间数组
	 * @param begindate
	 * @param enddate
	 * @param type
	 * @param otherinfo
	 * @return
	 */
	private static ArrayList getBeginDate(String begindate,String enddate,String type,int intervaltime,String otherinfo){
		ArrayList begindatelist = new ArrayList();
		
		if("1".equals(type) && intervaltime > 0) { //天重复
			begindatelist.add(begindate);
			while(begindate.compareTo(enddate) <= 0) {				
				begindate = TimeUtil.dateAdd(begindate,intervaltime);
				if(begindate.compareTo(enddate) <= 0) {
					begindatelist.add(begindate);
				}
			}
		}
		else if("2".equals(type) && intervaltime > 0) { //周重复
			otherinfo=otherinfo.replaceAll("7", "0");//转换数据库保存的星期天为7 计算为0
			String weekdate = "";
			if(!"".equals(otherinfo)){
				weekdate = getFirstDayOfWeek(begindate);
				for(int i=0; i<7; i++) {
					String weekcount = String.valueOf(TimeUtil.dateWeekday(weekdate));
	                if(otherinfo.indexOf(weekcount) >= 0) { 
	                	if(weekdate.compareTo(begindate)>=0&&weekdate.compareTo(enddate) <= 0){
		        			begindatelist.add(weekdate);
	                	}
	                }
	                weekdate = TimeUtil.dateAdd(weekdate,1);
				}
				
				while(begindate.compareTo(enddate) <= 0) {
			          begindate = TimeUtil.dateAdd(begindate,intervaltime*7);
			          weekdate = getFirstDayOfWeek(begindate);
					  
			          for(int i=0; i<7; i++) {
			        	  String weekcount = String.valueOf(TimeUtil.dateWeekday(weekdate));
			        	  if(!"".equals(otherinfo)){
				              if(otherinfo.indexOf(weekcount) >= 0) {
								  if(weekdate.compareTo(enddate) <= 0){
				        			begindatelist.add(weekdate);
								  }else{
									  break;
								  }
				              }
			        	  }
			              weekdate = TimeUtil.dateAdd(weekdate,1);
			          }
			   }
      	   }
		 }
		else if("3".equals(type) && intervaltime > 0) { //月重复
			 int year = Integer.parseInt(begindate.substring(0, 4));
			 int month = Integer.parseInt(begindate.substring(5, 7));
			 String datestr = "";
			 if(!"".equals(otherinfo)) {
				 if(Integer.parseInt(otherinfo) < 10) {
					 datestr = "0"+otherinfo;
				 } else {
					 datestr = otherinfo;
				 }			 
			 }
			 String firstDate = String.valueOf(year)+"-"+(month < 10?("0"+String.valueOf(month)):String.valueOf(month))+"-"+datestr;
			 if(begindate.compareTo(firstDate) <= 0){
				 begindatelist.add(firstDate);
			 }
			 while((begindate.substring(0, 7)).compareTo(enddate.substring(0, 7)) <= 0){
				 //if(month == 12) {
				//	year = year+1;
				//	month = 1;
				// } else {
					month = month + intervaltime;
				// }
				 if(month > 12) {
					year = year+month/12;
					month = month%12;
				 }
				 String monthstr = "";
				 if(month < 10){
					monthstr = "0"+String.valueOf(month);
				 } else {
					monthstr = String.valueOf(month);
				 }
				 
				 begindate = String.valueOf(year)+"-"+monthstr+"-"+datestr;
				 if((begindate.substring(0, 7)).compareTo(enddate.substring(0, 7)) <= 0) {
					begindatelist.add(begindate);
				 }
		     }
		 }
		 //System.out.println(begindatelist);
		 return begindatelist;
	}
 
	 /**
     * 返回特定日期所处这一周的周一所处的日期
     * 
     * @return String
     */
	private static String getFirstDayOfWeek(String date) {
        Calendar calendar = TimeUtil.getCalendar(date);
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        Date dateBegin = new Date(0);
        dateBegin.setTime(calendar.getTimeInMillis() - (long) (TimeUtil.dateWeekday(date) - 1) * 24 * 60 * 60 * 1000);
        return formatter.format(dateBegin);
    }
    /**
     * 删除未生成的周期会议
     * @param meetingid
     */
    public static void deleteMeetingRepeat(String meetingid){
    	RecordSet rs = new RecordSet();
    	rs.executeSql("delete from Meeting_repeat where meetingid=" + meetingid);
    }
    
    /**
     * 获取某天的第n个工作日后的日期
     * @param CurrentDate
     * @param days
     * @return
     */
    private static String getWorkDayByDays(String CurrentDate, int days){
    	return getWorkDayByDays(CurrentDate,days,1);
    }
    
    /**
     * 获取某天的第n个工作日后的日期
     * @param CurrentDate
     * @param days
     * @param subCompanyId 分部id
     * @return
     */
    private static String getWorkDayByDays(String CurrentDate, int days, int subCompanyId){
    	String edate = CurrentDate;
    	String tmpdate = edate;
		HrmScheduleDiffUtil hsdu = new HrmScheduleDiffUtil();
    	for(int i = 0,j=0; i < days; i++,j++){
    		tmpdate = TimeUtil.dateAdd(tmpdate, 1);
    		//System.out.println(tmpdate+"--"+hsdu.getIsWorkday(tmpdate,1,""));
    		if(hsdu.getIsWorkday(tmpdate,subCompanyId,"")){
    			edate = tmpdate;
    		} else {
    			i--;
    		}
    		if(j >= 100){
    			//超过100天的推迟，则认为没有设置工作日,日期不变。
    			edate = CurrentDate;
    			break;
    		}
    	}
    	return edate;
    }
    
    /**
     * 判断工作日是否设定：从当前日期往后一百天检查是否存在工作日，要是存在则有设定，要是不存在就没有设定。
     * @param currentDate
     * @param subCompanyId
     * @param countryid
     * @return 已经设定 true  没有设定 false
     */
    private static boolean hasWorkDaySet(String currentDate,int subCompanyId,String countryid){
    	String edate = currentDate;
    	String tmpdate = edate;
    	boolean rtn = false;
		HrmScheduleDiffUtil hsdu = new HrmScheduleDiffUtil();
    	for(int i = 0,j=0; i < 100; i++,j++){
    		tmpdate = TimeUtil.dateAdd(tmpdate, 1);
    		if(hsdu.getIsWorkday(tmpdate,subCompanyId,countryid)){
    			rtn = true;
    			break;
    		}
    	}
    	return rtn;
    }
    
    /**
     * 获取某天的第n个工作日后的日期
     * @param CurrentDate
     * @param days
     * @return
     */
    private static String getDayByDays(String CurrentDate, int days){
    	String edate = CurrentDate;
    	String tmpdate = edate;
    	for(int i = 0; i < days; i++){
    		tmpdate = TimeUtil.dateAdd(tmpdate, 1);
    		edate = tmpdate;
    	}
    	return edate;
    }
    
    /**
     * 添加重复会议-更新记录
     * @param days
     * @param meetingid
     * @param begindate
     * @param enddate
     * @param type
     * @param intervaltime
     * @param otherinfo
     */
    public static void updateMeetingRepeat(int days, String meetingid, String begindate,String enddate,String type,int intervaltime,String otherinfo){
    	updateMeetingRepeat(days,meetingid,begindate,enddate,type,intervaltime,otherinfo,0);
    }
    
    /**
     * 添加重复会议-更新记录
     * @param days
     * @param meetingid
     * @param begindate
     * @param enddate
     * @param type
     * @param intervaltime
     * @param otherinfo
     * @param repeatStrategy 重复会议策略
     */
    public static void updateMeetingRepeat(int days, String meetingid, String begindate,String enddate,String type,int intervaltime,String otherinfo, int repeatStrategy){
    	ArrayList begindatelist = getBeginDate(begindate, enddate, type, intervaltime, otherinfo);
    	RecordSet rs = new RecordSet();
		Date newdate = new Date() ;
    	long datetime = newdate.getTime() ;
		Timestamp timestamp = new Timestamp(datetime) ;
		String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
		//提前days生成会议
		String edate = getDayByDays(CurrentDate, days);
		boolean firstMtOver = false;
		for(int d=0; d<begindatelist.size(); d++) {
			String date = (String)begindatelist.get(d);
			if(date.compareTo(edate) < 0 ){
				try {
					cloneMeeting(meetingid, date);
				} catch (Exception e) {
					rs.writeLog("生成会议失败,meetingid:["+meetingid+"]date:+["+date+"]");
					rs.writeLog(e);
				}
			} else {
				rs.executeSql("insert into Meeting_repeat(meetingid,begindate) values("+meetingid+",'"+date+"') ");
			}
		}
		try {
			StaticObj.getInstance().removeObject("MeetingComInfo");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
    
    /**
     * 结束重复会议
     * @param meetingid 重复模板会议
     */
    public void stopIntervalMeeting(String meetingid){
    	stopIntervalMeeting(meetingid, null);
    }
    
    /**
     * 提前结束重复会议
     * @param meetingid 重复模板会议
     * @param enddate 结束日期
     */
    public void stopIntervalMeeting(String meetingid, String enddate){
    	if(meetingid == null || "".equals(meetingid)){
    		return;
    	}
    	RecordSet rs = new RecordSet();
    	String stopdate = enddate;
    	
    	if(enddate == null || "".equals(enddate)){
    		Date newdate = new Date() ;
        	long datetime = newdate.getTime() ;
    		Timestamp timestamp = new Timestamp(datetime);
    		stopdate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
    	}
    	rs.executeSql("delete from Meeting_repeat where begindate > '" + stopdate+"' and meetingid = "+ meetingid);
    	
    	rs.executeSql("update Meeting set meetingstatus = 5, repeatenddate = '"+stopdate+"' where  id = "+ meetingid);

    }
    
    /**
     * 批量生成重复会议
     * @param days
     * @throws Exception
     */
    public static void batchCloneMeeting() throws Exception{
    	MeetingSetInfo meetingSetInfo = new MeetingSetInfo();
    	Date newdate = new Date() ;
    	long datetime = newdate.getTime() ;
		Timestamp timestamp = new Timestamp(datetime) ;
		String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
		//提前days生成会议
		String enddate = getDayByDays(CurrentDate, meetingSetInfo.getDays());
		RecordSet rs = new RecordSet();
		RecordSet recordSet = new RecordSet();
		rs.executeSql("select id, meetingid, begindate from Meeting_repeat where begindate <= '" + enddate+"'");
		while(rs.next()){
			String meetingid = Util.null2String(rs.getString("meetingid"));
			String begindate = Util.null2String(rs.getString("begindate"));
			String id = Util.null2String(rs.getString("id"));
			if(begindate.compareTo(CurrentDate) >= 0){
				cloneMeeting(meetingid, begindate);
			}
			recordSet.executeSql("delete from Meeting_repeat where id= "+ id);
		}
		StaticObj.getInstance().removeObject("MeetingComInfo");
    }
    
    
    /**
     * 生成会议日程和会议提醒
     * @param meetingid
     * @param date
     * @throws Exception
     */
    public static void  creatWpAndSwfForMeeting(String meetingid, String date) throws Exception{
    	//生成会议日程和会议提醒
		createWPAndRemind(meetingid,date,"");
    }
    
    /**
     * 复制新增会议
     * @param meetingid meeting
     * @return
     * @throws Exception
     */
    public  static String  copyMeetingfromMeeting(String meetingid, int usrid) throws Exception{
    	RecordSet rs = new RecordSet();
    	rs.executeSql("select * from meeting where (cancel <> '1' or cancel is null) and meetingstatus = 2 and  id ="+meetingid);
    	if(!rs.next()){
    		rs.writeLog("会议id：["+meetingid+"]不存在，复制生成会议失败。");
    		return "-1";
    	} else {
            return ""+copyMeeting(rs,true,null,usrid);
    	}
    }
    
    /**
     * 根据模板会议生成新的会议
     * @param meetingid
     * @param date
     * @throws Exception
     */
    public static void  cloneMeeting(String meetingid, String date) throws Exception{
    	
    	RecordSet rs = new RecordSet();
    	rs.executeSql("select * from meeting where (cancel <> '1' or cancel is null) and meetingstatus = 2 and  id ="+meetingid);
    	if(!rs.next()){
    		rs.writeLog("会议id：["+meetingid+"]生成重复会议失败，模板会议不存在，或者没有审批通过，或者已经取消。");
    	} else {
    		//生成周期会议策略
    		int repeatStrategy = Util.getIntValue(rs.getString("repeatStrategy"),0);
    		
    		//根据创建人获取分部id，用来处理工作日
    		int subid = Util.getIntValue(new ResourceComInfo().getSubCompanyID(rs.getString("creater")),1);
    		
    		HrmScheduleDiffUtil hsdu = new HrmScheduleDiffUtil();
    		//如果是非工作日
    		if(!hsdu.getIsWorkday(date,subid,"")){
    			//推迟到下一工作日
	    		if(repeatStrategy == 1){
	    			String tdate = getWorkDayByDays(date, 1, subid);
	    			rs.writeLog("会议id：["+meetingid+"]日期["+date+"]生成重复会议推迟到["+tdate+"]。");
	    			date=tdate;
	    			date=tdate;
	    		} else if(repeatStrategy == 2) {
	    			//取消会议
	    			rs.writeLog("会议id：["+meetingid+"]日期["+date+"]生成重复会议取消。");
	    			return;
	    		}
    		}
    		
    		copyMeeting(rs,false,date,0);
            return;
    	}
    }
    
    /**
     * 查询会议内容结果集,返回空,则未查询到值
     * @param meetingId
     * @return
     */
    private static RecordSet getMeetingData(String meetingId){
    	RecordSet rsData=new RecordSet();
    	rsData.execute("select * from meeting where (cancel <> '1' or cancel is null) and id="+meetingId);
		if(rsData.next()){
			return rsData;
		}else{
			return null;
		}
    }
    
    /**
     * 复制会议
     * 或者克隆会议(生成周期会议)
     * @param rs  会议参考对象 结果集
     * @param isCopy  复制:true or 克隆:false
     * @param date		克隆时间
     * @param userid	复制人
     * @return
     */
    private static int copyMeeting(RecordSet rs,boolean isCopy,String date,int userid) throws Exception{
    	MeetingViewer meetingViewer = new MeetingViewer();
		MeetingRoomComInfo meetingRoomComInfo = new MeetingRoomComInfo();
		RecordSet recordSet=new RecordSet();
		int sysLang=7;
		recordSet.execute("SELECT systemlanguage FROM HrmResource where id="+userid);
		if(recordSet.next()){
			sysLang=Util.getIntValue(recordSet.getString("systemlanguage"));
		}
		Date newdate = new Date() ;
		long datetime = newdate.getTime() ;
		Timestamp timestamp = new Timestamp(datetime) ;
		String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
		String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16) + ":" +(timestamp.toString()).substring(17,19);
		char flag = 2;
		String ProcPara = "";
    	//基本信息
		String meetingid=rs.getString("id");
		String meetingtype = Util.null2String(rs.getString("meetingtype"));
		String name=Util.null2String(rs.getString("name"));//会议名称
		String caller=Util.null2String(rs.getString("caller"));//召集人,必填
		String contacter=Util.null2String(rs.getString("contacter"));//联系人,空值使用当前操作人
		String creater=Util.null2String(rs.getString("creater"));
		//会议室
		int roomType = rs.getInt("roomType");
		String address=Util.null2String(rs.getString("address"));//会议地点
		String customizeAddress = Util.null2String(rs.getString("customizeAddress"));
		String desc=Util.spacetoHtml(Util.null2String(rs.getString("desc_n")));//描述,可为空
    	//时间
    	int repeatType = Util.getIntValue(rs.getString("repeatType"),0);//是否是重复会议,0 正常会议.
    	String begindate=Util.null2String(rs.getString("begindate"));//开始日期
    	String enddate=Util.null2String(rs.getString("enddate"));//结束日期
    	String repeatbegindate=Util.null2String(rs.getString("repeatbegindate"));//重复开始日期
    	String repeatenddate=Util.null2String(rs.getString("repeatenddate"));//重复结束日期
		String begintime=Util.null2String(rs.getString("begintime"));//开始时间
		String endtime=Util.null2String(rs.getString("endtime"));//结束时间
    	//重复策略字段
    	int repeatdays = Util.getIntValue(rs.getString("repeatdays"),0);
    	int repeatweeks = Util.getIntValue(rs.getString("repeatweeks"),0);
    	String rptWeekDays=Util.null2String(rs.getString("rptWeekDays"));
    	int repeatmonths = Util.getIntValue(rs.getString("repeatmonths"),0);
    	int repeatmonthdays = Util.getIntValue(rs.getString("repeatmonthdays"),0);
    	int repeatStrategy = Util.getIntValue(rs.getString("repeatStrategy"),0);
		
		//提醒方式和时间
		int remindType=1;//老的提醒方式
		String remindTypeNew=Util.null2String(rs.getString("remindTypeNew"));//新的提示方式
		int remindImmediately = Util.getIntValue(rs.getString("remindImmediately"),0);  //是否立即提醒 
		int remindBeforeStart = Util.getIntValue(rs.getString("remindBeforeStart"),0);  //是否开始前提醒
		int remindBeforeEnd = Util.getIntValue(rs.getString("remindBeforeEnd"),0);  //是否结束前提醒
		int remindHoursBeforeStart = Util.getIntValue(rs.getString("remindHoursBeforeStart"),0);//开始前提醒小时
		int remindTimesBeforeStart = Util.getIntValue(Util.null2String(rs.getString("remindTimesBeforeStart")),0);  //开始前提醒时间
	    int remindHoursBeforeEnd = Util.getIntValue(rs.getString("remindHoursBeforeEnd"),0);//结束前提醒小时
	    int remindTimesBeforeEnd = Util.getIntValue(Util.null2String(rs.getString("remindTimesBeforeEnd")),0);  //结束前提醒时间
	    //参会人员
	    String hrmmembers=Util.null2String(rs.getString("hrmmembers"));//参会人员
	    int totalmember=Util.getIntValue(rs.getString("totalmember"),0);//参会人数
		String othermembers=Util.null2String(rs.getString("othermembers"));//其他参会人员
		String crmmembers=Util.null2String(rs.getString("crmmembers"));//参会客户
		int crmtotalmember=Util.getIntValue(rs.getString("crmtotalmember"),0);//参会人数
		//其他信息
		String projectid=Util.null2String(rs.getString("projectid"));	//加入了项目id
		String accessorys = Util.null2String(rs.getString("accessorys"));
		String addressdesc=rs.getString("addressdesc");
		int meetingstatus=0;
		String repeatMeetingId="";
		//根据复制会议还是周期会议判断,相应修改对应的值
		if(isCopy){//复制会议,只修改创建人和联系人
			if(userid>0){//有效人员.
				contacter=""+userid;
				creater=""+userid;
			}
			name+="("+SystemEnv.getHtmlLabelName(77, sysLang) +")";
		}else{//克隆周期会议
			begindate=date;
			enddate=date;
			repeatType=0;//生成正常会议
			meetingstatus=2;//直接生成正常会议
			repeatMeetingId=meetingid;
			remindImmediately=0;//不支持立即提醒
		}
		//正常会议时,情况重复策略
		if(repeatType<=0){
			repeatType=0;
			repeatdays = 0;
	    	repeatweeks = 0;
	    	rptWeekDays="";
	    	repeatmonths = 0;
	    	repeatmonthdays = 0;
	    	repeatStrategy =0;
		}
		
		
		String description = "您有会议: "+name+"   会议时间:"+begindate+" "+begintime+" 会议地点:"+getMeetingRoomInfoname(""+address)+customizeAddress;
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
		ProcPara += flag + creater;
		ProcPara += flag + CurrentDate;
		ProcPara += flag + CurrentTime;
	    ProcPara += flag + ""+totalmember;
	    ProcPara += flag + othermembers;
	    ProcPara += flag + addressdesc;
	    ProcPara += flag + description;
	    ProcPara += flag + ""+remindType;
	    ProcPara += flag + ""+remindBeforeStart;
	    ProcPara += flag + ""+remindBeforeEnd;
	    ProcPara += flag + ""+remindTimesBeforeStart;
	    ProcPara += flag + ""+remindTimesBeforeEnd;
	    ProcPara += flag + customizeAddress;
	    if (recordSet.getDBType().equals("oracle"))
		{
	    	recordSet.executeProc("Meeting_Insert",ProcPara);
	    
	    	recordSet.executeSql("SELECT max(id) FROM Meeting where creater = "+creater);
		}
		else
		{
			recordSet.executeProc("Meeting_Insert",ProcPara);
		}
	    recordSet.next();
		String MaxID = recordSet.getString(1);
		//更新其他字段
    	String updateSql = "update Meeting set repeatType = " + repeatType 
						+" , repeatdays = "+ repeatdays 
						+" , repeatweeks = "+ repeatweeks 
						+" , rptWeekDays = '"+ rptWeekDays +"' "
						+" , repeatbegindate = '"+ repeatbegindate +"' "
						+" , repeatenddate = '"+ repeatenddate +"' "
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
						+" ,accessorys = '"+accessorys+"'"
						+" ,meetingstatus = "+meetingstatus
						+" ,repeatMeetingId = '"+repeatMeetingId+"' "
						+" where id = " + MaxID;
    	
    	recordSet.executeSql(updateSql);
		//保存自定义字段
		MeetingFieldManager mfm=new MeetingFieldManager(1);
		mfm.editCustomData(rs,Util.getIntValue(MaxID),isCopy);
		//保存参会人员,直接拿主表保存参会人员数据
		ArrayList arrayhrmids02 = Util.TokenizerString(hrmmembers,",");
		for(int i=0;i<arrayhrmids02.size();i++){
			ProcPara =  MaxID;
			ProcPara += flag + "1";
			ProcPara += flag + "" + arrayhrmids02.get(i);
			ProcPara += flag + "" + arrayhrmids02.get(i);
			recordSet.executeProc("Meeting_Member2_Insert",ProcPara);
			
			//标识会议是否查看过
			StringBuffer stringBuffer = new StringBuffer();
			stringBuffer.append("INSERT INTO Meeting_View_Status(meetingId, userId, userType, status) VALUES(");
			stringBuffer.append(MaxID);
			stringBuffer.append(", ");
			stringBuffer.append(arrayhrmids02.get(i));
			stringBuffer.append(", '");
			stringBuffer.append("1");
			stringBuffer.append("', '");
			stringBuffer.append("0");
			stringBuffer.append("')");
			recordSet.executeSql(stringBuffer.toString());
		}
		//参会客户,取参会人员表数据,减少查询membermanager花费时间
		recordSet.executeProc("Meeting_Member2_SelectByType", meetingid+flag+"2");
		while(recordSet.next()){
			ProcPara =  MaxID;
			ProcPara += flag + "2";
			ProcPara += flag + "" + recordSet.getString("memberid");
			ProcPara += flag + "" + recordSet.getString("membermanager");
			recordSet.executeProc("Meeting_Member2_Insert",ProcPara);
		}
		//复制议程
    	recordSet.executeProc("Meeting_Topic_SelectAll",""+meetingid);
    	MeetingFieldManager mfm2=new MeetingFieldManager(2);
    	mfm2.editCustomDataDetail(recordSet, Util.getIntValue(MaxID));
		//复制会议服务
    	recordSet.execute("select * from meeting_service_new where meetingid="+meetingid);
    	MeetingFieldManager mfm3=new MeetingFieldManager(3);
    	mfm3.editCustomDataDetail(recordSet, Util.getIntValue(MaxID));
		//设置会议权限
		meetingViewer.setMeetingShareById(""+MaxID);
		//如果正常会议,生成相应日程
		if(meetingstatus==2){
			createWPAndRemind(MaxID,null,"");
		}
		return Util.getIntValue(MaxID);
    }
    
    /**
     * 生成日程 和 会议提醒
     * @param meetingid
     * @param date
     * @param ip
     */
    public static void createWPAndRemind(String meetingid,String date,String ip) throws Exception{
    	RecordSet rs = new RecordSet();
    	RecordSet recordSet = new RecordSet();
    	rs.executeSql("select * from meeting where (cancel <> '1' or cancel is null) and meetingstatus = 2 and  id ="+meetingid);
    	if(!rs.next()){
    		rs.writeLog("会议id：["+meetingid+"]生成日程和相关提醒失败，会议不存在，或者没有审批通过，或者已经取消。");
    	} else {
    		MeetingRoomComInfo meetingRoomComInfo = new MeetingRoomComInfo();
    		ResourceComInfo resourceComInfo = new ResourceComInfo();
    		SysRemindWorkflow sysRemindWorkflow = new SysRemindWorkflow();
    		Date newdate = new Date() ;
    		long datetime = newdate.getTime() ;
    		Timestamp timestamp = new Timestamp(datetime) ;
    		String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
    		String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16) + ":" +(timestamp.toString()).substring(17,19);
    		char flag = 2;
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

    	    String remindTypeNew=Util.null2String(rs.getString("remindTypeNew"));//新的提示方式
    		int remindImmediately = Util.getIntValue(rs.getString("remindImmediately"),0);  //是否立即提醒 
    		int remindBeforeStart = Util.getIntValue(rs.getString("remindBeforeStart"),0);  //是否开始前提醒
    		int remindBeforeEnd = Util.getIntValue(rs.getString("remindBeforeEnd"),0);  //是否结束前提醒
    		int remindHoursBeforeStart = Util.getIntValue(rs.getString("remindHoursBeforeStart"),0);//开始前提醒小时
    		int remindTimesBeforeStart = Util.getIntValue(Util.null2String(rs.getString("remindTimesBeforeStart")),0);  //开始前提醒时间
    	    int remindHoursBeforeEnd = Util.getIntValue(rs.getString("remindHoursBeforeEnd"),0);//结束前提醒小时
    	    int remindTimesBeforeEnd = Util.getIntValue(Util.null2String(rs.getString("remindTimesBeforeEnd")),0);  //结束前提醒时间
    	    String description= Util.toMultiLangScreen("84535,2103")+": "+name+"   "+Util.toMultiLangScreen("81901")+":"+begindate+" "+begintime+//您有会议  会议时间
    	    " "+Util.toMultiLangScreen("2105")+":"+getMeetingRoomInfoname(""+address)+customizeAddress;
    	    
    	    if(date!=null&&!"".equals(date)){
    	    	begindate=date;
    	    	enddate=date;
    	    }
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
    	    	WorkPlan workPlan = new WorkPlan();
			    WorkPlanService workPlanService = new WorkPlanService();
			    workPlan.setCreaterId(Integer.parseInt(creater));
			    workPlan.setWorkPlanType(Integer.parseInt(Constants.WorkPlan_Type_ConferenceCalendar));        
			    workPlan.setWorkPlanName(name);    
			    workPlan.setUrgentLevel(Constants.WorkPlan_Urgent_Normal);
			    workPlan.setResourceId(SWFAccepter);
			    workPlan.setBeginDate(begindate);
			    workPlan.setEndDate(enddate);
			    if(begintime!=null&&!"".equals(begintime)){
			        workPlan.setBeginTime(begintime);  //开始时间
			    } else{
			        workPlan.setBeginTime(Constants.WorkPlan_StartTime);  //开始时间
			    }
			    if(begintime!=null&&!"".equals(begintime)){//结束时间
			    	workPlan.setEndTime(endtime);  
			    } else{
			    	workPlan.setEndTime(Constants.WorkPlan_EndTime);  //结束时间
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
			    
				WorkPlanLogMan logMan = new WorkPlanLogMan();
			    //插入日志
				String[] logParams = new String[] {String.valueOf(workPlan.getWorkPlanID()), WorkPlanLogMan.TP_CREATE, caller, ip};
			    logMan.writeViewLog(logParams);
			    
			    //生成流程提醒
				String SWFTitle=Util.toMultiLangScreen("24215")+":"; //文字,会议通知
				SWFTitle += name;
				SWFTitle += " "+Util.toMultiLangScreen("81901")+":"; //会议时间
				SWFTitle += begindate+" "+begintime;
				SWFTitle +=" "+Util.toMultiLangScreen("2105")+":"+getMeetingRoomInfoname(""+address)+customizeAddress;
				String SWFRemark="";
				String SWFSubmiter=creater;
				try {
					sysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(SWFSubmiter),SWFAccepter,SWFRemark);
				} catch (Exception e) {
					rs.writeLog("会议通知提醒流程生成失败：["+SWFTitle+"]");
					rs.writeLog(e);
					
				}

                Map<String, String> schedule = new HashMap<String, String>();
                schedule.put("module", "5");//标记会议模块
                schedule.put("id",meetingid);
                schedule.put("createrid",creater);
                schedule.put("creater",StringUtils.isNotBlank(creater)?resourceComInfo.getLastname(creater):"");
                schedule.put("receivetime",createdate+" "+createtime);

                List<String> userlist = new ArrayList<String>();
                List<String> loginidlist = new ArrayList<String>();
                String[] users=SWFAccepter.split(",");
                for(int i=0;i<users.length;i++){
                    String userid=users[i];
                    if(userid!=null&&!"".equals(userid)&&!userid.equals(creater)){
                        rs.execute("select loginid from HrmResource where id="+userid);
                        if(rs.next()){
                            String loginid=rs.getString("loginid");
                            if(!"".equals(loginid)){
                                loginidlist.add(loginid);
                                userlist.add(userid);
                            }
                        }
                    }
                                
                }

                if(loginidlist.size()>0){
                	pushNotificationService(loginidlist,name,schedule);
                }

				
				if(!"".equals(remindTypeNew)){//选择了提醒方式
	    	    	if(remindImmediately==1){//立即提醒
	    	    		MeetingRemindUtil.remindImmediately(meetingid,null,SWFAccepter);
	    	    	}
	    	    	if(remindBeforeStart==1){//开始前提醒
	    	    		List beginDateTimeRemindList = Util.processTimeBySecond(begindate, begintime, (remindHoursBeforeStart*60+remindTimesBeforeStart)* -1 * 60);
	    	    		MeetingRemindUtil.remindAtTime(meetingid, (String)beginDateTimeRemindList.get(0)+" "+(String)beginDateTimeRemindList.get(1), "start");
	    	    	}
	    	    	if(remindBeforeEnd==1){//结束前提醒
	    	    		List endDateTimeRemindList = Util.processTimeBySecond(enddate, endtime, (remindHoursBeforeEnd*60+remindTimesBeforeEnd) * -1 * 60);
	    	    		MeetingRemindUtil.remindAtTime(meetingid, (String)endDateTimeRemindList.get(0)+" "+(String)endDateTimeRemindList.get(1), "end");
	    	    	}
	    	    }
    	    }
    	    
    	    //生成服务通知
    	    SWFAccepter="";
    	    Set<String> hrmidSet=new HashSet<String>();
    	    String hrmid="";
    	    String[] hrmids=null;
    	    recordSet.executeSql("select hrmids from Meeting_Service_New where meetingid="+meetingid);
    	    while(recordSet.next()){
    	    	hrmid=recordSet.getString(1);
    	    	if(hrmid!=null&&!"".equals(hrmid)){
    	    		hrmids=hrmid.split(",");
    	    		for(String tempid:hrmids){
    	    			if(!"".equals(tempid)) hrmidSet.add(tempid);
    	    		}
    	    	}
    	    }
    	    for (String tempid:hrmidSet) {
    	    	SWFAccepter+=","+tempid;
			}
    	    if(!SWFAccepter.equals("")){
    	    	SWFAccepter=SWFAccepter.substring(1);
    	    	String SWFTitle=Util.toMultiLangScreen("2107")+":";//文字,会议服务
    	    	SWFTitle += name;
    	    	SWFTitle += "-"+resourceComInfo.getResourcename(creater);
    	    	SWFTitle += "-"+CurrentDate;
    	    	String SWFRemark="";
    	    	try {
    	    		sysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(creater),SWFAccepter,SWFRemark);
    	    	} catch (Exception e) {
    	    		recordSet.writeLog("会议服务提醒流程生成失败：["+SWFTitle+"]");
    	    		recordSet.writeLog(e);
    	    	}
    	    }
            return;
    	}
    }
    
    /**
     * 手机消息使用线程推送
     */
    private static void pushNotificationService(final List<String> loginidlist,final String name,final Map<String,String> schedule){
    	new Thread(){
    		public void run() {
    			PushNotificationService pns = new PushNotificationService();
                pns.push(StringUtils.join(loginidlist, ','), "新会议:"+name, 1, schedule);
    		}
    	}.start();
    }
    
    /**
     * 生成日程 和 会议提醒
     * @param meetingid
     * @param date
     * @param ip
     */
    public static void createWPAndEmail(String meetingid,String date,String ip) throws Exception{
    	RecordSet rs = new RecordSet();
    	RecordSet recordSet = new RecordSet();
    	rs.executeSql("select * from meeting where (cancel <> '1' or cancel is null) and meetingstatus = 2 and  id ="+meetingid);
    	if(!rs.next()){
    		rs.writeLog("会议id：["+meetingid+"]生成日程和相关提醒失败，会议不存在，或者没有审批通过，或者已经取消。");
    	} else {
    		MeetingRoomComInfo meetingRoomComInfo = new MeetingRoomComInfo();
    		ResourceComInfo resourceComInfo = new ResourceComInfo();
    		SysRemindWorkflow sysRemindWorkflow = new SysRemindWorkflow();
    		Date newdate = new Date() ;
    		long datetime = newdate.getTime() ;
    		Timestamp timestamp = new Timestamp(datetime) ;
    		String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
    		String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16) + ":" +(timestamp.toString()).substring(17,19);
    		char flag = 2;
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

    	    String remindTypeNew=Util.null2String(rs.getString("remindTypeNew"));//新的提示方式
    		int remindImmediately = Util.getIntValue(rs.getString("remindImmediately"),0);  //是否立即提醒 
    		int remindBeforeStart = Util.getIntValue(rs.getString("remindBeforeStart"),0);  //是否开始前提醒
    		int remindBeforeEnd = Util.getIntValue(rs.getString("remindBeforeEnd"),0);  //是否结束前提醒
    		int remindHoursBeforeStart = Util.getIntValue(rs.getString("remindHoursBeforeStart"),0);//开始前提醒小时
    		int remindTimesBeforeStart = Util.getIntValue(Util.null2String(rs.getString("remindTimesBeforeStart")),0);  //开始前提醒时间
    	    int remindHoursBeforeEnd = Util.getIntValue(rs.getString("remindHoursBeforeEnd"),0);//结束前提醒小时
    	    int remindTimesBeforeEnd = Util.getIntValue(Util.null2String(rs.getString("remindTimesBeforeEnd")),0);  //结束前提醒时间
    	    String description= Util.toMultiLangScreen("84535,2103")+": "+name+"   "+Util.toMultiLangScreen("81901")+":"+begindate+" "+begintime+//您有会议  会议时间
    	    " "+Util.toMultiLangScreen("2105")+":"+getMeetingRoomInfoname(""+address)+customizeAddress;
    	    
    	    if(date!=null&&!"".equals(date)){
    	    	begindate=date;
    	    	enddate=date;
    	    }
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
    	    	WorkPlan workPlan = new WorkPlan();
			    WorkPlanService workPlanService = new WorkPlanService();
			    workPlan.setCreaterId(Integer.parseInt(creater));
			    workPlan.setWorkPlanType(Integer.parseInt(Constants.WorkPlan_Type_ConferenceCalendar));        
			    workPlan.setWorkPlanName(name);    
			    workPlan.setUrgentLevel(Constants.WorkPlan_Urgent_Normal);
			    workPlan.setResourceId(SWFAccepter);
			    workPlan.setBeginDate(begindate);
			    workPlan.setEndDate(enddate);
			    if(begintime!=null&&!"".equals(begintime)){
			        workPlan.setBeginTime(begintime);  //开始时间
			    } else{
			        workPlan.setBeginTime(Constants.WorkPlan_StartTime);  //开始时间
			    }
			    if(begintime!=null&&!"".equals(begintime)){//结束时间
			    	workPlan.setEndTime(endtime);  
			    } else{
			    	workPlan.setEndTime(Constants.WorkPlan_EndTime);  //结束时间
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
			    
				WorkPlanLogMan logMan = new WorkPlanLogMan();
			    //插入日志
				String[] logParams = new String[] {String.valueOf(workPlan.getWorkPlanID()), WorkPlanLogMan.TP_CREATE, caller, ip};
			    logMan.writeViewLog(logParams);
			    
			    //生成流程提醒
				String SWFTitle=Util.toMultiLangScreen("24215")+":"; //文字,会议通知
				SWFTitle += name;
				SWFTitle += " "+Util.toMultiLangScreen("81901")+":"; //会议时间
				SWFTitle += begindate+" "+begintime;
				SWFTitle +=" "+Util.toMultiLangScreen("2105")+":"+getMeetingRoomInfoname(""+address)+customizeAddress;
				String SWFRemark="";
				String SWFSubmiter=creater;
				
				//邮件发送  2017-1-17 start
				BaseBean baseBean = new BaseBean();
				baseBean.writeLog("===========================MeetingInterval.java(会议创建提醒邮件发送) start===========================");
				//邮件标题
				String mailTitle = SWFTitle;
				//邮件内容
				String mailContent = "以下是提醒内容，请点击查看详情：<br>";
				//连接路径
				String url = Util.null2String(baseBean.getPropValue("meeting", "showMeetingInfoUrl"));
				if(url.indexOf("$meetingid$")>-1){
					url = url.replace("$meetingid$", meetingid);
				}else{
					url = "/meeting/data/ViewMeetingTab.jsp?meetingid="+meetingid;
				}
				baseBean.writeLog("邮件连接url："+url);
				mailContent += "<a style=\"color:red\" target=\"_blank\" href=\""+url+"\">"+mailTitle+"</a><br>";
				
				MailSend localMailSend = new MailSend();
				boolean bool = localMailSend.sendSysInternalMail("1", SWFAccepter, null, mailTitle, mailContent);
				baseBean.writeLog("发送通知邮件是否成功："+bool);
				baseBean.writeLog("===========================MeetingInterval.java(会议创建提醒邮件发送) end===========================");
				//邮件发送  2017-1-17 end
				

                Map<String, String> schedule = new HashMap<String, String>();
                schedule.put("module", "5");//标记会议模块
                schedule.put("id",meetingid);
                schedule.put("createrid",creater);
                schedule.put("creater",StringUtils.isNotBlank(creater)?resourceComInfo.getLastname(creater):"");
                schedule.put("receivetime",createdate+" "+createtime);

                List<String> userlist = new ArrayList<String>();
                List<String> loginidlist = new ArrayList<String>();
                String[] users=SWFAccepter.split(",");
                for(int i=0;i<users.length;i++){
                    String userid=users[i];
                    if(userid!=null&&!"".equals(userid)&&!userid.equals(creater)){
                        rs.execute("select loginid from HrmResource where id="+userid);
                        if(rs.next()){
                            String loginid=rs.getString("loginid");
                            if(!"".equals(loginid)){
                                loginidlist.add(loginid);
                                userlist.add(userid);
                            }
                        }
                    }
                                
                }

                if(loginidlist.size()>0){
                	pushNotificationService(loginidlist,name,schedule);
                }

				
				if(!"".equals(remindTypeNew)){//选择了提醒方式
	    	    	if(remindImmediately==1){//立即提醒
	    	    		MeetingRemindUtil.remindImmediately(meetingid,null,SWFAccepter);
	    	    	}
	    	    	if(remindBeforeStart==1){//开始前提醒
	    	    		List beginDateTimeRemindList = Util.processTimeBySecond(begindate, begintime, (remindHoursBeforeStart*60+remindTimesBeforeStart)* -1 * 60);
	    	    		MeetingRemindUtil.remindAtTime(meetingid, (String)beginDateTimeRemindList.get(0)+" "+(String)beginDateTimeRemindList.get(1), "start");
	    	    	}
	    	    	if(remindBeforeEnd==1){//结束前提醒
	    	    		List endDateTimeRemindList = Util.processTimeBySecond(enddate, endtime, (remindHoursBeforeEnd*60+remindTimesBeforeEnd) * -1 * 60);
	    	    		MeetingRemindUtil.remindAtTime(meetingid, (String)endDateTimeRemindList.get(0)+" "+(String)endDateTimeRemindList.get(1), "end");
	    	    	}
	    	    }
    	    }
    	    
    	    //生成服务通知
    	    SWFAccepter="";
    	    Set<String> hrmidSet=new HashSet<String>();
    	    String hrmid="";
    	    String[] hrmids=null;
    	    recordSet.executeSql("select hrmids from Meeting_Service_New where meetingid="+meetingid);
    	    while(recordSet.next()){
    	    	hrmid=recordSet.getString(1);
    	    	if(hrmid!=null&&!"".equals(hrmid)){
    	    		hrmids=hrmid.split(",");
    	    		for(String tempid:hrmids){
    	    			if(!"".equals(tempid)) hrmidSet.add(tempid);
    	    		}
    	    	}
    	    }
    	    for (String tempid:hrmidSet) {
    	    	SWFAccepter+=","+tempid;
			}
    	    if(!SWFAccepter.equals("")){
    	    	SWFAccepter=SWFAccepter.substring(1);
    	    	String SWFTitle=Util.toMultiLangScreen("2107")+":";//文字,会议服务
    	    	SWFTitle += name;
    	    	SWFTitle += "-"+resourceComInfo.getResourcename(creater);
    	    	SWFTitle += "-"+CurrentDate;
    	    	String SWFRemark="";
    	    	try {
    	    		sysRemindWorkflow.setMeetingSysRemind(SWFTitle,Util.getIntValue(meetingid),Util.getIntValue(creater),SWFAccepter,SWFRemark);
    	    	} catch (Exception e) {
    	    		recordSet.writeLog("会议服务提醒流程生成失败：["+SWFTitle+"]");
    	    		recordSet.writeLog(e);
    	    	}
    	    }
            return;
    	}
    }


	public static  String getMeetingRoomInfoname(String id){
		RecordSet rs=new RecordSet();
		String[] split = id.split(",");
		String names="";
		for (String s : split) {
			rs.executeQuery("select name from meetingroom where id=?",s);
			if(rs.next()){
				names+=","+rs.getString(1);
			}
		}
		return "".equals(names)?"":names.substring(1);
	}
    
    public static void main(String args[]){
    	MeetingInterval mi = new MeetingInterval();
    	ArrayList begindatelist = mi.getBeginDate("2014-09-25", "2014-10-25", "2", 1, "1,3,6,7");
    	for(int i = 0; i < begindatelist.size(); i++){
    		//System.out.println(begindatelist.get(i));
    	}
    }
}


