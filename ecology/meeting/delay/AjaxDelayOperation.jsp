<%@ page language="java" contentType="text/html; charset=utf-8" %>
<%@ page import="weaver.file.FileUpload" %>
<%@ page import="java.util.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.sql.Timestamp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="meetingSetInfo" class="weaver.meeting.Maint.MeetingSetInfo" scope="page"/>
<%@ page import="weaver.file.Prop"%>
<%
User user = HrmUserVarify.getUser (request , response) ;
if(user == null)  return ;

FileUpload fu = new FileUpload(request);
String CurrentUser = ""+user.getUID();
String CurrentUserName = ""+user.getUsername();
String SubmiterType = ""+user.getLogintype();
String ClientIP = fu.getRemoteAddr();

Date newdate = new Date() ;
long datetime = newdate.getTime() ;
Timestamp timestamp = new Timestamp(datetime) ;
String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16) + ":" +(timestamp.toString()).substring(17,19);

char flag = 2;
String ProcPara = "";
String Sql="";

String method = Util.null2String(fu.getParameter("method"));
String meetingtype=Util.null2String(fu.getParameter("meetingtype"));
String meetingid=Util.null2String(fu.getParameter("meetingid"));
String approvewfid ="";
//判断会议室下一个会议日期时间
if("chkRoomDate".equals(method)){
	String returnstr = "0";
	String meetingids=Util.null2String(fu.getParameter("meetingid"));
	String enddate =Util.null2String(fu.getParameter("enddate"));
	String endtime =Util.null2String(fu.getParameter("endtime"));
	String nextdate=Util.null2String(fu.getParameter("nextdate"));
	String nexttime=Util.null2String(fu.getParameter("nexttime"));
	String delaydate=Util.null2String(fu.getParameter("delaydate"));
	String delaytime=Util.null2String(fu.getParameter("delaytime"));
	String addressselect = Util.null2String(fu.getParameter("addressselect"));
	String address = Util.null2String(fu.getParameter("address"));
	String customizeaddress = Util.null2String(fu.getParameter("customizeaddress"));
	long tss = com.weaver.formmodel.util.DateHelper.getMinutesBetween(enddate+"/"+endtime+":00",delaydate+"/"+delaytime+":00");
	if(tss >= 0){
		returnstr = "2";
	}else{
		if("9999-12-31".equals(nextdate) && "59:59".equals(nexttime)){
			returnstr = "0";
		}else{
			long ts = com.weaver.formmodel.util.DateHelper.getMinutesBetween(nextdate+"/"+nexttime+":00",delaydate+"/"+delaytime+":00");
			if(ts>=10){
				returnstr = "0";
			}else{
				returnstr = "1";
			}
		}
		if("0".equals(returnstr)){

			String addresss []=null;
			if("0".equals(addressselect))
				addresss=address.split(",");
			else
			    addresss=customizeaddress.split(",");

			for (String s : addresss) {

				String chkRoomSql = "select begindate,enddate,begintime,endtime,id,meetingtype from meeting where meetingstatus " +
						"in (1,2) and repeatType = 0 and isdecision<2  and (begindate || ' ' || begintime >= '"+enddate+" "+endtime+"')";
				if("0".equals(addressselect)){
					chkRoomSql += " and ','||address||','  like '%,"+s+",%'";
				}else{
					chkRoomSql += " and customizeaddress='"+s+"'";
				}
				chkRoomSql += " order by begindate,begintime";
				new weaver.general.BaseBean().writeLog("chkRoomSql:"+chkRoomSql);
				RecordSet.executeSql(chkRoomSql);
				while (RecordSet.next()) {
					nextdate = Util.null2String(RecordSet.getString("begindate"));
					nexttime = Util.null2String(RecordSet.getString("begintime"));
					long ts = com.weaver.formmodel.util.DateHelper.getMinutesBetween(nextdate+"/"+nexttime+":00",delaydate+"/"+delaytime+":00");
					if("0".equals(returnstr)&&ts>=10){
						returnstr = "0";
					}else{
						returnstr = "1";
						out.write(returnstr);
						return;
					}
				}

			}


		}
	}
	out.write(returnstr);
}
//会议室冲突校验
if("chkRoom".equals(method)){
	String meetingaddress = Util.null2String(fu.getParameter("address"));
	String begindate=Util.null2String(fu.getParameter("begindate"));
	String begintime=Util.null2String(fu.getParameter("begintime"));
	String enddate=Util.null2String(fu.getParameter("enddate"));
	String endtime=Util.null2String(fu.getParameter("endtime"));
	String requestid = Util.null2String(fu.getParameter("requestid"));
	String meetingids=Util.null2String(fu.getParameter("meetingid"));
	String returnstr = "0";
	if(meetingSetInfo.getRoomConflictChk() == 1 ){
		if(!"".equals(requestid)) {
		   RecordSet.executeSql("select approveid from Bill_Meeting where requestid="+requestid);
		   if(RecordSet.next()) {
			  meetingids = Util.null2String(RecordSet.getString("approveid"));
		   }
		}
		String meetingType = Util.null2String(Prop.getPropValue("meeting", "meetingtype"));
		System.out.println("meetingType:"+meetingType);
		String chkRoomSql = "select address,begindate,enddate,begintime,endtime,id,meetingtype from meeting where meetingstatus in (1,2) and repeatType = 0 and isdecision<2 and (cancel is null or cancel<>'1') and (begindate <= '"+enddate+"' and enddate >='"+begindate+"')";	
		System.out.println("chkRoomSql:"+chkRoomSql);
		RecordSet.executeSql(chkRoomSql);
		while(RecordSet.next()) {
			String begindatetmp = Util.null2String(RecordSet.getString("begindate"));
			String begintimetmp = Util.null2String(RecordSet.getString("begintime"));
			String enddatetmp = Util.null2String(RecordSet.getString("enddate"));
			String endtimetmp = Util.null2String(RecordSet.getString("endtime"));
			String addresstmp = Util.null2String(RecordSet.getString("address"));
			String mid = Util.null2String(RecordSet.getString("id"));
			String mtype = Util.null2String(RecordSet.getString("meetingtype"));

			String str1 = begindate+" "+begintime;
			String str2 = enddatetmp+" "+endtimetmp;
			String str3 = enddate+" "+endtime;
			String str4 = begindatetmp+" "+begintimetmp;

			if(!"".equals(meetingaddress) && meetingaddress.equals(addresstmp) && !mid.equals(meetingids)) {
				System.out.println("str1:"+str1+"str2:"+str2+"str3:"+str3+"str4:"+str4);
				System.out.println("mtype:"+(str1.compareTo(str2) < 0 && str3.compareTo(str4) > 0));
				if((str1.compareTo(str2) < 0 && str3.compareTo(str4) > 0)) {
					
				   returnstr = "1";
				   System.out.println("mtype:"+mtype);
				   System.out.println("mtype:"+("".equals(meetingType)));
				   
				   if(mtype.equals(meetingType)){
						//lq 有强制占用会议室时间						
						returnstr = "2";
						break;
				   }
				   
				}
			}
		}
	}
    out.write(returnstr);
}

%>
