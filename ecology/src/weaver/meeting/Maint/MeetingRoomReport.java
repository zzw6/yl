/*
 * MeetingRoomReport.java Created on 2004-11-12 10:57:31
 *
 * Copyright (c) 2001-2004 泛微软件, 版权所有.
 */
package weaver.meeting.Maint;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.hrm.User;
import weaver.hrm.resource.ResourceComInfo;
import weaver.meeting.defined.MeetingFieldComInfo;
import weaver.systeminfo.SystemEnv;
/**
 * Description: MeetingRoomReport.java
 * 
 * @author dongping
 * @version 1.0 2004-11-12
 */

public class MeetingRoomReport extends BaseBean{   
    private final static int Type_BYMONTH = 2; 
    private final static int Type_BYWEEK = 3;
    private final static int Type_BYDAY = 4;
    
    ResourceComInfo rc = null;
    ArrayList roomIds = null ;    
    RecordSet rs = null ;
    public MeetingRoomReport() {
        roomIds = MeetingRoomComInfo.getRoomIds(); 
        rs = new RecordSet();
        try {
            rc = new ResourceComInfo();
        } catch (Exception ex) {
            writeLog(ex.getMessage());
        }
    }
   
    /** 
     * @param day : if selectType is Type_BYWEEK the day must the first day of this week 
     *              if selectType is Type_BYMONTH the day must the first day of this month
     *               
     * @param selectType ：build sql sentence type
     * @param roomId ：use the room`s id
     * @return sql: builded sql sentence
     */
    public String getSql(String day,int selectType,int roomid){
        String returnStr = "" ;   
        switch (selectType) {
            case Type_BYMONTH :
                returnStr="select meeting.*, (SELECT count(1) from Meeting_Member2 where meetingId = meeting.id ) as total, meeting_type.name AS meetingTypeName from meeting, meeting_type where meeting.meetingType = meeting_type.id AND meeting.repeatType = 0 AND meeting.meetingstatus in (1,2) and ('"+day+"'" +
                        " between SUBSTRING(meeting.begindate,1,7) and SUBSTRING(meeting.enddate,1,7)) and (meeting.isdecision<2)" +
                        " and ','||meeting.address||','  like '%,"+roomid+",%' order by meeting.begindate desc";
                break ;
            case Type_BYWEEK :
                returnStr="select meeting.*, (SELECT count(1) from Meeting_Member2 where meetingId = meeting.id ) as total, meeting_type.name AS meetingTypeName from meeting, meeting_type where meeting.meetingType = meeting_type.id AND meeting.repeatType = 0 AND meeting.meetingstatus in (1,2) and ( "   ;   
                for (int h = -1;h<6;h++){                 
                    String newTempDate = TimeUtil.dateAdd(day,h) ;
                    returnStr +="('"+newTempDate+"' between meeting.begindate and meeting.enddate) or" ;         
                }
                returnStr = returnStr.substring(0,returnStr.length()-2);
                returnStr += ") and ','||meeting.address||','  like '%,"+roomid+",%' and (meeting.isdecision<2) order by meeting.begindate desc" ;
                break ;                
            case Type_BYDAY : 
                returnStr = "select meeting.*, (SELECT count(1) from Meeting_Member2 where meetingId = meeting.id ) as total, meeting_type.name AS meetingTypeName from meeting, meeting_type where meeting.meetingType = meeting_type.id AND meeting.repeatType = 0 AND meeting.meetingstatus in (1,2) and ('"+day+"' " +
                        "between meeting.begindate and meeting.enddate)  and (meeting.isdecision<2) " +
                        " and ','||meeting.address||','  like '%,"+roomid+",%' order by meeting.begintime desc" ;
                break ;      
        }
        
        if ((rs.getDBType()).equals("oracle")) {
            returnStr = Util.StringReplace(returnStr,"SUBSTRING","substr");   
        }
        return returnStr;
    }
    
    
    /** 
     * @param day : if selectType is Type_BYWEEK the day must the first day of this week 
     *              if selectType is Type_BYMONTH the day must the first day of this month
     *               
     * @param selectType ：build sql sentence type
     * @param roomId ：use the room`s id
     * @return sql: builded sql sentence
     */
    public String getSqlNobyRoom(String day,int selectType){
        String returnStr = "" ;   
        switch (selectType) {
            case Type_BYMONTH :                  
                returnStr="meeting.* , (SELECT count(1) from Meeting_Member2 where meetingId = meeting.id ) as total from meeting where meetingstatus in (1,2) AND repeatType = 0 and ('"+day+"'" +
                        " between SUBSTRING(begindate,1,7) and SUBSTRING(enddate,1,7)) and (isdecision<2)" +
                        "  order by begindate desc";
                break ;
            case Type_BYWEEK :
                returnStr="meeting.* , (SELECT count(1) from Meeting_Member2 where meetingId = meeting.id ) as total from meeting where  meetingstatus in (1,2) AND repeatType = 0 and ( "   ;   
                for (int h = -1;h<6;h++){                 
                    String newTempDate = TimeUtil.dateAdd(day,h) ;
                    returnStr +="('"+newTempDate+"' between begindate and enddate) or" ;         
                }
                returnStr = returnStr.substring(0,returnStr.length()-2);
                returnStr += ") and (isdecision<2) order by begindate desc" ;
                break ;                
            case Type_BYDAY : 
                returnStr = "meeting.* , (SELECT count(1) from Meeting_Member2 where meetingId = meeting.id ) as total from meeting where  meetingstatus in (1,2) AND repeatType = 0 and ('"+day+"' " +
                        "between begindate and enddate)  and (isdecision<2) " +
                        "  order by begintime desc" ;
                break ;      
        }
        
        if ((rs.getDBType()).equals("oracle")) {
            returnStr = Util.StringReplace(returnStr,"SUBSTRING","substr");   
        }
        return returnStr;
    }


    /**
     * 
     * @param selectType 2:Type_BYMONTH 3:Type_BYWEEK 4:Type_BYDAY
     * @param today : current day
     * @return : By week mapping
     */
    public HashMap getMapping(String day,int selectType) {
        HashMap returnMap = new HashMap();               
       
        ArrayList roomIds = MeetingRoomComInfo.getRoomIds();
        String sql = "";
        
        for(int i=0;i<roomIds.size();i++){
            HashMap tempMap = new HashMap();
            
            ArrayList ids = new ArrayList();
            ArrayList names = new ArrayList();
            ArrayList totalmembers = new ArrayList();      
            ArrayList callers = new ArrayList();
            ArrayList contacters = new ArrayList();
            ArrayList beginDates = new ArrayList();
            ArrayList endDates = new ArrayList();
            ArrayList begintimes = new ArrayList();
            ArrayList endtimes = new ArrayList();
            ArrayList addresses = new ArrayList();
            ArrayList cancels = new ArrayList();
            List meetingTypeList = new ArrayList();
            List meetingStatusList = new ArrayList();
            
            if (selectType != 2 && selectType != 3 && selectType != 4){
                writeLog("the meeting room query way is not found!");
            } else {
                sql = getSql(day,selectType,Util.getIntValue((String)roomIds.get(i)));
            }      
           
            rs.executeSql(sql);
                       
            while(rs.next()) {
                String id = Util.null2String(rs.getString("id"));
                String name = Util.null2String(rs.getString("name"));
                String totalmember = Util.null2String(rs.getString("total"));
                String caller = Util.null2String(rs.getString("caller"));
                String contacter = Util.null2String(rs.getString("contacter"));
                String beginDate = Util.null2String(rs.getString("begindate"));
                String endDate = Util.null2String(rs.getString("enddate"));        
                String begintime = Util.null2String(rs.getString("begintime"));
                String endtime = Util.null2String(rs.getString("endtime"));
                String address =  Util.null2String(rs.getString("address"));
                String cancel = Util.null2String(rs.getString("cancel"));
                String meetingType = Util.null2String(rs.getString("meetingTypeName"));
                String meetingStatus = Util.null2String(rs.getString("meetingStatus"));
                
                ids.add(id);
                names.add(name);  
                totalmembers.add(totalmember); 
                callers.add(caller); 
                contacters.add(contacter);                 
                beginDates.add(beginDate); 
                endDates.add(endDate); 
                begintimes.add(begintime); 
                endtimes.add(endtime);
                addresses.add(address);
                cancels.add(cancel);
                meetingTypeList.add(meetingType);
                meetingStatusList.add(meetingStatus);
           }
            
            tempMap.put("ids",ids) ;
            tempMap.put("names",names) ;
            tempMap.put("totalmembers",totalmembers) ;
            tempMap.put("callers",callers) ;
            tempMap.put("contacters",contacters) ;
            tempMap.put("beginDates",beginDates) ;
            tempMap.put("endDates",endDates) ;
            tempMap.put("begintimes",begintimes) ;
            tempMap.put("endtimes",endtimes) ;   
            tempMap.put("addresses",addresses) ;
            tempMap.put("cancels",cancels);
            tempMap.put("meetingTypes", meetingTypeList);
            tempMap.put("meetingStatus", meetingStatusList);
            
            returnMap.put(""+roomIds.get(i),tempMap);            
        }
        return returnMap;
    }    
    
    public String getMeetRoomUseCase(String name,String totalmember,String caller,String contacter,String beginDate,
                                     String endDate,String begintime,String endtime){
    	String returnStr = "" ;
		MeetingFieldComInfo mfc=new MeetingFieldComInfo();
		returnStr = "" + SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("2")),7)+":  " + name
		+ "    "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("31")),7)+":   " + totalmember+ "\n"
		+ SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("3")),7)+":    " + rc.getResourcename(caller)
		+ "   "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("4")),7)+":  "
		+ rc.getResourcename(contacter) + "\n"
		+ SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("17")),7)+":  " + beginDate + "     "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("19")),7)+":  "
		+ endDate + "\n" + SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("18")),7)+":  "
		+ begintime + "      "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("20")),7)+":  "
		+endtime ;
        
        return returnStr ;
    } 
    
    public String getMeetRoomUseCase(String name,String totalmember,String caller,String contacter,String beginDate,
            String endDate,String begintime,String endtime,User user){
		String returnStr = "" ;
		MeetingFieldComInfo mfc=new MeetingFieldComInfo();
		returnStr = "" + SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("2")),user.getLanguage())+":  " + name
		+ "    "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("31")),user.getLanguage())+":   " + totalmember+ "\n"
		+ SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("3")),user.getLanguage())+":    " + rc.getResourcename(caller)
		+ "   "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("4")),user.getLanguage())+":  "
		+ rc.getResourcename(contacter) + "\n"
		+ SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("17")),user.getLanguage())+":  " + beginDate + "     "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("19")),user.getLanguage())+":  "
		+ endDate + "\n" + SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("18")),user.getLanguage())+":  "
		+ begintime + "      "+SystemEnv.getHtmlLabelName(Util.getIntValue(mfc.getLabel("20")),user.getLanguage())+":  "
		+endtime ;
		
		return returnStr ;
	}
    
    public String getMeetRoomInfo(String key,MeetingRoomComInfo mr) throws Exception{
		String returnStr = "" ;
		returnStr = "" + (SystemEnv.getHtmlLabelName(780, 7)+SystemEnv.getHtmlLabelName(195, 7))+":" + mr.getMeetingRoomInfoname(key)+ "\n"
		+ (SystemEnv.getHtmlLabelName(780, 7)+SystemEnv.getHtmlLabelName(433, 7))+":" + mr.getMeetingRoomInfodesc(key)+ "\n"
		+ SystemEnv.getHtmlLabelName(2156, 7)+":" + rc.getLastname(mr.getMeetingRoomInfohrmid(key))+ "\n"
		+ SystemEnv.getHtmlLabelName(780, 7)+SystemEnv.getHtmlLabelName(1326,7)+":" +mr.getMeetingRoomInfoequipment(key);
		
		
		return returnStr ;
    } 
    
    public String getMeetRoomInfo(String key,MeetingRoomComInfo mr,User user) throws Exception{
		String returnStr = "" ;
		returnStr = "" + (SystemEnv.getHtmlLabelName(780, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(195, user.getLanguage()))+":" + mr.getMeetingRoomInfoname(key)+ "\n"
		+ (SystemEnv.getHtmlLabelName(780, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(433, user.getLanguage()))+":" + mr.getMeetingRoomInfodesc(key)+ "\n"
		+ SystemEnv.getHtmlLabelName(2156, user.getLanguage())+":" + rc.getLastname(mr.getMeetingRoomInfohrmid(key))+ "\n"
		+ (SystemEnv.getHtmlLabelName(780, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(1326, user.getLanguage()))+":" +mr.getMeetingRoomInfoequipment(key);
		
		
		return returnStr ;
    } 
}
