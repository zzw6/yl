<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="weaver.splitepage.transform.SptmForMeeting"%>
<%@page import="weaver.meeting.MeetingShareUtil"%>
<%@page import="com.weaver.formmodel.util.DateHelper"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@page import="weaver.meeting.defined.MeetingFieldManager"%>
<%@page import="org.json.JSONObject"%> 
<%@ page import="weaver.general.IsGovProj" %>
<%@page import="weaver.meeting.util.html.HtmlUtil"%> 
<%@ page import="weaver.workflow.request.RequestInfo" %>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet2" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet3" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="meetingSetInfo" class="weaver.meeting.Maint.MeetingSetInfo" scope="page"/>
<jsp:useBean id="MeetingFieldComInfo" class="weaver.meeting.defined.MeetingFieldComInfo" scope="page"/>
<jsp:useBean id="MeetingFieldGroupComInfo" class="weaver.meeting.defined.MeetingFieldGroupComInfo" scope="page"/>
<%@ include file="/cowork/uploader.jsp" %>
 
<%
String showDiv = Util.null2String(request.getParameter("showdiv"));
String needRefresh=Util.null2String(request.getParameter("needRefresh"));
int isgoveproj = Util.getIntValue(IsGovProj.getPath(),0);//0:非政务系统，1：政务系统
String userid = ""+user.getUID();
String logintype = ""+user.getLogintype();

String meetingid = Util.null2String(request.getParameter("meetingid"));
String tab = Util.null2String(request.getParameter("tab"));

RecordSet.executeProc("Meeting_SelectByID",meetingid);
RecordSet.next();
String meetingtype=RecordSet.getString("meetingtype");
String meetingname=RecordSet.getString("name");
String caller=RecordSet.getString("caller");
String contacter=RecordSet.getString("contacter");
//获取会议记录人id  lq  2015-10-22
String recorder=RecordSet.getString("recorder");
String addressselect = RecordSet.getString("addressselect");
String address=RecordSet.getString("address");
String customizeaddress =RecordSet.getString("customizeaddress");
String begindate=RecordSet.getString("begindate");
String begintime=RecordSet.getString("begintime");
String enddate=RecordSet.getString("enddate");
String endtime=RecordSet.getString("endtime");

String desc=RecordSet.getString("desc_n");
String creater=RecordSet.getString("creater");
String createdate=RecordSet.getString("createdate");

String createtime=RecordSet.getString("createtime");
String approver=RecordSet.getString("approver");
String approvedate=RecordSet.getString("approvedate");
String approvetime=RecordSet.getString("approvetime");

String isapproved=RecordSet.getString("isapproved");
String isdecision=RecordSet.getString("isdecision");
String decision=RecordSet.getString("decision");
String decisiondocid=RecordSet.getString("decisiondocid");

String decisionwfids=RecordSet.getString("decisionwfids");
String decisioncrmids=RecordSet.getString("decisioncrmids");
String decisionprjids=RecordSet.getString("decisionprjids");
String decisiontskids=RecordSet.getString("decisiontskids");
String decisionatchids=RecordSet.getString("decisionatchids");

String totalmember=RecordSet.getString("totalmember");
String othermembers=RecordSet.getString("othermembers");
String othersremark=RecordSet.getString("othersremark");
String addressdesc=RecordSet.getString("addressdesc");
String remindTypeNew=RecordSet.getString("remindTypeNew");
String meetingstatus=RecordSet.getString("meetingstatus");

//lq  议事规则  获取 议事规则标识 和 分部id
String isparliament = RecordSet.getString("isparliament");
String subcompanyid = RecordSet.getString("subcompanyid");
int repeatType = Util.getIntValue(RecordSet.getString("repeatType"),0);
//只有会议的创建人、主持人、记录人有权限发起这个操作
boolean isedit = false;
if(userid.equals(contacter) || userid.equals(caller) || userid.equals(recorder)){
	isedit = true;
}
if(!isedit){
	response.sendRedirect("/notice/noright.jsp") ;
}
String currentDate = DateHelper.getCurrentDate();
String currentTime = DateHelper.getCurrentTime();
double sy_hour = 0.00; //剩余时长
String sy_hour_str = "0小时0分0秒";
if(!"".equals(begindate)&&!"".equals(begintime)&&!"".equals(enddate)&&!"".equals(endtime)){
	String fromdatetime = DateHelper.getCurrentDate()+" "+DateHelper.getCurrentTime();
	String todatetime = enddate+" "+endtime+":00";
	long timeInterval = TimeUtil.timeInterval(fromdatetime, todatetime);
	java.text.DecimalFormat df = new java.text.DecimalFormat("#.##");
	sy_hour = Double.parseDouble(df.format((double)timeInterval/60/60));
	if(sy_hour<=0){
		sy_hour = 0.0;
		sy_hour_str = "0小时0分0秒";
	}else{
		//小时：h=time/3600（整除）
		long h = timeInterval /3600;
		//分钟：m=(time-h*3600)/60 （整除）
		long m = (timeInterval-h*3600)/60;
		//秒：s=(time-h*3600) mod 60 （取余）
		long s = (timeInterval-h*3600) % 60;
		sy_hour_str = h+"小时"+m+"分"+s+"秒";
	}
}
String begindatetmp = "";
String begintimetmp = "";
double yc_hour = 0.00; //延长时间
String yc_hour_str = "";
if(sy_hour>0 && sy_hour <=0.25){ //剩余时间在15分钟以内才计算延长时间
	String chkRoomSql = "select begindate,enddate,begintime,endtime,id,meetingtype from meeting where meetingstatus in (1,2) and repeatType = 0 and isdecision<2  and (begindate || ' ' || begintime >= '"+enddate+" "+endtime+"')";
	if("0".equals(addressselect)){
		chkRoomSql += " and ','||address||',' like '%,"+address+",%'";
	}else{
		chkRoomSql += " and customizeaddress='"+customizeaddress+"'";
	}
	chkRoomSql += " order by begindate,begintime";
	//System.out.println("chkRoomSql:"+chkRoomSql);
	RecordSet.executeSql(chkRoomSql);
	if(RecordSet.next()) {
		begindatetmp = Util.null2String(RecordSet.getString("begindate"));
		begintimetmp = Util.null2String(RecordSet.getString("begintime"));
		
		String fromdatetime = enddate+" "+endtime+":00"; 
		String todatetime = begindatetmp+" "+begintimetmp+":00";
		long timeInterval = TimeUtil.timeInterval(fromdatetime, todatetime);
		//下一次会议前十分钟 （需要减去十分钟，十分钟为等于600秒）
		timeInterval = timeInterval - 10*60;
		java.text.DecimalFormat df = new java.text.DecimalFormat("#.##");
		yc_hour = Double.parseDouble(df.format((double)timeInterval/60/60));
		if(yc_hour <= 0){
			yc_hour = 0.0;
			yc_hour_str = "0小时0分0秒";
		}else{
			//小时：h=time/3600（整除）
			long h = timeInterval /3600;
			//分钟：m=(time-h*3600)/60 （整除）
			long m = (timeInterval-h*3600)/60;
			//秒：s=(time-h*3600) mod 60 （取余）
			long s = (timeInterval-h*3600) % 60;
			yc_hour_str = h+"小时"+m+"分"+s+"秒";
		}
	}else{
		begindatetmp = DateHelper.getCurrentDate();//"9999-12-31";
		begintimetmp = "22:59";
		
		String fromdatetime = enddate+" "+endtime+":00"; 
		String todatetime = begindatetmp+" "+begintimetmp+":00";
		long timeInterval = TimeUtil.timeInterval(fromdatetime, todatetime);
		//下一次会议前十分钟 （需要减去十分钟，十分钟为等于600秒）
		timeInterval = timeInterval - 10*60;
		java.text.DecimalFormat df = new java.text.DecimalFormat("#.##");
		yc_hour = Double.parseDouble(df.format((double)timeInterval/60/60));
		if(yc_hour <= 0){
			yc_hour = 0.0;
			yc_hour_str = "0小时0分0秒";
		}else{
			//小时：h=time/3600（整除）
			long h = timeInterval /3600;
			//分钟：m=(time-h*3600)/60 （整除）
			long m = (timeInterval-h*3600)/60;
			//秒：s=(time-h*3600) mod 60 （取余）
			long s = (timeInterval-h*3600) % 60;
			yc_hour_str = h+"小时"+m+"分"+s+"秒";
		}
		
	}
}
%>

<HTML><HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<script language=javascript src="/js/weaver_wev8.js"></script>
</HEAD>
<%

String titlename="";
titlename+= "<B>"+SystemEnv.getHtmlLabelName(401,user.getLanguage())+":</B>"+createdate;

String imagefilename = "/images/hdMaintenance_wev8.gif";
titlename = SystemEnv.getHtmlLabelName(2103,user.getLanguage())+":"+Util.forHtml(meetingname)+"   "+titlename;
String needfav ="1";
String needhelp ="";

%>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>

<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
	// 
	if(sy_hour>0 && sy_hour <= 0.25){
	    RCMenu += "{"+SystemEnv.getHtmlLabelName(2191,user.getLanguage())+",javascript:doEdit(),_top} " ;
		RCMenuHeight += RCMenuHeightStep ;
	}
	//关闭
	RCMenu += "{"+SystemEnv.getHtmlLabelName(309,user.getLanguage())+",javascript:btn_cancle(),_self} " ;
	RCMenuHeight += RCMenuHeightStep ;
	
%>
	
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align: right; width: 400px !important">
			<%if(sy_hour>0 && sy_hour <= 0.25){ %>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(2191,user.getLanguage()) %>" class="e8_btn_top middle" onclick="doEdit()"/>
			<%} %>
			<span title="<%=SystemEnv.getHtmlLabelName(23036, user.getLanguage())%>"  class="cornerMenu middle"></span>
		</td>
	</tr>
</table>


<div id="tabDiv">
	<span style="width:10px"></span>
	<span id="hoverBtnSpan" class="hoverBtnSpan">
	</span>
</div>
<div class="zDialog_div_content" >
<FORM id=weaver name=weaver action="/meeting/delay/DelayOperation.jsp" method=post>
<input class=inputstyle type="hidden" name="method" value="edit">
<input class=inputstyle type="hidden" name="meetingid" value="<%=meetingid%>">
<input class=inputstyle type="hidden" name="enddate" value="<%=enddate%>">
<input class=inputstyle type="hidden" name="endtime" value="<%=endtime%>">
<div id="nomalDiv">
<wea:layout type="2col">
<wea:group context="<%="会议信息" %>" attributes="{'groupDisplay':''}">
<%    
//遍历分组
MeetingFieldManager hfm = new MeetingFieldManager(1);
hfm.getCustomData(Util.getIntValue(meetingid));
List<String> groupList=hfm.getLsGroup();
List<String> fieldList=null;
for(String groupid:groupList){
	fieldList= hfm.getUseField(groupid);
	if(fieldList!=null&&fieldList.size()>0){		
%>

	<%for(String fieldid:fieldList){
		if(repeatType > 0) {//周期会议
			if("0".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}else{//非周期会议
			if("1".equals(MeetingFieldComInfo.getIsrepeat(fieldid))) continue;
		}
		if("0".equals(MeetingFieldComInfo.getIsused(fieldid))) continue;//没有启用,隐藏处理
		
		String fieldname = MeetingFieldComInfo.getFieldname(fieldid);
		int fieldlabel = Util.getIntValue(MeetingFieldComInfo.getLabel(fieldid));
		int fieldhtmltype = Integer.parseInt(MeetingFieldComInfo.getFieldhtmltype(fieldid));
		int type = Integer.parseInt(MeetingFieldComInfo.getFieldType(fieldid));
		boolean issystem ="1".equals(MeetingFieldComInfo.getIssystem(fieldid))||"0".equals(MeetingFieldComInfo.getIssystem(fieldid));
		boolean ismand="1".equals(MeetingFieldComInfo.getIsmand(fieldid));
		String weekStr="";
		JSONObject cfg= hfm.getFieldConf(fieldid);
		String fieldValue = hfm.getData(fieldname);
		
		//转成html显示
		if(fieldhtmltype==4){//check框,变成disabled
			cfg.put("disabled","disabled");
			fieldValue=HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
		}else if(fieldhtmltype==6){
			cfg.put("canDelAcc",false);//是否有删除按钮
			cfg.put("canupload",false);//是否可以上传
			cfg.put("candownload",true);//是否有下载按钮
			fieldValue=HtmlUtil.getHtmlElementString(fieldValue,cfg,user);
		}else if(fieldhtmltype==3){
			fieldValue=hfm.getHtmlBrowserFieldvalue(user,Integer.parseInt(fieldid),fieldhtmltype,type,fieldValue);
		}else{
			fieldValue=hfm.getFieldvalue(user, Integer.parseInt(fieldid), fieldhtmltype, type, fieldValue, 0);
		}
		
		// 
		if("name".equals(fieldname)){%>		
		<wea:item>
			<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item>
			<%=fieldValue%>
			<input type="hidden" name="meetingid" value="<%=meetingid %>" />
		</wea:item>	
	<%	}if("xiaoshi".equals(fieldname)){
		int timeInterval = (int)(Double.valueOf(fieldValue)*3600);
		//小时：h=time/3600（整除）
		int h = timeInterval /3600;
		//分钟：m=(time-h*3600)/60 （整除）
		int m = (timeInterval-h*3600)/60;
		//秒：s=(time-h*3600) mod 60 （取余）
		int s = (timeInterval-h*3600) % 60;
		String xiaoshi_str = h+"小时"+m+"分"+s+"秒";
	%>		
		<wea:item>
			<%=SystemEnv.getHtmlLabelName(fieldlabel,user.getLanguage())%>
		</wea:item> 
		<wea:item>
			<%=xiaoshi_str%>
		</wea:item>	
	<%	}
	}%>
<%}
}
%>	
		<wea:item>
			剩余时长
		</wea:item> 
		<wea:item>
			 <%=sy_hour_str %>
		</wea:item>	
		
		<wea:item>
			可延时时长
		</wea:item> 
		<wea:item>
			<%=yc_hour_str %>
			<input type="hidden" name="yctimes" value="<%=yc_hour %>" />
		</wea:item>
		
		<%if(sy_hour>0 && sy_hour <= 0.25){ %>
		<wea:item>
			延长结束时间
		</wea:item> 
		<wea:item>
			<input type='hidden' id='delaydate' name='delaydate' value='<%=currentDate %>' _minDate='<%=currentDate %>'  _maxDate='<%=begindatetmp %>'  class='wuiDate' _callback='' _isrequired="yes"/>
			<button class=Clock type='button' onclick ="onshowMeetingTime(delaytimespan,delaytime,'0')"></button>
			<span id ='delaytimespan' name='delaytimespan'><%=currentTime.substring(0,5) %></span>
			<input class=inputstyle type = hidden id='delaytime' name ='delaytime' value ='<%=currentTime.substring(0,5) %>' >
		</wea:item>	
		<%}else{ %>
		<wea:item>
			是否可延时
		</wea:item> 
		<wea:item>
			不可延时
		</wea:item>	
		<%}%>
 </wea:group>
</wea:layout>
</FORM>
</div>

<script language=javascript>
var diag_vote;
function showDialog(url, title, w,h){
	if(window.top.Dialog){
		diag_vote = new window.top.Dialog();
	} else {
		diag_vote = new Dialog();
	}
	diag_vote.currentWindow = window;
	diag_vote.Width = w;
	diag_vote.Height = h;
	diag_vote.Modal = true;
	diag_vote.Title = title;
	diag_vote.URL = url;
	diag_vote.show();
}

function doEdit(){ 
	window.top.Dialog.confirm("确定延迟会议时长？",function(){
	   var delaydate = $('#delaydate').val();
	   var delaytime = $('#delaytime').val();
	   CheckMeeting('<%=begindatetmp%>','<%=begintimetmp%>',delaydate,delaytime)
	});
}

function CheckMeeting(nextdate,nexttime,delaydate,delaytime){
	$.post("/meeting/delay/AjaxDelayOperation.jsp?method=chkRoomDate",
	       {enddate:'<%=enddate%>',endtime:'<%=endtime%>',nextdate:nextdate,nexttime:nexttime,delaydate:delaydate,delaytime:delaytime,meetingid:'<%=meetingid%>',addressselect:'<%=addressselect%>',address:'<%=address%>',customizeaddress:'<%=customizeaddress%>'}
	       ,function(datas){
		if(datas != 0){
			if(datas == 2){
				Dialog.alert("调整日期时间不能小于该会议结束日期时间，请选择其他时间段。");		
			}else{
			    Dialog.alert("会议室已经被占用无法延迟，请选择其他时间段。");	
			}
		} else {
			document.weaver.submit();
		}
	});
}

function opendoc(showid,versionid,docImagefileid)
{
	openFullWindowHaveBar("/docs/docs/DocDspExt.jsp?id="+showid+"&imagefileId="+docImagefileid+"&meetingid=<%=meetingid%>&isFromAccessory=true");
}
function opendoc1(showid)
{
	openFullWindowHaveBar("/docs/docs/DocDsp.jsp?id="+showid+"&isOpenFirstAss=1&meetingid=<%=meetingid%>");
}
function downloads(files)
{
	document.location.href="/weaver/weaver.file.FileDownload?fileid="+files+"&download=1&meetingid=<%=meetingid%>";
}
	
function forbiddenPage(){  
    window.parent.forbiddenPage();
}  

function releasePage(){  
    window.parent.releasePage();
}

function btn_cancle(){
	parent.closeDialog();
}

jQuery(document).ready(function(){
	window.parent.hideMember();
	window.parent.hideDicision();
	resizeDialog(document);
});
</script>
</div>
<div id="zDialog_div_bottom" class="zDialog_div_bottom">
	<wea:layout type="2col">
		<wea:group context="">
			<wea:item type="toolbar">
				<input type="button"
						value="<%=SystemEnv.getHtmlLabelName(309, user.getLanguage())%>"
						id="zd_btn_cancle" class="zd_btn_cancle" onclick="btn_cancle()">
				</wea:item>
		</wea:group>
	</wea:layout>
</div>
</body>
</html>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<SCRIPT language="javascript" src="/js/selectDateTime_wev8.js"></script>
<script language=javascript>
function btn_cancle(){
		window.parent.closeDialog();
	}
</script>
