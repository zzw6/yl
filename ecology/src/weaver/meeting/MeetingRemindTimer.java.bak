package weaver.meeting;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimerTask;

import weaver.conn.RecordSet;
import weaver.email.MailSend;
import weaver.file.Prop;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;

public class MeetingRemindTimer extends TimerTask {
	 
	//private static ResourceComInfo rc;
	
	private static BaseBean bb;
	
	static{
		try {
			//rc = new ResourceComInfo();
			bb = new BaseBean();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void run() {
		RecordSet rs = new RecordSet();
		RecordSet rs2 = new RecordSet();
		String bds = "",eds = "";
		if(!"oracle".equals(rs.getDBType())){
			bds = "(t1.begindate+' '+t1.begintime)";
			eds = "(t1.enddate+' '+t1.endtime)";
		}else{
			bds = "(t1.begindate||' '||t1.begintime)";
			eds = "(t1.enddate||' '||t1.endtime)";
		}
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		String nowDate = sdf.format(System.currentTimeMillis());
		//会议延时扫描
		int ifYsMeeting = Util.getIntValue(Prop.getPropValue("meetingforyl","ifYsMeeting"),0);
		if(ifYsMeeting==1){
			try{
				//bb.writeLog("==========会议扫描MeetingRemindTimer开始执行==========");
				//会议延时扫描
				String lastDate = sdf.format(System.currentTimeMillis()+15*60*1000);
				//bb.writeLog("nowDate=========="+nowDate);
				//bb.writeLog("lastDate=========="+lastDate);
				StringBuffer sb = new StringBuffer();
				sb.append("select t1.* from meeting t1 where t1.caller <> 21 and t1.roomtype = 1 and (t1.sfys is null or t1.sfys = '') ");
				sb.append("and t1.meetingstatus = 2 and t1.repeatType = 0 and (t1.cancel <> 1 or t1.cancel is null) ");
				sb.append("and "+eds+" <= '"+lastDate+"' and "+eds+" >= '"+nowDate+"'");
				//bb.writeLog("会议延时扫描SQL=========="+sb.toString());
				rs.executeSql(sb.toString());
				while(rs.next()){
					String id = Util.null2String(rs.getString("id"));
					String name = Util.null2String(rs.getString("name"));
					String enddate = Util.null2String(rs.getString("enddate"));
					String endtime = Util.null2String(rs.getString("endtime"));
					String caller = Util.null2String(rs.getString("caller"));
					Date date = sdf.parse(enddate+" "+endtime);
					long time = date.getTime()+10*60*1000;
					String timeLimit = sdf.format(time);
					bb.writeLog("会议:"+name+",ID:"+id+",符合延时推送条件,执行推送");
					String address = Util.null2String(rs.getString("address"));
 					if(!"".equals(address)){
						rs2.executeSql("select 1 from meeting t1 where ','||t1.address||','  like '%,"+address+",%'"
								+" and t1.repeatType = 0 and (t1.cancel <> 1 or t1.cancel is null) "
								+ " and ("+bds+" <='"+timeLimit+"' and "+eds+" >='"+timeLimit+"')");
						String tipMsg = "",url = "";
						if(rs2.next()){
							tipMsg = "您的["+name+"]会议离预定结束时间还有15分钟，因该会议室下一时段已被预定，请及时结束您的会议。";
							url = "/mobile/plugin/5/detail.jsp?id="+id;
						}else{
							tipMsg = "您的["+name+"]会议离预定结束时间还有15分钟，是否需要延时?";
							url = "/mobile/plugin/5/mtdelayed.jsp?id="+id;
						}
						rs2.executeSql("update meeting set sfys = 1 where id = "+id);//标记为已扫描过延迟
						MeetingUtilForYl.sendMsg(caller, tipMsg, url);
					}
				}
			}catch(Exception e){
				bb.writeLog("延时扫描程序执行异常===="+e.getMessage());
				e.printStackTrace();
			}
		}
		//会议签到扫描
		int ifCancelMeeting = Util.getIntValue(Prop.getPropValue("meetingforyl","ifCancelMeeting"),0);
		if(ifCancelMeeting==1){
			try{
				int tssj = 10,qxsj = 15;//提示时间 取消时间
				rs.executeSql("select * from uf_hyqd");
				if(rs.next()){
					tssj = Util.getIntValue(rs.getString("tssj"),10);
					qxsj = Util.getIntValue(rs.getString("qxsj"),15);
				}
				String tenDate = sdf.format(System.currentTimeMillis()-tssj*60*1000);//当前系统时间-10分钟
				String fifteenDate = sdf.format(System.currentTimeMillis()-qxsj*60*1000);//当前系统时间-15分钟
				StringBuffer sb = new StringBuffer();
				sb.append("select t1.* from meeting t1 where (t1.sfqd is null or t1.sfqd = '') ");
				sb.append("and t1.meetingstatus = 2 and t1.repeatType = 0 and (t1.cancel <> 1 or t1.cancel is null) ");
				sb.append("and "+bds+" = '"+tenDate+"' ");
				sb.append("and not exists (select 1 from uf_meetingSignIn s where s.meetingid = t1.id)");
				//bb.writeLog("10分钟签到SQL========\n"+sb.toString());
				rs.executeSql(sb.toString());
				while(rs.next()){
					String id = Util.null2String(rs.getString("id"));
					String name = Util.null2String(rs.getString("name"));
					String creater = Util.null2String(rs.getString("creater"));
					bb.writeLog("会议:"+name+",ID:"+id+",符合"+tssj+"分钟无人签到条件，执行推送提示即将取消会议");
					String content = "您召集的["+name+"]会议在开始"+tssj+"分钟内无人签到，系统将在5分钟后取消该会议并同步释放会议室";
					String url = "/mobile/plugin/5/detail.jsp?id="+id;
					rs2.executeSql("update meeting set sfqd = 1 where id = "+id);//标记为已扫描过签到
					MeetingUtilForYl.sendMsg(creater, content, url);
				}
				sb = new StringBuffer();
				sb.append("select t1.* from meeting t1 where ");
				sb.append("t1.meetingstatus = 2 and t1.repeatType = 0 and (t1.cancel <> 1 or t1.cancel is null) ");
				sb.append("and "+bds+" = '"+fifteenDate+"' ");
				sb.append("and not exists (select 1 from uf_meetingSignIn s where s.meetingid = t1.id)");
				//bb.writeLog("\n15分钟无人签到会议取消SQL========\n"+sb.toString());
				rs.executeSql(sb.toString());
				while(rs.next()){
					String id = Util.null2String(rs.getString("id"));
					String name = Util.null2String(rs.getString("name"));
					String caller = Util.null2String(rs.getString("caller"));
					String hrmmembers = Util.null2String(rs.getString("hrmmembers"));
					//String ccmeetingnotice = Util.null2String(rs.getString("ccmeetingnotice"));
					bb.writeLog("会议:"+name+",ID:"+id+",符合开始后"+qxsj+"分钟无人签到条件，自动取消会议并执行推送");
					String content = "您参加的["+name+"]会议因无人执行签到，系统已强制取消会议，请知晓！";
					String url = "/mobile/plugin/5/detail.jsp?id="+id;
					cancelMeeting(id,name);
					MeetingUtilForYl.sendMsg(hrmmembers+","+caller, content, url);
				}
			}catch(Exception e){
				bb.writeLog("签到扫描程序执行异常===="+e.getMessage());
				e.printStackTrace();
			}
		}
		//会议评估扫描
		int ifOverMeeting = Util.getIntValue(Prop.getPropValue("meetingforyl","ifOverMeeting"),0);
		if(ifOverMeeting==1){
			String scanDate = Util.null2String(Prop.getPropValue("meetingforyl","sacnDate"));
			if(scanDate.equals("")){
				scanDate = TimeUtil.getCurrentTimeString();
			}
			try{
				StringBuffer sb = new StringBuffer();
				sb.append("select t1.* from meeting t1 where (t1.sfjs is null or t1.sfjs = '') ");
				sb.append("and t1.meetingstatus = 2 and t1.repeatType = 0 and (t1.cancel <> 1 or t1.cancel is null) ");
				sb.append("and ((t1.meetingtype = 1 or t1.meetingtype = 21 or t1.meetingtype = 41 or t1.meetingtype = 42) ");
				sb.append(" or t1.isAppraise = 3)");
				sb.append("and "+bds+">'"+scanDate+"' and  "+eds+" <= '"+nowDate+"'");
				rs.executeSql(sb.toString());
				bb.writeLog("扫描会议结束发送评估提醒SQL===="+sb.toString());
				while(rs.next()){
					String id = Util.null2String(rs.getString("id"));
					rs2.executeSql("update meeting set sfjs = 1 where id = "+id);//标记为已扫描过评估
					String name = Util.null2String(rs.getString("name"));
					String hrmmembers = Util.null2String(rs.getString("hrmmembers"));
					bb.writeLog("会议:"+name+",ID:"+id+",符合会议结束提醒");
					
					String mailTitle = "邮件通知：【"+name+"】会议已结束，请您就该会议作出中肯的评价！";
					String mailContent = "以下是提醒内容，请点击查看详情：<br>";
					mailContent += "<a style=\"color:red\" target=\"_blank\" href=\"/mobile/plugin/5/appraiseJump.jsp?id="+
							id+"&type=2\">"+ mailTitle + "</a><br>";
					//String content = "您的["+name+"]会议已结束，请您就该会议作出中肯的评价！";
					//String url = "/mobile/plugin/5/appraise.jsp?id="+id;
					MailSend send = new MailSend();
					send.sendSysInternalMail("1", hrmmembers, null, mailTitle, mailContent);
					//MeetingUtilForYl.sendMsg(hrmmembers, content, url);
				}
			}catch(Exception e){
				bb.writeLog("会议结束扫描程序执行异常===="+e.getMessage());
				e.printStackTrace();
			}
		}
	}
	
	private void cancelMeeting(String meetingid,String name){
		RecordSet rs = new RecordSet();
		String currentDate = TimeUtil.getCurrentDateString();
		String currentTime = TimeUtil.getOnlyCurrentTimeString().substring(0,5);
		StringBuffer sb = new StringBuffer();
		sb.append("insert into MeetingLog (relatedid,relatedname,operatetype,operatedesc,operateitem,operateuserid,");
		sb.append("operatedate,operatetime,clientaddress,istemplate, operatesmalltype,operateusertype) values ");
		sb.append("('"+meetingid+"','"+name+"','2','无人签到取消会议','303',1,'"+currentDate+"','"+currentTime+"','127.0.0.1','0',1,'1')");
		bb.writeLog("执行会议取消SQL========"+sb.toString());
		rs.executeSql(sb.toString());
		//更新会议状态
		rs.executeSql("update meeting set cancel='1',meetingStatus=4,canceldate='"+currentDate+"',canceltime='"+currentTime+"' where id="+meetingid);
		//标识会议已经被取消
		rs.executeSql("UPDATE Meeting_View_Status SET status = '2' WHERE meetingId = "+meetingid);
		rs.execute("select id from workplan where meetingId='"+meetingid+"'");
		weaver.WorkPlan.WorkPlanHandler wph = new weaver.WorkPlan.WorkPlanHandler();
		while(rs.next()){
			wph.delete(rs.getString("id"));
		}
	}
	
}