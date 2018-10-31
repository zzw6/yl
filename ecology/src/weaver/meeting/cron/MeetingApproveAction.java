package weaver.meeting.cron;

import com.weavernorth.util.TimeUtils;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.interfaces.workflow.action.Action;
import weaver.soa.workflow.request.RequestInfo;

/**
 * 会议审批日期修改
 */
public class MeetingApproveAction extends BaseBean implements Action {

	public String execute(RequestInfo request) {
		
		this.writeLog("MeetingApproveAction start ---- " + TimeUtil.getCurrentTimeString());
		
		String requestid = request.getRequestid();
		int userid = request.getRequestManager().getUser().getUID();
		RecordSet rs = null;
		TimeUtils t = null;
		try {
			rs = new RecordSet();
			t = new TimeUtils();
			int approveid = 0;
			rs.executeSql("select approveid from bill_meeting where requestid = " + requestid);
			if (rs.next()) {
				approveid = Util.getIntValue(rs.getString("approveid"));
			}

			this.writeLog("MeetingApproveAction approveid ---- " + approveid);
			
			if(approveid > 0){
				String sql = "update meeting set approver='" + userid
				+ "',approvedate='" + TimeUtil.getCurrentDateString()
				+ "',approvetime='" + t.meetingTimeFormatting(TimeUtil.getOnlyCurrentTimeString())
				+ "' where id = " + approveid;
				
				this.writeLog("MeetingApproveAction sql ---- " + sql);
				
				rs.executeSql(sql);
				
				
				String begindate = "";
				String meetingtype = "";
	    		rs.executeSql("select begindate,meetingtype from meeting  where id=" + approveid);
	        	if(rs.next()){
	        		begindate = Util.null2String(rs.getString("begindate"));
	        		meetingtype = Util.null2String(rs.getString("meetingtype"));
	        	}
	        	
	        	rs.executeProc("Meeting_Type_SelectByID",meetingtype);
	        	rs.next();
	        	String isTickling = Util.null2String(rs.getString("isTickling"));
	        	
	    		int result = Util.getIntValue(""+com.weaver.formmodel.util.DateHelper.getDaysBetween(begindate,TimeUtil.getCurrentDateString()), 0);
	    		
	    		rs.executeSql("update meeting set datetime_ks = "+ result +" where id = " + approveid);
	    		
	    		rs.executeSql("delete meeting_sharedetail where sharelevel = 4 and meetingid = " + approveid);
	    		
	    		if("1".equals(isTickling)){
	    			rs.executeSql("update meeting set isAppraise = 3 where id = " + approveid);
	    		}
			}
			this.writeLog("MeetingApproveAction end ---- " + TimeUtil.getCurrentTimeString());
		} catch (Exception e) {
			this.writeLog("MeetingApproveAction Exception " + e);
		}
		return Action.SUCCESS;
	}
}
