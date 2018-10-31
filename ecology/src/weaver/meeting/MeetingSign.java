package weaver.meeting;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.company.DepartmentComInfo;
import weaver.hrm.resource.ResourceComInfo;

/**
 * Description: MeetingUtil.java
 * 
 * @author dongping
 * @version 1.0 2005-3-7
 */
public class MeetingSign extends BaseBean {
	
	private String type;

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	/***
	 * 
	 * 获取签到人姓名;
	 * 
	 * @param memberid
	 * @param membertype
	 * @return
	 */
	public String getResourceOrCrmName(String memberid, String membertype) {
		StringBuffer returnName = new StringBuffer();
		ResourceComInfo rc = null;
		RecordSet rs = null;
		try {
			rc = new ResourceComInfo();
			if ("1".equals(membertype)) {
				returnName.append("<a href=\"javaScript:openhrm(" + memberid + ");\" ");
				returnName.append(" onclick='pointerXY(event);'>");
				returnName.append(rc.getLastname(memberid) + "</a>");
			} else {
				rs = new RecordSet();
				String crmName = "";
				rs.executeSql("select name from uf_meeting_out_hum where id = " + memberid);
				if (rs.next()) {
					crmName = Util.null2String(rs.getString("name"));
				}
				returnName.append(crmName);
			}
		} catch (Exception e) {
			this.writeLog("getResourceOrCrmName Exception :" + e);
		}
		return returnName.toString();
	}
	
	/***
	 * 
	 * 获取签到人姓名;
	 * 
	 * @param memberid
	 * @param membertype
	 * @return
	 */
	public String getResourceOrCrmName1(String memberid, String membertype) {
		String returnName = "";
		ResourceComInfo rc = null;
		RecordSet rs = null;
		try {
			rc = new ResourceComInfo();
			if ("1".equals(membertype)) {
				returnName = rc.getLastname(memberid);
			} else {
				rs = new RecordSet();
				String crmName = "";
				rs.executeSql("select name from uf_meeting_out_hum where id = " + memberid);
				if (rs.next()) {
					crmName = Util.null2String(rs.getString("name"));
				}
				returnName = crmName;
			}
		} catch (Exception e) {
			this.writeLog("getResourceOrCrmName1 Exception :" + e);
		}
		return returnName;
	}
	
	public String getDeptmentName(String memberid, String membertype){
		String returnDep = "";
		ResourceComInfo rc = null;
		DepartmentComInfo dc = null;
		RecordSet rs = null;
		try{
			rc = new ResourceComInfo();
			dc = new DepartmentComInfo();
			if("1".equals(membertype)){
				returnDep = dc.getDepartmentname(rc.getDepartmentID(memberid));
			}else {
				rs = new RecordSet();
				rs.executeSql("select company from uf_meeting_out_hum where id = " + memberid);
				if (rs.next()) {
					returnDep = Util.null2String(rs.getString("company"));
				}
			}
		}catch(Exception e){
			this.writeLog("getDeptmentName Exception :" + e);
		}
		return returnDep;
	}
	
	public String getMeetingSignin(String meetingid, String memberid){
		String returnValue = "";
		RecordSet rs = null;
		try{
			rs = new RecordSet();
			int signCount = 0;
			rs.executeSql("select count(*) as signCount from uf_meetingsignin where meetingid = " + meetingid + " and members = " + memberid + " ");
			if(rs.next()){
				signCount = Util.getIntValue(rs.getString("signCount"));
			}
			if(signCount > 0){
				returnValue = "已签到";
			}else{
				returnValue = "未签到";
			}
		}catch(Exception e){
			this.writeLog("getMeetingSignin Exception :" + e);
		}
		return returnValue;
	}
	
	public String getMeetingSigninDate(String meetingid, String memberid){
		String returnValue = "";
		RecordSet rs = null;
		try{
			rs = new RecordSet();
			rs.executeSql("select signindate from uf_meetingsignin where meetingid = " + meetingid + " and members = " + memberid + " ");
			if(rs.next()){
				returnValue = Util.null2String(rs.getString("signindate"));
			}
		}catch(Exception e){
			this.writeLog("getMeetingSigninDate Exception :" + e);
		}
		return returnValue;
	}
	
	public String getMeetingSigninTime(String meetingid, String memberid){
		String returnValue = "";
		RecordSet rs = null;
		try{
			rs = new RecordSet();
			rs.executeSql("select signintime from uf_meetingsignin where meetingid = " + meetingid + " and members = " + memberid + " ");
			if(rs.next()){
				returnValue = Util.null2String(rs.getString("signintime"));
			}
		}catch(Exception e){
			this.writeLog("getMeetingSigninTime Exception :" + e);
		}
		return returnValue;
	}
	
	
	public String getDeptmentName(String departmentid){
		String returnDep = "";
		DepartmentComInfo dc = null;
		try{
			dc = new DepartmentComInfo();
			returnDep = dc.getDepartmentname(departmentid);
		}catch(Exception e){
			this.writeLog("getDeptmentName Exception :" + e);
		}
		return returnDep;
	}
	
	public String getMeetingNumber(String departmentid, String meetingid){
		String returnVal = "";
		RecordSet rs = null;
		try{
			rs = new RecordSet();
			int hrmCount = 0;
			StringBuffer hrmSql = new StringBuffer();
			hrmSql.append("select count(*) hrmCount ");
			hrmSql.append(" from hrmresource a,Meeting_Member2 b ");
			hrmSql.append("	where a.id = b.memberid ");
			hrmSql.append(" and  a.departmentid = " + departmentid);
			hrmSql.append(" and b.meetingid = " + meetingid);
			hrmSql.append("  and a.status in (0, 1, 2, 3) ");
			hrmSql.append(" and a.loginid is not null ");
			rs.executeSql(hrmSql.toString());
			if(rs.next()){
				hrmCount = Util.getIntValue(rs.getString("hrmCount"), 0);
			}
			int viewCount = 0;
			hrmSql = new StringBuffer();
			hrmSql.append("select count(*) as viewCount");
			hrmSql.append(" from hrmresource a, uf_meetingsignin b");
			hrmSql.append(" where a.id = b.members ");
			hrmSql.append(" and b.meetingid = " + meetingid);
			hrmSql.append(" and a.departmentid = " + departmentid);
			rs.executeSql(hrmSql.toString());
			if(rs.next()){
				viewCount = Util.getIntValue(rs.getString("viewCount"), 0);
			}
			returnVal = hrmCount + "/" + viewCount;
		}catch(Exception e){
			this.writeLog("getMeetingNumber Exception :" + e);
		}
		return returnVal;
	}
	
	public String getMeetingSign(String departmentid, String meetingid){
		StringBuffer returnName = new StringBuffer();
		RecordSet rs = null;
		ResourceComInfo rc = null;
		try{
			rs = new RecordSet();
			rc = new ResourceComInfo();
			StringBuffer hrmSql = new StringBuffer();
			hrmSql.append("select b.members ");
			hrmSql.append(" from hrmresource a, uf_meetingsignin b ");
			hrmSql.append(" where a.id = b.members ");
			hrmSql.append(" and meetingid = " + meetingid);
			hrmSql.append(" and departmentid = " + departmentid);
			rs.executeSql(hrmSql.toString());
			while(rs.next()){
				String userid = Util.null2String(rs.getString("members"));
				if(null != this.getType()){
					if("1".equals(this.getType())){
						returnName.append(rc.getLastname(userid));
					}else{
						returnName.append("<a href=\"javaScript:openhrm(" + userid + ");\" ");
						returnName.append(" onclick='pointerXY(event);'>");
						returnName.append(rc.getLastname(userid) + "</a>");
						returnName.append("&nbsp;&nbsp;");
					}
				}else{
					returnName.append("<a href=\"javaScript:openhrm(" + userid + ");\" ");
					returnName.append(" onclick='pointerXY(event);'>");
					returnName.append(rc.getLastname(userid) + "</a>");
					returnName.append("&nbsp;&nbsp;");
				}
			}
		}catch(Exception e){
			this.writeLog("getMeetingSign Exception :" + e);
		}
		return returnName.toString();
	}

	public String getMeetingNoSign(String departmentid, String meetingid){
		StringBuffer returnName = new StringBuffer();
		RecordSet rs = null;
		ResourceComInfo rc = null;
		try{
			rs = new RecordSet();
			rc = new ResourceComInfo();
			StringBuffer hrmSql = new StringBuffer();
			hrmSql.append("select b.memberid ");
			hrmSql.append(" from hrmresource a,Meeting_Member2 b ");
			hrmSql.append("	where a.id = b.memberid ");
			hrmSql.append(" and  a.departmentid = " + departmentid);
			hrmSql.append(" and b.meetingid = " + meetingid);
			hrmSql.append("  and a.status in (0, 1, 2, 3) ");
			hrmSql.append(" and a.loginid is not null ");
			hrmSql.append(" and b.memberid not in ");
			hrmSql.append(" (select b.members ");
			hrmSql.append(" from hrmresource a, uf_meetingsignin b ");
			hrmSql.append(" where a.id = b.members ");
			hrmSql.append(" and meetingid = " + meetingid);
			hrmSql.append(" and departmentid = " + departmentid + " ) ");
			rs.executeSql(hrmSql.toString());
			while(rs.next()){
				String userid = Util.null2String(rs.getString("memberid"));
				if(null != this.getType()){
					if("1".equals(this.getType())){
						returnName.append(rc.getLastname(userid));
					}else{
						returnName.append("<a href=\"javaScript:openhrm(" + userid + ");\" style=\"color: red;\" ");
						returnName.append(" onclick='pointerXY(event);'>");
						returnName.append(rc.getLastname(userid) + "</a>");
						returnName.append("&nbsp;&nbsp;");
					}
				}else{
					returnName.append("<a href=\"javaScript:openhrm(" + userid + ");\" style=\"color: red;\" ");
					returnName.append(" onclick='pointerXY(event);'>");
					returnName.append(rc.getLastname(userid) + "</a>");
					returnName.append("&nbsp;&nbsp;");
				}
			}
		}catch(Exception e){
			this.writeLog("getMeetingNoSign Exception :" + e);
		}
		return returnName.toString();
	}
}