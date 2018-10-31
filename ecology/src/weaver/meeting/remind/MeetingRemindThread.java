package weaver.meeting.remind;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.system.ThreadWork;

public class MeetingRemindThread implements ThreadWork {

	public void doThreadWork() {
		BaseBean bb = new BaseBean();
		RecordSet rs = new RecordSet();
		RecordSet rs1 = new RecordSet();
		try {
			String currentTime = TimeUtil.getCurrentTimeString();
			rs.execute("select * from meeting_remind where remindTime <= '" + currentTime + "'");
			while (rs.next()) {
				///MeetingRemindUtil.remindImmediately(rs.getString("meeting"), rs .getString("modetype"), "");
				rs1.execute("delete from meeting_remind where id = " + rs.getString("id"));
			}
		} catch (Exception e) {
			bb.writeLog("MeetingRemindThread Exception ---------- " + e);
		}
	}
}
