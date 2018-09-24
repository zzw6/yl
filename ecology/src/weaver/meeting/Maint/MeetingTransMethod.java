package weaver.meeting.Maint;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.weavernorth.util.TimeUtils;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import weaver.conn.RecordSet;
import weaver.crm.Maint.CustomerInfoComInfo;
import weaver.docs.category.CategoryUtil;
import weaver.docs.category.MainCategoryComInfo;
import weaver.docs.category.SecCategoryComInfo;
import weaver.docs.category.SubCategoryComInfo;
import weaver.hrm.company.DepartmentComInfo;
import weaver.hrm.company.SubCompanyComInfo;
import weaver.hrm.resource.ResourceComInfo;
import weaver.hrm.roles.RolesComInfo;
import weaver.hrm.User;
import weaver.proj.Maint.ProjectInfoComInfo;
import weaver.systeminfo.SystemEnv;
import weaver.systeminfo.systemright.CheckSubCompanyRight;
import weaver.general.Util;

/**
 * 会议监控转换
 * User: mackjoe
 * Date: 2006-3-27
 * Time: 15:28:24
 */
public class MeetingTransMethod {
    public MeetingTransMethod() {
    }
    
    /**
     * 获取目录名称
     * @param category
     * @return
     * @throws Exception
     */
    public String getCategorypath(String category)throws Exception{
    	String categorypath = "";
    	if(!category.equals("")){
            String[] categoryArr = Util.TokenizerString2(category,",");
            categorypath=CategoryUtil.getCategoryPath(Util.getIntValue(categoryArr[categoryArr.length-1]));
            //categorypath += "/"+(new MainCategoryComInfo().getMainCategoryname(categoryArr[0]));
            //categorypath += "/"+(new SubCategoryComInfo().getSubCategoryname(categoryArr[1]));
            //categorypath += "/"+(new SecCategoryComInfo().getSecCategoryname(categoryArr[2]));
        }
    	return categorypath;
    }
    
      
    public List checkOperate(String id, String cnt){
    	List edList = new ArrayList();
    	int count = Util.getIntValue(cnt, 1);
    	for(int i = 0; i < count; i++){
    		edList.add("true");
    	}
    	
    	return edList;
    }  
    
    
    /**
     * 会议室共享范围处理权限
     * @param id
     * @param para
     * @return
     */
    public List checkRoomPrmOperate(String id){
    	List edList = new ArrayList();
    	
    	//删除
    	edList.add("true");
    	
    	return edList;
    }
    
    /**
     * 获取召集人类型
     * @param type1
     * @return
     * @throws Exception
     */
    public String getMeetingRepeatType(String type1, String para)throws Exception{
    	
    	int lang = Util.getIntValue(para, 7) ;
    	switch(Util.getIntValue(type1)){
    	case 1:
    		//2:部门安全级别
    		return SystemEnv.getHtmlLabelName(25895,lang);
    	case 2:
    		//3:角色安全级别
    		return SystemEnv.getHtmlLabelName(25896,lang);
    	case 3:
    		//4:所有人安全级别
    		return SystemEnv.getHtmlLabelName(25897,lang);
    	default:
	    	//5:分部安全级别
	    	return SystemEnv.getHtmlLabelName(32872,lang);
    	}
    }
    
    /**
     * 获取召集人类型
     * @param type1
     * @return
     * @throws Exception
     */
    public String getMeetingCallertype(String type1, String para)throws Exception{
    	
    	int lang = Util.getIntValue(para, 7) ;
    	
    	switch(Util.getIntValue(type1)){
    	case 1:
    		//1:人力资源
	    	return SystemEnv.getHtmlLabelName(179,lang);
    	case 2:
    		//2:部门安全级别
    		return SystemEnv.getHtmlLabelName(124,lang);
    	case 3:
    		//3:角色安全级别
    		return SystemEnv.getHtmlLabelName(122,lang);
    	case 4:
    		//4:所有人安全级别
    		return SystemEnv.getHtmlLabelName(1340,lang);
    	case 5:
	    	//5:分部安全级别
	    	return SystemEnv.getHtmlLabelName(141,lang);
    	}
    	return "";
    }
    
    /**
     * 获取安全级别
     * @param type
     * @param para
     * @return
     * @throws Exception
     */
    public String getMeetingCallerlevel(String type, String para )throws Exception{
    	List parameterList = Util.TokenizerString(para, "+");
    	int id1 = -1;
    	int id2 = -1;
    	switch(Util.getIntValue(type)){
    	case 1:
    		//1:人力资源
    		return "";
    	case 2:
    		//2:部门安全级别
    	case 3:
    		//3:角色安全级别
    	case 4:
    		//4:所有人安全级别
    	case 5:
    		//5:分部安全级别
    		id1 = 0;
    		id2 = 1;
    		break;
    	}
    	String level = "";
    	if( id1 != -1 && id2 != -1 && parameterList != null ){
    		level = (parameterList.get(id1) == null?"":parameterList.get(id1).toString());
    		if(parameterList.size() > 1){
	    		String maxlvl = (parameterList.get(id2) == null?"":parameterList.get(id2).toString());
	    		if(!"".equals(maxlvl)){
	    			level += "-"+maxlvl;
	    		}
    		}
    	}
    	return level;
    }
    
    /**
     * 获取会议召集人的对象
     * @param type
     * @param para
     * @return
     * @throws Exception
     */
    public String getMeetingCallerObj(String type, String para )throws Exception{
    	List parameterList = Util.TokenizerString(para, "+");
    	if(parameterList != null && parameterList.size() > 0){
    		String id = "";
	    	switch(Util.getIntValue(type)){
	    	case 1:
	    		//1:人力资源
	    		id = parameterList.get(2) == null?"":parameterList.get(2).toString();
	    		ResourceComInfo rsc = new ResourceComInfo();
		    	return rsc.getLastname(id);
	    		
	    	case 2:
	    		//2:部门安全级别
	    		id = parameterList.get(0) == null?"":parameterList.get(0).toString();
	    		DepartmentComInfo dept = new DepartmentComInfo();
	    		return dept.getDepartmentname(id);
	    	case 3:
	    		//2:角色
	    		id = parameterList.get(3) == null?"":parameterList.get(3).toString();
	    		int rolelevel = Util.getIntValue(parameterList.get(4) == null?"-1":parameterList.get(4).toString()) ;
	    		int lang = Util.getIntValue(parameterList.get(5) == null?"7":parameterList.get(5).toString()) ;
	    		String rstr = new RolesComInfo().getRolesRemark(id);
	    		switch(rolelevel){
	    		case 0:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(124,lang);
	    			break;
	    		case 1:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(141,lang);
	    			break;
	    		case 2:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(140,lang);
	    			break;
	    		}
	    		return rstr;
	    	case 4:
	    		//4:所有人安全级别
	    		return "";
	    	case 5:
		    	//5:分部安全级别
	    		id = parameterList.get(1) == null?"":parameterList.get(1).toString();
	    		SubCompanyComInfo scc = new SubCompanyComInfo();
		    	return scc.getSubCompanyname(id);
	    		
	    	}
    	
    	}
    	return "";
    }
    
    /**
     * 获取共享范围类型
     * @param type1
     * @return
     * @throws Exception
     */
    public String getMeetingPermissiontype(String type1, String para)throws Exception{
    	
    	int lang = Util.getIntValue(para, 7) ;
    	
    	switch(Util.getIntValue(type1)){
    	case 1:
    		//1:部门安全级别
    		return SystemEnv.getHtmlLabelName(124,lang);
    	case 2:
    		//2:角色安全级别
    		return SystemEnv.getHtmlLabelName(122,lang);
    	case 3:
    		//3:所有人安全级别
    		return SystemEnv.getHtmlLabelName(1340,lang);
    	case 5:
	    	//5:人力资源
	    	return SystemEnv.getHtmlLabelName(179,lang);
    	case 6:
	    	//6:分部安全级别
	    	return SystemEnv.getHtmlLabelName(141,lang);
    	}
    	return "";
    }
    
    /**
     * 获取参会人类型名称
     * @param type1
     * @return
     * @throws Exception
     */
    public String getMeetingMembertype(String type1, String para)throws Exception{
    	
    	int lang = Util.getIntValue(para, 7) ;
    	
    	switch(Util.getIntValue(type1)){
    	case 1:
	    	//1:人力资源
	    	return SystemEnv.getHtmlLabelName(179,lang);
    	case 2:
    		//3:客户
    		return SystemEnv.getHtmlLabelName(136,lang);
    	case 3:
    		//3:所有人安全级别
    		return SystemEnv.getHtmlLabelName(1340,lang);
    	case 5:
    		//5:部门安全级别
    		return SystemEnv.getHtmlLabelName(124,lang);
    	case 6:
	    	//6:分部安全级别
	    	return SystemEnv.getHtmlLabelName(141,lang);
    	case 7:
    		//7:角色安全级别
    		return SystemEnv.getHtmlLabelName(122,lang);
    	}
    	return "";
    }
    
    /**
     * 获取会议参会人的对象
     * @param type
     * @param para
     * @return
     * @throws Exception
     */
    public String getMeetingMemberObj(String type, String para )throws Exception{
    	List parameterList = Util.TokenizerString(para, "+");
    	if(parameterList != null && parameterList.size() > 0){
    		String id = "";
	    	switch(Util.getIntValue(type)){
	    	case 1:
		    	//1:人力资源
	    		id = parameterList.get(2) == null?"":parameterList.get(2).toString();
	    		ResourceComInfo rsc = new ResourceComInfo();
		    	return rsc.getLastname(id);
	    	case 2:
	    		//2:客户
	    		id = parameterList.get(2) == null?"":parameterList.get(2).toString();
	    		return new CustomerInfoComInfo().getCustomerInfoname(id);
	    	case 3:
	    		//3:所有人安全级别
	    		return "";
	    	case 5:
	    		//5:部门安全级别
	    		id = parameterList.get(0) == null?"":parameterList.get(0).toString();
	    		DepartmentComInfo dept = new DepartmentComInfo();
	    		return dept.getDepartmentname(id);
	    	case 6:
		    	//6:分部安全级别
	    		id = parameterList.get(1) == null?"":parameterList.get(1).toString();
	    		SubCompanyComInfo scc = new SubCompanyComInfo();
		    	return scc.getSubCompanyname(id);
	    	case 7:
	    		//2:角色
	    		id = parameterList.get(3) == null?"":parameterList.get(3).toString();
	    		int rolelevel = Util.getIntValue(parameterList.get(4) == null?"-1":parameterList.get(4).toString()) ;
	    		int lang = Util.getIntValue(parameterList.get(5) == null?"7":parameterList.get(5).toString()) ;
	    		String rstr = new RolesComInfo().getRolesRemark(id);
	    		switch(rolelevel){
	    		case 0:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(124,lang);
	    			break;
	    		case 1:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(141,lang);
	    			break;
	    		case 2:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(140,lang);
	    			break;
	    		}
	    		return rstr;
	    	}
    	
    	}
    	return "";
    }
    
    /**
     * 默认参会人员安全级别
     * @param type
     * @param para
     * @return权限类型
     * @throws Exception
     */
    public String getMeetingMemberlevel(String type, String para )throws Exception{
    	List parameterList = Util.TokenizerString(para, "+");
    	int id1 = -1;
    	int id2 = -1;
    	switch(Util.getIntValue(type)){
    	case 1:
    		//1:人力资源
    	case 2:
    		//2:客户
    		return "";
    	case 3:
    		//3:角色安全级别
    	case 4:
    		//4:所有人安全级别
    	case 5:
    	case 6:
    	case 7:
    		//5:分部安全级别
    		id1 = 0;
    		id2 = 1;
    		break;
    	}
    	String level = "";
    	if( id1 != -1 && id2 != -1 && parameterList != null ){
    		level = (parameterList.get(id1) == null?"":parameterList.get(id1).toString());
    		if(parameterList.size() > 1){
	    		String maxlvl = (parameterList.get(id2) == null?"":parameterList.get(id2).toString());
	    		if(!"".equals(maxlvl)){
	    			level += "-"+maxlvl;
	    		}
    		}
    	}
    	return level;
    }
    
    /**
     * 获取会议室共享范围的对象
     * @param type
     * @param para
     * @return
     * @throws Exception
     */
    public String getMeetingPermissionObj(String type, String para )throws Exception{
    	List parameterList = Util.TokenizerString(para, "+");
    	if(parameterList != null && parameterList.size() > 0){
    		String id = "";
	    	switch(Util.getIntValue(type)){
	    	case 1:
	    		//1:部门安全级别
	    		id = parameterList.get(0) == null?"":parameterList.get(0).toString();
	    		DepartmentComInfo dept = new DepartmentComInfo();
	    		return dept.getDepartmentname(id);
	    	case 2:
	    		//2:角色
	    		id = parameterList.get(3) == null?"":parameterList.get(3).toString();
	    		int rolelevel = Util.getIntValue(parameterList.get(4) == null?"-1":parameterList.get(4).toString()) ;
	    		int lang = Util.getIntValue(parameterList.get(5) == null?"7":parameterList.get(5).toString()) ;
	    		String rstr = new RolesComInfo().getRolesRemark(id);
	    		switch(rolelevel){
	    		case 0:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(124,lang);
	    			break;
	    		case 1:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(141,lang);
	    			break;
	    		case 2:
	    			rstr += "/" + SystemEnv.getHtmlLabelName(140,lang);
	    			break;
	    		}
	    		return rstr;
	    	case 3:
	    		//3:所有人安全级别
	    		return "";
	    	case 5:
		    	//5:人力资源
	    		id = parameterList.get(2) == null?"":parameterList.get(2).toString();
	    		ResourceComInfo rsc = new ResourceComInfo();
		    	return rsc.getLastname(id);
	    	case 6:
		    	//6:分部安全级别
	    		id = parameterList.get(1) == null?"":parameterList.get(1).toString();
	    		SubCompanyComInfo scc = new SubCompanyComInfo();
		    	return scc.getSubCompanyname(id);
	    	}
    	
    	}
    	return "";
    }
    
    /**
     * 获取安全级别
     * @param type
     * @param para
     * @return
     * @throws Exception
     */
    public String getMeetingPermissionlevel(String type, String para )throws Exception{
    	List parameterList = Util.TokenizerString(para, "+");
    	int id1 = -1;
    	int id2 = -1;
    	switch(Util.getIntValue(type)){
    	case 1:
    		//1:部门安全级别
    		id1 = 0;
    		id2 = 1;
    		break;
    	case 2:
    		//2:角色
    		id1 = 6;
    		id2 = 7;
    		break;
    	case 3:
    		//3:所有人安全级别
    		id1 = 4;
    		id2 = 5;
    		break;
    	case 5:
	    	//5:人力资源
    		break;
    	case 6:
	    	//6:分部安全级别
    		id1 = 2;
    		id2 = 3;
    		break;
    	case 7:
	    	//7 参与人是角色
    		id1 = 2;
    		id2 = 3;
    		break;
    	}
    	String level = "";
    	if( id1 != -1 && id2 != -1 && parameterList != null ){
    		level = (parameterList.get(id1) == null?"":parameterList.get(id1).toString());
    		if(parameterList.size() > 1){
	    		String maxlvl = (parameterList.get(id2) == null?"":parameterList.get(id2).toString());
	    		if(!"".equals(maxlvl)){
	    			level += "-"+maxlvl;
	    		}
    		}
    	}
    	return level;
    }

    /**
     * 获得会议室名称
     * @param addressid
     * @return
     * @throws Exception
     */
    public String getMeetingAddress(String idString,String others) throws Exception{
        List parameterList = Util.TokenizerString(others, "+");
        String userLanguage=parameterList.get(0).toString();
        String customizeaddress=parameterList.get(1).toString();
        int lang=Integer.parseInt(userLanguage);
        MeetingRoomComInfo meetingRoomComInfo = new MeetingRoomComInfo();
        String br = "&#13;";
		String[] ids=idString.split(",");
		String linkstr ="";
		for (String addressid : ids) {
			String strTitle = meetingRoomComInfo.getMeetingRoomInfoname(addressid)+br+SystemEnv.getHtmlLabelNames("780,81710",lang)+"："+meetingRoomComInfo.getMeetingRoomInfodesc(addressid)+br+SystemEnv.getHtmlLabelName(2156,lang)+"："+new ResourceComInfo().getResourcename(meetingRoomComInfo.getMeetingRoomInfohrmid(addressid))+br+SystemEnv.getHtmlLabelNames("780,1326",lang)+"："+meetingRoomComInfo.getMeetingRoomInfoequipment(addressid);

			linkstr += ",<span title='"+strTitle+"'>" + meetingRoomComInfo.getMeetingRoomInfoname(addressid) + "</span>" ;

		}

		if(!"".equals(linkstr))
			linkstr=linkstr.substring(1);

		writeLog("linkstr"+linkstr);

		if(ids.length>1){
			return linkstr;
		}


        return (new MeetingRoomComInfo().getMeetingRoomInfoname(idString)).equals("")?("".equals(customizeaddress.trim())?"":customizeaddress+"("+SystemEnv.getHtmlLabelName(19516,lang)+")"):linkstr;
    }

    /**
     * 获得会议室使用占比
     * @param addressid
     * @return
     * @throws Exception
     */
    public String getMeetingUsedPercentage(String times,String totals) throws Exception{
    	if(Integer.parseInt(totals)!=0){
    		return new java.text.DecimalFormat("#0.00").format(Integer.parseInt(times)*100.0/Double.parseDouble(totals)) +"%";
    	}else{
    		return "";
    	}
    }
    
    /**
     * 获得分部名称
     * @param resourceid
     * @return
     * @throws Exception
     */
    public String getMeetingSubCompany(String subcomid) throws Exception{
        return new SubCompanyComInfo().getSubCompanyname(subcomid);
    }
    
    
    /**
     * 会议室列表处理权限
     * @param id
     * @param para
     * @return
     */
    public List checkRoomOperate(String id,String para){
    	List edList = new ArrayList();
    	CheckSubCompanyRight CheckSubCompanyRight=new CheckSubCompanyRight(); 
    	List parameterList = Util.TokenizerString(para, "+");
    	String status=parameterList.get(0).toString();
    	int subcomp=Util.getIntValue(parameterList.get(1).toString(),0);
    	int userid=Util.getIntValue(parameterList.get(2).toString(),0);
    	String detachable=parameterList.get(3).toString();
    	if("1".equals(detachable)){
    		int operatelevel= CheckSubCompanyRight.ChkComRightByUserRightCompanyId(userid,"MeetingRoomAdd:Add",subcomp);
			if(operatelevel<1){
				//编辑
		    	edList.add("false");
		    	//删除
		    	edList.add("false");
	    		//封存
	    		edList.add("false");
	    		//解封
	    		edList.add("false");
		    	//共享范围
		    	edList.add("false");
			}else{
				//编辑
		    	edList.add("true");
		    	//删除
		    	edList.add("true");
		    	if(!"2".equals(status)){
		    		//封存
		    		edList.add("true");
		    		//解封
		    		edList.add("false");
		    	} else {
		    		//封存
		    		edList.add("false");
		    		//解封
		    		edList.add("true");
		    	}
		    	//共享范围
		    	edList.add("true");	
			}
    	}else{
    		//编辑
        	edList.add("true");
        	//删除
        	edList.add("true");
        	if(!"2".equals(status)){
        		//封存
        		edList.add("true");
        		//解封
        		edList.add("false");
        	} else {
        		//封存
        		edList.add("false");
        		//解封
        		edList.add("true");
        	}
        	//共享范围
        	edList.add("true");
    	}
    	return edList;
    }  
    
    /**
     * 会议室列表处理权限
     * @param id
     * @param para
     * @return
     */
    public List checkTypeOperate(String id,String para){
    	List edList = new ArrayList();
    	CheckSubCompanyRight CheckSubCompanyRight=new CheckSubCompanyRight(); 
    	List parameterList = Util.TokenizerString(para, "+");
    	String cnt=parameterList.get(0).toString();
    	int subcomp=Util.getIntValue(parameterList.get(1).toString(),0);
    	int userid=Util.getIntValue(parameterList.get(2).toString(),0);
    	String detachable=parameterList.get(3).toString();
    	if("1".equals(detachable)){
    		int operatelevel= CheckSubCompanyRight.ChkComRightByUserRightCompanyId(userid,"MeetingType:Maintenance",subcomp);
			if(operatelevel<1){
		    	int count = Util.getIntValue(cnt, 1);
		    	for(int i = 0; i < count; i++){
		    		edList.add("false");
		    	}
			}else{
		    	int count = Util.getIntValue(cnt, 1);
		    	for(int i = 0; i < count; i++){
		    		edList.add("true");
		    	}
			}
    	}else{
    		
        	int count = Util.getIntValue(cnt, 1);
        	for(int i = 0; i < count; i++){
        		edList.add("true");
        	}
    	}
    	return edList;
    }  
    
    /**
     * 会议室状态
     * @param id
     * @param para
     * @return
     */
    public String getRoomStatus(String status,String para){
    	int lang = 7;
    	try{
    		lang = Integer.parseInt(para);
    	}catch(Throwable t){
    		lang = 7;
    	}
    	
    	if(!"2".equals(status)){
    		//正常
    		return SystemEnv.getHtmlLabelName(225,lang);
    	} else {
    		//已封存
    		return SystemEnv.getHtmlLabelName(22205,lang);
    	}
    	
    }  
    
    public String getCheckbox(String para){
    	if("false".equals(para)){
    		return "false";
    	}
    	return "true";
    }
    /**
     * 会议室check
     * @param para
     * @return
     */
    public String getRoomCheckbox(String para){
    	String canedit="true";
    	CheckSubCompanyRight CheckSubCompanyRight=new CheckSubCompanyRight(); 
    	List parameterList = Util.TokenizerString(para, "+");
    	int subcomp=Util.getIntValue(parameterList.get(0).toString(),0);
    	int userid=Util.getIntValue(parameterList.get(1).toString(),0);
    	String detachable=parameterList.get(2).toString();
    	if("1".equals(detachable)){
    		int operatelevel= CheckSubCompanyRight.ChkComRightByUserRightCompanyId(userid,"MeetingRoomAdd:Add",subcomp);
			if(operatelevel<1){
				canedit="false";
			}
    	}
    	return canedit;
    }
    
    /**
     * 会议类型check
     * @param para
     * @return
     */
    public String getTypeCheckbox(String para){
    	String canedit="true";
    	CheckSubCompanyRight CheckSubCompanyRight=new CheckSubCompanyRight(); 
    	List parameterList = Util.TokenizerString(para, "+");
    	int subcomp=Util.getIntValue(parameterList.get(0).toString(),0);
    	int userid=Util.getIntValue(parameterList.get(1).toString(),0);
    	String detachable=parameterList.get(2).toString();
    	if("1".equals(detachable)){
    		int operatelevel= CheckSubCompanyRight.ChkComRightByUserRightCompanyId(userid,"MeetingType:Maintenance",subcomp);
			if(operatelevel<1){
				canedit="false";
			}
    	}
    	return canedit;
    }
    
    /**
     * 获得用户名称
     * @param resourceid
     * @return
     * @throws Exception
     */
    public String getMeetingResource(String resourceid) throws Exception{
    	String str = "<a href=javaScript:openhrm(" + resourceid + "); onclick='pointerXY(event);'>" + new ResourceComInfo().getResourcename(resourceid) + "</a>";
        return str;
    }
    
    /**
     * 获得用户名称
     * @param resourceid
     * @return
     * @throws Exception
     */
    public String getMeetingMultResource(String resourceid) throws Exception{
    	String str = "";
    	ResourceComInfo rc = new ResourceComInfo();
    	if(!resourceid.equals("")){
			ArrayList resourceids = Util.TokenizerString(resourceid,",");
			for(int i=0;i<resourceids.size();i++){
				str += "<a href=javaScript:openhrm(" + resourceids.get(i) + "); onclick='pointerXY(event);'>" + rc.getResourcename(""+resourceids.get(i)) + "</a>&nbsp;";
			}
    	}
        return str.length() > 1?str.substring(0, str.length() - 6):str;
    }

    /**
     * 获取会议通知提前下发天数
     * @param mid
     * @param para
     * @return
     * @throws Exception
     */
    public String getNotifydate(String mid, String para) throws Exception
    {
    	String result = "";
    	
    	String createdate = "";
		String createtime = "";
		String approvedate = "";
		String approvetime = "";
		
    	String sql = "select createdate,createtime,approvedate,approvetime from meeting where id='"+mid+"' ";
    	weaver.conn.RecordSet rs = new weaver.conn.RecordSet();
    	rs.executeSql(sql);
    	if(rs.next()){
    		createdate = Util.null2String(rs.getString("createdate"));//+" "+rs.getString("createtime");
    		createtime = Util.null2String(rs.getString("createtime"));//+" "+rs.getString("approvetime");
    		approvedate = Util.null2String(rs.getString("approvedate"));
    		approvetime = Util.null2String(rs.getString("approvetime"));
    	}
    	
    	TimeUtils t = new TimeUtils();
    		
    	if(!"".equals(approvedate)){
    		result = approvedate + " " + t.meetingTimeFormatting(approvetime);
    	}else{
    		result = createdate + " " + t.meetingTimeFormatting(createtime);
    	}
    	return result;
    }
    /**
     * 获取会议通知下发时间
     * @param mid
     * @param para
     * @return
     * @throws Exception
     */
    public String getNotifydays(String mid, String para) throws Exception
    {
    	String result = "0";
    	
    	String createdate = "";
		String approvedate = "";
		String begindate = "";
    	String sql = "select createdate,approvedate,begindate from meeting  where id='"+mid+"' ";
    	weaver.conn.RecordSet rs = new weaver.conn.RecordSet();
    	rs.executeSql(sql);
    	if(rs.next()){
    		createdate = Util.null2String(rs.getString("createdate"));
    		approvedate = Util.null2String(rs.getString("approvedate"));
    		begindate = Util.null2String(rs.getString("begindate"));
    	}
    	
    	String datetime_xf = "";
    	if(!"".equals(approvedate)){
    		datetime_xf = approvedate;
    	}else{
    		datetime_xf = createdate;
    	}
    	
		result = Util.getIntValue(""+com.weaver.formmodel.util.DateHelper.getDaysBetween(begindate,datetime_xf) , 0) + "";
		
    	rs.executeSql("update meeting set datetime_ks = "+ result +" where id = " + mid);
    	
    	return result;
    }
    
    public String getOverDays(String num, String parameter) throws Exception
    {
    	int number = Util.getIntValue(num);
    	if(number>0){
    		int days = 0;
    		String sql = "SELECT COUNT(*) counts FROM HrmPubHoliday WHERE holidaydate <= to_char(sysdate,'yyyy-mm-dd') AND holidaydate >= '"+parameter+"'";
    		RecordSet rs = new RecordSet();
    		rs.execute(sql);
    		if(rs.next()){
    			days = rs.getInt("counts");
    		}
    		number = number-days;
    	}
    	if(number<0){
    		number = 0;
    	}
    	return ""+number;
    }
    
    public String getMeetingStatusNew(String meetingStatus, String para) throws Exception
    {
    	return "未开始";
    }
    /**
     * 获得会议状态
     * @param meetingStatus
     * @param para
     * @return 会议状态
     */
    public String getMeetingStatus1(String meetingStatus) throws Exception
    {
        String result = "";
        
        if ("0".equals(meetingStatus) || "1".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(220, 7);
        }
        else if ("2".equals(meetingStatus))
        {
        	 result = SystemEnv.getHtmlLabelNames("225", 7); 
	         
        }
        else if ("3".equals(meetingStatus))
        {
       	 result = SystemEnv.getHtmlLabelNames("130039", 7); 
        }
        else if ("4".equals(meetingStatus))
        {
          	 result = SystemEnv.getHtmlLabelNames("201", 7); 
        }

        return result;
    }
    /**
     * 获得会议状态
     * @param meetingStatus
     * @param para
     * @return 会议状态
     */
    public String getMeetingStatus(String meetingStatus, String para) throws Exception
    {
        String result = "";
        
        Date newdate = new Date() ;
        long datetime = newdate.getTime() ;
        Timestamp timestamp = new Timestamp(datetime) ;
        String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
        String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16);

        List parameterList = Util.TokenizerString(para, "+");
        String userLanguage=parameterList.get(0).toString();
        String endDate=parameterList.get(1).toString();
        String endTime=parameterList.get(2).toString();
        String status=parameterList.get(3).toString();
        //int repeatType=Util.getIntValue(parameterList.get(4).toString(), 0);
        
        if ("0".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(220, Integer.parseInt(userLanguage));
        }
        else if ("1".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(2242, Integer.parseInt(userLanguage));
        }
        else if ("2".equals(meetingStatus))
        {
	         if((endDate+":"+endTime).compareTo(CurrentDate+":"+CurrentTime)>0)    
	        	result = SystemEnv.getHtmlLabelName(225, Integer.parseInt(userLanguage));
	         else
	            result = SystemEnv.getHtmlLabelName(405, Integer.parseInt(userLanguage));
	         if(status.equals("2"))
	        	 result = SystemEnv.getHtmlLabelName(405, Integer.parseInt(userLanguage)); 
	         
        }
        else if ("3".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(1010, Integer.parseInt(userLanguage));
        }
        else if ("4".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(20114, Integer.parseInt(userLanguage));
        }
        
        else if ("5".equals(meetingStatus))
        {
            result = SystemEnv.getHtmlLabelName(405, Integer.parseInt(userLanguage));
        }

        return result;
    }
    
    /**
     * 得到会议连接
     * @param name
     * @param id
     * @return
     * @throws Exception
     */
    public String getMeetingName(String name, String parameter) throws Exception
    {
        List parameterList = Util.TokenizerString(parameter, "+");

        String id = (String) parameterList.get(0);

        String status = (String) parameterList.get(1);
        
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append("<A href='#' onclick='javascript:view(");
        stringBuffer.append(id);
        stringBuffer.append(");return false;'>");
        stringBuffer.append(Util.forHtml("".equals(name)?id:name));
        stringBuffer.append("</A>");
        
        if("0".equals(status))
        {
            stringBuffer.append("<IMG src='/images/BDNew_wev8.gif' align=absbottom border=0>");
        }
        else if("2".equals(status))
        {
            stringBuffer.append("<IMG src='/images/BDCancel_wev8.gif' align=absbottom border=0>");
        }        
        
        return stringBuffer.toString();
    }
    

    /**
     * 获得会议（开始、结束）时间
     * @param strdate
     * @param strtime
     * @return （开始、结束）时间
     */
    public String getMeetingDateTime(String strdate,String strtime){
    	
    	TimeUtils t = new TimeUtils();
    	
    	String time1 = t.meetingTimeFormatting(strtime);
    	
        return strdate+" "+time1;
    }
    
    /**
     * 获得会议（开始 ~ 结束）时间
     * @param strdate
     * @param strtime
     * @return （开始、结束）时间
     */
    public String getMeetingTime(String strdate,String para){
    	List parameterList = Util.TokenizerString(para, "+");
    	String strtime = (String) parameterList.get(0);
    	String enddata = (String) parameterList.get(1);
    	String endTime = (String) parameterList.get(2);
    	
    	TimeUtils t = new TimeUtils();
    	
    	String time1 = t.meetingTimeFormatting(strtime);
    	
    	String time2 = t.meetingTimeFormatting(endTime);
    	
        return strdate+" "+time1 + " ~ " + enddata + " " + time2;
    }
    
    /**
     * 会议室使用情况会议取消处理权限
     * @param id
     * @param column:caller+userid+cancelRight+column:cancel+column:meetingstatus+column:enddate+column:endtime+column:isdecision
     * @return
     */
    public List checkMtnCnclOperate(String id,String para){
    	List parameterList = Util.TokenizerString(para, "+");
    	String caller = (String) parameterList.get(0);
    	String userid = (String) parameterList.get(1);
    	String cancelRight = (String) parameterList.get(2);
    	String cancel = (String) parameterList.get(3);
    	String meetingstatus = (String) parameterList.get(4);
    	String endDate=parameterList.get(5).toString();
        String endTime=parameterList.get(6).toString();
        String status=parameterList.get(7).toString();
        Date newdate = new Date() ;
        long datetime = newdate.getTime() ;
        Timestamp timestamp = new Timestamp(datetime) ;
        String CurrentDate = (timestamp.toString()).substring(0,4) + "-" + (timestamp.toString()).substring(5,7) + "-" +(timestamp.toString()).substring(8,10);
        String CurrentTime = (timestamp.toString()).substring(11,13) + ":" + (timestamp.toString()).substring(14,16);

    	String bol = "false";
    	if ("2".equals(meetingstatus))
        {
    		if((endDate+":"+endTime).compareTo(CurrentDate+":"+CurrentTime)>0){
    			if(caller.equals(userid)){
    				bol = "true";
    			} else if("true".equals(cancelRight) && !cancel.equals("1")){
    				bol = "true";
    			}
    		}
        }
    	List edList = new ArrayList();
    	edList.add(bol);
    	return edList;
    }  
    
    /**
     * 获取会议任务的状态
     * @param status
     * @param para
     * @return
     */
    public String getMeetingDecisionStatus(String status, String para){
    	List parameterList = Util.TokenizerString(para, "+");
    	String begint = (String) parameterList.get(0);
    	String endt = (String) parameterList.get(1);
    	String lang = (String) parameterList.get(2);
    	String currentTime = (String) parameterList.get(3);
    	if(!"0".equals(status)){
    		return SystemEnv.getHtmlLabelName(1961, Util.getIntValue(lang,7));
    	} else {
    		if(begint.compareTo(currentTime) > 0){
    			return SystemEnv.getHtmlLabelName(1979, Util.getIntValue(lang,7));//"未开始";
    		} else if(begint.compareTo(currentTime) <= 0 && endt.compareTo(currentTime) >= 0){
    			return SystemEnv.getHtmlLabelName(1960, Util.getIntValue(lang,7));//"进行中";
    		} else {
    			return SystemEnv.getHtmlLabelName(32556, Util.getIntValue(lang,7));//"已延期";
    		}
    	}
    }
    
    public List checkMeetingDecisionOpt(String id, String status){
    	List edList = new ArrayList();
    	
    	if(!"0".equals(status)){
    		edList.add("false");
    	} else {
    		edList.add("true");
    	}
    	
    	return edList;
    }
    
    public List checkMeetingIntervalOpt(String id, String para){
    	List edList = new ArrayList();
    	
    	List parameterList = Util.TokenizerString(para, "+");
    	String caller = (String) parameterList.get(0);
    	String contacter = (String) parameterList.get(1);
    	String creater = (String) parameterList.get(2);
    	String status = (String) parameterList.get(3);
    	String enddate = (String) parameterList.get(4);
    	String userid = (String) parameterList.get(5);
    	String currentdate = (String) parameterList.get(6);
    	
    	if(enddate.compareTo(currentdate) <= 0 || !"2".equals(status)){
    		edList.add("false");
    		edList.add("false");
    		return edList;
    	}
    	weaver.meeting.Maint.MeetingSetInfo meetingSetInfo = new weaver.meeting.Maint.MeetingSetInfo();
    	int userPrm=0;
    	boolean canOpt = false;

    	if(userid.equals(caller)){
    		userPrm = 3;
    	} else if(userid.equals(contacter)){
    	   userPrm = meetingSetInfo.getContacterPrm();
    	} else if(userid.equals(creater)){
    	   userPrm = meetingSetInfo.getCreaterPrm();
    	}
    	
    	if(userPrm == 3 || userid.equals(caller)){
    		canOpt = true;
    	}
    	
    	//只有具有召集人权限的才可以提前终止会议。
    	if(canOpt){
    		edList.add("true");
    		edList.add("true");
    	} else {
    		edList.add("false");
    		edList.add("false");
    	}
    	return edList;
    }
    
    public String getMeetingName(String meetingid) throws Exception{
    	return "<A style=\"CURSOR: pointer;\" href=\'/meeting/data/ProcessMeeting.jsp?meetingid="+meetingid+"\' target=\'_blank\'>"+new MeetingComInfo().getMeetingInfoname(""+meetingid)+"</A>&nbsp;";
    }
    
    
    public String getMeetingTopicDate(String id, String para){
    	RecordSet rs = new RecordSet();
    	rs.executeProc("Meeting_TopicDate_SelectAll",para+Util.getSeparator()+id);
    	String rstr = "";
    	while(rs.next()){
    		rstr +="<p>"+rs.getString("begindate")+" "+rs.getString("begintime")+"</p><p> - </p><p>"+rs.getString("enddate")+" "+rs.getString("endtime")+"</p>";
    	}
    	return rstr;
    }
    
    public String getProjectString(String projid, String para) throws Exception{
    	return "<a href=\'/proj/data/ViewProject.jsp?ProjID="+projid+"\' target=\'_blank\' >"+Util.toScreen((new ProjectInfoComInfo().getProjectInfoname(projid)),Util.getIntValue(para, 7))+"</a>";
    }
    
    public String getMultCustomerLinkStr(String crmids) throws Exception{
    	CustomerInfoComInfo comInfo = new CustomerInfoComInfo();
    	String returnStr ="";
    	ArrayList a_crmids = Util.TokenizerString(crmids,",");
    	for(int i=0;i<a_crmids.size();i++){
    		String id = (String)a_crmids.get(i);
    		returnStr += "<a href=\"/CRM/data/ViewCustomer.jsp?CustomerID="+id+"\" target=\'_blank\' >"+comInfo.getCustomerInfoname(id)+"</a> ";
    	}
    	return returnStr ;
    }
    
    public String getMeetingTopicIsOpen(String isopen,String para){
    	String rstr = "";
    	if("1".equals(isopen)){
    		rstr += "<input type=checkbox  checked disabled>";
    	}else{
    		rstr += "<input type=checkbox  disabled>";
    	}
    	rstr += SystemEnv.getHtmlLabelName(2161,Util.getIntValue(para, 7));
    	return rstr;
    }
    
    public List checkMeetingTopicOpt(String id, String para){
    	List parameterList = Util.TokenizerString(para, "+");
    	String isdecision = (String) parameterList.get(1);
    	String ismanager = (String) parameterList.get(0);
    	List edList = new ArrayList();
    	if(!isdecision.equals("1") && !isdecision.equals("2")){
    		edList.add("true");
    	} else {
    		edList.add("false");
    	}
    	if("true".equals(ismanager) && !isdecision.equals("1") && !isdecision.equals("2")){
    		edList.add("true");
    	} else {
    		edList.add("false");
    	}
    	
    	return edList;
    }
    
    //人力资源用于可编辑列表
    public String getHrmResourcesEdit(String ids) throws Exception{
    	JSONArray jsa = new JSONArray();
    	String Names = "";
        String[] IdArrays = Util.TokenizerString2(ids,",");
        ResourceComInfo rci = new ResourceComInfo();
        for (int i=0 ;i<IdArrays.length;i++){
            String tempDocId = IdArrays[i];
            Names = "<a href=javaScript:openhrm(" + tempDocId + "); onclick='pointerXY(event);'>" + rci.getResourcename(tempDocId) + "</a>&nbsp;";
            JSONObject json = new JSONObject();
            json.put("browserValue", tempDocId);
            json.put("browserSpanValue", Names);
            jsa.add(json);
        }
        return jsa.toString();
    }
    
    //项目用于可编辑列表
    public String getProjectEdit(String ids) throws Exception{
    	JSONArray jsa = new JSONArray();
    	String Names = "";
        String[] IdArrays = Util.TokenizerString2(ids,",");
        ProjectInfoComInfo prj = new ProjectInfoComInfo();
        for (int i=0 ;i<IdArrays.length;i++){
            String tempDocId = IdArrays[i];
            Names = "<a href='/proj/data/ViewProject.jsp?ProjID="+tempDocId+"' target='_blank'>"+prj.getProjectInfoname(tempDocId)+"</a>&nbsp;";
            JSONObject json = new JSONObject();
            json.put("browserValue", tempDocId);
            json.put("browserSpanValue", Names);
            jsa.add(json);
        }
        return jsa.toString();
    }
    
  //客户用于可编辑列表
    public String getCrmEdit(String ids) throws Exception{
    	JSONArray jsa = new JSONArray();
    	String Names = "";
        String[] IdArrays = Util.TokenizerString2(ids,",");
        CustomerInfoComInfo comInfo = new CustomerInfoComInfo();
        for (int i=0 ;i<IdArrays.length;i++){
            String tempDocId = IdArrays[i];
            Names = "<a href=\"/CRM/data/ViewCustomer.jsp?CustomerID="+tempDocId+"\" target=\'_blank\' >"+comInfo.getCustomerInfoname(tempDocId)+"</a> ";
            JSONObject json = new JSONObject();
            json.put("browserValue", tempDocId);
            json.put("browserSpanValue", Names);
            jsa.add(json);
        }
        return jsa.toString();
    }
    
    //会议服务类型操作
    public List getMeetingServiceTypeOpt(String id, String isuse){
    	List edList = new ArrayList();
		edList.add("true");
    	if("1".equals(isuse)){
    		edList.add("false");
    	} else {
    		edList.add("true");
    	}
    	return edList;
    }
    
    //会议服务类型checkbox操作
    public String getMeetingServiceTypeCheckbox(String isuse){
    	String canedit="true";
    	if("1".equals(isuse)){
    		canedit="false";
    	}
    	return canedit;
    }
    
    //会议服务项目操作
    public List getMeetingServiceItemOpt(String id, String isuse){
    	List edList = new ArrayList();
		edList.add("true");
    	if("1".equals(isuse)){
    		edList.add("false");
    	} else {
    		edList.add("true");
    	}
    	return edList;
    }
    
    //会议服务类型checkbox操作
    public String getMeetingServiceItemCheckbox(String isuse){
    	String canedit="true";
    	if("1".equals(isuse)){
    		canedit="false";
    	}
    	return canedit;
    }
    
    /**
     * 服务项目
     * @param itemsvalue
     * @return
     */
    public String getServiceItemNames(String itemsvalue){
    	String linkurlStart="<a href=\"javascript:void(0)\">";
		String aEnd="</a>";
    	String showname="";
    	if(!"".equals(itemsvalue)){
	    	RecordSet rs = new RecordSet();
	    	String sql = "select itemname,id from Meeting_Service_Item where id in(" + itemsvalue+ ")";
	    	//System.out.println(sql);
	    	rs.executeSql(sql);
	    	while (rs.next()) {
	    		showname += linkurlStart+rs.getString(1) +aEnd+ "&nbsp;&nbsp;";
	    	}
    	}
    	return showname;
    }
    
    
    
    //会议流程操作
    public List getMeetingWFOpt(String id, String para){
    	List edList = new ArrayList();
    	List parameterList = Util.TokenizerString(para, "+");
    	String wfp = (String) parameterList.get(0);
    	String formid = (String) parameterList.get(1);
    	edList.add(wfp);
    	if("85".equals(formid)){
    		edList.add("false");
    	}else{
    		edList.add("true");
    	}
    	return edList;
    }
    
    public String getWfNameForWfDoc(String wfid,String wfp){
    	String link = "";
    	String wfname = "";
    	RecordSet recordSet = new RecordSet();
    	String sql = "select workflowname from workflow_base where id="+wfid;
    	recordSet.executeSql(sql);
    	if(recordSet.next()){
    		wfname = recordSet.getString("workflowname");
    	}
    	if("true".equals(wfp)){
    		link = "<a href='javascript:viewDetail("+wfid+")'>"+wfname+"</a>";
    	}else{
    		link=wfname;
    	}
    	return link;
    }
    
    /**
     * 标题点击
     * @param name
     * @param params
     * @return
     */
    public String getClickMethod(String name,String params){
    	List parameterList = Util.TokenizerString(params, "+");
    	if(parameterList.size()==2){
    		String id=(String)parameterList.get(0);
    		String method=(String)parameterList.get(1);
    		return "<a href='javascript:"+method+"("+id+")'>"+name+"</a>";
    	}
    	return name;
    }
    
      public void writeLog(Object obj) {
        writeLog(getClass().getName(),obj);
      }

      public void writeLog(String classname , Object obj)  {
          Log log= LogFactory.getLog(classname);
          if(obj instanceof Exception)
          log.error(classname ,(Exception)obj);
          else{
          log.error(obj);
          }
      }
}
