package weaver.meeting.remind;

import java.util.Set;

import com.erie.ErieUtils;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.meeting.MeetingUtilForYl;

/***
 * 
 * message 会议提醒
 * 
 * @author 51ibm
 * 
 */
public class RemindEmessage implements IMeetingRemind {

	public void sendRemind(Set<String> touser, String title, String msg) {
		BaseBean bb = new BaseBean();
		RecordSet rs = new RecordSet();
		ErieUtils u = new ErieUtils();
		bb.writeLog("RemindEmessage start -----------");
		try {
			if (touser != null && touser.size() > 0) {
				String sendUsers = "";
				for (String hrmid : touser) {
					if (null != hrmid && !"".equals(hrmid)) {
						sendUsers += "," + hrmid + ",";
					}
				}
				String tmpUser = u.replaceStr(sendUsers);
				if (!"".equals(tmpUser)) {
					int id = 0;
					rs.executeProc("MeetingRemark_Get", "");
					if (rs.next()) {
						id = Util.getIntValue(rs.getString(1), 0);
					}
					boolean isSuccess = rs.executeSql("insert into meeting_Remark (id,msg) values (" + id + ",'" + msg + "')");
					if(isSuccess){
						MeetingUtilForYl.sendMsg(tmpUser, msg, "/mobile/plugin/5/ShowMessage.jsp?id=" + id);
					}
				}
			}
			bb.writeLog("RemindEmessage end -----------");
		} catch (Exception e) {
			bb.writeLog("RemindEmessage Exception " + e);
		}
	}
}
