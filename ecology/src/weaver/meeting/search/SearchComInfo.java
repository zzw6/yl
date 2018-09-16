/**
Modified By Charoes Huang ,July 29,2004
Description: 加上对会议状态的搜索
*/
package weaver.meeting.search;

import java.util.*;
import weaver.conn.*;
import weaver.file.*;
import weaver.general.*;
import weaver.conn.RecordSet;
import weaver.general.Util;


public class SearchComInfo extends BaseBean{
	
	private boolean isinit=true;

	private String meetingtype = "";
	private int timeSag = 0;
	private int timeSagEnd=0;
	private String name="";
	private String address="";
	private String begindate="";
	private String enddate="";
	private String callers="";
	private String callersDep="";
	private String callersSub="";
	private String contacters="";
	private String contactersDep="";
	private String contactersSub="";
	private String creaters="";
	private String creatersDep="";
	private String creatersSub="";
	private String hrmids="";
	private String crmids="";
    private String projectid="";
	//added by Charoes Huang
    private String meetingstatus="";
    
    private String meetingStartdatefrom="";
    private String meetingStartdateto="";
    private String meetingEnddatefrom="";
    private String meetingEnddateto="";

	public SearchComInfo() throws Exception{
		if(isinit)
		{
			resetSearchInfo();
			isinit = false;
		}
	}

	public void resetSearchInfo(){

	 meetingtype = "";
	 name="";
	 address="";
	 begindate="";
	 enddate="";
	 callers="";
	 callersDep="";
	 callersSub="";
	 contacters="";
	 contactersDep="";
	 contactersSub="";
	 creaters="";
	 creatersDep="";
	 creatersSub="";
	 hrmids="";
	 crmids="";	
	 projectid="";
	 meetingstatus="";
	}

//
	public void setprojectid(String newValue){
		projectid = newValue;
		}	
	public String getprojectid(){
		return projectid;
	}
	
//	
	
	public void setmeetingtype(String newValue){
		meetingtype = newValue;
	}

	public String getmeetingtype(){
		return meetingtype;
	}
	public void setname(String newValue){
		name = newValue;
	}

	public String getname(){
		return name;
	}
	public void setaddress(String newValue){
		address = newValue;
	}

	public String getaddress(){
		return address;
	}
	
	public void setbegindate(String newValue){
		begindate = newValue;
	}

	public String getbegindate(){
		return begindate;
	}

	public void setenddate(String newValue){
		enddate = newValue;
	}

	public String getenddate(){
		return enddate;
	}

	public void setcallers(String newValue){
		callers = newValue;
	}

	public String getcallers(){
		return callers;
	}

	public void setcontacters(String newValue){
		contacters = newValue;
	}

	public String getcontacters(){
		return contacters;
	}

	public void setcreaters(String newValue){
		creaters = newValue;
	}

	public String getcreaters(){
		return creaters;
	}

	public void sethrmids(String newValue){
		hrmids = newValue;
	}

	public String gethrmids(){
		return hrmids;
	}

	public void setcrmids(String newValue){
		crmids = newValue;
	}

	public String getcrmids(){
		return crmids;
	}
	//added by Charoes Huang On July 29,2004
	public String getmeetingstatus(){
		return meetingstatus;
	}
	//added by Charoes Huang On July 29,2004
	public void setmeetingstatus(String value){
		meetingstatus = value;
	}

	
	public String FormatSQLSearch(int langid){
		String strResult = "";
		int ishead=0;
		if(!meetingtype.equals("")){
			ishead=1;
			strResult = " where t1.meetingtype in ("+meetingtype+") ";
		}
		if(!projectid.equals("")){
				if(ishead==0){
				ishead=1;
				strResult = " where t1.projectid ="+projectid;
			}else{
				
				strResult = " and t1.projectid ="+projectid;
				}
		}
		if(!name.equals("")){
	
			if(ishead==0){
				ishead=1;
				strResult = " where  t1.name like '%" + Util.fromScreen2(name,langid) + "%' ";
			}else{
				strResult += " and  t1.name like '%" + Util.fromScreen2(name,langid) + "%' ";
			}
		}
		if(!address.equals("")){
			RecordSet rs=new RecordSet();
			if(ishead==0){
				ishead=1;
				if((rs.getDBType()).equals("oracle")){
					strResult = " where ','||address||',' like '%,"+address+",%'";
				}else{
					strResult = " where ','+address+',' like '%,"+address+",%'";
				}
			}else{
				if((rs.getDBType()).equals("oracle")){
					strResult += " and  ','||address||',' like '%,"+address+",%'";
				}else{
					strResult += " and  ','+address+',' like '%,"+address+",%'";
				}
			}
		}		
		
		//开始时间
		if(timeSag > 0&&timeSag<6){
			String doclastmoddatefrom = TimeUtil.getDateByOption(""+timeSag,"0");
			String doclastmoddateto = TimeUtil.getDateByOption(""+timeSag,"1");
			if(!doclastmoddatefrom.equals("")){
				if(ishead==0){
					ishead=1;
					strResult = " where enddate >= '" + doclastmoddatefrom + "'";
				}else{
					strResult += " and enddate >= '" + doclastmoddatefrom + "'";
				}
			}
			
			if(!doclastmoddateto.equals("")){
				if(ishead==0){
					ishead=1;
					strResult = " where begindate <= '" + doclastmoddateto + "'";
				}else{
					strResult += " and begindate <= '" + doclastmoddateto + "'";
				}
			}
			
		}else{
			if(timeSag==6){//指定时间
				if(!"".equals(meetingStartdatefrom)){
					if(ishead==0){
						ishead=1;
						strResult = " where enddate >= '" + meetingStartdatefrom + "'";
					}else{
						strResult += " and enddate >= '" + meetingStartdatefrom + "'";
					}
				}
				
				if(!"".equals(meetingStartdateto)){
					if(ishead==0){
						ishead=1;
						strResult = " where begindate <= '" + meetingStartdateto + "'";
					}else{
						strResult += " and begindate <= '" + meetingStartdateto + "'";
					}
				}
				
			}
			
		}
//		//结束时间
//		if(timeSagEnd > 0&&timeSagEnd<6){
//			String doclastmoddatefrom = TimeUtil.getDateByOption(""+timeSagEnd,"0");
//			String doclastmoddateto = TimeUtil.getDateByOption(""+timeSagEnd,"1");
//			if(!doclastmoddatefrom.equals("")){
//				if(ishead==0){
//					ishead=1;
//					strResult = " where enddate >= '" + doclastmoddatefrom + "'";
//				}else{
//					strResult += " and enddate >= '" + doclastmoddatefrom + "'";
//				}
//			}
//			
//			if(!doclastmoddateto.equals("")){
//				if(ishead==0){
//					ishead=1;
//					strResult = " where enddate <= '" + doclastmoddateto + "'";
//				}else{
//					strResult += " and enddate <= '" + doclastmoddateto + "'";
//				}
//			}
//			
//		}else{
//			if(timeSagEnd==6){//指定时间
//				if(!"".equals(meetingEnddatefrom)){
//					if(ishead==0){
//						ishead=1;
//						strResult = " where enddate >= '" + meetingEnddatefrom + "'";
//					}else{
//						strResult += " and enddate >= '" + meetingEnddatefrom + "'";
//					}
//				}
//				
//				if(!"".equals(meetingEnddateto)){
//					if(ishead==0){
//						ishead=1;
//						strResult = " where enddate <= '" + meetingEnddateto + "'";
//					}else{
//						strResult += " and enddate <= '" + meetingEnddateto + "'";
//					}
//				}
//				
//			}
//			
//		}
		
		if(!callers.equals("")){
			if(ishead==0){
				ishead=1;
				strResult = " where t1.caller in (" + callers + ") ";
			}else{
				strResult += " and t1.caller in (" + callers + ") ";
			}
		}
				
		if(!callersDep.equals("")){
			if(ishead==0){
				ishead=1;
				strResult= (" where ( exists (select 1 from HrmResource where t1.caller = HrmResource.id and HrmResource.departmentid in( "+ callersDep +") " +
						" UNION select 1 from HrmResourceVirtual where t1.caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ callersDep +")" +
						")) ");
			}else{
				strResult += (" AND ( exists (select 1 from HrmResource where t1.caller = HrmResource.id and HrmResource.departmentid in( "+ callersDep +") " +
						" UNION select 1 from HrmResourceVirtual where t1.caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ callersDep +")" +
						")) ");
			}
		} 
		
		if(!callersSub.equals("")){
			if(ishead==0){
				ishead=1;
				strResult=(" where ( exists (select 1 from HrmResource where t1.caller = HrmResource.id and HrmResource.subcompanyid1 in("+ callersSub +")" +
						" UNION select 1 from HrmResourceVirtual where t1.caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ callersSub +")" +
						") ) ");
			}else{
				strResult +=(" AND ( exists (select 1 from HrmResource where t1.caller = HrmResource.id and HrmResource.subcompanyid1 in("+ callersSub +")" +
						" UNION select 1 from HrmResourceVirtual where t1.caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ callersSub +")" +
						") ) ");
			}
		}
		
		
		if(!contacters.equals("")){
			if(ishead==0){
				ishead=1;
				strResult = " where t1.contacter in (" + contacters + ") ";
			}else{
				strResult += " and t1.contacter in (" + contacters + ") ";
			}
		}
		if(!contactersDep.equals("")){
			if(ishead==0){
				ishead=1;
				strResult= (" where ( exists (select 1 from HrmResource where t1.contacter = HrmResource.id and HrmResource.departmentid in( "+ contactersDep +")" +
						" UNION select 1 from HrmResourceVirtual where t1.contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ contactersDep +")" +
						") ) ");
			}else{
				strResult += (" AND ( exists (select 1 from HrmResource where t1.contacter = HrmResource.id and HrmResource.departmentid in( "+ contactersDep +")" +
						" UNION select 1 from HrmResourceVirtual where t1.contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ contactersDep +")" +
						") ) ");
			}
		} 
		
		if(!contactersSub.equals("")){
			if(ishead==0){
				ishead=1;
				strResult=(" where ( exists (select 1 from HrmResource where t1.contacter = HrmResource.id and HrmResource.subcompanyid1 in("+ contactersSub +")" +
						" UNION select 1 from HrmResourceVirtual where t1.contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ contactersSub +")" +
						") ) ");
			}else{
				strResult +=(" AND ( exists (select 1 from HrmResource where t1.contacter = HrmResource.id and HrmResource.subcompanyid1 in("+ contactersSub +")" +
						" UNION select 1 from HrmResourceVirtual where t1.contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ contactersSub +")" +
						") ) ");
			}
		}
		if(!creaters.equals("")){
			if(ishead==0){
				ishead=1;
				strResult = " where t1.creater in (" + creaters + ") ";
			}else{
				strResult += " and t1.creater in (" + creaters + ") ";
			}
		}
		if(!creatersDep.equals("")){
			if(ishead==0){
				ishead=1;
				strResult= (" where ( exists (select 1 from HrmResource where t1.creater = HrmResource.id and HrmResource.departmentid in( "+ creatersDep +")" +
						" UNION select 1 from HrmResourceVirtual where t1.creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ creatersDep +")" +
						") ) ");
			}else{
				strResult += (" AND ( exists (select 1 from HrmResource where t1.creater = HrmResource.id and HrmResource.departmentid in( "+ creatersDep +")" +
						" UNION select 1 from HrmResourceVirtual where t1.creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ creatersDep +")" +
						") ) ");
			}
		} 
		
		if(!creatersSub.equals("")){
			if(ishead==0){
				ishead=1;
				strResult=(" where ( exists (select 1 from HrmResource where t1.creater = HrmResource.id and HrmResource.subcompanyid1 in("+ creatersSub +")" +
						" UNION select 1 from HrmResourceVirtual where t1.creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ creatersSub +")" +
						") ) ");
			}else{
				strResult +=(" AND ( exists (select 1 from HrmResource where t1.creater = HrmResource.id and HrmResource.subcompanyid1 in("+ creatersSub +")" +
						" UNION select 1 from HrmResourceVirtual where t1.creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ creatersSub +")" +
						") ) ");
			}
		}		
		String meetingids = "";
		String hrmidssql ="";
		
		if(!hrmids.equals("")){
			RecordSet rs = new RecordSet();
			hrmidssql = "select meetingid from Meeting_Member2 where membertype='1' and ( memberid in (" + hrmids + ") ";
			ArrayList arrayhrmids = Util.TokenizerString(hrmids,",");

			if(rs.getDBType().equals("oracle")){
				for(int i=0;i<arrayhrmids.size();i++){
					hrmidssql += " or concat(concat(',' , othermember) , ',')  like '%," +arrayhrmids.get(i)+ ",%' ";				
				}
			}else{
				for(int i=0;i<arrayhrmids.size();i++){
					hrmidssql += " or ','+othermember+',' like '%," +arrayhrmids.get(i)+ ",%' ";				
				}
			}

			hrmidssql += ") ";
			hrmidssql += " union select id  meetingid from Meeting where caller in (" + hrmids + ") or contacter in (" + hrmids + ") ";
			meetingids +=",-1";
			rs.executeSql(hrmidssql);
			//writeLog("hrmidssql:"+hrmidssql) ;
			while(rs.next()){
				meetingids += ","+rs.getString(1);
			}

		}
		if(!meetingids.equals("")){
			meetingids = meetingids.substring(1);
			if(ishead==0){
				ishead=1;
				strResult = " where t1.id in (" + meetingids + ") ";
			}
			else{
				strResult += " and t1.id in (" + meetingids + ") ";
			}
		}
		
		meetingids = "";
		String crmidssql ="";
		
		if(!crmids.equals("")){
			crmidssql = "select meetingid from Meeting_Member2 where membertype='2' and memberid in (" + crmids + ") ";
			crmidssql += " group by meetingid";
			meetingids +=",-1";
			RecordSet rs = new RecordSet();
			rs.executeSql(crmidssql);
			while(rs.next()){
				meetingids += ","+rs.getString(1);
			}
		}
		if(!meetingids.equals("")){
			meetingids = meetingids.substring(1);
			if(ishead==0){
				ishead=1;
				strResult = " where t1.id in (" + meetingids + ") ";
			}
			else{
				strResult += " and t1.id in (" + meetingids + ") ";
			}
		}
		
		if(!"".equals(meetingstatus)){
			if(ishead==0){
				ishead=1;
				strResult = " where t1.meetingstatus in (" + meetingstatus + ") ";
			}
			else{
				strResult += " and t1.meetingstatus in (" + meetingstatus+ ") ";
			}
		}

		return strResult;
	}

    public String FormatSQLSearch1(int langid){
		String strResult = "";
		int ishead=0;
		
		if(!meetingtype.equals("")){
			ishead=1;
			strResult = " where meetingtype in ("+meetingtype+") ";
		}
		if(!projectid.equals("")){
				if(ishead==0){
				ishead=1;
				strResult = " where projectid ="+projectid;
			}else{
				
				strResult = " and projectid ="+projectid;
				}
		}
		if(!name.equals("")){
	
			if(ishead==0){
				ishead=1;
				strResult = " where  name like '%" + Util.fromScreen2(name,langid) + "%' ";
			}else{
				strResult += " and  name like '%" + Util.fromScreen2(name,langid) + "%' ";
			}
		}

		if(!address.equals("")){
			RecordSet rs=new RecordSet();
			if(ishead==0){
				ishead=1;
				if((rs.getDBType()).equals("oracle")){
					strResult = " where  ','||address||',' like '%,"+address+",%'";
				}else{
					strResult = " where  ','+address+',' like '%,"+address+",%'";
				}
			}else{
				if((rs.getDBType()).equals("oracle")){
					strResult += " and  ','||address||',' like '%,"+address+",%'";
				}else{
					strResult += " and  ','+address+',' like '%,"+address+",%'";
				}
			}
		}

		//时间
		if(timeSag > 0&&timeSag<6){
			String doclastmoddatefrom = TimeUtil.getDateByOption(""+timeSag,"0");
			String doclastmoddateto = TimeUtil.getDateByOption(""+timeSag,"1");
			if(ishead==0){
				ishead=1;
				strResult = " where (enddate >= '" + doclastmoddatefrom + "' and begindate <= '" + doclastmoddateto + "') ";
			}else{
				strResult += " and (enddate >= '" + doclastmoddatefrom + "' and begindate <= '" + doclastmoddateto + "') ";
			}
		}else{
			if(timeSag==6){//指定时间
				if(!"".equals(meetingStartdatefrom)){
					if(ishead==0){
						ishead=1;
						strResult = " where enddate >= '" + meetingStartdatefrom + "'";
					}else{
						strResult += " and enddate >= '" + meetingStartdatefrom + "'";
					}
				}
				
				if(!"".equals(meetingStartdateto)){
					if(ishead==0){
						ishead=1;
						strResult = " where begindate <= '" + meetingStartdateto + "'";
					}else{
						strResult += " and begindate <= '" + meetingStartdateto + "'";
					}
				}
				
			}
			
		}
//		//结束时间
//		if(timeSagEnd > 0&&timeSagEnd<6){
//			String doclastmoddatefrom = TimeUtil.getDateByOption(""+timeSagEnd,"0");
//			String doclastmoddateto = TimeUtil.getDateByOption(""+timeSagEnd,"1");
//			if(!doclastmoddatefrom.equals("")){
//				if(ishead==0){
//					ishead=1;
//					strResult = " where enddate >= '" + doclastmoddatefrom + "'";
//				}else{
//					strResult += " and enddate >= '" + doclastmoddatefrom + "'";
//				}
//			}
//			
//			if(!doclastmoddateto.equals("")){
//				if(ishead==0){
//					ishead=1;
//					strResult = " where enddate <= '" + doclastmoddateto + "'";
//				}else{
//					strResult += " and enddate <= '" + doclastmoddateto + "'";
//				}
//			}
//			
//		}else{
//			if(timeSagEnd==6){//指定时间
//				if(!"".equals(meetingEnddatefrom)){
//					if(ishead==0){
//						ishead=1;
//						strResult = " where enddate >= '" + meetingEnddatefrom + "'";
//					}else{
//						strResult += " and enddate >= '" + meetingEnddatefrom + "'";
//					}
//				}
//				
//				if(!"".equals(meetingEnddateto)){
//					if(ishead==0){
//						ishead=1;
//						strResult = " where enddate <= '" + meetingEnddateto + "'";
//					}else{
//						strResult += " and enddate <= '" + meetingEnddateto + "'";
//					}
//				}
//				
//			}
//			
//		}
		
		if(!callers.equals("")){
			if(ishead==0){
				ishead=1;
				strResult = " where caller in (" + callers + ") ";
			}else{
				strResult += " and caller in (" + callers + ") ";
			}
		}
				
		if(!callersDep.equals("")){
			if(ishead==0){
				ishead=1;
				strResult= (" where ( exists (select 1 from HrmResource where caller = HrmResource.id and HrmResource.departmentid in( "+ callersDep +")" +
						" UNION select 1 from HrmResourceVirtual where caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ callersDep +")" +
						") ) ");
			}else{
				strResult += (" AND ( exists (select 1 from HrmResource where caller = HrmResource.id and HrmResource.departmentid in( "+ callersDep +")" +
						" UNION select 1 from HrmResourceVirtual where caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ callersDep +")" +
						") ) ");
			}
		} 
		
		if(!callersSub.equals("")){
			if(ishead==0){
				ishead=1;
				strResult=(" where ( exists (select 1 from HrmResource where caller = HrmResource.id and HrmResource.subcompanyid1 in("+ callersSub +")" +
						" UNION select 1 from HrmResourceVirtual where caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ callersSub +")" +
						") ) ");
			}else{
				strResult +=(" AND ( exists (select 1 from HrmResource where caller = HrmResource.id and HrmResource.subcompanyid1 in("+ callersSub +")" +
						" UNION select 1 from HrmResourceVirtual where caller = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ callersSub +")" +
						") ) ");
			}
		}
		
		
		if(!contacters.equals("")){
			if(ishead==0){
				ishead=1;
				strResult = " where contacter in (" + contacters + ") ";
			}else{
				strResult += " and contacter in (" + contacters + ") ";
			}
		}
		if(!contactersDep.equals("")){
			if(ishead==0){
				ishead=1;
				strResult= (" where ( exists (select 1 from HrmResource where contacter = HrmResource.id and HrmResource.departmentid in( "+ contactersDep +")" +
						" UNION select 1 from HrmResourceVirtual where contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ contactersDep +")" +
						") ) ");
			}else{
				strResult += (" AND ( exists (select 1 from HrmResource where contacter = HrmResource.id and HrmResource.departmentid in( "+ contactersDep +")" +
						" UNION select 1 from HrmResourceVirtual where contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ contactersDep +")" +
						") ) ");
			}
		} 
		
		if(!contactersSub.equals("")){
			if(ishead==0){
				ishead=1;
				strResult=(" where ( exists (select 1 from HrmResource where contacter = HrmResource.id and HrmResource.subcompanyid1 in("+ contactersSub +")" +
						" UNION select 1 from HrmResourceVirtual where contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ contactersSub +")" +
						") ) ");
			}else{
				strResult +=(" AND ( exists (select 1 from HrmResource where contacter = HrmResource.id and HrmResource.subcompanyid1 in("+ contactersSub +")" +
						" UNION select 1 from HrmResourceVirtual where contacter = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ contactersSub +")" +
						") ) ");
			}
		}
		if(!creaters.equals("")){
			if(ishead==0){
				ishead=1;
				strResult = " where creater in (" + creaters + ") ";
			}else{
				strResult += " and creater in (" + creaters + ") ";
			}
		}
		if(!creatersDep.equals("")){
			if(ishead==0){
				ishead=1;
				strResult= (" where ( exists (select 1 from HrmResource where creater = HrmResource.id and HrmResource.departmentid in( "+ creatersDep +")" +
						" UNION select 1 from HrmResourceVirtual where creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ creatersDep +")" +
						") ) ");
			}else{
				strResult += (" AND ( exists (select 1 from HrmResource where creater = HrmResource.id and HrmResource.departmentid in( "+ creatersDep +")" +
						" UNION select 1 from HrmResourceVirtual where creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.departmentid in( "+ creatersDep +")" +
						") ) ");
			}
		} 
		
		if(!creatersSub.equals("")){
			if(ishead==0){
				ishead=1;
				strResult=(" where ( exists (select 1 from HrmResource where creater = HrmResource.id and HrmResource.subcompanyid1 in("+ creatersSub +")" +
						" UNION select 1 from HrmResourceVirtual where creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ creatersSub +")" +
						") ) ");
			}else{
				strResult +=(" AND ( exists (select 1 from HrmResource where creater = HrmResource.id and HrmResource.subcompanyid1 in("+ creatersSub +")" +
						" UNION select 1 from HrmResourceVirtual where creater = HrmResourceVirtual.resourceid and HrmResourceVirtual.subcompanyid in( "+ creatersSub +")" +
						") ) ");
			}
		}	
				
		String meetingids = "";
		String hrmidssql ="";
		
		if(!hrmids.equals("")){
			RecordSet rs = new RecordSet();
			hrmidssql = "select meetingid from Meeting_Member2 where membertype='1' and ( memberid in (" + hrmids + ") ";
			ArrayList arrayhrmids = Util.TokenizerString(hrmids,",");

			if(rs.getDBType().equals("oracle")){
				for(int i=0;i<arrayhrmids.size();i++){
					hrmidssql += " or concat(concat(',' , othermember) , ',')  like '%," +arrayhrmids.get(i)+ ",%' ";				
				}
			}else{
				for(int i=0;i<arrayhrmids.size();i++){
					hrmidssql += " or ','+othermember+',' like '%," +arrayhrmids.get(i)+ ",%' ";				
				}
			}

			hrmidssql += ") ";
			hrmidssql += " union select id  meetingid from Meeting where caller in (" + hrmids + ") or contacter in (" + hrmids + ") ";
			meetingids +=",-1";
			rs.executeSql(hrmidssql);
			//writeLog("hrmidssql:"+hrmidssql) ;
			while(rs.next()){
				meetingids += ","+rs.getString(1);
			}

		}
		if(!meetingids.equals("")){
			meetingids = meetingids.substring(1);
			if(ishead==0){
				ishead=1;
				strResult = " where id in (" + meetingids + ") ";
			}
			else{
				strResult += " and id in (" + meetingids + ") ";
			}
		}
		
		meetingids = "";
		String crmidssql ="";
		
		if(!crmids.equals("")){
			crmidssql = "select meetingid from Meeting_Member2 where membertype='2' and memberid in (" + crmids + ") ";
			crmidssql += " group by meetingid";
			meetingids +=",-1";
			RecordSet rs = new RecordSet();
			rs.executeSql(crmidssql);
			while(rs.next()){
				meetingids += ","+rs.getString(1);
			}
		}
		if(!meetingids.equals("")){
			meetingids = meetingids.substring(1);
			if(ishead==0){
				ishead=1;
				strResult = " where id in (" + meetingids + ") ";
			}
			else{
				strResult += " and id in (" + meetingids + ") ";
			}
		}
		
		if(!"".equals(meetingstatus)){
			if(ishead==0){
				ishead=1;
				strResult = " where meetingstatus in (" + meetingstatus + ") ";
			}
			else{
				strResult += " and meetingstatus in (" + meetingstatus+ ") ";
			}
		}

		return strResult;
	}

	public int getTimeSag() {
		return timeSag;
	}

	public void setTimeSag(int timeSag) {
		this.timeSag = timeSag;
	}

	public String getCallersDep() {
		return callersDep;
	}

	public void setCallersDep(String callersDep) {
		this.callersDep = callersDep;
	}

	public String getCallersSub() {
		return callersSub;
	}

	public void setCallersSub(String callersSub) {
		this.callersSub = callersSub;
	}

	public String getContactersDep() {
		return contactersDep;
	}

	public void setContactersDep(String contactersDep) {
		this.contactersDep = contactersDep;
	}

	public String getContactersSub() {
		return contactersSub;
	}

	public void setContactersSub(String contactersSub) {
		this.contactersSub = contactersSub;
	}

	public String getCreatersDep() {
		return creatersDep;
	}

	public void setCreatersDep(String creatersDep) {
		this.creatersDep = creatersDep;
	}

	public String getCreatersSub() {
		return creatersSub;
	}

	public void setCreatersSub(String creatersSub) {
		this.creatersSub = creatersSub;
	}

	public int getTimeSagEnd() {
		return timeSagEnd;
	}

	public void setTimeSagEnd(int timeSagEnd) {
		this.timeSagEnd = timeSagEnd;
	}

	public String getMeetingStartdatefrom() {
		return meetingStartdatefrom;
	}

	public void setMeetingStartdatefrom(String meetingStartdatefrom) {
		this.meetingStartdatefrom = meetingStartdatefrom;
	}

	public String getMeetingStartdateto() {
		return meetingStartdateto;
	}

	public void setMeetingStartdateto(String meetingStartdateto) {
		this.meetingStartdateto = meetingStartdateto;
	}

	public String getMeetingEnddatefrom() {
		return meetingEnddatefrom;
	}

	public void setMeetingEnddatefrom(String meetingEnddatefrom) {
		this.meetingEnddatefrom = meetingEnddatefrom;
	}

	public String getMeetingEnddateto() {
		return meetingEnddateto;
	}

	public void setMeetingEnddateto(String meetingEnddateto) {
		this.meetingEnddateto = meetingEnddateto;
	}
	
}