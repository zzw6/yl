package weaver.meeting.remind;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.meeting.defined.MeetingFieldComInfo;
import weaver.meeting.defined.MeetingFieldManager;

/**
 * @author HuangGuanGuan
 * Jan 21, 2015
 * 会议提醒帮助类
 */
public class MeetingRemindUtil {
	 
	private static IMeetingRemind getRemindObject(String classname){
		IMeetingRemind obj=null;
		if(classname!=null&&!"".equals(classname)){
			try {
				obj=(IMeetingRemind)Class.forName(classname).newInstance();
			} catch (InstantiationException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		return obj;
	}
	
	/**
	 * 立即提醒
	 * @param meetingid
	 * @param mode
	 */
	public static void remindImmediately(String meetingid,String mode,String touser){
		BaseBean bb = new BaseBean();
		try {
			if(mode==null||"".equals(mode)) mode="create";
			if(meetingid!=null&&!"".equals(meetingid)){
				RecordSet rs=new RecordSet();
				//正常提醒时,会议状态是正常状态
				rs.execute("select * from meeting where  (cancel <> '1' or cancel is null) and meetingstatus = 2 and id="+meetingid);
				if(rs.next()){
					String remindType=rs.getString("remindTypeNew");
					RecordSet rs1=new RecordSet();
					RecordSet rs2=new RecordSet();
					IMeetingRemind  remind=null;
					Set<String> hrmids=new HashSet<String>();
					if(touser==null||"".equals(touser)){//没有传入发送者
						touser="";
			    	    String sql="select distinct membermanager from Meeting_Member2 where (isattend <> '2' or isattend is null) and meetingid="+meetingid;
			    	    rs2.executeSql(sql);
			    		while(rs2.next()){
			    			hrmids.add(rs2.getString(1));
			    		}
					}else{
						StringTokenizer sthrmid = new StringTokenizer(touser, ",");
				        while (sthrmid.hasMoreTokens()) {
				            String id = sthrmid.nextToken();
				            if(id!=null&&!"".equals(id)){
				            	hrmids.add(id);
				            }
				        }
					}
					String currentRemindType="";
					//处理前后逗号,防止异常
					if(remindType.startsWith(",")){
						remindType=remindType.substring(1);
					}
					if(remindType.endsWith(",")){
						remindType=remindType.substring(0,remindType.length()-1);
					}
					if(!"".equals(remindType)){
						rs1.execute("select * from meeting_remind_type where id in("+remindType+")");
						MeetingFieldManager mfm=new MeetingFieldManager(1); 
						List<String> templateList = mfm.getTemplateField();
						MeetingFieldComInfo mfComInfo=new MeetingFieldComInfo();
						while(rs1.next()){
							String title="";
							String msg="";
							boolean hastitle="1".equals(rs1.getString("hastitle"));
							currentRemindType=rs1.getString("id");
							remind=getRemindObject(rs1.getString("clazzname"));
							if(remind!=null){
								rs2.execute("select title,body from meeting_remind_template where type="+currentRemindType+" and modetype='"+mode+"'");
								if(rs2.next()){
									title=rs2.getString("title");
									msg=rs2.getString("body");
								}else{
									if(!"create".equals(mode)){
										rs2.execute("select title,body from meeting_remind_template where type="+currentRemindType+" and modetype='create'");
										if(rs2.next()){
											title=rs2.getString("title");
											msg=rs2.getString("body");
										}
									}
								}
								if(!"".equals(msg)){//找到模板
									//替换模板参数
									for(String fieldid:templateList){
										String fieldname = mfComInfo.getFieldname(fieldid);
										String fieldValue = rs.getString(fieldname);
										int fieldHtmlType = Util.getIntValue(mfComInfo.getFieldhtmltype(fieldid));
										int fieldType = Util.getIntValue(mfComInfo.getFieldType(fieldid));
										fieldValue=mfm.getRemindFieldvalue(Util.getIntValue(fieldid),fieldHtmlType, fieldType,fieldValue,7);
										msg=msg.replace("#["+fieldname+"]", fieldValue);
										if(hastitle){
											title=title.replace("#["+fieldname+"]", fieldValue);
										}
										if(msg.indexOf("#[")==-1 && title.indexOf("#[")==-1) break; //没有参数时提前结束循环
									}
									remind.sendRemind(hrmids,title, msg);
								}
							}
						}
					}
				}	
			}
		} catch (Exception e) {
			bb.writeLog("remindImmediately Exception -- " + e);
		}
	}
	
	/**
	 * 用来向定时提醒表插入数据
	 * @param meetingid
	 * @param time
	 * @param mode
	 */
	public static void remindAtTime(String meetingid,String time,String mode){
		RecordSet rs=new RecordSet();
		rs.execute("insert into meeting_remindNew(meeting,remindTime,modetype) values("+meetingid+",'"+time+"','"+mode+"')");
	}

	/**
	 * 取消会议时的立即提醒
	 * @param meetingid
	 * @param remindType
	 */
	public static void cancelMeeting(String meetingid){
		try {
			if(meetingid!=null&&!"".equals(meetingid)){
				RecordSet rs=new RecordSet();
				//正常提醒时,会议状态是正常状态
				rs.execute("select * from meeting where  cancel = '1' and meetingstatus = 4 and id="+meetingid);
				if(rs.next()){
					String remindType=rs.getString("remindTypeNew");
					RecordSet rs1=new RecordSet();
					RecordSet rs2=new RecordSet();
					IMeetingRemind  remind=null;
					Set<String> hrmids=new HashSet<String>();
		    	    String sql="select distinct membermanager from Meeting_Member2 where (isattend <> '2' or isattend is null) and meetingid="+meetingid;
		    	    rs2.executeSql(sql);
		    		while(rs2.next()){
		    			hrmids.add(rs2.getString(1));
		    		}
					String currentRemindType="";
					//处理前后逗号,防止异常
					if(remindType.startsWith(",")){
						remindType=remindType.substring(1);
					}
					if(remindType.endsWith(",")){
						remindType=remindType.substring(0,remindType.length()-1);
					}
					if(!"".equals(remindType)){
						rs1.execute("select * from meeting_remind_type where id in("+remindType+")");
						MeetingFieldManager mfm=new MeetingFieldManager(1); 
						List<String> templateList = mfm.getTemplateField();
						MeetingFieldComInfo mfComInfo=new MeetingFieldComInfo();
						while(rs1.next()){
							String title="";
							String msg="";
							boolean hastitle="1".equals(rs1.getString("hastitle"));
							currentRemindType=rs1.getString("id");
							remind=getRemindObject(rs1.getString("clazzname"));
							if(remind!=null){
								rs2.execute("select title,body from meeting_remind_template where type="+currentRemindType+" and modetype='cancel'");
								if(rs2.next()){
									title=rs2.getString("title");
									msg=rs2.getString("body");
								}
								if(!"".equals(msg)){//找到模板
									//替换模板参数
									for(String fieldid:templateList){
										String fieldname = mfComInfo.getFieldname(fieldid);
										String fieldValue = rs.getString(fieldname);
										int fieldHtmlType = Util.getIntValue(mfComInfo.getFieldhtmltype(fieldid));
										int fieldType = Util.getIntValue(mfComInfo.getFieldType(fieldid));
										fieldValue=mfm.getRemindFieldvalue(Util.getIntValue(fieldid),fieldHtmlType, fieldType,fieldValue,7);
										msg=msg.replace("#["+fieldname+"]", fieldValue);
										if(hastitle){
											title=title.replace("#["+fieldname+"]", fieldValue);
										}
										if(msg.indexOf("#[")==-1 && title.indexOf("#[")==-1) break; //没有参数时提前结束循环
									}
									remind.sendRemind(hrmids,title, msg);
								}
							}
						}
					}
				}	
			}
		} catch (Exception e) {
			 
		}
	}
	
	/**
	 * 回执提醒其他参会人员
	 * @param meetingid
	 * @param remindType
	 * @param touser 必须指定其他人员
	 */
	public static void remindReceipt(String meetingid,String touser){
		if(touser!=null&&!"".equals(touser)){
			remindImmediately(meetingid, null, touser);
		}
	}
	
}
