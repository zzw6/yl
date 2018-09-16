/**
 * Copyright (c) 2001-2006 泛微软件
 * 泛微协同商务系统，版权所有。
 */

package weaver.splitepage.transform;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import weaver.crm.Maint.CustomerContacterComInfo;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.meeting.Maint.MeetingRoomComInfo;
import weaver.systeminfo.SystemEnv;

/**
 * 会议模块标签类
 * 
 * @author Sun
 * @version 1.0
 */
public class SptmForMeeting
{
    MeetingRoomComInfo meetingRoomComInfo;
    ResourceComInfo resourceComInfo;
    
    /**
     * 构造方法
     */
    public SptmForMeeting() throws Exception
    {
        meetingRoomComInfo = new MeetingRoomComInfo();
        resourceComInfo = new ResourceComInfo();
    }

    /**
     * 得到会议连接
     * @param name
     * @param id
     * @return
     * @throws Exception
     */
    public String getMeetingName(String name, String parameter) throws Exception
    {
        List parameterList = Util.TokenizerString(parameter, "+");

        String id = (String) parameterList.get(0);

        String status = (String) parameterList.get(1);
        
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append("<A href='/meeting/data/ProcessMeeting.jsp?meetingid=");
        stringBuffer.append(id);
        stringBuffer.append("'>");
        stringBuffer.append(Util.forHtml(name));
        stringBuffer.append("</A>");
        
        if("0".equals(status))
        {
            stringBuffer.append("<IMG src='/images/BDNew_wev8.gif' align=absbottom border=0>");
        }
        else if("2".equals(status))
        {
            stringBuffer.append("<IMG src='/images/BDCancel_wev8.gif' align=absbottom border=0>");
        }        
        
        return stringBuffer.toString();
    }
    
    /**
     * 得到会议地址
     * @param address
     * @return
     * @throws Exception
     */
    public String getMeetingRoomAddress(String address, String customizeAddress) throws Exception
    {
    	String[] ids=address.split(",");
    	String ret="";
    	for(int i=0;i<ids.length;i++){
    		if(!"".equals(ids[i])){
        		ret+="<A href='/meeting/Maint/MeetingRoom.jsp'>" + meetingRoomComInfo.getMeetingRoomInfoname(ids[i]) + "</A> ";
    		}
    	}
        return ret + customizeAddress;
    }
    
    /**
     * 得到相关人员
     * @param hrmResourceId
     * @return
     * @throws Exception
     */
    public String getHrmResource(String hrmResourceId) throws Exception
    {
        return "<A href='/hrm/resource/HrmResource.jsp?id=" + hrmResourceId + "'>" + resourceComInfo.getResourcename(hrmResourceId) + "</A>";
    }
    
    /**
     * 得到会议状态
     * @param meetingStatus
     * @param userLanguage
     * @return
     * @throws Exception
     */
    public String getMeetingStatus(String meetingStatus, String para) throws Exception
    {
        String result = "";
        
        Date newdate = new Date() ;
        long datetime = newdate.getTime() ;
        Timestamp timestamp = new Timestamp(datetime) ;
        String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
        String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16);

        List parameterList = Util.TokenizerString(para, "+");
        String userLanguage=parameterList.get(0).toString();
        String endDate=parameterList.get(1).toString();
        String endTime=parameterList.get(2).toString();
        String status=parameterList.get(3).toString();
        
        if ("0".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(220, Integer.parseInt(userLanguage));
        }
        else if ("1".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(2242, Integer.parseInt(userLanguage));
        }
        else if ("2".equals(meetingStatus))
        {
         if((endDate+":"+endTime).compareTo(CurrentDate+":"+CurrentTime)>0)    
        	result = SystemEnv.getHtmlLabelName(225, Integer.parseInt(userLanguage));
         else
            result = SystemEnv.getHtmlLabelName(405, Integer.parseInt(userLanguage));
         if(status.equals("2"))
        	 result = SystemEnv.getHtmlLabelName(405, Integer.parseInt(userLanguage));          
        }
        else if ("3".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(1010, Integer.parseInt(userLanguage));
        }
        else if ("4".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(20114, Integer.parseInt(userLanguage));
        }

        return result;
    }
    
    /**
     * 得到日期时间
     * @param date
     * @param time
     * @return
     * @throws Exception
     */
    public String getDateTime(String date, String time) throws Exception
    {
        return date + " " + time;
    }
        
}
