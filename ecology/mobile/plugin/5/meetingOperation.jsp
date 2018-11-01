<%@ page language="java" pageEncoding="UTF-8"%>
<%@ include file="/page/maint/common/initNoCache.jsp"%>
<%@ page import="weaver.general.*"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@ page import="net.sf.json.JSONArray"%>
<%@ page import="weaver.file.FileUpload"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="weaver.conn.RecordSet"%>
<%@ page import="weaver.file.Prop"%>
<%@ page import="weaver.meeting.MeetingShareUtil"%>
<%@ page import="weaver.meeting.MeetingLog"%>
<%@ page import="weaver.meeting.defined.MeetingWFUtil"%>
<%@ page import="weaver.meeting.Maint.MeetingInterval"%>
<%@ page import="weaver.meeting.remind.MeetingRemindUtil"%>
<%@ page import="weaver.meeting.MeetingUtilForYl"%>
<%@ page import="weaver.hrm.company.SubCompanyComInfo" %>
<%@ page import="com.weavernorth.util.QRCode"%>
<%@ page import="com.google.zxing.BarcodeFormat"%>
<%@ page import="java.io.File"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page"/>
<jsp:useBean id="rs3" class="weaver.conn.RecordSet" scope="page"/>
<jsp:useBean id="rc" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>
<jsp:useBean id="dc" class="weaver.hrm.company.DepartmentComInfo" scope="page" />
<jsp:useBean id="SysRemindWorkflow" class="weaver.system.SysRemindWorkflow" scope="page"/>
<jsp:useBean id="docImageManager" class="weaver.docs.docs.DocImageManager" scope="page" />
<%
	request.setCharacterEncoding("UTF-8");
	JSONObject json = new JSONObject();
	int status = 1;String msg = "";
	int userid = user.getUID();
	String subcompanyid = String.valueOf(user.getUserSubCompany1());
	try{
		FileUpload fu = new FileUpload(request);
		String operation = Util.null2String(fu.getParameter("operation"));
		if("getMeetingNum".equals(operation)){
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			int year = Util.getIntValue(fu.getParameter("year"));
			int month = Util.getIntValue(fu.getParameter("month"));
			String beginDate = "",endDate = "";
			Calendar calendar = Calendar.getInstance();
			if(year!=0){//初始化,取当前月
				calendar.set(Calendar.YEAR,year);
				calendar.set(Calendar.MONTH,month);
			}
			calendar.set(Calendar.DAY_OF_MONTH,1);//设置成本月第一天
			Calendar endCalendar = (Calendar)calendar.clone();//复制一份
			calendar.add(Calendar.DAY_OF_YEAR,-7);//减去7天
			beginDate = sdf.format(calendar.getTime());
			
			endCalendar.roll(Calendar.DAY_OF_MONTH,-1);//获取本月最后一天
			endCalendar.add(Calendar.DAY_OF_YEAR,13);//加上13天
			endDate = sdf.format(endCalendar.getTime());
			String sql = getSql(subcompanyid,user,beginDate,endDate,1);
			rs.executeSql(sql);
			Map<String,Integer> map = new HashMap<String,Integer>();
			String currentDate = TimeUtil.getCurrentDateString();
			List<String> list=new ArrayList<String>();
			while(rs.next()){
			    String id=Util.null2String(rs.getString("id"));
			    if(list.contains(id)){
			        continue;
				}
				list.add(id);
				String beginDate2 = Util.null2String(rs.getString("beginDate"));
				String endDate2 = Util.null2String(rs.getString("endDate"));
				int dateSize = TimeUtil.dateInterval(beginDate2,endDate2);
				Calendar c = Calendar.getInstance();
				c.setTime(sdf.parse(beginDate2));//从开始日期开始循环
				for(int i=0;i<=dateSize;i++){
					String date = sdf.format(c.getTime());
					Integer count = 0;
					if(map.containsKey(date)){
						count = map.get(date);
					}
					count++;
					map.put(date, count);
					c.add(Calendar.DAY_OF_YEAR,1);
				}
			}
			JSONArray ja = new JSONArray();
			for(Map.Entry<String,Integer> e:map.entrySet()){
				JSONObject jo = new JSONObject();
				String date = e.getKey();
				int offset = TimeUtil.dateInterval(date,currentDate);//当前时间减去该日期
				jo.put("date", date);
				jo.put("count", e.getValue());
				jo.put("offset", offset);
				ja.add(jo);
			}
			json.put("meetings", ja);
			status = 0;
		}else if("getMeetingList".equals(operation)){
			String selectday = Util.null2String(fu.getParameter("selectday"));
			if(!selectday.equals("")){
				String sql = getSql(subcompanyid,user,selectday,"",2);
				//System.out.println(sql);
				rs.executeSql(sql);
				new weaver.general.BaseBean().writeLog("getMeetingList"+sql);

				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
				JSONArray ja = new JSONArray();
				List<String> list=new ArrayList<String>();
				while(rs.next()){
					String id = Util.null2String(rs.getString("id"));
					if(list.contains(id)){
					    continue;
					}
					list.add(id);
					String contacter = Util.null2String(rs.getString("contacter"));//创建人
					String caller = Util.null2String(rs.getString("caller"));//主持人(召集人)id
					String recorder = Util.null2String(rs.getString("recorder"));//会议记录人id
					String hrmmembers = Util.null2String(rs.getString("hrmmembers"));//参会人
					String name = Util.null2String(rs.getString("name"));
					String roomname = Util.null2String(rs.getString("roomname"));
					String customizeAddress = Util.null2String(rs.getString("customizeAddress"));
					if("".equals(roomname)){
						roomname = customizeAddress;
					}
					String beginDate = Util.null2String(rs.getString("beginDate"));
					String endDate = Util.null2String(rs.getString("endDate"));
					String begintime = Util.null2String(rs.getString("begintime"));
					String endtime = Util.null2String(rs.getString("endtime"));
					int creater=Util.getIntValue(rs.getString("creater"));//创建人
					String isdecision = Util.null2String(rs.getString("isdecision"));//会议决议
					int meetingstatus = Util.getIntValue(rs.getString("meetingstatus"));//会议状态
					int meetingover = 0;//会议进行状态 0已结束 1进行中  2未开始
					if(meetingstatus==0){
						meetingover = 3;//草稿
					}else if(meetingstatus==1){
						meetingover = 4;//审批中
					}else{
						Date startDate = sdf.parse(beginDate+" "+begintime);
						Date endDate2 = sdf.parse(endDate+" "+endtime);
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
					String userType = "";
					if(caller.equals(user.getUID()+"")){
						userType = "<span style='font-size:12px;'>[主持人]</span>";
					}else if(recorder.equals(user.getUID()+"")){
						userType = "<span style='font-size:12px;'>[记录人]</span>";
					}else if((","+hrmmembers+",").indexOf(","+user.getUID()+",")>-1){
						userType = "<span style='font-size:12px;'>[参会人]</span>";
					}else if(contacter.equals(user.getUID()+"")){
						userType = "<span style='font-size:12px;'>[创建人]</span>";
					}
					JSONObject jo = new JSONObject();
					jo.put("id", id);
					jo.put("name", name);
					jo.put("roomname", roomname);
					jo.put("beginDate", beginDate);
					jo.put("endDate", endDate);
					jo.put("begintime", begintime);
					jo.put("endtime", endtime);
					jo.put("meetingover", meetingover);
					jo.put("userType", userType);
					jo.put("create",rc.getLastname(creater+""));
					jo.put("createid",creater+"");
					ja.add(jo);
				}
				json.put("meetings", ja);
				status = 0;
			}else{
				msg = "获取日期失败";
			}
		}else if("doReback".equals(operation)){
			String mtname = Util.null2String(fu.getParameter("mtname"));
			String meetingid = Util.null2String(fu.getParameter("meetingid"));
			String othermember = Util.null2String(fu.getParameter("othermember"));
			String hrmids = Util.null2String(fu.getParameter("hrmids"));//老的参会人员数据
			int isattend = Util.getIntValue(fu.getParameter("isattend"),0);
			String attendName = "参加";
			if(isattend==2){
				attendName = "不参加";
			}
			String oName = "";
			if(!"".equals(othermember)){
				oName = MeetingUtilForYl.getUserNames(othermember,rc);
				if(isattend==1){
					isattend = 3;
				}else if(isattend==2){
					isattend = 4;
					attendName = "他人参加";
				}
				//将新增的人员放入参会人员中
				String[] os = othermember.split(",");
				if(null!=os&&os.length>0){
					for(String o:os){
						if((","+hrmids+",").indexOf(","+o+",")<0){//不存在该参会人员 Meeting_Member2表插入参会人员
							hrmids = hrmids+","+o;
							rs.executeSql("insert into Meeting_Member2 (meetingid,membertype,memberid,membermanager,isattend)"+
								" values ("+meetingid+",1,"+o+","+o+",0)");
						}
					}
					String[] hrmidss = hrmids.split(",");
					int totalmember = 0;//更新应到人数
					if(null!=hrmidss){
						totalmember = hrmidss.length;
					}
					String[] costHour = MeetingUtilForYl.getCostHour(hrmids,meetingid,"","","","");
					String cost = costHour[0];
					//更新会议表的参会人 参会人数 成本
					rs.executeSql("update meeting set hrmmembers = '"+hrmids+"',totalmember = "+totalmember+",cost = '"+cost+"' where id ="+meetingid);
				}
			}
			rs.executeSql("update Meeting_Member2 set isattend = "+isattend+",othermember='"
				+othermember+"' where meetingid="+meetingid+" and memberid = "+userid);
			//发送emessage提醒
			//MeetingUtilForYl.sendMsg(othermember, "新会议:"+mtname, "/mobile/plugin/5/detail.jsp?id="+meetingid);
			json.put("isattend", isattend);
			json.put("attendName", attendName);
			json.put("oName", oName);
			status = 0;
		}else if("loadTopic".equals(operation)){
			String meetingid = Util.null2String(fu.getParameter("meetingid"));
			String sql = "select t.* from Meeting_Topic t where t.meetingid = "+meetingid;
			//获取序号字段名称
			String orderNumberName = Util.null2String(Prop.getPropValue("meeting", "orderNumberName"));	
			if(orderNumberName.equals("")){
				orderNumberName = "xuhao";
			}
			sql +="order by "+orderNumberName;
			rs.executeSql(sql);
			JSONArray ja = new JSONArray();
			while(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				String subject = Util.null2String(rs.getString("subject"));
				String hrmids = Util.null2String(rs.getString("hrmids"));
				String xuhao = Util.null2String(rs.getString("xuhao"));
				String jcd = Util.null2String(rs.getString("jcd"));
				String startdate = Util.null2String(rs.getString("startdate"));
				String starttime = Util.null2String(rs.getString("starttime"));
				String enddate = Util.null2String(rs.getString("enddate"));
				String endtime = Util.null2String(rs.getString("endtime"));
				JSONObject jo = new JSONObject();
				jo.put("id", id);
				jo.put("subject", subject);
				jo.put("hrmids", hrmids);
				jo.put("hrmspans", rc.getLastname(hrmids));
				jo.put("xuhao", xuhao);
				jo.put("jcd", jcd);
				jo.put("startdate", startdate);
				jo.put("starttime", starttime);
				jo.put("enddate", enddate);
				jo.put("endtime", endtime);
				ja.add(jo);
			}
			json.put("topicList",ja);
			//获取议程附件
			JSONArray ja2 = new JSONArray();
			rs.executeSql("select * from Meeting_Topic_Attach where meetingid = "+meetingid+" order by xuhao,id");
			while(rs.next()){
				int fujian = Util.getIntValue(rs.getString("fujian"),0);
				docImageManager.resetParameter();
		        docImageManager.setDocid(fujian);
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
		          	JSONObject jo = new JSONObject();
					jo.put("fileid", docImagefileid);
					jo.put("filesize", docImagefileSizeStr);
					jo.put("filename", docImagefilename);
					ja2.add(jo);
		        }
			}
			json.put("topicAttatchList",ja2);
			status = 0;
		}else if("getTopicById".equals(operation)){
			String topicid = Util.null2String(fu.getParameter("topicid"));
			rs.executeSql("select * from Meeting_Topic where id ="+topicid);
			if(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				String subject = Util.null2String(rs.getString("subject"));
				String hrmids = Util.null2String(rs.getString("hrmids"));
				String xuhao = Util.null2String(rs.getString("xuhao"));
				String jcd = Util.null2String(rs.getString("jcd"));
				String startdate = Util.null2String(rs.getString("startdate"));
				String starttime = Util.null2String(rs.getString("starttime"));
				String enddate = Util.null2String(rs.getString("enddate"));
				String endtime = Util.null2String(rs.getString("endtime"));
				JSONObject jo = new JSONObject();
				jo.put("id", id);
				jo.put("subject", subject);
				jo.put("hrmids", MeetingUtilForYl.getUserNames(hrmids,rc));
				jo.put("xuhao", xuhao);
				jo.put("jcd", jcd);
				jo.put("startdate", startdate);
				jo.put("starttime", starttime);
				jo.put("enddate", enddate);
				jo.put("endtime", endtime);
				json.put("topic", jo);
				status = 0;
			}else{
				msg = "议程信息不存在";
			}
		}else if("overMeeting".equals(operation)){
			String meetingid = Util.null2String(fu.getParameter("meetingid"));
			rs.executeSql("select * from meeting where id = '"+meetingid+"'");
			if(rs.next()){
				String MeetingName = rs.getString("name");
				String hrmids = rs.getString("hrmmembers");//参会人员
				String meetingStatus = rs.getString("meetingStatus");
				String begindate = rs.getString("begindate");
				String begintime = rs.getString("begintime");
				String enddate = rs.getString("enddate");
				String endtime = rs.getString("endtime");
				//增加日志
				MeetingLog meetingLog = new MeetingLog();
				meetingLog.resetParameter();
				meetingLog.insSysLogInfo(user,Util.getIntValue(meetingid),MeetingName,"结束会议","303","2",1,Util.getIpAddr(request));
				RecordSet rs2 = new RecordSet();
				String currentDate = TimeUtil.getCurrentDateString();
				String currentTime = TimeUtil.getOnlyCurrentTimeString().substring(0,5);
				//获取会议成本和小时
				String[] costHour = MeetingUtilForYl.getCostHour(hrmids,meetingid,begindate,begintime,currentDate,currentTime);
				String cost = costHour[0],hour = costHour[1];
				StringBuffer sb = new StringBuffer();
				sb.append("update meeting set enddate='"+currentDate+"',endtime='"+currentTime+"'");
				sb.append(",cost='"+cost+"',xiaoshi='"+hour+"'");
				sb.append(" where id = "+meetingid);
				//System.out.println(sb.toString());
				rs2.executeSql(sb.toString());
				status = 0;
			}else{
				msg = "会议不存在";
			}
		}else if("cancelMeeting".equals(operation)){
			String meetingid = Util.null2String(fu.getParameter("meetingid"));
			rs.executeSql("select * from meeting where id = '"+meetingid+"'");
			if(rs.next()){
				RecordSet rs2 = new RecordSet();
				String MeetingName = Util.null2String(rs.getString("name"));
				String remindTypeNew = Util.null2String(rs.getString("remindTypeNew"));
				String hrmmembers = Util.null2String(rs.getString("hrmmembers"));
				String contacterN = Util.null2String(rs.getString("contacter"));
				String callerN = Util.null2String(rs.getString("caller"));
				String createrN = Util.null2String(rs.getString("creater"));
				String recorderN = Util.null2String(rs.getString("recorder"));
				String rOtherpersonnel = Util.null2String(rs.getString("otherpersonnel"));
				String rTempotherpersonnel = Util.null2String(rs.getString("tempotherpersonnel"));
				String rCcmeetingminutes = Util.null2String(rs.getString("ccmeetingminutes"));
				String rCcmeetingnotice = Util.null2String(rs.getString("ccmeetingnotice"));
				int meetingstatus = Util.getIntValue(rs.getString("meetingstatus"),0);
				int requestId = Util.getIntValue(rs.getString("requestId"),0);
				int repeattype = Util.getIntValue(rs.getString("repeattype"),0);
				int meetingtype1 = Util.getIntValue(rs.getString("meetingtype"),0);
				//增加日志
				MeetingLog meetingLog = new MeetingLog();
				meetingLog.resetParameter();
				meetingLog.insSysLogInfo(user,Util.getIntValue(meetingid),MeetingName,"取消会议","303","2",1,Util.getIpAddr(request));
				String currentDate = TimeUtil.getCurrentDateString();
				String currentTime = TimeUtil.getOnlyCurrentTimeString().substring(0,5);
				//发送流程提醒
				if(meetingstatus!=1){
					char flag = 2;
					String wfname="";
					String wfaccepter="";
					String wfremark="";
					wfname=Util.toMultiLangScreen("23269")+":"+MeetingName+"-"+user.getLastname()+"-"+currentDate;
					wfremark = wfname;
					rs2.executeProc("Meeting_Member2_SelectByType",meetingid+flag+"1");
					while(rs2.next()){
					   wfaccepter+=","+rs2.getString("memberid");
					}
					if(!"".equals(callerN) && (wfaccepter+",").indexOf(","+callerN+",") == -1){//主持人
						wfaccepter += ","+callerN;
					}
					if(!"".equals(contacterN) && (wfaccepter+",").indexOf(","+contacterN+",") == -1){//联系人
						wfaccepter += ","+contacterN;
					}
					wfaccepter = addUser(wfaccepter,recorderN);//记录人
					wfaccepter = addUser(wfaccepter,rOtherpersonnel);//其他参会人1
					wfaccepter = addUser(wfaccepter,rTempotherpersonnel);//其他参会人2
					wfaccepter = addUser(wfaccepter,rCcmeetingminutes);//会议纪要抄送人
					wfaccepter = addUser(wfaccepter,rCcmeetingnotice);//会议通知抄送人
					if(!"".equals(wfaccepter)){
						wfaccepter=wfaccepter.substring(1);
					}
				    SysRemindWorkflow.setMeetingSysRemind(wfname,Util.getIntValue(meetingid),Util.getIntValue(contacterN),wfaccepter,wfremark);
				}
				//更新会议状态
				rs2.executeSql("update meeting set cancel='1',meetingStatus=4,canceldate='"+currentDate+"',canceltime='"+currentTime+"' where id="+meetingid);
				//标识会议已经被取消
				rs2.executeSql("UPDATE Meeting_View_Status SET status = '2' WHERE meetingId = "+meetingid+"  AND userId <> "+userid);
				rs2.execute("select id from workplan where meetingId='"+meetingid+"'");
				weaver.WorkPlan.WorkPlanHandler wph = new weaver.WorkPlan.WorkPlanHandler();
				while(rs2.next()){
					wph.delete(rs2.getString("id"));
				}
				//待审批则删除相关流程
				if(1 == meetingstatus){	
		       		if(repeattype>0){//周期会议,查看周期会议审批流程
			    		rs2.executeSql("Select formid From Meeting_Type t1 join workflow_base t2 on t1.approver1=t2.id  where t1.approver1>0 and t1.ID ="+meetingtype1);
			    	}else{
			    		rs2.executeSql("Select formid From Meeting_Type t1 join workflow_base t2 on t1.approver=t2.id  where t1.approver>0 and t1.ID ="+meetingtype1);
			    	}
			   		if(rs2.next()){
			   			int fromid=rs2.getInt("formid");
			   		    if(requestId>0){
				   			MeetingWFUtil.deleteWF(requestId,meetingid,fromid);
			   		        rs2.executeSql("delete From workflow_currentoperator where requestid="+requestId);
			   		    }
			   		}
				}
			    MeetingInterval.deleteMeetingRepeat(meetingid);
			    //之前是正常会议,被取消后进行取消会议提醒
			    if(meetingstatus==2){
				    //MeetingRemindUtil.cancelMeeting(meetingid);
				    String toUsers = hrmmembers+","+callerN+","+rCcmeetingnotice;
			    	//MeetingUtilForYl.sendMsg(toUsers, "已取消:"+MeetingName, "/mobile/plugin/5/detail.jsp?id="+meetingid);
			    }
				status = 0;
			}else{
				msg = "会议不存在";
			}
		}else if("getMtType".equals(operation)){
			String sqlwhere = MeetingShareUtil.getTypeShareSql(user);
			//System.out.println("select * from Meeting_Type a where 1=1 "+sqlwhere+" order by a.id");
			rs.executeSql("select * from Meeting_Type a where 1=1 "+sqlwhere+" order by a.id");
			JSONArray ja = new JSONArray();
			while(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				String name = Util.null2String(rs.getString("name"));
				String isagenda = Util.null2String(rs.getString("isagenda"));
				JSONObject jo = new JSONObject();
				jo.put("id", id);
				jo.put("name", name);
				jo.put("isagenda", isagenda);
				ja.add(jo);
			}
			json.put("mtTypesList", ja);
			status = 0;
		}else if("getOutUsers".equals(operation)){
			rs.executeSql("select * from uf_meeting_out_hum where isclose = 1 and modedatacreater = "+userid+" order by id desc");
			JSONArray ja = new JSONArray();
			while(rs.next()){
				String outid = Util.null2String(rs.getString("id"));
				String name = Util.null2String(rs.getString("name"));
				String photo = Util.null2String(rs.getString("photo"));
				photo = MeetingUtilForYl.getUserImgForOut(photo);
				String sex = Util.null2String(rs.getString("sex"));
				if(sex.equals("0")){
					sex = "男";
				}else if(sex.equals("1")){
					sex = "女";
				}else {
					sex = "未知";
				}
				String company = Util.null2String(rs.getString("company"));
				String duties = Util.null2String(rs.getString("duties"));
				String mobilephone = Util.null2String(rs.getString("mobilephone"));
				JSONObject jo = new JSONObject();
				jo.put("id", outid);
				jo.put("name", name);
				jo.put("photo", photo);
				jo.put("sex", sex);
				jo.put("company", company);
				jo.put("duties", duties);
				jo.put("mobilephone", mobilephone);
				ja.add(jo);
			}
			json.put("outUsers", ja);
			status = 0;
		}else if("getCost".equals(operation)){
			String hrmmembers = Util.null2String(fu.getParameter("hrmmembers"));
			String begindate = Util.null2String(fu.getParameter("begindate"));
			String begintime = Util.null2String(fu.getParameter("begintime"));
			String enddate = Util.null2String(fu.getParameter("enddate"));
			String endtime = Util.null2String(fu.getParameter("endtime"));
			String cost = "",hour = "";
			if(!"".equals(begindate)&&!"".equals(begintime)&&!"".equals(enddate)&&!"".equals(endtime)){
				String[] costHour = MeetingUtilForYl.getCostHour(hrmmembers,"",begindate,begintime,enddate,endtime);
				cost = costHour[0];hour = costHour[1];
			}
			json.put("cost", cost);
			json.put("hour", hour);
			status = 0;
		}else if("getAddressList".equals(operation)){
			int type = Util.getIntValue(fu.getParameter("type"),1);
			String hrmmembers = Util.null2String(fu.getParameter("hrmmembers"));
			String begindate = Util.null2String(fu.getParameter("begindate"));
			String begintime = Util.null2String(fu.getParameter("begintime"));
			String enddate = Util.null2String(fu.getParameter("enddate"));
			String endtime = Util.null2String(fu.getParameter("endtime"));
			String caller = Util.null2String(fu.getParameter("caller"));
			String recorder = Util.null2String(fu.getParameter("recorder"));
			String othermembers = Util.null2String(fu.getParameter("othermembers"));
			String ccmeetingnotice = Util.null2String(fu.getParameter("ccmeetingnotice"));
			String ccmeetingminutes = Util.null2String(fu.getParameter("ccmeetingminutes"));
			if("".equals(begindate)){
				begindate = TimeUtil.getCurrentDateString();
			}
			if("".equals(enddate)){
				enddate = TimeUtil.getCurrentDateString();
			}
			if("".equals(begintime)){
				begintime = "00:00";
			}
			if("".equals(endtime)){
				endtime = "23:59";
			}
			String bdstr = begindate+" "+begintime;
			String edstr = enddate+" "+endtime;
			String bds = "",eds = "";
			if(!"oracle".equals(rs.getDBType())){
				bds = "(m.begindate+' '+m.begintime)";
				eds = "(m.enddate+' '+m.endtime)";
			}else{
				bds = "(m.begindate||' '||m.begintime)";
				eds = "(m.enddate||' '||m.endtime)";
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select a.id,a.name,a.subcompanyid,a.roomdesc,a.hrmid,a.humnum,");
			sb.append("case when a.subcompanyid = "+subcompanyid+" then 1 else 2 end msort,");
			sb.append("(select count(*) from meeting m where (m.meetingstatus = 2 or m.meetingstatus = 1) ");

			//','||m.address||','  like '%,'||to_char(a.id)||',%'
			sb.append(" and ','||m.address||','  like '%,'||to_char(a.id)||',%' and m.repeatType = 0");
			sb.append(" and (("+bds+" <='"+bdstr+"' and "+eds+" >='"+bdstr+"')");
			sb.append(" or ("+bds+">='"+bdstr+"' and "+bds+" <='"+edstr+"'))");
			sb.append(") as amount");
			sb.append(" from MeetingRoom a");
			sb.append(" where (a.status=1 or a.status is null ) ");
			if(type==2){//智能匹配 计算参会人数
				if(!"".equals(othermembers)||!"".equals(caller)||!"".equals(recorder)||!"".equals(hrmmembers)){
					int humCount = othermembers.split(",").length;
					//String humStr = caller+","+recorder+","+hrmmembers+","+ccmeetingnotice+","+ccmeetingminutes;
					String humStr = caller+","+recorder+","+hrmmembers;
					String tempHumStr = ","; 
					String[] humArray = humStr.split(",");
					for(int i=0;i<humArray.length;i++){
						String tempHumId = Util.null2String(humArray[i]);
						if(!"".equals(tempHumId)){
							if(tempHumStr.indexOf(","+tempHumId+",")==-1){
								tempHumStr += tempHumId+",";
								humCount++;
							}	
						}
					}
					sb.append(" and a.humnum >="+humCount);
				}
			}
			String sqlwhere = MeetingShareUtil.getRoomShareSql(user);//会议室共享SQL
			sb.append(sqlwhere);
			sb.append(" order by msort,a.id");
			//System.out.println(sb.toString());
			rs.executeSql(sb.toString());
			JSONArray ja = new JSONArray();
			SubCompanyComInfo sc = new SubCompanyComInfo();
			List<String> list=new ArrayList<String>();
			while(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				if(list.contains(id)){
				    continue;
				}
				list.add("id");
				String name = Util.null2String(rs.getString("name"));
				String subcompanyName = sc.getSubcompanyname(Util.null2String(rs.getString("subcompanyid")));
				String roomdesc = Util.null2String(rs.getString("roomdesc"));
				String hrmName = MeetingUtilForYl.getUserNames(Util.null2String(rs.getString("hrmid")),rc);
				String humnum = Util.null2String(rs.getString("humnum"));
				int count = Util.getIntValue(rs.getString("amount"),0);
				if(type!=2||count<=0){
					JSONObject jo = new JSONObject();
					jo.put("id", id);
					jo.put("name", name);
					jo.put("subcompanyName", subcompanyName);
					jo.put("roomdesc", roomdesc);
					jo.put("hrmName", hrmName);
					jo.put("humnum", humnum);
					jo.put("count", count);
					ja.add(jo);
				}
			}
			json.put("addressList", ja);
			status = 0;
		}else if("getQRCode".equals(operation)){
			int addressselect = Util.getIntValue(fu.getParameter("addressselect"),0);
			String address = Util.null2String(fu.getParameter("address"));
			String customizeAddress = Util.null2String(fu.getParameter("customizeAddress"));
			String codeContent = "";
			String fileBasePath = application.getRealPath("/");
			String extPath = "filesystem/weavernorth/qrfile/";
			String imgFilePath = "";
			String fileName = "";
			if(addressselect==1){
				fileName = "mt_address_"+address+".png";
				File extFile = new File(fileBasePath + extPath+fileName);
				if(extFile.exists()){
					imgFilePath = "/"+extPath + fileName;
				}
				codeContent = "/mobile/plugin/5/mtsignin.jsp?addressId="+address;
			}else{
				codeContent = "/mobile/plugin/5/mtsignin.jsp?addressName="+customizeAddress;
			}
			if(imgFilePath.equals("")){//不存在 则新生成
				codeContent = new String(codeContent.getBytes("UTF-8"), "ISO-8859-1");
				if(fileName.equals("")){
					fileName = UUID.randomUUID().toString().replace("-", "")+".png";
				}
				File filePath = new File(fileBasePath + extPath);
				if(!filePath.exists()){//不存在创建文件夹
					filePath.mkdirs();
				}
				File file = new File(fileBasePath + extPath + fileName);//创建图片文件对象
				QRCode qrCode = new QRCode();
				qrCode.encode(codeContent, file,"png", BarcodeFormat.QR_CODE, 500,500, null);//生成二维码图片
				imgFilePath = "/"+extPath + fileName;
			}
			json.put("imgFilePath",imgFilePath);
			status = 0;
		}else if("checkAddress".equals(operation)){
			String address = Util.null2String(fu.getParameter("address"));
			String a = Util.null2String(fu.getParameter("a"));
			String b = Util.null2String(fu.getParameter("b"));
			String c = Util.null2String(fu.getParameter("c"));
			String d = Util.null2String(fu.getParameter("d"));
			String meetingid = Util.null2String(fu.getParameter("meetingid"));
			if(!"".equals(address)&&!"".equals(a)&&!"".equals(b)&&!"".equals(c)&&!"".equals(d)){
				StringBuffer sb = new StringBuffer();
				String bdstr = a+" "+b;
				String edstr = c+" "+d;
				String bds = "",eds = "";
				if(!"oracle".equals(rs.getDBType())){
					bds = "(m.begindate+' '+m.begintime)";
					eds = "(m.enddate+' '+m.endtime)";
				}else{
					bds = "(m.begindate||' '||m.begintime)";
					eds = "(m.enddate||' '||m.endtime)";
				}
				//','||t1.address||','  like '%,'||to_char(t3.id)||',%'
				sb.append("select count(*) as amount from meeting m where (m.meetingstatus = 2 or m.meetingstatus = 1) ");
				sb.append(" and ','||m.address||','  like '%,"+address+",%' and m.repeatType = 0");
				sb.append(" and (("+bds+" <='"+bdstr+"' and "+eds+" >='"+bdstr+"')");
				sb.append(" or ("+bds+">='"+bdstr+"' and "+bds+" <='"+edstr+"'))");
				if(!"".equals(meetingid)){
					sb.append(" and m.id <> "+meetingid);
				}
				//System.out.println(sb.toString());
				new weaver.general.BaseBean().writeLog("sql"+sb.toString());
				rs.executeSql(sb.toString());
				int count = 0;
				if(rs.next()){
					count = Util.getIntValue(rs.getString(1),0);
				}
				json.put("count", count);
				status = 0;
			}else{
				msg = "会议室为空或者时间为空";
			}
		}else if("getChangeMeeting".equals(operation)){
			String bds = "";
			if(!"oracle".equals(rs.getDBType())){
				bds = "(m.begindate+' '+m.begintime)";
			}else{
				bds = "(m.begindate||' '||m.begintime)";
			}

			rs.executeSql("select m.*,r.name as roomname from meeting " +
					"m,MeetingRoom r"
					+" where ','||m.address||','  like '%,'||to_char(r.id)||',%' and m.creater = "+userid
					+" and m.meetingstatus in (1,2) and "+bds+">'"+TimeUtil.getCurrentTimeString()
					+"' order by m.enddate,m.endtime,m.id");
			JSONArray ja = new JSONArray();
			List<String> list=new ArrayList<String>();
			while(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				if(list.contains(id)){
				    continue;
				}
				list.add(id);
				String name = Util.null2String(rs.getString("name"));
				String roomname = Util.null2String(rs.getString("roomname"));
				String customizeAddress = Util.null2String(rs.getString("customizeAddress"));
				if("".equals(roomname)){
					roomname = customizeAddress;
				}
				String a = Util.null2String(rs.getString("begindate"));
				String b = Util.null2String(rs.getString("begintime"));
				String c = Util.null2String(rs.getString("enddate"));
				String d = Util.null2String(rs.getString("endtime"));
				JSONObject jo = new JSONObject();
				jo.put("id",id);
				jo.put("name",name);
				jo.put("roomname",roomname);
				jo.put("a",a);
				jo.put("b",b);
				jo.put("c",c);
				jo.put("d",d);
				ja.add(jo);
			}
			json.put("mtList",ja);
			status = 0;
		}else if("signMeeting".equals(operation)){
			String meetingid = Util.null2String(fu.getParameter("meetingid")); 
			StringBuffer sb = new StringBuffer();
			String signindate = TimeUtil.getCurrentDateString();
			String signintime = TimeUtil.getOnlyCurrentTimeString();
			sb.append("insert into uf_meetingSignIn (meetingid,members,signindate,signintime,status) values ");
			sb.append("("+meetingid+","+user.getUID()+",'"+signindate+"','"
					+signintime+"',0)");
			//System.out.println(sb.toString());
			boolean sqlFlag = rs.executeSql(sb.toString());
			if(sqlFlag){
				json.put("signindate",signindate);
				json.put("signintime",signintime);
				status = 0;
			}else{
				msg = "签到失败:SQL执行错误";
			}
		}else if("getSingList".equals(operation)){
			try{
				String meetingid = Util.null2String(fu.getParameter("meetingid")); 
				String showDate = Util.null2String(fu.getParameter("showDate")); 
				String begindate = Util.null2String(fu.getParameter("begindate")); 
				String enddate = Util.null2String(fu.getParameter("enddate"));
				String begintime = Util.null2String(fu.getParameter("begintime")); 
				String endtime = Util.null2String(fu.getParameter("endtime"));
				rs.executeSql("select m.memberid from Meeting_Member2 m where m.meetingid = "+meetingid+" order by m.id");
				JSONArray userList = new JSONArray();
				int hrmCount = rs.getCounts();
				int signCount = 0;
				while(rs.next()){
					String memberid = Util.null2String(rs.getString("memberid"));
					String userImg = MeetingUtilForYl.getUserImg(memberid,rc);
					String userName = rc.getLastname(memberid);
					String deptid = rc.getDepartmentID(memberid);
					String dept = dc.getDepartmentname(deptid);
					JSONObject u = new JSONObject();
					u.put("memberid", memberid);
					u.put("userImg", userImg);
					u.put("userName", userName);
					u.put("deptid", deptid);
					u.put("dept", dept);
					int ifSignToady = 1;//今天是否签到 1未签到 0已签到 2 迟到
					String nowSignDate = "";//今天的签到时间
					Map<String,JSONObject> map = new HashMap<String,JSONObject>();
					rs3.executeSql("select * from uf_meetingSignIn where meetingid = "+meetingid+" and members = '"+memberid
									+"' and signindate = '"+showDate+"'");
					if(rs3.next()){
						String signindate = Util.null2String(rs3.getString("signindate"));
						String signintime = Util.null2String(rs3.getString("signintime"));
						ifSignToady = 0;
						nowSignDate = signindate+" "+signintime;
						//判断是否迟到
						String compareDate = signindate+" "+begintime+":00";
						if(TimeUtil.timeInterval(compareDate,nowSignDate)>0){
							ifSignToady = 2;
						}
						signCount++;
						nowSignDate = signintime.substring(0,5);
					}
					u.put("nowSignDate", nowSignDate);
					u.put("ifSignToady", ifSignToady);
					if(ifSignToady==1){
						u.put("statusName", "未签到");
					}else{
						u.put("statusName", "已签到");
					}
					userList.add(u);
				}
				json.put("hrmCount", hrmCount);
				json.put("signCount", signCount);
				json.put("noSignCount", hrmCount-signCount);
				json.put("userList", userList);
				status = 0;
			}catch(Exception e){
				msg = "获取签到数据失败:"+e.getMessage();
			}
		}else if("getAddressMT".equals(operation)){
			String addressid = Util.null2String(fu.getParameter("addressid")); 
			String currentMonth = Util.null2String(fu.getParameter("currentMonth")); 
			int currentDay = Util.getIntValue(fu.getParameter("currentDay"),0);
			if(!"".equals(addressid)&&currentDay!=0){
				currentMonth = currentMonth.replace("年","-").replace("月","-");
				String selDate = currentMonth+currentDay;
				if(currentDay<10){
					selDate = currentMonth+"0"+currentDay;
				}
				rs.executeSql("select t1.*,t3.name as roomname from Meeting t1,MeetingRoom t3 "+
					"where  ','||t1.address||','  like '%,'||to_char(t3.id)||',%' and  ','||t1.address||','  like '%,"+addressid+",%'  and t1.beginDate <= '"+
					selDate+"' and t1.endDate >= '"+selDate+"' and (t1.cancel <> 1 or t1.cancel is null) order by t1.beginDate,t1.begintime,t1.id");
				JSONArray ja = new JSONArray();
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
				List<String> list=new ArrayList<String>();
				while(rs.next()){
					String id = Util.null2String(rs.getString("id"));
					if(list.contains(id)){
					    continue;
					}
					list.add(id);
					String name = Util.null2String(rs.getString("name"));
					String roomname = Util.null2String(rs.getString("roomname"));
					String customizeAddress = Util.null2String(rs.getString("customizeAddress"));
					if("".equals(roomname)){
						roomname = customizeAddress;
					}
					String beginDate = Util.null2String(rs.getString("beginDate"));
					String endDate = Util.null2String(rs.getString("endDate"));
					String begintime = Util.null2String(rs.getString("begintime"));
					String endtime = Util.null2String(rs.getString("endtime"));
					String isdecision = Util.null2String(rs.getString("isdecision"));//会议决议
					int meetingstatus = Util.getIntValue(rs.getString("meetingstatus"),0);//会议状态
					int creater=Util.getIntValue(rs.getString("creater"));//创建人
					int meetingover = 0;//会议进行状态 0已结束 1进行中  2未开始
					Date startDate = sdf.parse(beginDate+" "+begintime);
					Date endDate2 = sdf.parse(endDate+" "+endtime);
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
					JSONObject jo = new JSONObject();
					jo.put("id", id);
					jo.put("name", name);
					jo.put("roomname", roomname);
					jo.put("beginDate", beginDate);
					jo.put("endDate", endDate);
					jo.put("begintime", begintime);
					jo.put("endtime", endtime);
					jo.put("meetingover", meetingover);
					jo.put("create",rc.getLastname(creater+""));
					ja.add(jo);
				}
				json.put("meetings",ja);
				status = 0;
			}else{
				msg = "相关参数错误";
			}
		}else if("loadDecision".equals(operation)){
			String meetingid = Util.null2String(fu.getParameter("meetingid"));
			String sql = "select t.* from Meeting_Decision t where t.meetingid = "+meetingid+" order by coding";
			rs.executeSql(sql);
			JSONArray ja = new JSONArray();
			while(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				String subject = Util.null2String(rs.getString("subject"));
				String hrmids = Util.null2String(rs.getString("hrmid02"));
				String xuhao = Util.null2String(rs.getString("coding"));
				String remark = Util.null2String(rs.getString("remark"));
				JSONObject jo = new JSONObject();
				jo.put("id", id);
				jo.put("subject", subject);
				jo.put("hrmids", hrmids);
				jo.put("hrmspans", MeetingUtilForYl.getUserNames(hrmids, rc));
				jo.put("xuhao", xuhao);
				jo.put("remark", remark);
				ja.add(jo);
			}
			json.put("topicList",ja);
			status = 0;
		}else if("getDecisionById".equals(operation)){
			String topicid = Util.null2String(fu.getParameter("topicid"));
			rs.executeSql("select * from Meeting_Decision where id ="+topicid);
			if(rs.next()){
				String id = Util.null2String(rs.getString("id"));
				String subject = Util.null2String(rs.getString("subject"));
				String hrmids = Util.null2String(rs.getString("hrmid02"));
				String xuhao = Util.null2String(rs.getString("coding"));
				String remark = Util.null2String(rs.getString("remark"));
				JSONObject jo = new JSONObject();
				jo.put("id", id);
				jo.put("subject", subject);
				jo.put("hrmids", hrmids);
				jo.put("hrmspans", MeetingUtilForYl.getUserNames(hrmids, rc));
				jo.put("xuhao", xuhao);
				jo.put("remark", remark);
				json.put("topic", jo);
				status = 0;
			}else{
				msg = "议程信息不存在";
			}
		}else if("delayedMT".equals(operation)){
			String meetingid = Util.null2String(fu.getParameter("meetingid"));
			String enddate = Util.null2String(fu.getParameter("enddate"));
			if(!"".equals(enddate)){
				String[] e = enddate.split(" ");
				String[] costHour = MeetingUtilForYl.getCostHour("", meetingid, "", "",e[0],e[1]);
				rs.executeSql("update meeting set enddate = '"+e[0]+"',endtime = '"+e[1]
						+"',sfys = 2,cost='"+costHour[0]+"',xiaoshi='"+costHour[1]+"' where id = "+meetingid);
				status = 0;
			}else{
				msg = "延时时间不能为空";
			}
		}
	}catch(Exception e){
		e.printStackTrace();
		msg = "程序出现异常:"+e.getMessage();
	}
	json.put("status",status);
	json.put("msg",msg);
	//System.out.println(json.toString());
	out.print(json.toString());
%>
<%!
	private String getSql(String subcompanyid,User user,String beginDate,String endDate,int type){
		String masterNum = "0";
		String whereSql = ""; 
		whereSql += " or t1.id in ( ";
		whereSql += " select id from meeting mt ";	
		//判断当前人是否是议事规则管理员
		if (HrmUserVarify.checkUserRight("RulesOfProcedure:Headquarters", user)){//总部管理权限		
			masterNum = "1";
			whereSql += " where (mt.isparliament = 1 or mt.isparliament = 2)";
		}else if (HrmUserVarify.checkUserRight("RulesOfProcedure:Division", user)){//分部管理权限
			masterNum = "2";		
			if(!"".equals(subcompanyid)){//分部人员 使用分部id过滤
				whereSql += " where mt.isparliament = 2 and mt.subcompanyid = "+subcompanyid;
			}else{
				masterNum = "0";
			}		
		}
		whereSql += " and mt.meetingstatus = 2)";
		StringBuffer sb = new StringBuffer();
		sb.append(" select t1.*,t3.name as roomname");
		sb.append(" from Meeting t1, MeetingRoom t3,Meeting_ShareDetail t2");
		sb.append(" where ','||t1.address||','  like '%,'||to_char(t3.id)||',%' and t1.id = t2.meetingId and t1.repeatType = 0 and");
		// 判断是否添加议事规则查询条件
		if(!"0".equals(masterNum)){
			sb.append("(");
		}
		String allUser=MeetingShareUtil.getAllUser(user);
		sb.append(" ((t1.meetingStatus in (1, 3) and t2.userId in ("+allUser+") AND t2.shareLevel in (1,4))" );
		sb.append(" or (t1.meetingStatus = 0  AND t1.creater in ("+allUser+") AND (t2.userId in ("+allUser+")))");
		sb.append(" or (t1.meetingStatus in (2, 4) AND (t2.userId in ("+allUser+"))))");
		if(!"0".equals(masterNum)){
			sb.append(whereSql+")");
		}
		sb.append(" and (t1.cancel <> 1 or t1.cancel is null) ");//过滤取消的会议
		sb.append(" and t2.sharelevel <> 102 and t2.sharelevel <> 103 ");//过滤会议纪要抄送人
		if(type==1){//当月起始时间内所有会议
			sb.append(" and ((t1.beginDate <='"+beginDate+"' and t1.endDate >='"+beginDate+"')");
			sb.append(" or (t1.beginDate>='"+beginDate+"' and t1.beginDate <='"+endDate+"'))");
		}else{//查询当天会议
			sb.append(" and (t1.beginDate <= '"+beginDate+"' and t1.endDate >= '"+beginDate+"')");
		}
		sb.append(" order by t1.beginDate ,t1.begintime,t1.id");
		//System.out.println(sb.toString());
		return sb.toString();
	}
	
	private String addUser(String s1,String s2){
		if(s2!=null&&!"".equals(s2)){
			String temp[] = s2.split(",");
			if(temp.length>0){
				for(int i=0;i<temp.length;i++){
					String rHrmid = temp[i];
					if(!"".equals(rHrmid) && (s1+",").indexOf(","+rHrmid+",") == -1){
						s1 += ","+rHrmid;
					}
				}			 
			}
		}
		return s1;
	}
%>