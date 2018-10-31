package com.weavernorth.util;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;

public class TimeUtils extends BaseBean {

	public static void main(String[] ages) {
		TimeUtils t = new TimeUtils();
		String value = t.meetingTimeFormatting("09:30:00");
		System.out.println("value:" + value);
	}

	public String meetingTimeFormatting(String meetingTime) {
		String formattingStr = "";
		try {

			String timestrformart = "HH:mm";
			SimpleDateFormat SDF = new SimpleDateFormat(timestrformart);

			Calendar calendar = Calendar.getInstance();
			calendar.setTime(SDF.parse(meetingTime));
			formattingStr = SDF.format(calendar.getTime());
		} catch (Exception e) {
			formattingStr = "";
			this.writeLog("meetingTimeFormatting Exception" + e);
		}
		return formattingStr;
	}
	
	public String replaceRepStr(String str) {
		ArrayList list = Util.TokenizerString(str, ",");
		HashSet wt_personsHs = new HashSet(list);
		list.clear();
		list.addAll(wt_personsHs);
		String temp = "";
		if (list != null) {
			for (int i = 0; i < list.size(); i++) {
				if (temp.equals(""))
					temp = (String) list.get(i);
				else
					temp += "," + (String) list.get(i);
			}
		}
		return temp;
	}
	
	public String replaceStr(String str) {
		ArrayList list = Util.TokenizerString(str, ",");
		String temp = "";
		if (list != null) {
			for (int i = 0; i < list.size(); i++) {
				if (temp.equals(""))
					temp = (String) list.get(i);
				else
					temp += "," + (String) list.get(i);
			}
		}
		return temp;
	}
	
	public String getMeetingCost(String cost){
		return cost + "元";
	}
	
	public String getMeetingXiaoShi(String xiaoshi){
		return xiaoshi + "小时";
	}
	
	public int getDaysByYearMonth(int year, int month) {
		Calendar a = null;
		int t_Days = 0;
		try {
			a = Calendar.getInstance();
			a.set(Calendar.YEAR, year);
			a.set(Calendar.MONTH, month - 1);
			a.set(Calendar.DATE, 1);
			a.roll(Calendar.DATE, -1);
			t_Days = a.get(Calendar.DATE);
		} catch (Exception e) {
			this.writeLog("getDaysByYearMonth Exception" + e);
		}
		return t_Days;
	}
	
	public String computeMeetingCost(String hrmmembers,String begindate,String begintime,String enddate,String endtime){
		String returnValue = "";
		RecordSet rs = null;
		RecordSet rs1 = null;
		try{
			rs = new RecordSet();
			rs1 = new RecordSet();
			double cost = 0;
			//查询统计参与人员的权限
			String sql = "select seclevel,count(*) num from HrmResource "; 
			sql += "where id in ("+hrmmembers+") " ;
			sql += "group by seclevel ";
			//查询人员费用表
			rs.executeSql(sql);
			//查询标准计算费用
			while(rs.next()){
				int seclevel = rs.getInt("seclevel");
				int num = rs.getInt("num");
				float levelCost = 0;
				if(seclevel == 0){
					continue;
				}
				String getCostSql = "select * from uf_meeting_cost "; 
				getCostSql += "where aqjba < "+seclevel+" ";
				getCostSql += "and  aqjbb >= "+seclevel+" ";
				rs1.executeSql(getCostSql);
				if(rs1.next()){
					levelCost = rs1.getFloat("fybz");
					cost += levelCost * num;
				}
			}
			double hour = 0.00;
			if(!"".equals(begindate)&&!"".equals(begintime)&&!"".equals(enddate)&&!"".equals(endtime)){
				String fromdatetime = begindate+" "+begintime+":00";
				String todatetime = enddate+" "+endtime+":00";
				long timeInterval = TimeUtil.timeInterval(fromdatetime, todatetime);
				DecimalFormat df = new DecimalFormat("#.##");
				hour = Double.parseDouble(df.format((double)timeInterval/60/60));
				cost = cost*hour;
			}else{
				cost = 0;
			}
			returnValue = cost+","+hour;
		}catch(Exception e){
			this.writeLog("computeMeetingCost Exception" + e);
		}
		return returnValue;
	}
	
	 public String getCurrentTimeString() {
		 String timestrformart = "yyyy'-'MM'-'dd' 'HH:mm" ;
		 SimpleDateFormat SDF = new SimpleDateFormat(timestrformart) ;
		 Calendar calendar = Calendar.getInstance() ;
		 return SDF.format(calendar.getTime()) ;
	 }
}
