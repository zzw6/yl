package weaver.meeting.Maint;

import java.util.*;
import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.StaticObj;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;

public class MeetingRoomComInfo extends BaseBean {
	private ArrayList ids = null;

	private ArrayList names = null;

	private ArrayList descs = null;

	private ArrayList hrmids = null;
	
	private ArrayList equipments = null;
	
	private ArrayList statuss = null;

	private StaticObj staticobj = null;

	private int current_index = -1;

	private int array_size = 0;

	ResourceComInfo rc = null;
	
	private static Object lock = new Object();	

	public MeetingRoomComInfo() throws Exception {
		staticobj = StaticObj.getInstance();
		getMeetingRoomInfo();
		array_size = ids.size();
	}

	private void getMeetingRoomInfo() throws Exception {
		synchronized(lock){
			if (staticobj.getObject("MeetingRoomInfo") == null){
				setMeetingRoomInfo();
			}
			ids = (ArrayList) (staticobj.getRecordFromObj("MeetingRoomInfo", "ids"));
			names = (ArrayList) (staticobj.getRecordFromObj("MeetingRoomInfo",
			"names"));
			descs = (ArrayList) (staticobj.getRecordFromObj("MeetingRoomInfo",
			"descs"));
			hrmids = (ArrayList) (staticobj.getRecordFromObj("MeetingRoomInfo",
			"hrmids"));
			equipments = (ArrayList) (staticobj.getRecordFromObj("MeetingRoomInfo",
			"equipments"));
			statuss = (ArrayList) (staticobj.getRecordFromObj("MeetingRoomInfo",
			"statuss"));
			
			if(ids == null){
				setMeetingRoomInfo();
    		}
			
		}
	}

	private void setMeetingRoomInfo() throws Exception {
		if (ids != null)
			ids.clear();
		else
			ids = new ArrayList();
		if (names != null)
			names.clear();
		else
			names = new ArrayList();
		if (descs != null)
			descs.clear();
		else
			descs = new ArrayList();
		if (hrmids != null)
			hrmids.clear();
		else
			hrmids = new ArrayList();
		if (equipments != null)
			equipments.clear();
		else
			equipments = new ArrayList();
		if (statuss != null)
			statuss.clear();
		else
			statuss = new ArrayList();

		RecordSet rs = new RecordSet();
		rs.executeSql("select id, name, roomdesc, hrmid, equipment, status from MeetingRoom");
		try {
			while (rs.next()) {
				ids.add(rs.getString(1));
				names.add(rs.getString(2));
				descs.add(rs.getString(3));
				hrmids.add(rs.getString(4));
				equipments.add(rs.getString(5));
				statuss.add(rs.getString(6));
			}
		} catch (Exception e) {
			writeLog(e);
			throw e;
		}
		staticobj.putRecordToObj("MeetingRoomInfo", "ids", ids);
		staticobj.putRecordToObj("MeetingRoomInfo", "names", names);
		staticobj.putRecordToObj("MeetingRoomInfo", "descs", descs);
		staticobj.putRecordToObj("MeetingRoomInfo", "hrmids", hrmids);
		staticobj.putRecordToObj("MeetingRoomInfo", "equipments", equipments);
		staticobj.putRecordToObj("MeetingRoomInfo", "statuss", statuss);
	}

	public int getMeetingRoomInfoNum() {
		return array_size;
	}

	public boolean next() {

		if ((current_index + 1) < array_size) {
			current_index++;
			return true;
		} else {
			current_index = -1;
			return false;
		}
	}

	public boolean next(String s) {
		while (((current_index + 1) < array_size)) {
			current_index++;
		}

		if ((current_index + 1) >= array_size) {
			current_index = -1;
			return false;
		} else {
			current_index++;
			return true;
		}
	}

	public void setTofirstRow() {
		current_index = -1;
	}

	public String getMeetingRoomInfoid() {
		return (String) (ids.get(current_index));
	}

	public String getMeetingRoomInfoname() {
		return ((String) (names.get(current_index)));
	}

	public String getMeetingRoomInfoname(String key) {
		int index = ids.indexOf(key);
		if (index != -1)
			return ((String) names.get(index));
		else
			return "";
	}

	public String getMeetingRoomInfodesc() {
		return ((String) (descs.get(current_index)));
	}

	public String getMeetingRoomInfodesc(String key) {
		String meetingaddr="";
		String [] adds = key.split(",");
		for(int i=0;i<adds.length;i++){
			if(!"".equals(adds[i])){
				String rooname =((String) descs.get(Util.getIntValue(adds[i])));
				if(!"".equals(meetingaddr)){
					meetingaddr+=",";
				}
				meetingaddr+=rooname;
			}
		}
		return meetingaddr;
	}

	public String getMeetingRoomInfohrmid() {
		return ((String) (hrmids.get(current_index)));
	}

	public String getMeetingRoomInfohrmid(String key) {
		int index = ids.indexOf(key);
		if (index != -1)
			return ((String) hrmids.get(index));
		else
			return "";
	}
	
	public String getMeetingRoomInfoequipment() {
		return ((String) (equipments.get(current_index)));
	}

	public String getMeetingRoomInfoequipment(String key) {
		int index = ids.indexOf(key);
		if (index != -1)
			return ((String) equipments.get(index));
		else
			return "";
	}
	
	public String getMeetingRoomInfostatus() {
		return ((String) (statuss.get(current_index)));
	}

	public String getMeetingRoomInfostatus(String key) {
		int index = ids.indexOf(key);
		if (index != -1)
			return ((String) statuss.get(index));
		else
			return "";
	}

	public void removeMeetingRoomInfoCache() {
		staticobj.removeObject("MeetingRoomInfo");
	}
    public static ArrayList getRoomIds() {
        RecordSet rs = new RecordSet();
        ArrayList returnList = new ArrayList() ;
        rs.executeProc("MeetingRoom_SelectAll","");        
        while (rs.next()) {
            returnList.add(rs.getString("id"));           
        }
        return returnList;
    }    
}