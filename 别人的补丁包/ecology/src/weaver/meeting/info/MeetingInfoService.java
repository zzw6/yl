package weaver.meeting.info;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import com.weavernorth.util.TimeUtils;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.hrm.report.schedulediff.HrmScheduleDiffUtil;

public class MeetingInfoService extends BaseBean {
	public String getMeetingEvaluate(String meetingid) {
		String retUrl = "";
		RecordSet rs = null;
		try {
			rs = new RecordSet();
			String isAppraise = "";
			rs.executeSql("select isAppraise from meeting where id = " + meetingid);
			if (rs.next()) {
				isAppraise = Util.null2String(rs.getString("isAppraise"));
			}
			if ("3".equals(isAppraise)) {
				int count1 = 0;
				rs.executeSql("select count(*) as count1 from MQEvaluate where meetingid = " + meetingid);
				if (rs.next()) {
					count1 = Util.getIntValue(rs.getString("count1"), 0);
				}
				if (count1 > 0) {
					retUrl = "<a href='javascript:meetingEvaluate(" + meetingid + ")'>评估结果</a>";
				} else {
					retUrl = "暂无评估结果";
				}
			} else {
				retUrl = "未开启评估";
			}
		} catch (Exception e) {
			this.writeLog("getMeetingEvaluate Exception " + e);
		}
		return retUrl;
	}

	public String getMeetingSign(String meetingid) {
		String retUrl = "";
		try {
			retUrl = "<a href='javascript:onShowSignIn(" + meetingid + ")'>签到记录</a>";
		} catch (Exception e) {
			this.writeLog("getMeetingEvaluate Exception " + e);
		}
		return retUrl;
	}

	/**
	 * 获取会议通知提前日期
	 * 
	 * @param mid
	 * @param para
	 * @return
	 * @throws Exception
	 */
	public String getNotifyDate(String meetingid) throws Exception {
		String result = "";
		RecordSet rs = new RecordSet();
		try {
			String createdate = "";
			String createtime = "";
			String approvedate = "";
			String approvetime = "";
			
			rs.executeSql("select createdate,createtime,approvedate,approvetime from meeting where id = " + meetingid);
			if (rs.next()) {
				createdate = Util.null2String(rs.getString("createdate"));
				createtime = Util.null2String(rs.getString("createtime"));
				approvedate = Util.null2String(rs.getString("approvedate"));
				approvetime = Util.null2String(rs.getString("approvetime"));
			}
			TimeUtils t = new TimeUtils();

			if (!"".equals(approvedate)) {
				result = approvedate + " " + t.meetingTimeFormatting(approvetime);
			} else {
				result = createdate + " " + t.meetingTimeFormatting(createtime);
			}
		} catch (Exception e) {
			this.writeLog("getNotifyDate Exception " + e);
		}
		return result;
	}
	
	public String getMeetingOverdueDays(String meetingid){
		String result = "";
		RecordSet rs = new RecordSet();
		try {
			String enddate = "";
			String decisiondate = "";
			String isdecision = "";
			rs.executeSql("select enddate,decisiondate,isdecision from meeting where id = " + meetingid);
			if (rs.next()) {
				enddate = Util.null2String(rs.getString("enddate"));
				decisiondate = Util.null2String(rs.getString("decisiondate"));
				isdecision = Util.null2String(rs.getString("isdecision"));
			}
			int datenum = 0;
			if("2".equals(isdecision)){
				datenum = TimeUtil.dateInterval(enddate, decisiondate) - 3;
			}else{
				String sysDate = TimeUtil.getCurrentDateString();
				datenum = TimeUtil.dateInterval(enddate, sysDate) - 3;
			}
			if (datenum <= 0) {
				result = "0";
			}else{
				int days = 0;
	    		String sql = "";
	    		if("2".equals(isdecision)){
	    			sql = "SELECT COUNT(*) counts FROM HrmPubHoliday WHERE holidaydate >= '"+enddate+"' and holidaydate <= '"+ decisiondate +"'";
	    		}else{
	    			sql = "SELECT COUNT(*) counts FROM HrmPubHoliday WHERE holidaydate <= to_char(sysdate,'yyyy-mm-dd') AND holidaydate >= '"+enddate+"' ";
	    		}
	    		rs.execute(sql);
	    		if(rs.next()){
	    			days = rs.getInt("counts");
	    		}
	    		datenum = datenum - days;
	    		if(datenum < 0){
	    			result = "0";
	        	}else{
	        		result = datenum + ""; 
	        	}
			}
		} catch (Exception e) {
			this.writeLog("getMeetingOverdueDays Exception " + e);
		}
		return result;
	}
	
	public String getAttachNotifyDate(String meetingid) throws Exception {
		String result = "";
		RecordSet rs = new RecordSet();
		try {
			String lastDate = "";
			String lastTime = "";
			rs.executeSql("select lastDate,lastTime from Meeting_Topic_attach where meetingid = " + meetingid + " order by lastDate desc,lastTime desc");
			if (rs.next()) {
				lastDate = Util.null2String(rs.getString("lastDate"));
				lastTime = Util.null2String(rs.getString("lastTime"));
			}
			
			if (!"".equals(lastDate) && !"".equals(lastTime)) {
				TimeUtils t = new TimeUtils();
				result = lastDate + " " + t.meetingTimeFormatting(lastTime);
			}else{
				result = "/";
			}
		} catch (Exception e) {
			this.writeLog("getAttachNotifyDate Exception " + e);
		}
		return result;
	}
	
	public String getMeetingDecisionDate(String decisionDate, String decisiontime) throws Exception {
		String result = "";
		try {
			if (!"".equals(decisionDate) && !"".equals(decisiontime)) {
				TimeUtils t = new TimeUtils();
				result = decisionDate + " " + t.meetingTimeFormatting(decisiontime);
			}else{
				result = "/";
			}
		} catch (Exception e) {
			this.writeLog("getMeetingDecisionDate Exception " + e);
		}
		return result;
	}
	
	public List<String> getMeetingOperator(String isAppraise) throws Exception {
		List<String> operateList = null;
		try {
			operateList = new ArrayList<String>();
			if("3".equals(isAppraise)){
				operateList.add("true");
			}else{
				operateList.add("false");
			}
		} catch (Exception e) {
			this.writeLog("getMeetingOperator Exception " + e);
		}
		return operateList;
	}
	
	 /**
     * 获取会议通知下发时间
     * @param mid
     * @param para
     * @return
     * @throws Exception
     */
    public String getNotifydays(String mid) throws Exception{
    	String result = "0";
    	
    	String createdate = "";
		String approvedate = "";
		String begindate = "";
    	String sql = "select createdate,approvedate,begindate from meeting  where id='"+mid+"' ";
    	weaver.conn.RecordSet rs = new weaver.conn.RecordSet();
    	rs.executeSql(sql);
    	if(rs.next()){
    		createdate = Util.null2String(rs.getString("createdate"));
    		approvedate = Util.null2String(rs.getString("approvedate"));
    		begindate = Util.null2String(rs.getString("begindate"));
    	}
    	String datetime_xf = "";
    	if(!"".equals(approvedate)){
    		datetime_xf = approvedate;
    	}else{
    		datetime_xf = createdate;
    	}
		result = Util.getIntValue(""+com.weaver.formmodel.util.DateHelper.getDaysBetween(begindate,datetime_xf) , 0) + "";
    	rs.executeSql("update meeting set datetime_ks = "+ result +" where id = " + mid);
    	return result;
    }
}
