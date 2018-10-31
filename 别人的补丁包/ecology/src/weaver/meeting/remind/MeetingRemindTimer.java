package weaver.meeting.remind;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.interfaces.schedule.BaseCronJob;

public class MeetingRemindTimer extends BaseCronJob {

	public void execute() {
		BaseBean bb = new BaseBean();
		RecordSet rs = new RecordSet();
		RecordSet rs1 = new RecordSet();
		try {
			String currentTime = TimeUtil.getCurrentTimeString();
			rs.execute("select * from meeting_remindNew where remindTime <= '" + currentTime + "'");
			while (rs.next()) {
				String remindId = Util.null2String(rs.getString("id"));
				String meetingId = Util.null2String(rs.getString("meeting"));
				String modetype = Util.null2String(rs.getString("modetype"));
				MeetingRemindUtil.remindImmediately(meetingId, modetype, "");
				
				rs1.execute("delete from meeting_remindNew where id = " + remindId);
			}
		} catch (Exception e) {
			bb.writeLog("MeetingRemindThread Exception ---------- " + e);
		}
	}
}
