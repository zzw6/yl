<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/page/maint/common/initNoCache.jsp"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="weaver.general.BaseBean"%>
<%@ page import="weaver.file.FileUpload"%>
<%@ page import="weaver.conn.RecordSet"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="weaver.general.TimeUtil"%>
<%@ page import="weaver.meeting.MeetingUtilForYl"%>
<%@ page import="weaver.hrm.resource.ResourceComInfo"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rc" class="weaver.hrm.resource.ResourceComInfo" scope="page" />
<jsp:useBean id="MeetingRoomComInfo" class="weaver.meeting.Maint.MeetingRoomComInfo" scope="page"/>
<%
	response.setHeader("Cache-Control", "no-store");
	response.setHeader("Pragrma", "no-cache");
	response.setDateHeader("Expires", 0);
	String userid = user.getUID()+"";
	FileUpload fu = new FileUpload(request);
	String clienttype = Util.null2String(fu.getParameter("clienttype"));
	String clientlevel = Util.null2String(fu.getParameter("clientlevel"));
	String module = Util.null2String(fu.getParameter("module"));
	String scope = Util.null2String(fu.getParameter("scope"));
	String param = "clienttype=" + clienttype + "&clientlevel="+ clientlevel + "&module=" + module + "&scope=" + scope;

	
	String selectDay = "",addressid = "",roomName = "",endday = "",selectTime = "",endTime = "",customizeAddress = "";
	String typename = "",meetingtype = "",isagenda = "0",meetingname = "",caller = "",recorder = "";
	String hrmids = "",othermembers = "",ccmeetingnotice = "",ccmeetingminutes = "",desc_n = "",cost = "0.0";
	int hrmNums = 0,otherNums = 0,roomType = 1,isAppraise = 2;
	String roomTypeName = "内部会议室";
	int totalmember = 0;
	String id = Util.null2String(fu.getParameter("id"));//会议ID
	boolean ifExist = false;
	if(!"".equals(id)){
		rs.executeSql("select t1.*,t2.name as roomname,t3.name as typename,t3.isagenda from Meeting t1"+
				" left join MeetingRoom t2 on t1.address = t2.id"+
				" left join Meeting_Type t3 on t3.id = t1.meetingtype"+
				" where t1.id = "+id+" and t1.meetingstatus = 0");
		if(rs.next()){
			ifExist = true;
			roomType = Util.getIntValue(rs.getString("roomType"));
			if(roomType==2){
				roomTypeName = "其他会议室";
			}
			addressid = Util.null2String(rs.getString("address"));
			roomName = Util.null2String(rs.getString("roomname"));//会议室名称
			customizeAddress = Util.null2String(rs.getString("customizeAddress"));//自定义会议室地点
			selectDay = Util.null2String(rs.getString("begindate"));
			selectTime = Util.null2String(rs.getString("begintime"));
			endday = Util.null2String(rs.getString("enddate"));
			endTime = Util.null2String(rs.getString("endtime"));
			typename = Util.null2String(rs.getString("typename"));
			meetingtype = Util.null2String(rs.getString("meetingtype"));
			isagenda = Util.null2String(rs.getString("isagenda"));
			meetingname = Util.null2String(rs.getString("name"));//名称
			caller = Util.null2String(rs.getString("caller"));//主持人(召集人)id
			recorder = Util.null2String(rs.getString("recorder"));//会议记录人id
			hrmids = Util.null2String(rs.getString("hrmmembers"));//参会人员
			hrmNums = hrmids.split(",").length;
			othermembers = Util.null2String(rs.getString("othermembers"));//外来人员
			otherNums = othermembers.split(",").length;
			ccmeetingnotice = Util.null2String(rs.getString("ccmeetingnotice"));//会议通知抄送人
			ccmeetingminutes = Util.null2String(rs.getString("ccmeetingminutes"));//会议纪要抄送人
			desc_n = Util.toHtmltextarea(rs.getString("desc_n"));//会议要求
			totalmember = Util.getIntValue(rs.getString("totalmember"),0);
			cost = Util.null2String(rs.getString("cost"));//会议成本
			isAppraise = Util.getIntValue(rs.getString("isAppraise"),2);
		}
	}
	if(!ifExist){
		id = "";
		addressid = Util.null2String(fu.getParameter("addressid"));
		roomName = "<font color='#999'>请选择会议地点</font>";
		if(!"".equals(addressid)){
			roomName = MeetingRoomComInfo.getMeetingRoomInfoname(addressid);
		}
		selectDay = Util.null2String(fu.getParameter("selectDay"));//日历界面点击日期创建会议
	}
	String a = Util.null2String(fu.getParameter("a"));
	String b = Util.null2String(fu.getParameter("b"));
	String c = Util.null2String(fu.getParameter("c"));
	String d = Util.null2String(fu.getParameter("d"));
	if(!"".equals(a)){
		selectDay = a;
	}
	if(!"".equals(b)){
		selectTime = b;
	}
	if(!"".equals(c)){
		endday = c;
	}
	if(!"".equals(d)){
		endTime = d;
	}
	String currentDate = TimeUtil.getCurrentDateString();
	if(selectDay.equals("")||TimeUtil.dateInterval(selectDay, currentDate)>0){
		selectDay = currentDate;
	}
	if(endday.equals("")||TimeUtil.dateInterval(endday, currentDate)>0){
		endday = selectDay;
	}
	if(selectTime.equals("")){
		selectTime = "09:00";
	}
	if(endTime.equals("")){
		endTime = "22:00";
	}
	String fromdatetime = selectDay+" "+selectTime+":00";
	String todatetime = endday+" "+endTime+":00";
	long timeInterval = TimeUtil.timeInterval(fromdatetime, todatetime);
	java.text.DecimalFormat df = new java.text.DecimalFormat("#.##");
	double hour = Double.parseDouble(df.format((double)timeInterval/60/60));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta http-equiv="Cache-Control" content="no-cache,must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<meta name="viewport" content="width=device-width,minimum-scale=1.0, maximum-scale=1.0" />
	<title>新建会议</title>
	<script type='text/javascript' src='/mobile/plugin/5/js/jquery.js'></script>
	<script type='text/javascript' src='/mobile/plugin/5/js/jquery.form.js'></script>
	<script type='text/javascript' src='/mobile/plugin/5/js/meeting.js?v=20180611'></script>
	<script src='/mobile/plugin/task/js/fastclick.min.js'></script>
	<script src="/mobile/plugin/5/js/jquery-weui.js"></script>
	<link rel="stylesheet" href="/mobile/plugin/5/css/weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/jquery-weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/icon.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/meeting.css?v=2017121806" />
	<!--日期时间控件-->
	<link rel="stylesheet" href="/mobile/plugin/5/css/mobiscroll.javascript.min.css" />
	<script type="text/javascript" src="/mobile/plugin/5/js/mobiscroll.javascript.min.js"></script>
</head>
<body ontouchstart id="body">
<div id="container">
	<div class="mt-tabbar">
		<div class="mt-tab mt-tab-current mt-tab-left" tab="mt-add-content">会议信息</div>
		<div class="mt-tab mt-tab-right" tab="mt-add-topic" id="mt-add-topic-btn">会议议程</div>
	</div>
	<form id="meetingForm" name="meetingForm" action="/mobile/plugin/5/saveMeeting.jsp" method="post" onsubmit="return false;">
	<input type="hidden" name="meetingid" value="<%=id%>"/>
	<div class="mt-detail-content" id="mt-add-content">
		<div class="weui-cell">
			<div class="weui-cell__hd mt-add-title">
				<div class="mt-bgimg" style="height:auto;"><i class="icon icon-81"></i></div>
			</div>
			<div class="weui-cell__bd">基本信息</div>
		</div>
		<div class="weui-cell weui-cell_vcode">
			<div class="weui-cell__hd">会议类型<font color="red">*</font></div>
			<div class="weui-cell__bd">
				<p id="meetingtypeSpan"></p>
				<input type="hidden" isagenda="" id="meetingtype" name="meetingtype" value=""/>
			</div>
			<div class="weui-cell__ft">
				<button class="weui-vcode-btn" onclick="showMtType();">
					<i class="weui-icon-search"></i>
				</button>
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">会议名称<font color="red">*</font></div>
			<div class="weui-cell__bd">
				<input class="weui-input" type="text" placeholder="请输入会议名称" id="name" name="name" value="<%=meetingname%>"/>
			</div>
		</div>
		<div class="weui-cell weui-cell_vcode">
			<div class="weui-cell__hd">主持人<font color="red">*</font></div>
			<div class="weui-cell__bd">
				<p id="callerSpan" onclick=""><%=MeetingUtilForYl.getUserNames(caller,rc) %></p>
				<input type="hidden" id="caller" name="caller" value="<%=caller%>"/>
			</div>
			<div class="weui-cell__ft">
				<button class="weui-vcode-btn" onclick="selectUser('caller','callerSpan',0);">
					<i class="weui-icon-search"></i>
				</button>
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">创建人</div>
			<div class="weui-cell__bd">
				<p id="callerSpan" onclick=""><%=MeetingUtilForYl.getUserNames(userid,rc) %></p>
			</div>
		</div>
		<div class="weui-cell weui-cell_vcode">
			<div class="weui-cell__hd">记录人</div>
			<div class="weui-cell__bd">
				<p id="recorderSpan" onclick=""><%=MeetingUtilForYl.getUserNames(recorder,rc) %></p>
				<input type="hidden" id="recorder" name="recorder" value="<%=recorder%>"/>
			</div>
			<div class="weui-cell__ft">
				<button class="weui-vcode-btn" onclick="selectUser('recorder','recorderSpan',0);">
					<i class="weui-icon-search"></i>
				</button>
			</div>
		</div>
		<div class="weui-cell weui-cell_vcode">
			<div class="weui-cell__hd">参会人员<font color="red">*</font></div>
			<div class="weui-cell__bd">
				<p id="hrmmembersSpan" onclick=""><%=MeetingUtilForYl.getUserNames(hrmids,rc) %></p>
				<input type="hidden" id="hrmmembers" name="hrmmembers" value="<%=hrmids%>"/>
			</div>
			<div class="weui-cell__ft">
				<button class="weui-vcode-btn" onclick="selectUser('hrmmembers','hrmmembersSpan',1);">
					<i class="weui-icon-search"></i>
				</button>
			</div>
		</div>
		<div class="weui-cell weui-cell_vcode">
			<div class="weui-cell__hd">外来人员</div>
			<div class="weui-cell__bd">
				<%
					String othermembersSpan = "";
					if(!"".equals(othermembers)){
						rs.executeSql("select * from uf_meeting_out_hum a where a.id in ("+othermembers+")");
						while(rs.next()){
							String name = Util.null2String(rs.getString("name"));
							othermembersSpan +=","+name;
						}
						if(!"".equals(othermembersSpan)){
							othermembersSpan = othermembersSpan.substring(1);
						}
					}
				%>
				<p id="othermembersSpan"><%=othermembersSpan %></p>
				<input type="hidden" id="othermembers" name="othermembers" value="<%=othermembers%>"/>
			</div>
			<div class="weui-cell__ft">
				<button class="weui-vcode-btn" onclick="showOutUser('<%=othermembers%>');">
					<i class="weui-icon-search"></i>
				</button>
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">应到人数</div>
			<div class="weui-cell__bd">
				<input class="weui-input" readonly type="number" min="0" id="totalmember" name="totalmember" value="<%=totalmember%>"/>
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">会议要求</div>
			<div class="weui-cell__bd">
				<textarea class="weui-textarea" placeholder="请输入会议要求" rows="3" id="desc_n" name="desc_n" ><%=desc_n %></textarea>
			</div>
		</div>
		<div class="line-height"></div>
		<div class="weui-cell weui-cell_access">
			<div class="weui-cell__hd mt-add-title">
				<div class="mt-bgimg" style="height:auto;"><i class="icon icon-81"></i></div>
			</div>
			<div class="weui-cell__bd">会议时间</div>
		</div>
		<div class="weui-cell weui-cell_access">
			<div class="weui-cell__hd">开始日期</div>
			<div class="weui-cell__bd">
				<input class="weui-input" value="<%=selectDay %>" min="<%=currentDate %>" type="date" name="begindate" 
					id="begindate" placeholder="选择开始日期" onchange="checkTime(this,1,1)"/>
			</div>
			<div class="weui-cell__ft"></div>
		</div>
		<div class="weui-cell weui-cell_access">
			<div class="weui-cell__hd">开始时间</div>
			<div class="weui-cell__bd">
				<input class="weui-input scroller_date" value="<%=selectTime %>" type="text" name="begintime" 
					id="begintime" placeholder="选择开始时间"  onchange="checkTime(this,2,1)"/>
			</div>
			<div class="weui-cell__ft"></div>
		</div>
		<div class="weui-cell weui-cell_access">
			<div class="weui-cell__hd">结束日期</div>
			<div class="weui-cell__bd">
				<input class="weui-input" type="date" min="<%=currentDate %>" value="<%=endday %>" name="enddate" 
					id="enddate" placeholder="选择结束日期"  onchange="checkTime(this,3,1)"/>
			</div>
			<div class="weui-cell__ft"></div>
		</div>
		<div class="weui-cell weui-cell_access">
			<div class="weui-cell__hd">结束时间</div>
			<div class="weui-cell__bd">
				<input class="weui-input scroller_date" value="<%=endTime %>" type="text" name="endtime" 
					id="endtime" placeholder="选择结束时间"  onchange="checkTime(this,4,1)"/>
			</div>
			<div class="weui-cell__ft"></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">会议时长</div>
			<div class="weui-cell__bd">
				<p id="xiaoshiSpan"><%=hour %></p>
				<input class="weui-input" type="hidden" id="xiaoshi" name="xiaoshi" />
			</div>
		</div>
		<div class="line-height"></div>
		<div class="weui-cell">
			<div class="weui-cell__hd mt-add-title">
				<div class="mt-bgimg" style="height:auto;"><i class="icon icon-81"></i></div>
			</div>
			<div class="weui-cell__bd">会议地点</div>
		</div>
		<div class="weui-cell weui-cell_select">
			<div class="weui-cell__hd">地点类型</div>
			<div class="weui-cell__bd">
				<input class="weui-input" data-values="<%=roomType %>" value="<%=roomTypeName %>" 
					type="text" id="addressselect" name="addressselect_input" />
			</div>
		</div>
		<div class="weui-cell weui-cell_vcode mt-add-address" id="address-1" <%if(roomType==2){ %>style="display:none;"<%} %>>
			<div class="weui-cell__hd">会议地点<font color="red">*</font></div>
			<div class="weui-cell__bd">
				<p id="addressSpan" onclick=""><%=roomName %></p>
				<input type="hidden" id="address" name="address" value="<%=addressid%>"/>
			</div>
			<div class="weui-cell__ft">
				<button style="font-size: 17px"  class="weui-vcode-btn" onclick="clearAddress(1,1);">
					<i class="weui-icon-cancel"></i>
				</button>
				<button class="weui-vcode-btn" onclick="showAddress(1,1);">
					<i class="weui-icon-search"></i>
				</button>

			</div>
		</div>
		<div class="weui-cell mt-add-address" <%if(roomType==1){ %>style="display:none;"<%} %> id="address-2">
			<div class="weui-cell__hd">自定义<font color="red">*</font></div>
			<div class="weui-cell__bd">
				<input class="weui-input" value="<%=customizeAddress %>" type="text" 
					placeholder="请输入自定义会议地点" id="customizeAddress" name="customizeAddress" />
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd"></div>
			<div class="weui-cell__bd">
				<div class="mt-add-btn" id="autoMatchBtn" onclick="showAddress(2,1)" 
					<%if(roomType==2){ %>style="display:none;"<%} %>>智能匹配</div>
				<div class="mt-add-btn" onclick="getQRCode()">获取二维码</div>
			</div>
		</div>
		<div class="line-height"></div>
		<div class="weui-cell">
			<div class="weui-cell__hd mt-add-title">
				<div class="mt-bgimg" style="height:auto;"><i class="icon icon-81"></i></div>
			</div>
			<div class="weui-cell__bd">其他信息</div>
		</div>
		<input type="hidden" value="1" name="remindTypeNew_input" id="remindTypeNew"/>
		<!-- 
		<div class="weui-cell weui-cell_select">
			<div class="weui-cell__hd">提醒方式</div>
			<div class="weui-cell__bd">
				<input class="weui-input" data-values="2" value="短信提醒" type="text" id="remindTypeNew" name="remindTypeNew_input"/>
			</div>
		</div>
		 -->
		<div class="weui-cell">
			<div class="weui-cell__hd">会议成本</div>
			<div class="weui-cell__bd">
				<p id="costSpan"><%=cost %></p>
				<input class="weui-input" type="hidden" id="cost" name="cost" value="<%=cost %>"/>
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">会议评估</div>
			<div class="weui-cell__bd">
				<select name="isAppraise" id="isAppraise" class="weui-select" style="padding-left:0;height:auto;line-height:26px;">
					<option value="2" <%if(isAppraise==2){ %>selected<%} %>>否</option>
					<option value="3" <%if(isAppraise==3){ %>selected<%} %>>是</option>
				</select>
			</div>
		</div>
		<div class="weui-cell weui-cell_vcode">
			<div class="weui-cell__hd">会议通知抄送人</div>
			<div class="weui-cell__bd">
				<p id="ccmeetingnoticeSpan" onclick=""><%=MeetingUtilForYl.getUserNames(ccmeetingnotice,rc) %></p>
				<input type="hidden" id="ccmeetingnotice" name="ccmeetingnotice" value="<%=ccmeetingnotice%>"/>
			</div>
			<div class="weui-cell__ft">
				<button class="weui-vcode-btn" onclick="selectUser('ccmeetingnotice','ccmeetingnoticeSpan',1);">
					<i class="weui-icon-search"></i>
				</button>
			</div>
		</div>
		<div class="weui-cell weui-cell_vcode">
			<div class="weui-cell__hd">会议纪要抄送人</div>
			<div class="weui-cell__bd">
				<p id="ccmeetingminutesSpan" onclick=""><%=MeetingUtilForYl.getUserNames(ccmeetingminutes,rc) %></p>
				<input type="hidden" id="ccmeetingminutes" name="ccmeetingminutes" value="<%=ccmeetingminutes%>"/>
			</div>
			<div class="weui-cell__ft">
				<button class="weui-vcode-btn" onclick="selectUser('ccmeetingminutes','ccmeetingminutesSpan',1);">
					<i class="weui-icon-search"></i>
				</button>
			</div>
		</div>
		<div class="line-height"></div>
		<div class="line-height"></div>
		<div class="line-height"></div>
	</div>
	<div class="mt-detail-content" id="mt-add-topic" style="display:none;">
		<div id="mt-topicList-div" class="mt-add-topic">
			<div class="weui-cell" style="height:30px;" onclick="showTopic(-1,1)">
				<div class="weui-cell__bd" style="color:#999;">议程列表</div>
				<div class="weui-cell__ft"><i class="icon icon-34 mt-topic-add"></i></div>
			</div>
		</div>
		<div class="line-height"></div>
		<div class="line-height"></div>
		<div id="mt-topicAttachList-div" style="display:none;">
			<div class="weui-cell">
				<div class="weui-cell__bd" style="color:#999;">附件列表</div>
				<div class="weui-cell__ft"></div>
			</div>
		</div>
	</div>
	</form>
	<div id="mt-add-div">
		<div class="mt-reback-zw"></div>
		<div class="mt-add-save" onclick="submitMT(1)"><i class="icon icon-67 mt-submit-btn"></i>保存</div>
		<div class="mt-add-submit" onclick="submitMT(2)"><i class="icon icon-66 mt-submit-btn"></i>提交</div>
	</div>
</div>
<!-- 会议类型弹出层 -->
<div id="mttypepopup" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-tabbar">
			<div class="mt-tabbar"><div class="mt-popup-title">会议类型</div></div>
		</div>
		<div class="mt-detail-content" id="mt-type-content">
			<div style="background:#f0f0f0;">
				<div class="weui-loadmore">
					<i class="weui-loading"></i><span class="weui-loadmore__tips" style="background:#f0f0f0;">正在加载</span>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 外部人员列表弹出层 -->
<div id="hrmpopupForOut" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-tabbar"><div class="mt-popup-title">外部人员</div></div>
		<div class="mt-detail-content" id="mt-outuser-content">
			<div style="background:#f0f0f0;">
				<div class="weui-loadmore">
					<i class="weui-loading"></i><span class="weui-loadmore__tips" style="background:#f0f0f0;">正在加载</span>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 会议室列表弹出层 -->
<div id="addresspopup" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-tabbar"><div class="mt-popup-title">选择会议室</div></div>
		<div class="mt-detail-content" id="mt-address-content-1">
			<div style="background:#f0f0f0;">
				<div class="weui-loadmore">
					<i class="weui-loading"></i><span class="weui-loadmore__tips" style="background:#f0f0f0;">正在加载</span>
				</div>
			</div>
		</div>
		<div class="mt-detail-content" id="mt-address-content-2" style="display:none;">
			
		</div>
	</div>
</div>
<!-- 二维码弹出层 -->
<div id="qrcodepopup" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-tabbar"><div class="mt-popup-title">会议室二维码</div></div>
		<div class="mt-detail-content" id="mt-qrcode-content"></div>
		<div style="margin-top:10px;text-align:center;" id="mt-qrcode-address"></div>
	</div>
</div>
<!-- 添加议程弹出层 -->
<div id="topicpopup" class="weui-popup__container" style="top:60px;">
	<div class="weui-popup__overlay" style="top:60px;"></div>
	<div class="weui-popup__modal">
		<div class="mt-detail-content" id="mt-topic-add-content">
			<input type="hidden" id="tc_index" value="-1"/>
			<div class="weui-cells">
				<div class="weui-cell">
					<div class="weui-cell__hd">序号</div>
					<div class="weui-cell__bd">
						<input class="weui-input" type="text" placeholder="请输入序号" id="tc_xuhao"/>
					</div>
				</div>
				<div class="weui-cell">
					<div class="weui-cell__hd">议题<font color="red">*</font></div>
					<div class="weui-cell__bd">
						<input class="weui-input" type="text" placeholder="请输入议题" id="tc_subject"/>
					</div>
				</div>
				<div class="weui-cell weui-cell_vcode">
					<div class="weui-cell__hd">决策人</div>
					<div class="weui-cell__bd">
						<p id="tc_hrmspans"></p>
						<input type="hidden" id="tc_hrmids"/>
					</div>
					<div class="weui-cell__ft">
						<button class="weui-vcode-btn" onclick="selectUser('tc_hrmids','tc_hrmspans',0);">
							<i class="weui-icon-search"></i>
						</button>
					</div>
				</div>
				<div class="weui-cell">
					<div class="weui-cell__hd">决策点</div>
					<div class="weui-cell__bd">
						<textarea class="weui-textarea" placeholder="请输入决策点" rows="3" id="tc_jcd"></textarea>
					</div>
				</div>
				<div class="weui-cell weui-cell_access">
					<div class="weui-cell__hd">开始日期</div>
					<div class="weui-cell__bd">
						<input class="weui-input" value="<%=selectDay %>" type="date" 
							id="tc_startdate" placeholder="选择开始日期" onchange="checkTime(this,1,2)"/>
					</div>
					<div class="weui-cell__ft"></div>
				</div>
				<div class="weui-cell weui-cell_access">
					<div class="weui-cell__hd">结束日期</div>
					<div class="weui-cell__bd">
						<input class="weui-input" type="date" value="<%=endday %>" 
							id="tc_enddate" placeholder="选择结束日期"  onchange="checkTime(this,3,2)"/>
					</div>
					<div class="weui-cell__ft"></div>
				</div>
				<div class="weui-cell weui-cell_access">
					<div class="weui-cell__hd">开始时间</div>
					<div class="weui-cell__bd">
						<input class="weui-input scroller_date" value="<%=selectTime %>" type="text" 
							id="tc_starttime" placeholder="选择开始时间"  onchange="checkTime(this,2,2)"/>
					</div>
					<div class="weui-cell__ft"></div>
				</div>
				<div class="weui-cell weui-cell_access">
					<div class="weui-cell__hd">结束时间</div>
					<div class="weui-cell__bd">
						<input class="weui-input scroller_date" value="<%=endTime %>" type="text" 
							id="tc_endtime" placeholder="选择结束时间"  onchange="checkTime(this,4,2)"/>
					</div>
					<div class="weui-cell__ft"></div>
				</div>
			</div>
			<div class="btn-wrapper">
				<a href="javascript:addTopic(1)" class="weui-btn weui-btn_primary" style="color:#fff;">确定</a>
			</div>
		</div>	
	</div>
</div>
<!-- 会议室详情-->
<% 
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy年MM月");
	String month = sdf.format(System.currentTimeMillis());
	Calendar calendar = Calendar.getInstance();  
	int currentDay = calendar.get(Calendar.DAY_OF_MONTH);
    int dayNum = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
%>
<div id="addressDetailPopup" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-detail-content" id="mt-ad-div">
			<div id="mt-ad-detail-div"></div>
			<div class="line-height"></div>
			<div class="weui-cell">
				<div class="weui-cell__bd" style="color:#999;">会议室使用情况</div>
				<div class="weui-cell__ft"></div>
			</div>
			<div class="mt-ad-header">
				<div class="mt-ad-month">
					<input class="weui-input mt-month-input" style="text-align:center;" id="currentMonth" type="text" value="<%=month %>"/>
				</div>
				<div class="mt-ad-day">
					<%
						for(int i=1;i<=dayNum;i++){  
							String cls = "";
							if(currentDay==i){
								cls = "item-current";
							}
							String style = "";
							if(i==31&&dayNum<31){
								style = "display:none;";
							}
					%>
						<div class="mt-ad-day-item <%=cls%>" id="mt-ad-day-<%=i%>" day="<%=i%>" style="<%=style%>"><%=i%></div>
					<%} %>
				</div>
			</div>
			<div id="mt-ad-content">
				<div class="weui-pull-to-refresh__layer">
					<div class='weui-pull-to-refresh__arrow'></div>
					<div class='weui-pull-to-refresh__preloader'></div>
					<div class="down">下拉刷新</div>
					<div class="up">释放刷新</div>
					<div class="refresh">正在刷新</div>
				</div>
				<div id="mt-cells" class="weui-cells"  style="margin-top:0;">
		          	
		        </div>
			</div>
		</div>
	</div>
</div>
<script type="text/javascript">
	var param = "<%=param%>";
	var userid = "<%=userid%>";
	var selectDay = "<%=selectDay%>";
	var currentDay = parseInt("<%=currentDay%>");
	var meetingid = "<%=id%>";
	hrmNums = parseInt("<%=hrmNums%>");
	otherNums = parseInt("<%=otherNums%>");
	var mobiscrollInstance;
	$(document).ready(function(){
		FastClick.attach(document.body);
		mobiscrollInstance = mobiscroll.time('.scroller_date',{
			theme:"android-holo-light",
			timeFormat:"HH:ii",
			buttons:['cancel','set'],
			lang:"zh",
			/**
			onBeforeShow: function (event, inst) {
				try{
					var a = $("#begindate").val();
					var b = $("#begintime").val();
					var c = $("#enddate").val();
					var d = $("#endtime").val();
					var arr1 = a.split("-");
				    var time1 = b.split(":");
				    var arr2 = c.split("-");
				    var time2 = d.split(":");
				    var minTime = new Date(arr1[0], arr1[1]-1, arr1[2],time1[0],time1[1]);
				    var maxTime = new Date(arr2[0], arr2[1]-1, arr2[2],time2[0],time2[1]);
				    inst.option({
				        min: minTime,
				        max: maxTime
				    });
				}catch(e){
					alert(e);
				}
			}
			**/
		});
		mobiscroll.date('.mt-month-input',{
			theme:"android-holo-light",
			dateFormat:"yy年mm月",
			monthNamesShort:['01','02','03','04','05','06','07','08','09','10','11','12'],
			lang:"zh",
			buttons:['cancel','set'],
			onSet: function (event, inst){
				var month = event.valueText.replace("年","-").replace("月","");
				var days = getDaysInMonth(month.split("-")[0],month.split("-")[1]);
				$(".mt-ad-day-item").each(function(){
					var day = parseInt($(this).attr("day"));
					if(day>days){
						$(this).hide();
					}else{
						$(this).show();
					}
				});
				if(currentDay>days){
					$(".mt-ad-day-item").removeClass("item-current");
					$("#mt-ad-day-"+days).addClass("item-current");
					currentDay = days;
				}
				loadAddressDetail();
		    }
		});
		//会议信息 会议议程tab切换
		$("#container .mt-tab").click(function(){
			$("#container .mt-tab").removeClass("mt-tab-current");
			$(this).addClass("mt-tab-current");
			var tab = $(this).attr("tab");
			$("#container .mt-detail-content").hide();
			$("#"+tab).show();
			popOpen = false;
			$.closePopup();
		});
		//会议地点选择
		$("#addressselect").select({
			  title: "选择地点类型",
			  items: [{title:"内部会议室",value:"1"},{title:"其他会议室",value:"2"}],
			  onChange:function(data){
				  var type = data.values[0];
				  $(".mt-add-address").hide();
				  $("#address-"+type).show();
				  if(type==1){
					  $("#autoMatchBtn").show();
				  }else{
					  $("#autoMatchBtn").hide();
				  }
			  }
		});
		//提醒方式选择
		//$("#remindTypeNew").select({
		//	  multi:true,
		//	  title: "选择提醒方式",
		//	  items: [{title:"短信提醒",value:"2"},{title:"Emessage提醒",value:"1"}]
		//});
		loadMtType('<%=meetingtype%>');//加载会议类型
		if(meetingid!=""){
			loadTopic();//加载议程
		}
	});
	function getRequestTitle(){
		return "新建会议";
	}
	function clearAddress() {
		$("#address").val('');
		$("#addressSpan").html('');
    }
	function doLeftButton(){
		if(outUserOpen){
			$.closePopup();
			$("#hrmpopupForOut").popup();
			outUserOpen = false;
		}else if(addressOpen){
			$.closePopup();
			$("#addresspopup").popup();
			addressOpen = false;
		}else if(popOpen){
			$.closePopup();
			popOpen = false;
		}else{
			window.location = "/mobile/plugin/5/meeting.jsp?"+param;
		}
		return "1";
	}
</script>	
</body>