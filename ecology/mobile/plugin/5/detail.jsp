<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/page/maint/common/initNoCache.jsp"%>
<%@ page import="weaver.general.BaseBean"%>
<%@ page import="weaver.general.TimeUtil"%>
<%@ page import="weaver.file.FileUpload"%>
<%@ page import="weaver.conn.RecordSet"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="weaver.hrm.resource.ResourceComInfo"%>
<%@ page import="weaver.meeting.MeetingUtilForYl"%>
<%@ page import="weaver.meeting.MeetingShareUtil"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page"/>
<jsp:useBean id="rs2" class="weaver.conn.RecordSet" scope="page"/>
<jsp:useBean id="rc" class="weaver.hrm.resource.ResourceComInfo" scope="page" />
<jsp:useBean id="dc" class="weaver.hrm.company.DepartmentComInfo" scope="page" />
<jsp:useBean id="docImageManager" class="weaver.docs.docs.DocImageManager" scope="page" />
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
	
	String id = Util.null2String(fu.getParameter("id"));//会议ID
	String operation = Util.null2String(fu.getParameter("operation"));//会议ID
	//on t1.address = t2.id
	String sql="select t1.*,t2.name as roomname from Meeting t1,MeetingRoom t2  where ','||t1.address||','  like '%,'||to_char(t2.id)||',%' and t1.id = "+id;
	RecordSet rs1=new RecordSet();
	rs1.executeSql(sql);
	String roomname ="";
	while (rs1.next()){
		roomname+=","+Util.null2String(rs1.getString("roomname"));
	}

	if(!"".equals(roomname)){
	    roomname=roomname.substring(1);
	}

			// Util.null2String(rs.getString("roomname"));//会议室名称

	rs.executeSql("select t1.*,t2.name as roomname from Meeting t1,MeetingRoom t2  where ','||t1.address||','  like '%,'||to_char(t2.id)||',%' and t1.id = "+id);
	if(rs.next()){
		String hrmIds = ","+Util.null2String(rs.getString("caller"))
				+","+Util.null2String(rs.getString("contacter"))
				+","+Util.null2String(rs.getString("recorder"))
				+","+Util.null2String(rs.getString("hrmmembers"))
				+","+Util.null2String(rs.getString("ccmeetingnotice"))
				+","+Util.null2String(rs.getString("ccmeetingminutes"))+","
				+","+Util.null2String(rs.getString("shareuser"))+",";
		if(hrmIds.indexOf(","+user.getUID()+",")>-1){
			String meetingname = Util.null2String(rs.getString("name"));//名称
			String caller = Util.null2String(rs.getString("caller"));//主持人(召集人)id
			String creater = Util.null2String(rs.getString("contacter"));//联系人id 伊利把联系人当做创建人
			//String creater = Util.null2String(rs.getString("creater"));//创建人id
			String recorder = Util.null2String(rs.getString("recorder"));//会议记录人id
			String customizeAddress = Util.null2String(rs.getString("customizeAddress"));//自定义会议室地点
			if("".equals(roomname)){
				roomname = customizeAddress;
			}
			String begindate = Util.null2String(rs.getString("begindate"));
			String begintime = Util.null2String(rs.getString("begintime"));
			String enddate = Util.null2String(rs.getString("enddate"));
			String endtime = Util.null2String(rs.getString("endtime"));
			String hrmids = Util.null2String(rs.getString("hrmmembers"));//参会人员
			String othermembers = Util.null2String(rs.getString("othermembers"));//外来人员
			String ccmeetingnotice = Util.null2String(rs.getString("ccmeetingnotice"));//会议通知抄送人
			String ccmeetingminutes = Util.null2String(rs.getString("ccmeetingminutes"));//会议纪要抄送人
			String desc_n = Util.spacetoHtml(rs.getString("desc_n"));//会议要求
			String cost = Util.null2String(rs.getString("cost"));//会议成本
			String accessorys = Util.null2String(rs.getString("accessorys"));//会议通知附件
			int requestid = rs.getInt("requestid");//流程ID
			String isdecision = Util.null2String(rs.getString("isdecision"));//会议决议
			int meetingstatus = Util.getIntValue(rs.getString("meetingstatus"),0);
			int isAppraise = Util.getIntValue(rs.getString("isAppraise"),2);//会议评估
			String address = Util.null2String(rs.getString("address"));//会议室ID
			int addressselect = Util.getIntValue(rs.getString("addressselect"),0);//0内部会议室 1其他会议室
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
			Date startDate = sdf.parse(begindate+" "+begintime);
			Date endDate2 = sdf.parse(enddate+" "+endtime);
			int meetingover = 0;//会议进行状态 0已结束 1进行中  2未开始
			if(meetingstatus==0){
				meetingover = 3;//草稿
			}else if(meetingstatus==1){
				meetingover = 4;//审批中
			}else{
				if(!"2".equals(isdecision)){//没有决议
					if(meetingstatus==4){//会议已结束
						meetingover = 0;
					}else if(startDate.getTime()>System.currentTimeMillis()){//未开始
						meetingover = 2;
					} else if(endDate2 != null&&System.currentTimeMillis()<= endDate2.getTime()){//进行中
						meetingover = 1;
					}
				}
			}
			boolean ifCreater = creater.equals(userid)?true:false;
			boolean ifCanCancel = false;//是否可取消会议
			boolean ifCanOver = false;//是否可结束会议
			if((caller.equals(userid)||creater.equals(userid))&&meetingover==2){//主持人创建人 可以取消未开始的会议
				ifCanCancel = true;
			}
			if((caller.equals(userid)||recorder.equals(userid)||creater.equals(userid))&&meetingover==1){//主持人记录人创建人 可以结束进行中的会议
				ifCanOver = true;
			}
			//标识会议已看
			rs2.executeSql("update meeting_view_status set status = '1' where meetingid = "+id+" and userid = "+userid);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta http-equiv="Cache-Control" content="no-cache,must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<meta name="viewport" content="width=device-width,minimum-scale=1.0, maximum-scale=1.0" />
	<title>会议详情</title>
	<script type='text/javascript' src='/mobile/plugin/5/js/jquery.js'></script>
	<script type='text/javascript' src='/mobile/plugin/5/js/meeting.js?v=2018020501'></script>
	<script src='/mobile/plugin/task/js/fastclick.min.js'></script>
	<script src="/mobile/plugin/5/js/jquery-weui.js"></script>
	<link rel="stylesheet" href="/mobile/plugin/5/css/weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/jquery-weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/icon.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/meeting.css?v=2018020501" />
</head>
<body ontouchstart id="body">
<div id="container">
	<div class="mt-tabbar">
		<div class="mt-tab mt-tab-current mt-tab-left" tab="mt-detail-content">会议信息</div>
		<div class="mt-tab mt-tab-right" tab="mt-detail-topic">会议议程</div>
	</div>
	<%if(ifCanCancel){ %>
		<div class="mt-operat-btn" id="cancelMt">取消会议</div>
	<%}else if(ifCanOver){ %>
		<div class="mt-operat-btn" id="overMt">结束会议</div>
	<%}else if(isdecision.equals("2")){ %>
		<div class="mt-operat-btn" id="deciMt">查看决议</div>
	<%} %>
	<div class="mt-detail-content" id="mt-detail-content">
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-67"></i></div>
			</div>
			<div class="weui-cell__bd" style="font-size:20px;color:#000;" id="mt-detail-mtname">
				<%=meetingname %>
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-50"></i></div>
			</div>
			<div class="weui-cell__bd">开始时间</div>
			<div class="weui-cell__ft"><%=begindate %>&nbsp;&nbsp;<%=begintime %></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-50"></i></div>
			</div>
			<div class="weui-cell__bd">结束时间</div>
			<div class="weui-cell__ft"><%=enddate %>&nbsp;&nbsp;<%=endtime %></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-84"></i></div>
			</div>
			<div class="weui-cell__bd">主持人</div>
			<div class="weui-cell__ft"><%=MeetingUtilForYl.getUserNames(caller,rc) %></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-84"></i></div>
			</div>
			<div class="weui-cell__bd">记录人</div>
			<div class="weui-cell__ft"><%=MeetingUtilForYl.getUserNames(recorder,rc) %></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-84"></i></div>
			</div>
			<div class="weui-cell__bd">创建人</div>
			<div class="weui-cell__ft"><%=MeetingUtilForYl.getUserNames(creater,rc) %></div>
		</div>
		<div class="weui-cell weui-cell_access" onclick="viewHrmid()">
			<div class="weui-cell__hd" style="position:absolute;top:5px;">
				<div class="mt-bgimg"><i class="icon icon-100"></i></div>
			</div>
			<div class="weui-cell__bd" style="margin-left:38px;">
				<div id="hrmCount">参会人员</div>
				<div class="mt-users-list">
				<% 
					char flag = 2;
					rs2.executeProc("Meeting_Member2_SelectByType",id+flag+"1");
					int j = 0;
					List<String[]> hrmUserList = new ArrayList<String[]>();
					boolean canReback = false;//是否可回执
					boolean ifReback = false;//是否已回执
					while(rs2.next()){
						String memberid = Util.null2String(rs2.getString("memberid"));
						String reotherusers = Util.null2String(rs2.getString("othermember"));
						int isattend = Util.getIntValue(rs2.getString("isattend"),0);
						String attendStatus = "";//回执状态 1已回执 2未回执
						if(isattend==0){
							attendStatus = "2";
						}else{
							attendStatus = "1";
						}
						String isattendName = "未回执";
						if(isattend==1){
							isattendName = "参加";
						}else if(isattend==2){
							isattendName = "不参加";
						}else if(isattend==3){
							isattendName = "参加";
						}else if(isattend==4){
							isattendName = "他人参加";
						}
						if(memberid.equals(userid)){
							canReback = true;
							if(isattend!=0){
								ifReback = true;
							}
						}
						String[] hrmUser = {memberid,isattend+"",isattendName,reotherusers,attendStatus};
						hrmUserList.add(hrmUser);
						if(j<4){
							j++;
				%>
				<div class="mt-users" onclick="viewHrmid()">
					<div class="mt-userimg2"><img src="<%=MeetingUtilForYl.getUserImg(memberid,rc) %>"/></div>
					<div class="mt-username"><%=rc.getLastname(memberid) %></div>
				</div>
				<%
					}} 
					int hrmCount = hrmUserList.size();
				%>
				</div>
			</div>
			<div class="weui-cell__ft"></div>
		</div>
		<div class="weui-cell weui-cell_access" onclick="viewHrmForOut()">
			<div class="weui-cell__hd" style="position:absolute;top:5px;">
				<div class="mt-bgimg"><i class="icon icon-100"></i></div>
			</div>
			<div class="weui-cell__bd" style="margin-left:38px;">
				<div id="otherCount">外部人员</div>
				<div class="mt-users-list">
				<% 
					List<String[]> outUserList = new ArrayList<String[]>();
					if(!"".equals(othermembers)){
						rs2.executeSql("select * from uf_meeting_out_hum a where a.id in ("+othermembers+")");
						int i = 0;
						while(rs2.next()){
							String outid = Util.null2String(rs2.getString("id"));
							String name = Util.null2String(rs2.getString("name"));
							String photo = Util.null2String(rs2.getString("photo"));
							photo = MeetingUtilForYl.getUserImgForOut(photo);
							String sex = Util.null2String(rs2.getString("sex"));
							if(sex.equals("0")){
								sex = "男";
							}else if(sex.equals("1")){
								sex = "女";
							}else {
								sex = "未知";
							}
							String company = Util.null2String(rs2.getString("company"));
							String duties = Util.null2String(rs2.getString("duties"));
							String mobilephone = Util.null2String(rs2.getString("mobilephone"));
							String[] outUser = {id,name,sex,photo,company,duties,mobilephone};
							outUserList.add(outUser);
							if(i<4){
								i++;
				%>
				<div class="mt-users" onclick="<%=getOpenUserForOut(outUser,2)%>">
					<div class="mt-userimg2"><img src="<%=photo%>"/></div>
					<div class="mt-username"><%=name%></div>
				</div>
				<%}}} 
					int otherCount = outUserList.size();
				%>
				</div>
			</div>
			<div class="weui-cell__ft"></div>
		</div>
		<%if(ifCreater){ %>
		<div class="weui-cell weui-cell_access" onclick="getQRCode2('<%=addressselect%>','<%=address%>','<%=customizeAddress%>')">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-27"></i></div>
			</div>
			<div class="weui-cell__bd">会议地点</div>
			<div class="weui-cell__ft" id="addressSpan"><%=roomname %></div>
		</div>
		<%}else{ %>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-27"></i></div>
			</div>
			<div class="weui-cell__bd">会议地点</div>
			<div class="weui-cell__ft" id="addressSpan"><%=roomname %></div>
		</div>
		<%} %>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-97"></i></div>
			</div>
			<div class="weui-cell__bd">会议要求</div>
			<div class="weui-cell__ft" style="text-align:left;"><%=desc_n %></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-2"></i></div>
			</div>
			<div class="weui-cell__bd">会议成本</div>
			<div class="weui-cell__ft"><%=cost %></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-1"></i></div>
			</div>
			<div class="weui-cell__bd">会议评估</div>
			<div class="weui-cell__ft">
				<%if(isAppraise==3){ %>
					是
				<%}else{ %>
					否
				<%} %>
			</div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-100"></i></div>
			</div>
			<div class="weui-cell__bd">会议通知抄送人</div>
			<div class="weui-cell__ft"><%=MeetingUtilForYl.getUserNames(ccmeetingnotice,rc) %></div>
		</div>
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-100"></i></div>
			</div>
			<div class="weui-cell__bd">会议纪要抄送人</div>
			<div class="weui-cell__ft"><%=MeetingUtilForYl.getUserNames(ccmeetingminutes,rc) %></div>
		</div>
		<% 
			if(!accessorys.equals("")){
				
		%>	
		<div class="weui-cell">
			<div class="weui-cell__hd">
				<div class="mt-bgimg"><i class="icon icon-111"></i></div>
			</div>
			<div class="weui-cell__bd">会议通知附件</div>
			<div class="weui-cell__ft"></div>
		</div>
		<% 
			String[] as = accessorys.split(",");
			for(String a:as){
				docImageManager.resetParameter();
		        docImageManager.setDocid(Util.getIntValue(a));
		        docImageManager.selectDocImageInfo();
		        if(docImageManager.next()){
		          	String docImagefileid = docImageManager.getImagefileid();
		          	int docImagefileSize = docImageManager.getImageFileSize(Util.getIntValue(docImagefileid));
		          	String docImagefilename = docImageManager.getImagefilename();
		          	String docImagefileSizeStr = "";
			        if(docImagefileSize / (1024 * 1024) > 0) {
			        	docImagefileSizeStr = (docImagefileSize / 1024 / 1024) + "M";
			        } else if(docImagefileSize / 1024 > 0) {
			        	docImagefileSizeStr = (docImagefileSize / 1024) + "K";
			        } else {
			        	docImagefileSizeStr = docImagefileSize + "B";
			        }
		%>
		<div class="weui-cell mt-detail-fj" onclick="downLoadAttach('<%=docImagefileid%>','<%=docImagefilename%>')">
			<div class="weui-cell__bd"><%=docImagefilename %></div>
			<div class="weui-cell__ft">
				<%=docImagefileSizeStr %>&nbsp;&nbsp;
				<i class="icon icon-114"></i>
			</div>
		</div>
		<% 	
			}}}
		%>
	</div>
	<div class="mt-detail-content" id="mt-detail-topic" style="display:none;">
		<div id="mt-topicList-div">
			<div class="weui-cell">
				<div class="weui-cell__bd" style="color:#999;">议程列表</div>
				<div class="weui-cell__ft"></div>
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
	<%if(canReback&&!ifReback&&(meetingover==2||meetingover==1)){ %>
	<div id="mt-reback-div">
		<div class="mt-reback-zw"></div>
		<div class="mt-reback-btn">会议回执</div>
	</div>
	<%} %>
</div>
<!-- 参会人员的签到和回执情况弹出层 -->
<div id="hrmpopup" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-tabbar">
			<div class="mt-tab mt-tab-current mt-tab-left" tab="mt-sign">签到人员</div>
			<div class="mt-tab mt-tab-right" tab="mt-reback">回执人员</div>
		</div>
		<div class="mt-operat-btn" style="padding:0 10px;right:0;" onclick="showSearchSignUser()"><i class="icon icon-4"></i></div>
		<% 
			String currentDate = TimeUtil.getCurrentDateString();
			String showDate = "",prevShow = "",nextShow = "";
			int beforeDay = TimeUtil.dateInterval(begindate,currentDate);//currentDate - begindate
			int endDay = TimeUtil.dateInterval(enddate,currentDate);//currentDate-enddate
			if(beforeDay<=0){
				showDate = begindate;
				prevShow = "none";
			}else if(endDay>=0){
				showDate = enddate;
				nextShow = "none";
			}else{
				showDate = currentDate;
			}
			int day = TimeUtil.dateInterval(begindate, enddate);
			if(day>0){
		%>	
		<div class="mt-detail-date">
			<div class="prev <%=prevShow %>"><i class="icon icon-109"></i></div>
			<div class="showdate"><%=showDate %></div>
			<div class="next <%=nextShow %>"><i class="icon icon-108"></i></div>
		</div>
		<%}%>
		<div class="mt-detail-text" id="mt-detail-text"></div>
		<div class="mt-detail-content" id="mt-sign"></div>
		<div class="mt-detail-content" id="mt-reback" style="display:none;">
			<%
				for(String[] hrmuser:hrmUserList){
					String memberid = hrmuser[0];
					String isattend = hrmuser[1];
					String isattendName = hrmuser[2];
					String reotherusers = hrmuser[3];
					String attendStatus = hrmuser[4];
					String deptid = rc.getDepartmentID(memberid);
			%>
			<div class="weui-cell mt-reback-cell" status="<%=attendStatus %>" userid="<%=memberid %>" deptid="<%=deptid %>" id="mt-reback-cell-<%=memberid%>" onclick="openuser(<%=memberid%>)">
				<div class="weui-cell__hd" style="margin-right:10px;">
					<div class="mt-userimg"><img src="<%=MeetingUtilForYl.getUserImg(memberid,rc) %>" width="60" height="60"/></div>
				</div>
				<div class="weui-cell__bd">
					<p><%=rc.getLastname(memberid) %></p>
					<p><%=dc.getDepartmentname(deptid)%></p>
				</div>
				<div class="weui-cell__ft">
					<div class="reback reback<%=isattend%>"><%=isattendName %></div>
				</div>
			</div>
			<%if(!"".equals(reotherusers)){%>
				<div class="mt-reback-others">其他参会人员:<%=MeetingUtilForYl.getUserNames(reotherusers,rc) %></div>
			<%} %>
			<%} %>
		</div>
	</div>
</div>
<!-- 签到,回执人员搜索 -->
<div id="searchSignUserPopup" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-detail-content" id="mt-add-content">
			<div class="weui-cell weui-cell_vcode">
				<div class="weui-cell__hd">人员</div>
				<div class="weui-cell__bd">
					<p id="ssuserSpan" onclick=""></p>
					<input type="hidden" id="ssuser" name="ssuser" value=""/>
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="selectUser('ssuser','ssuserSpan',1);">
						<i class="weui-icon-search"></i>
					</button>
				</div>
			</div>
			<div class="weui-cell weui-cell_vcode">
				<div class="weui-cell__hd">部门</div>
				<div class="weui-cell__bd">
					<p id="ssdeptSpan" onclick=""></p>
					<input type="hidden" id="ssdept" name="ssdept" value=""/>
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="selectDept('ssdept','ssdeptSpan',1);">
						<i class="weui-icon-search"></i>
					</button>
				</div>
			</div>
			<div class="weui-cell weui-cell_select" id="ss_weui-cell-sign">
				<div class="weui-cell__hd">状态</div>
				<div class="weui-cell__bd">
					<input class="weui-input" data-values="" value="全部" 
						type="text" id="signStatusSelect" name="signStatusSelect_input" />
				</div>
			</div>
			<div class="weui-cell weui-cell_select" id="ss_weui-cell-reback">
				<div class="weui-cell__hd">状态</div>
				<div class="weui-cell__bd">
					<input class="weui-input" data-values="" value="全部" 
						type="text" id="rebackStatusSelect" name="rebackStatusSelect_input" />
				</div>
			</div>
		</div>
		<div id="mt-sign-action-div">
			<div class="mt-sign-btn3" onclick="searchSignUser()">确定</div>
		</div>
	</div>
</div>
<!-- 外部人员列表弹出层 -->
<div id="hrmpopupForOut" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-tabbar"><div class="mt-popup-title">外部人员</div></div>
		<div class="mt-detail-content">
			<% 
				if(outUserList.size()>0){
					for(String[] outUser:outUserList){ 
						String photo = outUser[3];
			%>
			<div class="weui-cell" onclick="<%=getOpenUserForOut(outUser,1)%>">
				<div class="weui-cell__hd" style="margin-right:10px;">
					<div class="mt-userimg"><img src="<%=photo %>" width="60" height="60"/></div>
				</div>
				<div class="weui-cell__bd">
					<p><%=outUser[1]%></p>
					<p><%=outUser[4]%></p>
				</div>
				<div class="weui-cell__ft">
					<%=outUser[5] %>
				</div>
			</div>
			<%}}else{ %>
				<div style="background:#f0f0f0;">
					<div class='weui-loadmore weui-loadmore_line'><span class='weui-loadmore__tips' style="background:#f0f0f0;">没有外部人员</span></div>
				</div>
			<%} %>
		</div>
	</div>
</div>
<!-- 外部人员详情查看弹出层 -->
<div id="hrmpopupForOutDetail" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-udetail-top">
			<div class="mt-udetail-userimg">
				<div class="userimg-center"><img src="" id="mt-udetail-userimg"></div>
			</div>
			<div class="mt-udetail-username" id="mt-udetail-lastname"></div>
			<div class="mt-udetail-usertitle" id="mt-udetail-jobtitle"></div>
		</div>
		<div class="mt-udetail-bottom">
			<div class="weui-cells">
				<div class="weui-cell">
					<div class="weui-cell__bd">公司</div>
					<div class="weui-cell__ft" id="mt-udetail-company"></div>
				</div>
				<div class="weui-cell">
					<div class="weui-cell__bd">职务</div>
					<div class="weui-cell__ft" id="mt-udetail-duty"></div>
				</div>
				<div class="weui-cell">
					<div class="weui-cell__bd">手机</div>
					<div class="weui-cell__ft" id="mt-udetail-mobile"></div>
				</div>
				<div class="weui-cell">
					<div class="weui-cell__bd">性别</div>
					<div class="weui-cell__ft" id="mt-udetail-sex"></div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 回执界面弹出层 -->
<div id="rebackpopup" class="weui-popup__container">
	<div class="weui-popup__overlay"></div>
	<div class="weui-popup__modal">
		<div class="mt-tabbar"><div class="mt-popup-title">会议回执</div></div>
		<div class="weui-cells weui-cells_radio">
	      <label class="weui-cell weui-check__label" for="x11">
	        <div class="weui-cell__bd">
	          <p>参加</p>
	        </div>
	        <div class="weui-cell__ft">
	          <input type="radio" class="weui-check" value="1" name="rebackradio" id="x11" checked="checked">
	          <span class="weui-icon-checked"></span>
	        </div>
	      </label>
	      <label class="weui-cell weui-check__label" for="x12">
	        <div class="weui-cell__bd">
	          <p>不参加</p>
	        </div>
	        <div class="weui-cell__ft">
	          <input type="radio" name="rebackradio" value="2" class="weui-check" id="x12">
	          <span class="weui-icon-checked"></span>
	        </div>
	      </label>
	      <div class="weui-cell weui-cell_vcode">
				<div class="weui-cell__hd">
					<label class="weui-label">其他人员</label>
				</div>
				<div class="weui-cell__bd">
					<p id="othermemberspan" onclick=""></p>
					<input type="hidden" id="othermember" name="othermember" value="" />
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="selectUser('othermember','othermemberspan',1);">
						<i class="weui-icon-search"></i>
					</button>
				</div>
			</div>
	    </div>
	    <div class="btn-wrapper">
			<a href="javascript:doReback()" class="weui-btn weui-btn_primary" style="color:#fff;">提交</a>
		</div>
	</div>
</div>
<!-- 议程详情查看弹出层 -->
<div id="topicpopup" class="weui-popup__container" style="top:60px;">
	<div class="weui-popup__overlay" style="top:60px;"></div>
	<div class="weui-popup__modal">
		<div class="weui-cells">
			<div class="weui-cell">
				<div class="weui-cell__bd">序号</div>
				<div class="weui-cell__ft" id="mt-topic-xuhao"></div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__bd">议题</div>
				<div class="weui-cell__ft" id="mt-topic-subject"></div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__bd">决策人</div>
				<div class="weui-cell__ft" id="mt-topic-hrmids"></div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__bd">决策点</div>
				<div class="weui-cell__ft" id="mt-topic-jcd"></div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__bd">开始日期</div>
				<div class="weui-cell__ft" id="mt-topic-startdate"></div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__bd">结束日期</div>
				<div class="weui-cell__ft" id="mt-topic-enddate"></div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__bd">开始时间</div>
				<div class="weui-cell__ft" id="mt-topic-starttime"></div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__bd">结束时间</div>
				<div class="weui-cell__ft" id="mt-topic-endtime"></div>
			</div>
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
<script type="text/javascript">
	var param = "<%=param%>";
	var meetingid = "<%=id%>";
	var userid = "<%=userid%>";
	var caller = "<%=caller%>";
	var hrmids = "<%=hrmids%>";
	var hrmCount = "<%=hrmCount%>";
	var otherCount = "<%=otherCount%>";
	var showDate = "<%=showDate%>";//需要加载哪天的签到数据
	var dt_begindate = "<%=begindate%>";
	var dt_enddate = "<%=enddate%>";
	var topicLoaded = false;//是否加载过会议议程
	var searchUserPopup = false;//签到人员搜索弹出层
	var signRebackTab = "mt-sign";
	$(document).ready(function(){
		FastClick.attach(document.body);
		//设置参会人员数量和外来人员数量
		if(parseInt(hrmCount)>0){
			$("#hrmCount").append("(共计"+hrmCount+"人)");
		}
		if(parseInt(otherCount)>0){
			$("#otherCount").append("(共计"+otherCount+"人)");
		}
		//签到人员 回执人员tab切换
		$("#hrmpopup .mt-tab").click(function(){
			$("#hrmpopup .mt-tab").removeClass("mt-tab-current");
			$(this).addClass("mt-tab-current");
			signRebackTab = $(this).attr("tab");
			if(signRebackTab=="mt-sign"){
				$(".mt-detail-date").show();
			}else{
				$(".mt-detail-date").hide();
			}
			$("#hrmpopup .mt-detail-content").hide();
			$("#"+signRebackTab).show();
		});
		//会议信息 会议议程tab切换
		$("#container .mt-tab").click(function(){
			$("#container .mt-tab").removeClass("mt-tab-current");
			$(this).addClass("mt-tab-current");
			var tab = $(this).attr("tab");
			$("#container .mt-detail-content").hide();
			$("#"+tab).show();
			if(tab=="mt-detail-topic"&&!topicLoaded){
				loadTopic();
			}
			popOpen = false;
			$.closePopup();
		});
		//回执事件
		$(".mt-reback-btn").click(function(){
			popOpen = true;
			$("#rebackpopup").popup();
		});
		loadSignList();//加载签到数据
		<%if(ifCanCancel){%>//取消会议
			$("#cancelMt").click(function(){
				$.confirm("您是否确定取消会议?",function(){
					$.showLoading();
					$.ajax({
						type: "post",
					    url: "/mobile/plugin/5/meetingOperation.jsp",
					    data:{"operation":"cancelMeeting","meetingid":meetingid}, 
					    dataType:"json",
					   	success:function(data){
					   		$.hideLoading();
					   		if(data.status==0){
					   			$.toast("取消成功");
					   			doLeftButton();
					   		}else{
					   			$.alert(data.msg);
					   		}
					   	},
					    error: function(data){
					    	$.hideLoading();
						}
				    });
				});
			});
		<%}%>
		<%if(ifCanOver){%>//结束会议
			$("#overMt").click(function(){
				$.confirm("您是否确定提前结束会议?",function(){
					$.showLoading();
					$.ajax({
						type: "post",
					    url: "/mobile/plugin/5/meetingOperation.jsp",
					    data:{"operation":"overMeeting","meetingid":meetingid}, 
					    dataType:"json",
					   	success:function(data){
					   		$.hideLoading();
					   		if(data.status==0){
					   			$.toast("会议已提前结束");
					   			location.reload();
					   		}else{
					   			$.alert(data.msg);
					   		}
					   	},
					    error: function(data){
					    	$.hideLoading();
						}
				    });
				});
			});
		<%}%>
		$("#deciMt").click(function(){
			location.href = "/mobile/plugin/5/mtdecision.jsp?id="+meetingid;
		});
		if("<%=operation%>"=="showSign"){
			viewHrmid();
		}
		//移动人员显示位置
		$("#mt-reback").prepend($("#mt-reback-cell-"+userid));
		$("#mt-reback").prepend($("#mt-reback-cell-"+caller));
		//签到时间选择事件
		$(".mt-detail-date .prev").click(function(){
			showDate = addDate(showDate,-1);
			$(".showdate").html(showDate);
			checkBtn();
			loadSignList();
		});
		$(".mt-detail-date .next").click(function(){
			showDate = addDate(showDate,1);
			$(".showdate").html(showDate);
			checkBtn();
			loadSignList();
		});
		//签到人员搜索状态初始化
		$("#signStatusSelect").select({
			  title: "选择签到状态",
			  items: [{title:"全部",value:""},{title:"未签到",value:"1"},{title:"已签到",value:"0"}]
		});
		//回执人员搜索状态初始化
		$("#rebackStatusSelect").select({
			  title: "选择回执状态",
			  items: [{title:"全部",value:""},{title:"已回执",value:"1"},{title:"未回执",value:"2"}]
		});
	});
	//时间选择按钮点击对日期加减
	function addDate(date,days){ 
     	var d = new Date(date); 
       	d.setDate(d.getDate()+days); 
       	var m = d.getMonth()+1;
       	if(m<10){
       		m = "0"+m;
       	}
       	var day = d.getDate();
       	if(day<10){
       		day = "0"+day;
       	}
       	return d.getFullYear()+'-'+m+'-'+day; 
    }
	//隐藏和限制时间选择左右两边的按钮
	function checkBtn(){
		if(compdate(showDate,dt_begindate)){
			$(".mt-detail-date .prev").show();
		}else{
			$(".mt-detail-date .prev").hide();
		}
		if(compdate(dt_enddate,showDate)){
			$(".mt-detail-date .next").show();
		}else{
			$(".mt-detail-date .next").hide();
		}
	}
	//显示签到,回执人员搜索弹出层
	function showSearchSignUser(){
		if(signRebackTab=="mt-sign"){//当前在签到人员页签
			$("#ss_weui-cell-sign").show();
			$("#ss_weui-cell-reback").hide();
		}else{
			$("#ss_weui-cell-sign").hide();
			$("#ss_weui-cell-reback").show();
		}
		searchUserPopup = true;
		$("#searchSignUserPopup").popup();
	}
	//执行搜索签到回执人员
	function searchSignUser(){
		var ssuser = ","+$("#ssuser").val()+",";
		var ssdept = ","+$("#ssdept").val()+",";
		var ssStatus = "";
		var className = "";
		if(signRebackTab=="mt-sign"){
			className = "mt-sign-cell";
			ssStatus = $("#signStatusSelect").attr("data-values");
		}else{
			className = "mt-reback-cell";
			ssStatus = $("#rebackStatusSelect").attr("data-values");
		}
		$("."+className).each(function(){
			var userid = $(this).attr("userid");
			var deptid = $(this).attr("deptid");
			var status = $(this).attr("status");
			if((ssuser==",,"||ssuser.indexOf(","+userid+",")>-1)
				&&(ssdept==",,"||ssdept.indexOf(","+deptid+",")>-1)
				&&(ssStatus==""||ssStatus==status)){
				$(this).show();
			}else{
				$(this).hide();
			}
		});
		doLeftButton();
	}
	//加载签到数据
	function loadSignList(){
		$("#mt-sign").html(getLoadHtml("正在加载..."));
		$.ajax({
			type: "post",
		    url: "/mobile/plugin/5/meetingOperation.jsp",
		    data:{"operation":"getSingList","meetingid":meetingid,"showDate":showDate,
		    	"begindate":"<%=begindate%>","enddate":"<%=enddate%>","begintime":"<%=begintime%>","endtime":"<%=endtime%>"}, 
		    dataType:"json",
		   	success:function(data){
		   		if(data.status==0){
		   			var userList = data.userList;
		   			var temp = "";
		   			for(var i in userList){
		   				var u = userList[i];
		   				var ssStatus = u.ifSignToady;
		   				if(ssStatus==2){//迟到
		   					ssStatus = "0";
		   				}
		   				temp += '<div class="weui-cell mt-sign-cell" status="'+ssStatus+'" userid="'+u.memberid+'" deptid="'+u.deptid+'" id="mt-sign-cell-'+u.memberid+'" onclick="openuser('+u.memberid+')">'+
				   				'	<div class="weui-cell__hd" style="margin-right:10px;">'+
								'		<div class="mt-userimg">'+
						   		'			<img src="'+u.userImg+'" width="60" height="60"/>'+
						   		'		</div>'+
								'	</div>'+
								'	<div class="weui-cell__bd">'+
								'		<p>'+u.userName+'</p>'+
								'		<p>'+u.dept+'</p>'+
								'	</div>'+
								'	<div class="weui-cell__ft">'+
								'		<div class="signin'+u.ifSignToady+'">'+u.statusName+'</div>'+
								'		<div class="signdate">'+u.nowSignDate+'</div>'+
								'	</div>'+
								'</div>';
						//if(u.day>1&&u.signDay>0){
						//	temp += '<div class="mt-sign-title2">签到详情('+u.signDay+'/'+u.day+')</div>';
						//	for(var j in u.signList){
						//		var s = u.signList[j];
						//		temp += '<div class="mt-sign-item2">'+s.sstatus+'</div>';
						//	}
						//}
		   			}
		   			$("#mt-sign").html(temp);
		   			//移动人员显示位置
		   			$("#mt-sign").prepend($("#mt-sign-cell-"+userid));
		   			$("#mt-sign").prepend($("#mt-sign-cell-"+caller));
		   			//显示数量文字
		   			$("#mt-detail-text").html('应到参会人<font color="red">'+data.hrmCount+'</font>人'+
		   				'，已签到<font color="red">'+data.signCount+'</font>人， 未签到<font color="red">'+data.noSignCount+'</font>人');
		   		}else{
		   			$("#mt-sign").html(getTipsHtml(data.msg));
		   		}
		   	},
		    complete: function(data){
		    	$.hideLoading();
			}
	    });
	}
	//加载议程数据
	function loadTopic(){
		$.showLoading();
		$.ajax({
			type: "post",
		    url: "/mobile/plugin/5/meetingOperation.jsp",
		    data:{"operation":"loadTopic","meetingid":meetingid}, 
		    dataType:"json",
		   	success:function(data){
		   		if(data.status==0){
		   			topicLoaded = true;
		   			var topicList = data.topicList;
		   			var temp = "";
		   			if(topicList.length>0){
		   				for(var i=0;i<topicList.length;i++){
		   					var topic = topicList[i];
		   					temp += '<div class="weui-cell weui-cell_access" onclick="viewTopic('+topic.id+')">'+
		   							'	<div class="weui-cell__bd">'+topic.subject+'</div>'+
		   							'	<div class="weui-cell__ft">'+topic.starttime+'-'+topic.endtime+'</div>'+
		   							'</div>';
		   				}
		   				$("#mt-topicList-div").append(temp);
		   			}else{
		   				temp =  getTipsHtml("没有相关议程");
		   				$("#mt-topicList-div").html(temp);		
		   			}
		   			var attachList = data.topicAttatchList;
		   			var temp2 = "";
		   			if(attachList.length>0){
		   				for(var i=0;i<attachList.length;i++){
		   					var attach = attachList[i];
		   					temp2 += '<div class="weui-cell weui-cell_access" onclick="downLoadAttach('+attach.fileid+',\''+attach.filename+'\')">'+
		   							'	<div class="weui-cell__bd">'+attach.filename+'</div>'+
		   							'	<div class="weui-cell__ft">'+attach.filesize+'</div>'+
		   							'</div>';
		   				}
		   				$("#mt-topicAttachList-div").append(temp2).show();
		   			}else{
		   				$("#mt-topicAttachList-div").hide();
		   			}
		   		}else{
		   			$.alert(data.msg);
		   		}
		   	},
		    complete: function(data){
		    	$.hideLoading();
			}
	    });
	}
	//查看议程详情
	function viewTopic(topicid){
		$.showLoading();
		$.ajax({
			type: "post",
		    url: "/mobile/plugin/5/meetingOperation.jsp",
		    data:{"operation":"getTopicById","topicid":topicid}, 
		    dataType:"json",
		   	success:function(data){
		   		if(data.status==0){
		   			$("#mt-topic-xuhao").html(data.topic.xuhao);
		   			$("#mt-topic-subject").html(data.topic.subject);
		   			$("#mt-topic-hrmids").html(data.topic.hrmids);
		   			$("#mt-topic-jcd").html(data.topic.jcd);
		   			$("#mt-topic-startdate").html(data.topic.startdate);
		   			$("#mt-topic-starttime").html(data.topic.starttime);
		   			$("#mt-topic-enddate").html(data.topic.enddate);
		   			$("#mt-topic-endtime").html(data.topic.endtime);
		   			popOpen = true;
		   			$("#topicpopup").popup();
		   		}else{
		   			$.alert(data.msg);
		   		}
		   	},
		    complete: function(data){
		    	$.hideLoading();
			}
	    });
	}
	//回执
	function doReback(){
		$.confirm("确定提交回执?",function(){
			$.showLoading();
			var isattend = $("input[name='rebackradio']:checked").val();
			var othermember = $("#othermember").val();
			$.ajax({
				type: "post",
			    url: "/mobile/plugin/5/meetingOperation.jsp",
			    data:{"operation":"doReback","isattend":isattend,"meetingid":meetingid,"othermember":othermember,
			    	"hrmids":hrmids,"mtname":$("#mt-detail-mtname").html()}, 
			    dataType:"json",
			   	success:function(data){
			   		$.hideLoading();
			   		if(data.status==0){
			   			$.toast("回执成功");
			   			$("#mt-reback-div").remove();//移除回执按钮
			   			$("#mt-reback-cell-"+userid).find(".reback").removeClass("reback0")
			   				.addClass("reback"+data.isattend).html(data.attendName);
			   			if(data.oName!=""){
			   				$("#mt-reback-cell-"+userid).after('<div class="mt-reback-others">其他参会人员:'+data.oName+'</div>');
			   			}
			   			doLeftButton();//关闭弹出层
			   		}else{
			   			$.alert(data.msg);
			   		}
			   	},
			    error: function(data){
			    	$.hideLoading();
				}
		    });
		});
	}
	function getRequestTitle(){
		return "<%=meetingname%>";
	}
	function doLeftButton(){
		if(outUserOpen){
			$.closePopup();
			$("#hrmpopupForOut").popup();
			outUserOpen = false;
		}else if(searchUserPopup){
			searchUserPopup = false;
			$("#hrmpopup").popup();
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
<%! 
	
	private String getOpenUserForOut(String[] outUser,int type){
		return "openuserForOut('"+outUser[1]+"','"+outUser[2]+"','"+outUser[3]+"','"+outUser[4]+"','"+outUser[5]+"','"+outUser[6]+"','"+type+"')";
	}
%>
<%
	
		}else{
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta http-equiv="Cache-Control" content="no-cache,must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<meta name="viewport" content="width=device-width,minimum-scale=1.0, maximum-scale=1.0" />
	<title>会议详情</title>
	<link rel="stylesheet" href="/mobile/plugin/5/css/weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/jquery-weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/meeting.css?v=2018020501" />
</head>
<body>
	<div id="container">
		<div style="background:#f0f0f0;overflow:hidden;">
			<div class="weui-loadmore weui-loadmore_line">	
				<span class="weui-loadmore__tips" style="background:#f0f0f0;">您没有权限查看该会议</span>
			</div>
		</div>
	</div>
</body>
</html>
<%			
		}	
	}else{
		out.println("会议不存在");
		return;
	}
%>
