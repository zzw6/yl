<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.general.TimeUtil" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.*" %>
<%@ page import="weaver.hrm.*" %>
<jsp:useBean id="TimeUtils" class="com.weavernorth.util.TimeUtils" scope="page" />
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page" />

<%
User user = HrmUserVarify.getUser (request , response) ;

int currUser = user.getUID();
if(user == null){
	response.sendRedirect("/login/Login.jsp");
}

String operation = Util.fromScreen(request.getParameter("operation"),user.getLanguage());
String meetingId = Util.fromScreen(request.getParameter("meetingId"),user.getLanguage());

String[] queIds = request.getParameterValues("queId");
if(queIds != null){
	StringBuffer detailInSql = new StringBuffer();
	detailInSql.append("insert into MeetingAppraiseDetail ( ");
	
	StringBuffer inSql1 = new StringBuffer();
	inSql1.append("meetingId,userid,");
	int count = 1;
	for(int i =0; i < queIds.length; i++){
		int queId = Util.getIntValue(queIds[i]);
		if(queId > 0){
			String fildtype = "que" + count + "type";
			String fildmark = "que" + count + "mark";
			inSql1.append(fildtype + "," + fildmark + ",");
			count++;
		}
	}
	
	detailInSql.append(TimeUtils.replaceStr(inSql1.toString()));
	
	detailInSql.append(") values ( ");
	
	StringBuffer inSql2 = new StringBuffer();
	inSql2.append(" "+ meetingId +", "+ currUser +" ,");
	int count1 = 1;
	for(int i =0; i < queIds.length; i++){
		int queId = Util.getIntValue(queIds[i]);
		if(queId > 0){
			String quemark = Util.null2String(request.getParameter("quemark_" + queId));
			
			if(!"".equals(quemark)){
				String t_quemark = quemark.split("_")[0];
				String t_quetype = quemark.split("_")[1];
				
				inSql2.append("'"+ t_quetype +"'" + "," + t_quemark + ",");
				count1++;
			}
		}
	}
	
	detailInSql.append(TimeUtils.replaceStr(inSql2.toString()));
	
	detailInSql.append(")");
	
	BaseBean.writeLog("detailInSql.toString() : " + detailInSql.toString());
	
	boolean isSuccess = RecordSet.executeSql(detailInSql.toString());
	
	if(isSuccess){
		double quemark1 = 0;
		double queCount1 = 0;
		RecordSet.executeSql("select sum(que1mark) as quemark1,count(*) as queCount1 from MeetingAppraiseDetail where meetingId = " + meetingId);
		if(RecordSet.next()){
			quemark1 = Util.getDoubleValue(RecordSet.getString("quemark1"), 0);
			queCount1 = Util.getDoubleValue(RecordSet.getString("queCount1"), 0);
		}
		
		double quemark2 = 0;
		RecordSet.executeSql("select sum(que2mark) as quemark2 from MeetingAppraiseDetail where meetingId = " + meetingId);
		if(RecordSet.next()){
			quemark2 = Util.getDoubleValue(RecordSet.getString("quemark2"), 0);
		}
		
		double quemark3 = 0;
		RecordSet.executeSql("select sum(que3mark) as quemark3 from MeetingAppraiseDetail where meetingId = " + meetingId);
		if(RecordSet.next()){
			quemark3 = Util.getDoubleValue(RecordSet.getString("quemark3"), 0);
		}
		
		double queAve1 = 0;
		
		if(quemark1 > 0 && queCount1 > 0){
			double _queAve1 = quemark1 / queCount1;
			BigDecimal queAve1db = new BigDecimal(_queAve1);
			queAve1 = Util.getDoubleValue(queAve1db.setScale(1,BigDecimal.ROUND_HALF_UP).toString(), 0);
		}
		
		double queAve2 = 0;
		if(quemark2 > 0 && queCount1 > 0){
			double _queAve2 = quemark2 / queCount1;
			BigDecimal queAve2db = new BigDecimal(_queAve2);
			queAve2 = Util.getDoubleValue(queAve2db.setScale(1,BigDecimal.ROUND_HALF_UP).toString(), 0);
		}
		
		double queAve3 = 0;
		if(quemark3 > 0 && queCount1 > 0){
			double _queAve3 = quemark3 / queCount1;
			BigDecimal queAve3db = new BigDecimal(_queAve3);
			queAve3 = Util.getDoubleValue(queAve3db.setScale(1,BigDecimal.ROUND_HALF_UP).toString(), 0);
		}
		
		int appId = 0;
		RecordSet.executeSql("select id from MeetingAppraise where meetingId = " + meetingId);
		if(RecordSet.next()){
			appId = Util.getIntValue(RecordSet.getString("id"), 0);
		}
		
		double queCount = 0;
		double quemarkCount = quemark1 + quemark2 + quemark3;
		if(quemarkCount > 0 && queCount1 > 0){
			double _queCount = quemarkCount / queCount1;
			BigDecimal queCountdb = new BigDecimal(_queCount);
			queCount = Util.getDoubleValue(queCountdb.setScale(1,BigDecimal.ROUND_HALF_UP).toString(), 0);
		}
		
		StringBuffer appraiseSql = new StringBuffer();
		if(appId > 0){
			appraiseSql.append("update MeetingAppraise set ");
			appraiseSql.append("queCount1 = " + queAve1);
			appraiseSql.append(",queCount2 = " + queAve2);
			appraiseSql.append(",queCount3 = " + queAve3);
			appraiseSql.append(",queCount = " + queCount);
			appraiseSql.append(" where id = " + appId);
		}else{
			appraiseSql.append("insert into  MeetingAppraise ");
			appraiseSql.append("(meetingId,queCount1,queCount2,queCount3,queCount) values ");
			appraiseSql.append("(" + meetingId);
			appraiseSql.append("," + queAve1);
			appraiseSql.append("," + queAve2);
			appraiseSql.append("," + queAve3);
			appraiseSql.append("," + queCount);
			appraiseSql.append(")");
		}
		
		BaseBean.writeLog("appraiseSql.toString() : " + appraiseSql.toString());
		
		RecordSet.executeSql(appraiseSql.toString());
	}
}

response.sendRedirect("/meeting/Tickling/Reply/MeetingTicklingAdd.jsp?isClose=1");
%>
