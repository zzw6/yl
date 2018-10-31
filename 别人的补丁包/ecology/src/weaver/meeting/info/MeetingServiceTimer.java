package weaver.meeting.info;

import java.text.SimpleDateFormat;

import com.weavernorth.util.TimeUtils;

import weaver.conn.RecordSet;
import weaver.email.MailSend;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.interfaces.schedule.BaseCronJob;

/***
 * 
 * 推送
 * 
 * @author 51ibm
 * 
 */
public class MeetingServiceTimer extends BaseCronJob {
	public void execute() {
		RecordSet rs = null;
		RecordSet rsUp = null;
		StringBuffer sqlStr = null;
		TimeUtils t = null;
		String endDate = TimeUtil.getCurrentTimeString();
		try {
			rs = new RecordSet();
			rsUp = new RecordSet();
			t = new TimeUtils();
			BaseBean bb = new BaseBean();
			sqlStr = new StringBuffer();
			sqlStr.append("select id,name,creater,caller ");
			sqlStr.append(",(enddate || ' ' || endtime) as enddate ");
			sqlStr.append(" from meeting ");
			sqlStr.append(" where istick = '0' ");
			sqlStr.append(" and id in (select meetingid from MQEvaluate) ");
			sqlStr.append(" and isAppraise = '3' ");
			sqlStr.append(" and (enddate || ' ' || endtime) <= '"+ t.getCurrentTimeString() +"' ");
			bb.writeLog("sqlStr ------ " + sqlStr.toString());
			rs.executeSql(sqlStr.toString());
			while (rs.next()) {
				String meetingid = Util.null2String(rs.getString("id"));
				String meetingName = Util.null2String(rs.getString("name"));
				String creater = Util.null2String(rs.getString("creater"));
				String caller = Util.null2String(rs.getString("caller"));
				String startTime = Util.null2String(rs.getString("enddate"));
				
				bb.writeLog("meetingid ------ " + meetingid);
				bb.writeLog("meetingName ------ " + meetingName);
				bb.writeLog("creater ------ " + creater);
				bb.writeLog("caller ------ " + caller);
				bb.writeLog("startTime ------ " + startTime);
				bb.writeLog("endDate ------ " + endDate);
				long diffHour = this.dateDiff(startTime, endDate);
				bb.writeLog("diffHour ------ " + diffHour);
				if (diffHour >= 24) {
					String meetingNotice = t.replaceRepStr(creater + "," + caller);
					
					bb.writeLog("meetingNotice ------ " + meetingNotice);
					
					String description = "您的XXX会议的评估结果已出具，请您点击查阅";
					String mailTitle = description.replaceAll("XXX", meetingName);
					String mailContent = "以下是提醒内容，请点击查看详情：<br>";
					mailContent += "<a style=\"color:red\" target=\"_blank\" href=\"/mobile/plugin/5/appraiseJump.jsp?id=" + meetingid + "\">" + mailTitle + "</a><br>";
					MailSend send = new MailSend();
					boolean bool = send.sendSysInternalMail("1", meetingNotice, null, mailTitle, mailContent);
					
					bb.writeLog("bool ------ " + bool);
					
					if(bool){
						rsUp.executeSql("update meeting set istick = '1' where id = " + meetingid);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/****
	 * 
	 * 日期相减得到小时
	 * 
	 * @param startTime
	 * @param endTime
	 * @return
	 */
	private Long dateDiff(String startTime, String endTime) {
		String timestrformart = "yyyy'-'MM'-'dd' 'HH:mm:ss";
		if(startTime.length() < 19){
			startTime = startTime + ":00";
		}
		if(endTime.length() < 19){
			startTime = endTime + ":00";
		}
		SimpleDateFormat sd = new SimpleDateFormat(timestrformart);
		long diff;
		long hour = 0;
		try {
			diff = sd.parse(endTime).getTime() - sd.parse(startTime).getTime();
			hour = diff / 3600000;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return hour;
	}
}
