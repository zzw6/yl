package weaver.meeting.cron;

import java.util.Calendar;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.interfaces.schedule.BaseCronJob;
import weaver.meeting.remind.IMeetingRemind;
import weaver.system.SysRemindWorkflow;

public class MeetingDelayCron  extends BaseCronJob {
	private BaseBean bb=new BaseBean();
	private String cronExpr;
	public void setCronExpr(String cronExpr) {
		this.cronExpr=cronExpr;
	}

	@Override
	public String getCronExpr() {
		return cronExpr;
	}

	@Override
	public void execute() {
		
		try {
			generateReminder();
		} catch (Exception e) {
			e.printStackTrace();
			bb.writeLog(e.getMessage());
		}
	}
	/**
	 * 3)	会议结束前15分钟进行提醒
	 * 每分钟执行一次
	 * @throws Exception 
	 */
	public static synchronized void generateReminder() throws Exception {
		RecordSet rs=new RecordSet();
        Calendar today = Calendar.getInstance();
        String modedatacreatedate = Util.add0(today.get(Calendar.YEAR), 4) + "-" +
        		Util.add0(today.get(Calendar.MONTH) + 1, 2) + "-" +
        		Util.add0(today.get(Calendar.DAY_OF_MONTH), 2);

        String modedatacreatetime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
        		Util.add0(today.get(Calendar.MINUTE), 2) + ":" +
        		Util.add0(today.get(Calendar.SECOND), 2);
        
        writeLog("短信提醒name:"+modedatacreatedate+" "+modedatacreatetime);
        //取数据库服务器的当前时间
        //rs.executeProc("GetDBDateAndTime","");
        //if(rs.next()){
        	//modedatacreatedate = rs.getString("dbdate");
        	//modedatacreatetime = rs.getString("dbtime");
        //}
        //dateadd15 == 会议结束日期时间+15分钟（15*60秒）
        int remindtimes = Util.getIntValue(weaver.file.Prop.getPropValue("meetingRemind", "remindtimes"),15);
        
        String dateadd15 = weaver.general.TimeUtil.timeAdd(modedatacreatedate+" "+modedatacreatetime,remindtimes*60);//15分钟 * 60秒 时间增加15分钟
		String chkRoomSql = "select address,addressselect,customizeaddress,contacter,caller,recorder,name,id,begindate,enddate,begintime,endtime from meeting where meetingstatus in (1,2) and repeatType = 0 and isdecision<2  "
			                +"and (enddate || ' ' || endtime) = '"+dateadd15.substring(0,16)+"' ";
		
		chkRoomSql += " and id not in (select meetingid from uf_Delaytimes) ";
		
		chkRoomSql += " order by begindate,begintime";
		writeLog("短信提醒chkRoomSql:"+chkRoomSql);
		rs.executeSql(chkRoomSql);
		while(rs.next()) {
			boolean isadddatetime  = false;
			String meetingid = Util.null2String(rs.getString("id"));
			String name = Util.null2String(rs.getString("name"));
			String contacter = Util.null2String(rs.getString("contacter"));//创建人
			String caller = Util.null2String(rs.getString("caller"));//主持人
			String recorder = Util.null2String(rs.getString("recorder")); //会议记录人
			String addressselect = Util.null2String(rs.getString("addressselect"));
			String address = Util.null2String(rs.getString("address"));
			String customizeaddress = Util.null2String(rs.getString("customizeaddress"));
			String enddate = Util.null2String(rs.getString("enddate"));
			String endtime = Util.null2String(rs.getString("endtime"));
			 //计算下一会议室开始日期时间

			String [] tempAddress=null;
			if("0".equals(addressselect)){
				tempAddress=address.split(",");
			}else{
				tempAddress=customizeaddress.split(",");
			}
			RecordSet RecordSet = new RecordSet();
			RecordSet.writeLog("tempAddress"+tempAddress);

			for (String s : tempAddress) {
				chkRoomSql = "select begindate,enddate,begintime,endtime,id,meetingtype from meeting where meetingstatus in (1,2) and repeatType = 0 and isdecision<2  and (begindate || ' ' || begintime >= '"+enddate+" "+endtime+"')";

				//
				if("0".equals(addressselect)){
					chkRoomSql += " ','||address||','  like '%,"+s+",%'";
				}else{
					chkRoomSql += " and customizeaddress='"+s+"'";
				}
				chkRoomSql += " order by begindate,begintime";
				//System.out.println("chkRoomSql:"+chkRoomSql);
				new weaver.general.BaseBean().writeLog("chkRoomSql2---"+chkRoomSql);
				RecordSet.executeSql(chkRoomSql);
				if(RecordSet.next()) {
					String begindatetmp = Util.null2String(RecordSet.getString("begindate"));
					String begintimetmp = Util.null2String(RecordSet.getString("begintime"));

					String fromdatetime = enddate+" "+endtime+":00";
					String todatetime = begindatetmp+" "+begintimetmp+":00";
					long timeInterval = weaver.general.TimeUtil.timeInterval(fromdatetime, todatetime);
					//下一次会议前十分钟 （需要减去十分钟，十分钟为等于600秒）
					timeInterval = timeInterval - 10*60;
					java.text.DecimalFormat df = new java.text.DecimalFormat("#.##");
					double yc_hour = Double.parseDouble(df.format((double)timeInterval/60/60));
					RecordSet.writeLog("yc_hour"+yc_hour);
					if(yc_hour <= 0){
						yc_hour = 0.0;
						isadddatetime = false;
						break;
					}else{
						isadddatetime = true;
					}
				}else{
					//可延长
					isadddatetime = true;
				}

			}

			String roleId = weaver.file.Prop.getPropValue("download_configuration", "download.roleid");
			
			int hrmCount = 0;
			RecordSet.executeSql("select count(*) as hrmCount  from hrmrolemembers t1, hrmresource t2 where roleid = "+ roleId +"   and t1.resourceid = t2.id   and t2.id = " + caller);
			if(RecordSet.next()){
				hrmCount = Util.getIntValue(RecordSet.getString("hrmCount"), 0);
			}
			String hrmid = "";
			if(hrmCount > 0){
				hrmid = recorder;
			}else{
				hrmid = caller;
			}
			
			Set<String> hrmids=new HashSet<String>();
			hrmids.add(hrmid);
			String msg = "";
			String title = "";
			
			writeLog("短信提醒name:"+name);
			if(isadddatetime){
				msg = "会议："+name+"，离会议结束还有"+remindtimes+"分钟，是否进行延时？";
				title = "";
			}else{
				//msg = "会议："+name+"，离会议结束还有"+remindtimes+"分钟，请知晓！";
				msg = "您的"+name+"会议离预定结束时间还有"+remindtimes+"分钟，后续本会议室已被其他人员预定，请及时结束会议！";
				title = "";
			}
			//短信提醒 
			IMeetingRemind remind=null;
			try {
				remind=(IMeetingRemind)Class.forName("weaver.meeting.remind.RemindSms").newInstance();
			} catch (InstantiationException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
			writeLog("短信提醒hrmids:"+hrmids);
			remind.sendRemind(hrmids,title, msg);
		}
	}
	
	public static void main(String args[]){
		 Calendar today = Calendar.getInstance();
	        String modedatacreatedate = Util.add0(today.get(Calendar.YEAR), 4) + "-" +
	        		Util.add0(today.get(Calendar.MONTH) + 1, 2) + "-" +
	        		Util.add0(today.get(Calendar.DAY_OF_MONTH), 2);

	        String modedatacreatetime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
	        		Util.add0(today.get(Calendar.MINUTE), 2) + ":" +
	        		Util.add0(today.get(Calendar.SECOND), 2);
		String dateadd15 = weaver.general.TimeUtil.timeAdd(modedatacreatedate+" "+modedatacreatetime,(0-15)*60);
		System.out.println(dateadd15);
	}
	
	public static void writeLog(Object obj) {
	    writeLog("weaver.meeting.cron.MeetingDelayCron",obj);
	}
	
    public static void writeLog(String classname , Object obj)  {
	  Log log= LogFactory.getLog(classname);
	  if(obj instanceof Exception)
	    log.error(classname ,(Exception)obj);
	  else{
	    log.error(obj);
	  }
	}
}
