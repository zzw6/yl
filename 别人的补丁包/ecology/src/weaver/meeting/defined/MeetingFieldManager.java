package weaver.meeting.defined;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import weaver.conn.RecordSet;
import weaver.conn.RecordSetTrans;
import weaver.cpt.capital.CapitalComInfo;
import weaver.crm.Maint.CustomerInfoComInfo;
import weaver.docs.category.SecCategoryComInfo;
import weaver.docs.docs.DocComInfo;
import weaver.docs.docs.DocExtUtil;
import weaver.docs.docs.DocImageManager;
import weaver.docs.senddoc.DocReceiveUnitComInfo;
import weaver.file.FileUpload;
import weaver.general.AttachFileUtil;
import weaver.general.BaseBean;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.hrm.User;
import weaver.hrm.company.DepartmentComInfo;
import weaver.hrm.company.SubCompanyComInfo;
import weaver.hrm.resource.ResourceComInfo;
import weaver.meeting.MeetingBrowser;
import weaver.proj.Maint.ProjectInfoComInfo;
import weaver.systeminfo.SystemEnv;
import weaver.workflow.field.BrowserComInfo;
import weaver.workflow.workflow.WorkflowRequestComInfo;

/**
 * @author HuangGuanGuan
 * Jan 5, 2015
 * 会议卡片中自定义字段
 */
public class MeetingFieldManager extends BaseBean{
  private RecordSet rs = null;
  private RecordSet rsField = null;
  private RecordSet rsData = null;
  private int scopeid = 1;
  //存储所标识的集合里的所有字段的id
  private Set<String> sysFiledsId = null;//系统字段
  private Set<String> custFiledsId = null;
  private List<String> allFiledsId = null;
  private List<String> allFiledsName = null;
  private HashMap<String, String> allFiledsNameMap = null;
  private String base_datatable = "meeting";
  private boolean isdetail=false;
  private String base_id = "id"; //关联id
  private static Object lock=new Object();
  
  public MeetingFieldManager(int scopeid)throws Exception{
	this.scopeid = scopeid;
	MeetingDefinedComInfo defined=new MeetingDefinedComInfo();
	base_datatable=defined.getBase_datatable(""+scopeid);
	isdetail="1".equals(defined.getisdetail(""+scopeid));
	
    rsField = new RecordSet();
    rsData = new RecordSet();
  	rs=new RecordSet();
  	
    //加载所有字段
    getAllfiledname();
  }
  
  
  public List<String> getAllfiledname(){
	this.sysFiledsId= new HashSet<String>();
	this.custFiledsId= new HashSet<String>();
  	this.allFiledsId = new ArrayList<String>();
  	this.allFiledsName = new ArrayList<String>();
    this.allFiledsNameMap = new HashMap<String, String>();
  	RecordSet rs = new RecordSet();
		rs.executeSql("select fieldid, fieldname,issystem from meeting_formfield a, meeting_fieldgroup b where a.groupid = b.id AND b.grouptype="+this.scopeid);
	  while (rs.next()) {
	  	this.allFiledsId.add(rs.getString("fieldid"));
	  	this.allFiledsName.add(rs.getString("fieldname"));
	  	this.allFiledsNameMap.put(rs.getString("fieldid"),rs.getString("fieldname"));
	  	if("1".equals(rs.getString("issystem"))||"0".equals(rs.getString("issystem"))){
	  		this.sysFiledsId.add(rs.getString("fieldid"));
	  	}else{
	  		this.custFiledsId.add(rs.getString("fieldid"));
	  	}
	  }
    return this.allFiledsName;
  }
  
  /**
   * 获取所有自定义字段
   * @return
   */
  public Set<Integer> getCustDoc(String dataid){
	  Set<Integer> doc=new HashSet<Integer>();
	  Set<String> lsFieldid = this.custFiledsId;
	  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
	  RecordSet rs=new RecordSet();
	  String temp="";
	  for(String fieldid:lsFieldid){
      	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
      	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
      	String fieldtype = hrmFieldComInfo.getFieldType(fieldid);
      	String sql="";
      	if("6".equals(fieldhtmltype)){//附件
      		 sql="select "+fieldname+" from "+this.base_datatable+" where "+this.base_id+" = "+dataid;
      	}else if("3".equals(fieldhtmltype)){//浏览框
      		if("9".equals(fieldtype)||"37".equals(fieldtype)){//文档和多文档
      			sql="select "+fieldname+" from "+this.base_datatable+" where "+this.base_id+" = "+dataid;
      		}
      	}
      	if(!"".equals(sql)){
      		rs.execute(sql);
      		if(rs.next()){
      			temp=rs.getString(fieldname);
      			if(!"".equals(temp)){
      				StringTokenizer sthrmid = new StringTokenizer(temp, ",");
			        while (sthrmid.hasMoreTokens()) {
			            String id = sthrmid.nextToken();
			            if(id!=null&&!"".equals(id)){
			            	doc.add(Util.getIntValue(id));
			            }
			        }
      			}
      		}
      	}
      }
	  return doc;
  }
  
  /**
   * 得到此集合的所有字段的属性 Json形式
   * @return
   */
  public JSONObject getFieldConf(String fieldid) throws Exception{
  	MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
    
    JSONObject jsonObject=new JSONObject();
    jsonObject.put("id", fieldid);
  	jsonObject.put("fieldname", hrmFieldComInfo.getFieldname(fieldid));
  	jsonObject.put("fielddbtype", hrmFieldComInfo.getFielddbtype(fieldid));
  	jsonObject.put("fieldhtmltype", hrmFieldComInfo.getFieldhtmltype(fieldid));
  	jsonObject.put("type", hrmFieldComInfo.getFieldType(fieldid));
  	jsonObject.put("fieldlabel", hrmFieldComInfo.getLabel(fieldid));
  	jsonObject.put("sysfieldlabel", hrmFieldComInfo.getSysLabel(fieldid));
  	jsonObject.put("grouptype", hrmFieldComInfo.getGrouptype(fieldid));
  	jsonObject.put("issystem", hrmFieldComInfo.getIssystem(fieldid));
  	jsonObject.put("fieldkind", 0);
  	jsonObject.put("dsporder", hrmFieldComInfo.getDsporder(fieldid));
  	jsonObject.put("ismand", hrmFieldComInfo.getIsmand(fieldid));
  	jsonObject.put("isused", hrmFieldComInfo.getIsused(fieldid));
  	jsonObject.put("isdetail", 0);
  	
  	return jsonObject;
  }
  
  public List<String> getLsGroup() {
  	List<String> ls = new ArrayList<String>();
  	RecordSet rs = new RecordSet();
		rs.executeSql("select id from meeting_fieldgroup where grouptype ="+this.scopeid+" order by grouporder ");
	  while (rs.next()) {
	   	ls.add(rs.getString("id"));
	  }
    return ls;
  }
 
  /**
   * 返回字段Id
   * @return
   */
  public List<String> getLsField(String groupid) {
  	List<String> ls = new ArrayList<String>();
  	RecordSet rs = new RecordSet();
  	String sql = " select fieldid from meeting_formfield a where groupid = "+groupid +
				 				 " order by fieldorder";
  	rs.executeSql(sql);
  	while(rs.next()){
  		ls.add(rs.getString("fieldid"));
  	}
    return ls;
  }
  
  /**
   * 返回字段Id
   * @return
   */
  public List<String> getAllFieldByGroup() {
  	List<String> ls = new ArrayList<String>();
  	RecordSet rs = new RecordSet();
  	String sql = " select fieldid from meeting_formfield a join meeting_fieldgroup b on a.groupid=b.id where b.grouptype="+this.scopeid+" ORDER BY b.grouporder,a.fieldorder ";
  	rs.executeSql(sql);
  	while(rs.next()){
  		ls.add(rs.getString("fieldid"));
  	}
    return ls;
  }
  
  /**
   * 获取模板
   * @return
   */
  public List<String> getTemplateField(){
	  List<String> ls = new ArrayList<String>();
	  RecordSet rs = new RecordSet();
  	  String sql = " select fieldid from meeting_formfield a join meeting_fieldgroup g on a.groupid=g.id where g.grouptype =1 " +
  			"and isuse=1 and fieldhtmltype<>6 and fieldhtmltype<>4 and isrepeat<>1 and (fieldid<21 or fieldid>28) order by g.grouporder,a.fieldorder";
  	  rs.executeSql(sql);
  	  while(rs.next()){
  		ls.add(rs.getString("fieldid"));
  	  }
	  return ls;
  }
  /**
   * 返回启用字段Id
   * @return
   */
  public List<String> getUseField(String groupid) {
  	List<String> ls = new ArrayList<String>();
  	RecordSet rs = new RecordSet();
  	String sql = " select fieldid from meeting_formfield a where isuse=1 and groupid = "+groupid +
				 				 " order by fieldorder";
  	rs.executeSql(sql);
  	while(rs.next()){
  		ls.add(rs.getString("fieldid"));
  	}
    return ls;
  }
  
  /**
   * Process页面参会者分组显示内容
   * @return
   */
  public List<String> getProcessUseField() {
  	List<String> ls = new ArrayList<String>();
  	RecordSet rs = new RecordSet();
  	String sql = " select fieldid from meeting_formfield a where isuse=1 and groupid = 3 and fieldid not in (29,30,32) order by fieldorder";
  	rs.executeSql(sql);
  	while(rs.next()){
  		ls.add(rs.getString("fieldid"));
  	}
    return ls;
  }
  
  /**
   * 取得选择字段选择项的数据
   * @param id
   */
  public void getSelectItem(String id) {
    rs.executeSql("select * from meeting_selectitem where isdel=0 and fieldid=" + id + " order by listorder");
  }
  
  /**
   * 得到字段信息的文本长度，只有为单行文档的时候有效，注意不同的文本长度表示不同的字段类型.
   * @return
   */
  public String getStrLength(String fielddbtype, String htmltype, String type ) {
    if (htmltype.equals("1")) {
        if (type.equals("1")) {
            return fielddbtype.substring(fielddbtype.indexOf("(") + 1, fielddbtype.length() - 1);
        }
    }
    return "0";
  }
 
  /**
   * 选择项数据移动到下一行
   * @return
   */
  public boolean toFirstSelect() {
      return rs.first();
  }
  
  /**
   * 选择项数据移动到下一行
   * @return
   */
  public boolean nextSelect() {
      return rs.next();
  }

  /**
   * 得到选择项的值
   * @return
   */
  public String getSelectValue() {
      return rs.getString("selectvalue");
  }

  /**
   * 得到选择项的显示名称
   * @return
   */
  public String getSelectName() {
      return getSelectName(7);
  }
  
  /**
   * 得到选择项的显示名称
   * @return
   */
  public String getSelectName(int langId) {
      if(!"".equals(rs.getString("selectlabel"))){
    	  return SystemEnv.getHtmlLabelName(Util.getIntValue(rs.getString("selectlabel")),langId);
      }else{
    	  return rs.getString("selectname");
      }
  }
  
  /**
   * 是否被引用
   * @param scopeId
   * @param fieldid
   * @return
   */
  public boolean getIsUsed(String fieldname){
  	boolean isUsed = false;
  	RecordSet rs = new RecordSet();
  	rs.executeSql(" select count(*) from "+this.base_datatable+" where (" +fieldname+" is not null or " +fieldname+" not like '' )");
  	if(rs.next()){
  		if(rs.getInt(1)>0){
  			isUsed = true;
  		}
  	}
  	return isUsed;
  }
  
  /**
   * 向数据库中增加指定类型的数据字段
   * @param fielddbtype 字段的数据库类型，例如 varchar(100)、int、decimal……
   * @param fieldhtmltype 字段的类型 例如 单行文本、多行文本、选择框……
   * @param type 很据fieldhtmltype的不同代表的意义不同，对浏览框，代表的是浏览框的类型
   * @return 增加字段的id
   */
  public int addField( String fieldname, String fielddbtype, String fieldhtmltype, String type, String fieldlabel,
  										 String fieldorder, String ismand, String isuse, String groupid,int grouptype)throws Exception{
  	  int temId = -1;
  	  synchronized (lock) {//添加字段同步处理,防止fileid重复导致添加失败
  		  List<String> tables=new ArrayList<String>();
  		  List<String> forms=new ArrayList<String>();
  		  RecordSet rs=new RecordSet();
  		  rs.execute("select billid,tablename from meeting_bill where defined="+scopeid);
  		  while(rs.next()){
  			  if(!"".equals(rs.getString("tablename"))&&!"".equals(rs.getString("billid"))){
  				  tables.add(rs.getString("tablename"));
  				  forms.add(rs.getString("billid"));
  			  }
  		  }
  		  
	      rsField.executeSql("select max(fieldid) from meeting_formfield");
	      if(rsField.next()){
	          temId = rsField.getInt(1);
	      }
	      
	      if(temId == -1){
	          temId = 0;
	      }else{
	          temId ++;
	      }
	      
	      String sql=null;
	      String _fielddbtype=null;
	      if(fieldhtmltype.equals("6")||(fieldhtmltype.equals("3")&&(type.equals("161")||type.equals("162")||type.equals("17")))){
	      	boolean isoracle = (rsField.getDBType()).equals("oracle") ;
	      	boolean isdb2 = (rsField.getDBType()).equals("db2") ;        	
	      	if(fieldhtmltype.equals("6")){
				if(isoracle) _fielddbtype="varchar2(1000)";
				else if(isdb2) _fielddbtype="varchar(1000)";
				else _fielddbtype="varchar(1000)";
				fielddbtype=_fielddbtype;
			}
	      	if(type.equals("161")){
				if(isoracle) _fielddbtype="varchar2(1000)";
				else if(isdb2) _fielddbtype="varchar(1000)";
				else _fielddbtype="varchar(1000)";
			}else if(type.equals("17")){//多人力资源
				if(isoracle) {
					fielddbtype="clob";
		  		}
				_fielddbtype=fielddbtype;
			}else{
				if(isoracle) _fielddbtype="varchar2(4000)";
				else if(isdb2) _fielddbtype="varchar(2000)";
				else _fielddbtype="text";
			}      	
	      }else{
	    	  _fielddbtype=fielddbtype;
	      }
	      sql="alter table "+this.base_datatable+" add "+fieldname+" "+_fielddbtype;
	      RecordSetTrans rst = new RecordSetTrans();
	      try{
	      	rst.setAutoCommit(false);
	      	rst.executeSql(sql);
	      	sql = " insert into meeting_formfield (fieldid ,fielddbtype , fieldname ,fieldlabel ,fieldhtmltype , " 
	      			+ " type, fieldorder ,ismand ,isuse ,groupid, allowhide,issystem,isrepeat,grouptype)" 
	      			+ " values("+temId+",'"+fielddbtype+"','"+fieldname+"','"+fieldlabel+"','"+fieldhtmltype+"','"+type+"',"
	      			+ fieldorder+","+ismand+","+isuse+","+groupid+",1,-1,-1,"+grouptype+")";
	      	rst.executeSql(sql);
	      	if(tables.size()>0){
	      		String temp_table="";
	      		String temp_formid="";
	      		for(int i=0;i<tables.size();i++){
	      			String detail_table="";
		      		String isdetailstr="0";
	      			temp_table=tables.get(i);
	      			temp_formid=forms.get(i);
	      			sql="alter table "+temp_table+" add "+fieldname+" "+_fielddbtype;
	      			rst.executeSql(sql);
	      			if(isdetail){
	      				detail_table=temp_table;
	      				isdetailstr="1";
	      			}
	      			//往workflow_fieldbill
	      			sql = " insert into workflow_billfield (BILLID, FIELDNAME, FIELDLABEL, FIELDDBTYPE, " +
	      					"FIELDHTMLTYPE, TYPE, VIEWTYPE, DETAILTABLE, FROMUSER,DSPORDER) "
		      			+ "values ( "+temp_formid+", '"+fieldname+"', "+fieldlabel+", '"+fielddbtype+"', '"+fieldhtmltype+"', "+type+", "+isdetailstr+", '"+detail_table+"',0, "+temId+")";
	      			rst.executeSql(sql);
	      			rst.executeSql("insert into meeting_wf_relation(defined,fieldid,fieldname,billid,bill_fieldname) values("+
	      					scopeid+","+temId+",'"+fieldname+"',"+temp_formid+",'"+fieldname+"')");
	      		}
	      	}
	      	rst.commit();
	      }catch(Exception e){
	      	rsField.writeLog(e);
	      	rst.rollback();
	      	return -1;
	      }  
  	  }
      return temId;
  }
  
  /**
   * 更新字段
   * @param fieldname
   * @param fieldlabel
   * @param fieldorder
   * @param ismand
   * @param isuse
   * @param groupid
   */
  public void editField( String fieldid,String fieldorder, String ismand, String isuse, String groupid){
		String sql = null;
		RecordSet rs = new RecordSet();
    sql = " update meeting_formfield set fieldorder='"+fieldorder+"',ismand='"+ismand+"'," 
    		+ " isuse='"+isuse+"',groupid='"+groupid+"' " 
    		+ " where fieldid="+fieldid;
    rs.executeSql(sql);
	} 
  
/**
 * 删除字段
 * @param fieldname
 */
  public void deleteFields(String fieldid) {
	  String fieldname = this.allFiledsNameMap.get(fieldid);
	if(!sysFiledsId.contains(fieldid)&&!getIsUsed(fieldname)){//排除排除系统和已经使用的字段
		RecordSetTrans rst = new RecordSetTrans(); 
	  	try{
	     	rst.setAutoCommit(false);
	     	rst.executeSql("delete from meeting_formfield where fieldid= "+fieldid);
	     	rst.executeSql("alter table "+this.base_datatable+" drop column "+fieldname);
	     	//删除字段对应表相应数据
	     	rst.executeSql("delete from meeting_wf_relation where fieldid="+fieldid);
	     	rst.commit();
	    }catch(Exception e){
	     	rsField.writeLog(e);
	     	rst.rollback();
	    }  
	}
  }
  
  /**
   * 取得自定义字段的数据
   * @param id
   */
  public void getCustomData(int id) {
      rsData.executeSql("select * from "+this.base_datatable+" where id = " + id);
      rsData.next();
  }
  
  /**
   * 得到指定字段的自定义数据值
   * @param key
   * @return
   */
  public String getData(String key) {
  	try{
  		return rsData.getString(key);
  	}catch(Exception e){
  		rsData.writeLog(e);
  		return "";
  	}
  }
  
  /**
   * 得到指定字段的自定义数据值
   * @param key
   * @return
   */
  public String getData(String key,RecordSet rs) {
  	try{
  		return rs.getString(key);
  	}catch(Exception e){
  		rs.writeLog(e);
  		return "";
  	}
  }
  
  public String getFieldvalue(User user, int fieldId, int fieldHtmlType,
			int fieldType, String fieldValue, int isBill) throws Exception {
		return this.getFieldvalue(null, user, null, null, fieldId,
				fieldHtmlType, fieldType, fieldValue, isBill);
	}

	public String getFieldvalue(HttpSession session, int fieldId,
			int fieldHtmlType, int fieldType, String fieldValue, int isBill)
			throws Exception {
		return this.getFieldvalue(session, null, null, null, fieldId,
				fieldHtmlType, fieldType, fieldValue, isBill);
	}

	public String getFieldvalue(HttpSession session, User user,
			String workflowid, String requestid, int fieldId,
			int fieldHtmlType, int fieldType, String fieldValue, int isBill)
			throws Exception {
		RecordSet rs = new RecordSet();
		if (session != null)
			user = (User) session.getAttribute("weaver_user@bean");
		String showname = "";
		if(!"".equals(fieldValue)){
			if (fieldHtmlType == 3) {
				ArrayList tempshowidlist = Util.TokenizerString(fieldValue, ",");
				if (fieldType == 1 || fieldType == 17) { // 人员，多人员
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new ResourceComInfo()
								.getResourcename((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 2 || fieldType == 19) { // 日期,时间
					// showname += preAdditionalValue;
					showname += fieldValue;
				} else if (fieldType == 4 || fieldType == 57) { // 部门，多部门
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new DepartmentComInfo()
								.getDepartmentname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 8 || fieldType == 135) { // 项目，多项目
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new ProjectInfoComInfo()
								.getProjectInfoname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 7 || fieldType == 18) { // 客户，多客户
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new CustomerInfoComInfo()
								.getCustomerInfoname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 164) { // 分部
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new SubCompanyComInfo()
								.getSubCompanyname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 9) { // 单文档
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new DocComInfo()
								.getDocname((String) tempshowidlist.get(k));
					}
				} else if (fieldType == 37) { // 多文档
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new DocComInfo()
								.getDocname((String) tempshowidlist.get(k)) + ",";
					}
				} else if (fieldType == 23) { // 资产
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new CapitalComInfo()
								.getCapitalname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 16 || fieldType == 152) { // 相关请求
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new WorkflowRequestComInfo()
								.getRequestName((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 142) {// 收发文单位
					DocReceiveUnitComInfo docReceiveUnitComInfo = new DocReceiveUnitComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += docReceiveUnitComInfo
								.getReceiveUnitName((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 226 || fieldType == 227) {// -zzl系统集成浏览按钮
					showname += fieldValue;
				} else if (fieldType == 268 ) {// 多星期
					showname += MeetingBrowser.getWeekNames(fieldValue, user.getLanguage());
				} else if (fieldType == 269 ) {// 多提醒方式
					showname += MeetingBrowser.getRemindNames(fieldValue, user.getLanguage());
				} else {
					String sql = "";
					String tablename = new BrowserComInfo().getBrowsertablename(""
							+ fieldType);
					String columname = new BrowserComInfo().getBrowsercolumname(""
							+ fieldType);
					String keycolumname = new BrowserComInfo()
							.getBrowserkeycolumname("" + fieldType);
					if (columname.equals("") || tablename.equals("")
							|| keycolumname.equals("") || fieldValue.equals("")) {
						//writeLog("GET FIELD ERR: fieldType=" + fieldType);
					} else {
						sql = "select " + columname + " from " + tablename
								+ " where " + keycolumname + " in(" + fieldValue
								+ ")";
						rs.executeSql(sql);
						while (rs.next()) {
							showname += rs.getString(1) + ",";
						}
					}
				}
				if (showname.endsWith(",")) {
					showname = showname.substring(0, showname.length() - 1);
				}
			} else if (fieldHtmlType == 4) { // check框
				if (fieldValue.equals("1")) {
					showname += "√";
				}
			} else if (fieldHtmlType == 5) { // 选择框 select
				// 查询选择框的所有可以选择的值
				rs.executeSql("select selectlabel,selectvalue,selectname from meeting_selectitem where fieldid = "
						+ fieldId + "  order by listorder,id");
				while (rs.next()) {
					String tmpselectvalue = Util.null2String(rs.getString("selectvalue"));
					String selectlabel = Util.null2String(rs.getString("selectlabel"));
					String tmpselectname="";
					if(!"".equals(selectlabel)){
						tmpselectname=SystemEnv.getHtmlLabelName(Util.getIntValue(selectlabel),user.getLanguage());
					}else{
						tmpselectname= Util.toScreen(rs.getString("selectname"), user.getLanguage());
					}
					 
					if (tmpselectvalue.equals(fieldValue)) {
						showname += tmpselectname;
					}
				}
			} else if (fieldHtmlType == 6) { // 附件
				
				if (!fieldValue.equals("")) {
					
					DocImageManager docImageManager = new DocImageManager();
					SecCategoryComInfo secCategoryComInfo = new SecCategoryComInfo();
	                String sql = "select id,docsubject,accessorycount,seccategory,doccreatedate,doccreatetime from docdetail where id in(" + fieldValue + ") order by id asc";
	                rs.executeSql(sql);
	                int AttachmentCounts = rs.getCounts();
	                int linknum = -1;
	                while (rs.next()) {
	                  linknum++;
	                  String showid = Util.null2String(rs.getString("id"));
	                  int accessoryCount = rs.getInt("accessorycount");
	                  String SecCategory = Util.null2String(rs.getString("seccategory"));
	                  String doccreatedate = Util.null2String(rs.getString("doccreatedate"));
		              String doccreatetime = Util.null2String(rs.getString("doccreatetime"));
		              
	                  docImageManager.resetParameter();
	                  docImageManager.setDocid(Integer.parseInt(showid));
	                  docImageManager.selectDocImageInfo();

	                  String docImagefileid = "";
	                  long docImagefileSize = 0;
	                  String docImagefilename = "";
	                  String fileExtendName = "";
	                  int versionId = 0;

	                  if (docImageManager.next()) {
	                    // docImageManager会得到doc第一个附件的最新版本
	                    docImagefileid = docImageManager.getImagefileid();
	                    docImagefileSize = docImageManager.getImageFileSize(Util.getIntValue(docImagefileid));
	                    docImagefilename = docImageManager.getImagefilename();
	                    fileExtendName = docImagefilename.substring(docImagefilename.lastIndexOf(".") + 1).toLowerCase();
	                    versionId = docImageManager.getVersionId();
	                  }
	                  if (accessoryCount > 1) {
	                    fileExtendName = "htm";
	                  }
	                  boolean nodownload = secCategoryComInfo.getNoDownload(SecCategory).equals("1") ? true : false;
	                  String imgSrc = AttachFileUtil.getImgStrbyExtendName(fileExtendName, 20);
	                  showname += imgSrc + "\n";
	                  if (accessoryCount == 1 && (Util.isExt(fileExtendName)||fileExtendName.equalsIgnoreCase("pdf"))) {
	                	  showname += "<a style=\"cursor:pointer\" onclick=\"opendoc('" + showid + "','" + versionId + "','" + docImagefileid + "',1)\">" + docImagefilename + "</a>&nbsp;" + "\n";
	                  } else {
	                      showname += "<a style=\"cursor:pointer\" onclick=\"opendoc1('" + showid + "')\">" + docImagefilename + "</a>&nbsp;" + "\n";
	                  }
	                  if(true){
		                    if (accessoryCount == 1 && ((!fileExtendName.equalsIgnoreCase("xls") && !fileExtendName.equalsIgnoreCase("doc") && !fileExtendName.equalsIgnoreCase("ppt") && !fileExtendName.equalsIgnoreCase("xlsx") && !fileExtendName.equalsIgnoreCase("docx") && !fileExtendName.equalsIgnoreCase("pptx") && !fileExtendName.equalsIgnoreCase("pdf") && !fileExtendName.equalsIgnoreCase("pdfx")) || !nodownload)) {
		                    	showname += "<span id=\"selectDownload\">" + "\n";
		                      if ((!fileExtendName.equalsIgnoreCase("xls") && !fileExtendName.equalsIgnoreCase("doc") && !fileExtendName.equalsIgnoreCase("ppt") && !fileExtendName.equalsIgnoreCase("xlsx") && !fileExtendName.equalsIgnoreCase("docx") && !fileExtendName.equalsIgnoreCase("pptx") && !fileExtendName.equalsIgnoreCase("pdf") && !fileExtendName.equalsIgnoreCase("pdfx")) || !nodownload) {
		                    	  showname += "<button type=button  class=\"e8_btn_cancel\" accessKey=\"1\" onclick=\"downloads('" + docImagefileid + "')\">" + "\n";
		                    	  showname += "<u>" + linknum + "</u>-" + SystemEnv.getHtmlLabelName(258, 7) + "		(" + (docImagefileSize / 1000) + "K)" + "\n";
		                    	  showname += "</button>" + "\n";
		                      }
		                      showname += "</span>" + "\n";
		                    }
	                  }
	                }
				}
				/*
				rs.executeSql("select imagefileid, imagefilename from imagefile where imagefileid in (SELECT imagefileid FROM docimagefile WHERE docid in ("+ fieldValue +") ) order by imagefileid asc");
				while (rs.next()) {
					String fileid = rs.getString("imagefileid");
					String filename = rs.getString("imagefilename");
					showname += "<a style=\"cursor:hand\" href=\"/weaver/weaver.file.FileDownload?fileid="+fileid+"&download=1\" target=\"_blank\">" + filename + "</a>&nbsp;&nbsp;&nbsp;&nbsp;";
					showname += "[<A style=\"cursor:hand\" href=\"/weaver/weaver.file.FileDownload?fileid="+fileid+"&download=1\" target=\"_blank\">下载</A>]&nbsp;<br>" + "\n";
				}
				*/
			} else {
				showname = fieldValue;
			}
		}
		return showname;
  }
	public String getAttachFieldvalue(User user, int fieldId, int fieldHtmlType,int fieldType, String fieldValue, int isBill,String meetingid) throws Exception{
		 // 附件
		RecordSet rs = new RecordSet();
		String showname = "";
		if (!fieldValue.equals("")) {
			//如果添加的附件是在会议创建之后添加 new标示
			String createdate = "";
			String createtime = "";
			String _sql = "SELECT createdate,createtime FROM MEETING where id='"+meetingid+"'";
			rs.executeSql(_sql);
			if(rs.next()){
				createdate = Util.null2String(rs.getString("createdate"));
				createtime = Util.null2String(rs.getString("createtime"));
			}
			boolean isnewAttach = false;
			DocImageManager docImageManager = new DocImageManager();
			SecCategoryComInfo secCategoryComInfo = new SecCategoryComInfo();
            String sql = "select id,docsubject,accessorycount,seccategory,doccreatedate,doccreatetime from docdetail where id in(" + fieldValue + ") order by id asc";
            rs.executeSql(sql);
            int AttachmentCounts = rs.getCounts();
            int linknum = -1;
            while (rs.next()) {
	              linknum++;
	              String showid = Util.null2String(rs.getString("id"));
	              int accessoryCount = rs.getInt("accessorycount");
	              String SecCategory = Util.null2String(rs.getString("seccategory"));
	              String doccreatedate = Util.null2String(rs.getString("doccreatedate"));
	              String doccreatetime = Util.null2String(rs.getString("doccreatetime"));
	              java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	      		  try {
	      			  Date dt1 = sdf.parse(createdate+" "+createtime);
	      			  Date dt2 = sdf.parse(doccreatedate+" "+doccreatetime);
	      			  if( dt1.getTime() < dt2.getTime()){
	      				  isnewAttach = true;
	      			  }
	      		  } catch (Exception e) {
	      			  isnewAttach = false;
	      		  }
	              docImageManager.resetParameter();
	              docImageManager.setDocid(Integer.parseInt(showid));
	              docImageManager.selectDocImageInfo();
	
	              String docImagefileid = "";
	              long docImagefileSize = 0;
	              String docImagefilename = "";
	              String fileExtendName = "";
	              int versionId = 0;
	
	              if (docImageManager.next()) {
	                // docImageManager会得到doc第一个附件的最新版本
	                docImagefileid = docImageManager.getImagefileid();
	                docImagefileSize = docImageManager.getImageFileSize(Util.getIntValue(docImagefileid));
	                docImagefilename = docImageManager.getImagefilename();
	                fileExtendName = docImagefilename.substring(docImagefilename.lastIndexOf(".") + 1).toLowerCase();
	                versionId = docImageManager.getVersionId();
	              }
	              if(isnewAttach){
	            	  docImagefilename +="<img align=\"absbottom\" src=\"/images/BDNew_wev8.gif\" border=\"0\"/>";
	              }
	              if (accessoryCount > 1) {
	                fileExtendName = "htm";
	              }
	              boolean nodownload = secCategoryComInfo.getNoDownload(SecCategory).equals("1") ? true : false;
	              String imgSrc = AttachFileUtil.getImgStrbyExtendName(fileExtendName, 20);
	              showname += imgSrc + "\n";
	              if (accessoryCount == 1 && (Util.isExt(fileExtendName)||fileExtendName.equalsIgnoreCase("pdf"))) {
	            	  showname += "<a style=\"cursor:pointer\" onclick=\"opendoc('" + showid + "','" + versionId + "','" + docImagefileid + "',1)\">" + docImagefilename + "</a>&nbsp;" + "\n";
	              } else {
	                  showname += "<a style=\"cursor:pointer\" onclick=\"opendoc1('" + showid + "')\">" + docImagefilename + "</a>&nbsp;" + "\n";
	              }
	              if(true){
	                    if (accessoryCount == 1 && ((!fileExtendName.equalsIgnoreCase("xls") && !fileExtendName.equalsIgnoreCase("doc") && !fileExtendName.equalsIgnoreCase("ppt") && !fileExtendName.equalsIgnoreCase("xlsx") && !fileExtendName.equalsIgnoreCase("docx") && !fileExtendName.equalsIgnoreCase("pptx") && !fileExtendName.equalsIgnoreCase("pdf") && !fileExtendName.equalsIgnoreCase("pdfx")) || !nodownload)) {
	                    	showname += "<span id=\"selectDownload\">" + "\n";
	                      if ((!fileExtendName.equalsIgnoreCase("xls") && !fileExtendName.equalsIgnoreCase("doc") && !fileExtendName.equalsIgnoreCase("ppt") && !fileExtendName.equalsIgnoreCase("xlsx") && !fileExtendName.equalsIgnoreCase("docx") && !fileExtendName.equalsIgnoreCase("pptx") && !fileExtendName.equalsIgnoreCase("pdf") && !fileExtendName.equalsIgnoreCase("pdfx")) || !nodownload) {
	                    	  showname += "<button type=button  class=\"e8_btn_cancel\" accessKey=\"1\" onclick=\"downloads('" + docImagefileid + "')\">" + "\n";
	                    	  showname += "<u>" + linknum + "</u>-" + SystemEnv.getHtmlLabelName(258, 7) + "		(" + (docImagefileSize / 1000) + "K)" + "\n";
	                    	  showname += "</button>" + "\n";
	                      }
	                      showname += "</span>" + "\n";
	                    }
	              }
            }
		}
		/*
		rs.executeSql("select imagefileid, imagefilename from imagefile where imagefileid in (SELECT imagefileid FROM docimagefile WHERE docid in ("+ fieldValue +") ) order by imagefileid asc");
		while (rs.next()) {
			String fileid = rs.getString("imagefileid");
			String filename = rs.getString("imagefilename");
			showname += "<a style=\"cursor:hand\" href=\"/weaver/weaver.file.FileDownload?fileid="+fileid+"&download=1\" target=\"_blank\">" + filename + "</a>&nbsp;&nbsp;&nbsp;&nbsp;";
			showname += "[<A style=\"cursor:hand\" href=\"/weaver/weaver.file.FileDownload?fileid="+fileid+"&download=1\" target=\"_blank\">下载</A>]&nbsp;<br>" + "\n";
		}
		*/
	    return showname;
	}
	
	public String getHtmlBrowserFieldvalue(User user,int fieldId,
			int fieldHtmlType, int fieldType, String fieldValue)
			throws Exception {
		RecordSet rs = new RecordSet();
		String showname = "";
		if(!"".equals(fieldValue)){
			//<a href="/hrm/resource/HrmResource.jsp?id=360" target="_blank">lyx04</a>
			BrowserComInfo browserComInfo = new BrowserComInfo();
			String linkurl =browserComInfo.getLinkurl(""+fieldType);
			boolean isLink=!"".equals(linkurl);
			String linkurlStart="<a href=\""+linkurl;
			String linkurlEnd="\" target=\"_blank\">";
			String aEnd="</a>";
			if (fieldHtmlType == 3) {
				ArrayList tempshowidlist = Util.TokenizerString(fieldValue, ",");
				if (fieldType == 1 || fieldType == 17) { // 人员，多人员
					ResourceComInfo resourceComInfo=new ResourceComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+resourceComInfo.getResourcename((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":resourceComInfo.getResourcename((String) tempshowidlist.get(k))+"&nbsp;&nbsp;";
						if((k+1)%10==0) showname+="<br>";
					}
				} else if (fieldType == 2 || fieldType == 19) { // 日期,时间
					// showname += preAdditionalValue;
					showname += fieldValue;
				} else if (fieldType == 4 || fieldType == 57) { // 部门，多部门
					DepartmentComInfo departmentComInfo=new DepartmentComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+departmentComInfo.getDepartmentname((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":departmentComInfo.getDepartmentname((String) tempshowidlist.get(k))+"&nbsp;&nbsp;";
					}
				} else if (fieldType == 8 || fieldType == 135) { // 项目，多项目
					ProjectInfoComInfo projectInfoComInfo=new ProjectInfoComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+projectInfoComInfo.getProjectInfoname((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":projectInfoComInfo.getProjectInfoname((String) tempshowidlist.get(k))+ "&nbsp;&nbsp;";
					}
				} else if (fieldType == 7 || fieldType == 18) { // 客户，多客户
					CustomerInfoComInfo customerInfoComInfo=new CustomerInfoComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+customerInfoComInfo.getCustomerInfoname((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":customerInfoComInfo.getCustomerInfoname((String) tempshowidlist.get(k))+ "&nbsp;&nbsp;";
					}
				} else if (fieldType == 164) { // 分部
					SubCompanyComInfo subCompanyComInfo=new SubCompanyComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+subCompanyComInfo.getSubCompanyname((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":subCompanyComInfo.getSubCompanyname((String) tempshowidlist.get(k))
								+ "&nbsp;&nbsp;";
					}
				} else if (fieldType == 9) { // 单文档
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+new DocComInfo()
								.getDocname((String) tempshowidlist.get(k))+aEnd:new DocComInfo()
								.getDocname((String) tempshowidlist.get(k));
					}
				} else if (fieldType == 37) { // 多文档
					DocComInfo docComInfo=new DocComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+docComInfo.getDocname((String) tempshowidlist.get(k)) +aEnd+ "&nbsp;&nbsp;":docComInfo.getDocname((String) tempshowidlist.get(k)) + "&nbsp;&nbsp;";
					}
				} else if (fieldType == 23) { // 资产
					CapitalComInfo capitalComInfo=new CapitalComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+capitalComInfo.getCapitalname((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":capitalComInfo.getCapitalname((String) tempshowidlist.get(k))
								+ "&nbsp;&nbsp;";
					}
				} else if (fieldType == 16 || fieldType == 152) { // 相关请求
					WorkflowRequestComInfo workflowRequestComInfo=new WorkflowRequestComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+workflowRequestComInfo.getRequestName((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":workflowRequestComInfo.getRequestName((String) tempshowidlist.get(k))
								+ "&nbsp;&nbsp;";
					}
				} else if (fieldType == 142) {// 收发文单位
					DocReceiveUnitComInfo docReceiveUnitComInfo = new DocReceiveUnitComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += isLink?linkurlStart+tempshowidlist.get(k)+linkurlEnd+docReceiveUnitComInfo.getReceiveUnitName((String) tempshowidlist.get(k))
								+aEnd+ "&nbsp;&nbsp;":docReceiveUnitComInfo.getReceiveUnitName((String) tempshowidlist.get(k))
								+ "&nbsp;&nbsp;";
					}
				} else if (fieldType == 226 || fieldType == 227) {// -zzl系统集成浏览按钮
					showname += fieldValue;
				} else if (fieldType == 268 ) {// 多星期
					showname += MeetingBrowser.getWeekNames(fieldValue, user.getLanguage());
					showname=showname.replace(",", "&nbsp;&nbsp;");
				} else if (fieldType == 269 ) {// 多提醒方式
					showname += MeetingBrowser.getRemindNames(fieldValue, user.getLanguage());
					showname=showname.replace(",", "&nbsp;&nbsp;");
				} else {
					String sql = "";
					String tablename = browserComInfo.getBrowsertablename(""+ fieldType);
					String columname = browserComInfo.getBrowsercolumname(""+ fieldType);
					String keycolumname = browserComInfo.getBrowserkeycolumname("" + fieldType);
					if (columname.equals("") || tablename.equals("")
							|| keycolumname.equals("") || fieldValue.equals("")) {
						//writeLog("GET FIELD ERR: fieldType=" + fieldType);
					} else {
						sql = "select "+ columname +"," +keycolumname+" from " + tablename
								+ " where " + keycolumname + " in(" + fieldValue
								+ ")";
						rs.executeSql(sql);
						while (rs.next()) {
							showname += isLink?linkurlStart+rs.getString(2)+linkurlEnd+rs.getString(1) +aEnd+ "&nbsp;&nbsp;":rs.getString(1) + "&nbsp;&nbsp;";
						}
					}
				}
			}else {
				showname = fieldValue;
			}
		}
		return showname;
  }	
  
	public String getRemindFieldvalue(int fieldId,int fieldHtmlType, int fieldType, String fieldValue,int langid)
			throws Exception {
		RecordSet rs = new RecordSet();
		String showname = "";
		if(!"".equals(fieldValue)){
			if (fieldHtmlType == 3) {
				ArrayList tempshowidlist = Util.TokenizerString(fieldValue, ",");
				if (fieldType == 1 || fieldType == 17) { // 人员，多人员
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new ResourceComInfo()
								.getResourcename((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 2 || fieldType == 19) { // 日期,时间
					// showname += preAdditionalValue;
					showname += fieldValue;
				} else if (fieldType == 4 || fieldType == 57) { // 部门，多部门
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new DepartmentComInfo()
								.getDepartmentname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 8 || fieldType == 135) { // 项目，多项目
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new ProjectInfoComInfo()
								.getProjectInfoname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 7 || fieldType == 18) { // 客户，多客户
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new CustomerInfoComInfo()
								.getCustomerInfoname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 164) { // 分部
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new SubCompanyComInfo()
								.getSubCompanyname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 9) { // 单文档
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new DocComInfo()
								.getDocname((String) tempshowidlist.get(k));
					}
				} else if (fieldType == 37) { // 多文档
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new DocComInfo()
								.getDocname((String) tempshowidlist.get(k)) + ",";
					}
				} else if (fieldType == 23) { // 资产
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new CapitalComInfo()
								.getCapitalname((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 16 || fieldType == 152) { // 相关请求
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += new WorkflowRequestComInfo()
								.getRequestName((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 142) {// 收发文单位
					DocReceiveUnitComInfo docReceiveUnitComInfo = new DocReceiveUnitComInfo();
					for (int k = 0; k < tempshowidlist.size(); k++) {
						showname += docReceiveUnitComInfo
								.getReceiveUnitName((String) tempshowidlist.get(k))
								+ ",";
					}
				} else if (fieldType == 226 || fieldType == 227) {// -zzl系统集成浏览按钮
					showname += fieldValue;
				}else {
					String sql = "";
					String tablename = new BrowserComInfo().getBrowsertablename(""
							+ fieldType);
					String columname = new BrowserComInfo().getBrowsercolumname(""
							+ fieldType);
					String keycolumname = new BrowserComInfo()
							.getBrowserkeycolumname("" + fieldType);
					if (columname.equals("") || tablename.equals("")
							|| keycolumname.equals("") || fieldValue.equals("")) {
						//writeLog("GET FIELD ERR: fieldType=" + fieldType);
					} else {
						sql = "select " + columname + " from " + tablename
								+ " where " + keycolumname + " in(" + fieldValue
								+ ")";
						rs.executeSql(sql);
						while (rs.next()) {
							showname += rs.getString(1) + ",";
						}
					}
				}
				if (showname.endsWith(",")) {
					showname = showname.substring(0, showname.length() - 1);
				}
			}else if (fieldHtmlType == 5) { // 选择框 select
				// 查询选择框的所有可以选择的值
				rs.executeSql("select selectlabel,selectvalue,selectname from meeting_selectitem where fieldid = "
						+ fieldId + "  order by listorder,id");
				while (rs.next()) {
					String tmpselectvalue = Util.null2String(rs.getString("selectvalue"));
					String selectlabel = Util.null2String(rs.getString("selectlabel"));
					String tmpselectname="";
					if(!"".equals(selectlabel)){
						tmpselectname=SystemEnv.getHtmlLabelName(Util.getIntValue(selectlabel),langid);
					}else{
						tmpselectname= Util.toScreen(rs.getString("selectname"), langid);
					}
					 
					if (tmpselectvalue.equals(fieldValue)) {
						showname += tmpselectname;
					}
				}
			}else {
				showname = fieldValue;
			}
		}
		return showname;
  }
	
  /**
   * 编辑自定义数据-主表
   * @param request
   * @param dataId
   */
  public void editCustomData(HttpServletRequest request, int dataId)throws Exception {
  	
      RecordSet rs = new RecordSet();
      rs.executeSql("select "+this.base_id+" from "+this.base_datatable+" where "+this.base_id+"=" + dataId);
      if (rs.next()) {
    	  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
	        Set<String> lsFieldid = this.custFiledsId;
	        String sql = "update "+this.base_datatable+" set ";
	        String setStr = "";
	        for(String fieldid:lsFieldid){
	        	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
	        	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
	        	String requestname=fieldname;
	        	if("6".equals(fieldhtmltype)){
	        		requestname="field"+fieldid;
	        	}
	        	 
	        	setStr += "," + fieldname + "=";
	        	String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
	            if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") || fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
	               setStr += "'" + Util.null2String(request.getParameter(requestname)) + "'";
	            } else {
		           if (Util.null2String(request.getParameter(requestname)).equals("")) {
	                  setStr += "null";
	               } else {
	            	  setStr += Util.null2String(request.getParameter(requestname));
	               }
	           }
	        }
	        if (!setStr.equals("")) {
	          setStr = setStr.substring(1);
	          sql += setStr + " where "+this.base_id+"=" + dataId;
	          rs.executeSql(sql);
	        }
	        //对需要删除的附件进行处理
	        List<String> allFieldid = this.allFiledsId;
	        for(String fieldid:allFieldid){
	        	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
	        	if(!"6".equals(fieldhtmltype)) continue;
	        	//删除无效附件
	        	removeAttachment(request,fieldid);
	       }
      }

  }

  /**
   * 编辑自定义数据-主表
   * @param request
   * @param dataId
   */
  public void editCustomData(FileUpload request, int dataId)throws Exception {
  	
      RecordSet rs = new RecordSet();
      //判断系统字段,是否保存成功
      rs.executeSql("select "+this.base_id+" from "+this.base_datatable+" where "+this.base_id+"=" + dataId);
      if (rs.next()) {
    	  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
          Set<String> lsFieldid = this.custFiledsId;
          String sql = "update "+this.base_datatable+" set ";
          String setStr = "";
          for(String fieldid:lsFieldid){
	        	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
	        	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
	        	String requestname=fieldname;
	        	if("6".equals(fieldhtmltype)){
	        		requestname="field"+fieldid;
	        	} 
	        	setStr += "," + fieldname + "=";
	        	String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
	            if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") || fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
	               setStr += "'" + Util.null2String(request.getParameter(requestname)) + "'";
	            } else {
		           if (Util.null2String(request.getParameter(requestname)).equals("")) {
	                  setStr += "null";
	               } else {
	            	  setStr += Util.null2String(request.getParameter(requestname));
	               }
	           }
          }
          if (!setStr.equals("")) {
              setStr = setStr.substring(1);

              sql += setStr + " where "+this.base_id+"=" + dataId;
              rs.executeSql(sql);
          }
          //对需要删除的附件进行处理
          List<String> allFieldid = this.allFiledsId;
          for(String fieldid:allFieldid){
        	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
        	if(!"6".equals(fieldhtmltype)) continue;
        	//删除无效附件
        	removeAttachment(request,fieldid);
         }
      }

  }
  
  /**
   * 编辑自定义数据
   * @param rsData
   * @param dataId
   */
  public void editCustomData(RecordSet rsData, int dataId,boolean iscopy)throws Exception {
  	
      RecordSet rs = new RecordSet();
      rs.executeSql("select "+this.base_id+" from "+this.base_datatable+" where "+this.base_id+"=" + dataId);
      if (rs.next()) {
    	  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
	        Set<String> lsFieldid = this.custFiledsId;
	        String sql = "update "+this.base_datatable+" set ";
	        String setStr = "";
	        for(String fieldid:lsFieldid){
	        	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
	        	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
	        	if(iscopy&&"6".equals(fieldhtmltype)) continue;//如果是复制,附件上传字段不复制
	        	setStr += "," + fieldname + "=";
	        	String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
	            if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") || fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
	               setStr += "'" + Util.null2String(rsData.getString(fieldname)) + "'";
	            } else {
		           if (Util.null2String(rsData.getString(fieldname)).equals("")) {
	                  setStr += "null";
	               } else {
	            	  setStr += Util.null2String(rsData.getString(fieldname));
	               }
	           }
	        }
        if (!setStr.equals("")) {
          setStr = setStr.substring(1);
          sql += setStr + " where "+this.base_id+"=" + dataId;
          rs.executeSql(sql);
        }
      }

  }
  /**
   * 编辑自定义数据
   * 明细表,字段使用 fieldname+fieldid+rowindex 组合
   * @param request
   * @param dataId
   */
  public void editCustomDataDetail(HttpServletRequest request, int dataId,int row,int meeting)throws Exception {
  		
	  if(meeting>0){
		  if(dataId>0){
		      RecordSet rs = new RecordSet();
		      //判断系统字段,是否保存成功
		      rs.executeSql("select "+this.base_id+" from "+this.base_datatable+" where "+this.base_id+"=" + dataId);
		      if (rs.next()) {
		    	  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
		          List<String> lsFieldid = this.allFiledsId;
		          String sql = "update "+this.base_datatable+" set ";
		          String setStr = "";
		          boolean ishaveV = false;
		          for(String fieldid:lsFieldid){
			        	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
			        	if(!"1".equals(hrmFieldComInfo.getIsused(fieldid))) continue;
			        	String requstName=fieldname+"_"+fieldid+"_"+row;//otheritem_48_0
			        	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
			        	if("6".equals(fieldhtmltype)){
			        		requstName = "field"+fieldid+"_"+row;
			        	}
			        	setStr += "," + fieldname + "=";
			        	String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
			        	if(!"".equals(Util.null2String(request.getParameter(requstName)))){
				        	  ishaveV = true;
				        }
			            if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") || fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
			               setStr += "'" + Util.null2String(request.getParameter(requstName)) + "'";
			            } else {
				           if (Util.null2String(request.getParameter(requstName)).equals("")) {
			                  setStr += "null";
			               } else {
			            	  setStr += Util.null2String(request.getParameter(requstName));
			               }
			           }
		          }
		          if (!setStr.equals("") && ishaveV) {
		              setStr = setStr.substring(1);
		              if(this.base_datatable.equalsIgnoreCase("Meeting_Topic_attach")){
			        	  sql += setStr + ",lastDate = '"+ TimeUtil.getCurrentDateString() +"',lastTime = '"+ TimeUtil.getOnlyCurrentTimeString() +"' where "+this.base_id+"=" + dataId;
		              }else{
			        	  sql += setStr + " where "+this.base_id+"=" + dataId;
			          }
		              rs.executeSql(sql);
		          }
		      }
		  }else{
			  //会议服务,没有填写服务项目,忽略数据
			  if(this.base_datatable.equalsIgnoreCase("Meeting_Service_New")){
				  if ("".equals(Util.null2String(request.getParameter("items_46_"+row)))){
					  return;
				  }
			  }
			  //会议议程,没有填写议程主题,忽略数据
			  if(this.base_datatable.equalsIgnoreCase("Meeting_Topic")){
				  if ("".equals(Util.null2String(request.getParameter("subject_41_"+row)))){
					  return;
				  }
			  }
			  RecordSet rs = new RecordSet();
			  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
		      List<String> lsFieldid = this.allFiledsId;
		      String sql = "insert into "+this.base_datatable;
		      String nameStr = "";
		      String valueStr = "";
		      boolean ishaveV = false;
		      for(String fieldid:lsFieldid){
		      	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
		      	String requstName=fieldname+"_"+fieldid+"_"+row;//otheritem_48_0
		      	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
		      	if("6".equals(fieldhtmltype)){
	        		requstName = "field"+fieldid+"_"+row;
	        	}
		        nameStr += "," + fieldname;
		        String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
		        if(!"".equals(Util.null2String(request.getParameter(requstName)))){
		        	  ishaveV = true;
		        }
		          if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") ||
		          		fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
		              valueStr += ",'" + Util.null2String(request.getParameter(requstName)) + "'";
		          } else {
		          		if (Util.null2String(request.getParameter(requstName)).equals("")) {
		                  valueStr += ",null";
		              } else {
		                  valueStr += "," + Util.null2String(request.getParameter(requstName));
		              }
		          }
		      }
		      if (!nameStr.equals("") && ishaveV) {
		          nameStr = nameStr.substring(1);
		          valueStr = valueStr.substring(1);
		          if(this.base_datatable.equalsIgnoreCase("Meeting_Topic_attach")){
		        	  sql += "(meetingid," + nameStr + ",lastDate,lastTime) values(" + meeting + "," + valueStr + ",'"+TimeUtil.getCurrentDateString()+"','"+ TimeUtil.getOnlyCurrentTimeString() +"')";
		          }else{
		        	  sql += "(meetingid," + nameStr + ") values(" + meeting + "," + valueStr + ")";
		          }
		          //System.out.println("sql = " + sql);
		          rs.executeSql(sql);
		      }
		  }
		  
		  
	  }

  }
  
  /**
   * 编辑自定义数据
   * 明细表,字段使用 fieldname+fieldid+rowindex 组合
   * @param request
   * @param dataId
   */
  public void editCustomDataDetail(FileUpload request, int dataId,int row,int meeting)throws Exception {
  		
	  if(meeting>0){
		  if(dataId>0){
		      RecordSet rs = new RecordSet();
		      //判断系统字段,是否保存成功
		      rs.executeSql("select "+this.base_id+" from "+this.base_datatable+" where "+this.base_id+"=" + dataId);
		      if (rs.next()) {
		    	  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
		          List<String> lsFieldid = this.allFiledsId;
		          String sql = "update "+this.base_datatable+" set ";
		          String setStr = "";
		          boolean ishaveV = false;
		          for(String fieldid:lsFieldid){
			        	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
			        	if(!"1".equals(hrmFieldComInfo.getIsused(fieldid))) continue;
			        	String requstName=fieldname+"_"+fieldid+"_"+row;//otheritem_48_0
			        	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
			        	//field57_1
			        	if("6".equals(fieldhtmltype)){
			        		requstName = "field"+fieldid+"_"+row;
			        	}
			        	setStr += "," + fieldname + "=";
			        	String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
			        	if(!"".equals(Util.null2String(request.getParameter(requstName)))){
				        	  ishaveV = true;
				        }
			            if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") || fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
			               setStr += "'" + Util.null2String(request.getParameter(requstName)) + "'";
			            } else {
				           if (Util.null2String(request.getParameter(requstName)).equals("")) {
			                  setStr += "null";
			               } else {
			            	  setStr += Util.null2String(request.getParameter(requstName));
			               }
			           }
		          }
		          if (!setStr.equals("")&& ishaveV) {
		              setStr = setStr.substring(1);
		              if(this.base_datatable.equalsIgnoreCase("Meeting_Topic_attach")){
			        	  sql += setStr + ",lastDate = '"+ TimeUtil.getCurrentDateString() +"',lastTime = '"+ TimeUtil.getOnlyCurrentTimeString() +"' where "+this.base_id+"=" + dataId;
		              }else{
			        	  sql += setStr + " where "+this.base_id+"=" + dataId;
			          }
		              rs.executeSql(sql);
		          }
		      }
		  }else{
			  //会议服务,没有填写服务项目,忽略数据
			  if(this.base_datatable.equalsIgnoreCase("Meeting_Service_New")){
				  if ("".equals(Util.null2String(request.getParameter("items_46_"+row)))){
					  return;
				  }
			  }
			  //会议议程,没有填写议程主题,忽略数据
			  if(this.base_datatable.equalsIgnoreCase("Meeting_Topic")){
				  if ("".equals(Util.null2String(request.getParameter("subject_41_"+row)))){
					  return;
				  }
			  }
			  //会议议程附件,没有填序号,忽略数据
			  if(this.base_datatable.equalsIgnoreCase("Meeting_Topic_attach")){
				  
			  }
			  
			  RecordSet rs = new RecordSet();
			  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
		      List<String> lsFieldid = this.allFiledsId;
		      String sql = "insert into "+this.base_datatable;
		      String nameStr = "";
		      String valueStr = "";
		      boolean ishaveV = false;
		      for(String fieldid:lsFieldid){
		      	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
		      	String requstName=fieldname+"_"+fieldid+"_"+row;//otheritem_48_0
		      	String fieldhtmltype = hrmFieldComInfo.getFieldhtmltype(fieldid);
		        //field57_1
	        	if("6".equals(fieldhtmltype)){
	        		requstName = "field"+fieldid+"_"+row;
	        	}
		        nameStr += "," + fieldname;
		        
		        String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
		          if(!"".equals(Util.null2String(request.getParameter(requstName)))){
		        	  ishaveV = true;
		          }
		          if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") ||
		          		fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
		              valueStr += ",'" + Util.null2String(request.getParameter(requstName)) + "'";
		          } else {
		          		if (Util.null2String(request.getParameter(requstName)).equals("")) {
		                  valueStr += ",null";
		              } else {
		                  valueStr += "," + Util.null2String(request.getParameter(requstName));
		              }
		          }
		      }
		      if (!nameStr.equals("") && ishaveV) {
		          nameStr = nameStr.substring(1);
		          valueStr = valueStr.substring(1);
		          if(this.base_datatable.equalsIgnoreCase("Meeting_Topic_attach")){
		        	  sql += "(meetingid," + nameStr + ",lastDate,lastTime) values(" + meeting + "," + valueStr + ",'"+TimeUtil.getCurrentDateString()+"','"+ TimeUtil.getOnlyCurrentTimeString() +"')";
		          }else{
		        	  sql += "(meetingid," + nameStr + ") values(" + meeting + "," + valueStr + ")";
		          }
		          //System.out.println("sql = " + sql);
		          rs.executeSql(sql);
		      }
		  }
		  
		  
	  }

  }
  
  /**
   * 复制明细字段
   * 明细表,字段使用 fieldname+fieldid+rowindex 组合
   * @param request
   * @param dataId
   */
  public void editCustomDataDetail(RecordSet reData,int meeting)throws Exception {
	  if(meeting>0&&reData!=null){
		  RecordSet rs = new RecordSet();
		  MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
	      List<String> lsFieldid = this.allFiledsId;
		  while(reData.next()){
		      String sql = "insert into "+this.base_datatable;
		      String nameStr = "";
		      String valueStr = "";
		      for(String fieldid:lsFieldid){
		      	String fieldname = hrmFieldComInfo.getFieldname(fieldid);
		        nameStr += "," + fieldname;
		        String fielddbtype = hrmFieldComInfo.getFielddbtype(fieldid);
		          
		          if (fielddbtype.startsWith("text") || fielddbtype.startsWith("char") ||
		          		fielddbtype.startsWith("varchar")||fielddbtype.startsWith("clob")) {
		              valueStr += ",'" + Util.null2String(reData.getString(fieldname)) + "'";
		          } else {
		          		if (Util.null2String(reData.getString(fieldname)).equals("")) {
		                  valueStr += ",null";
		              } else {
		                  valueStr += "," +Util.null2String(reData.getString(fieldname));
		              }
		          }
		      }
		      if (!nameStr.equals("")) {
		          nameStr = nameStr.substring(1);
		          valueStr = valueStr.substring(1);
		          sql += "(meetingid," + nameStr + ") values(" + meeting + "," + valueStr + ")";
		          
		          if(this.base_datatable.equalsIgnoreCase("Meeting_Topic_attach")){
		        	  sql += "(meetingid," + nameStr + ",lastDate,lastTime) values(" + meeting + "," + valueStr + ",'"+TimeUtil.getCurrentDateString()+"','"+ TimeUtil.getOnlyCurrentTimeString() +"')";
		          }else{
		        	  sql += "(meetingid," + nameStr + ") values(" + meeting + "," + valueStr + ")";
		          }
		          
		          //System.out.println("sql = " + sql);
		          rs.executeSql(sql);
		      }
		  }
	  }

  }
  
  /**
   * 检测更新选择框的字段.
   * @param fieldid 选择框对应的字段id
   * @param value 选择值
   * @param name 选择显示名称
   */
  public void checkSelectField(int fieldid, List value, List name) {
      List srcSel = new ArrayList();
      List selDel = new ArrayList();
      rs.executeSql("select selectvalue from meeting_selectitem where fieldid=" + fieldid);
      while (rs.next()) {
          srcSel.add(rs.getString(1));
          selDel.add(rs.getString(1));
      }
      for (int i = 0; i < value.size(); i++) {
          if (srcSel.contains(String.valueOf(value.get(i)))) {
              rs.executeSql("update meeting_selectitem set selectname='" + name.get(i) + "', listorder=" + i + " where fieldid=" + fieldid + " and selectvalue=" + value.get(i));
          } else if (value.get(i).equals("-1")) {
              int temId = -1;
              rs.executeSql("select max(selectvalue) from meeting_selectitem where fieldid=" + fieldid);
              if (rs.next()) {
                  temId = rs.getInt(1);
              }
              if (temId == -1) {
                  temId = 0;
              } else {
                  temId++;
              }
              rs.executeSql("insert into meeting_selectitem(fieldid,selectvalue,selectname,listorder) values(" + fieldid + "," + temId + ",'" + name.get(i) + "'," + i + ")");
          }else if(Util.getIntValue((String)value.get(i),-1)>=0){
              rs.executeSql("insert into meeting_selectitem(fieldid,selectvalue,selectname,listorder) values(" + fieldid + "," + value.get(i) + ",'" + name.get(i) + "'," + i + ")");            	
          }
          selDel.remove(String.valueOf(value.get(i)));
      }

      String temStr = "";
      for (int i = 0; i < selDel.size(); i++) {
          temStr = temStr + "," + selDel.get(i);
      }
      if (!temStr.equals("")) {
          temStr = temStr.substring(1);
          rs.executeSql("delete from meeting_selectitem where fieldid=" + fieldid + " and selectvalue in(" + temStr + ")");
      }
      //更新流程中的选项值
      RecordSet rs1=new  RecordSet();
      List<String> valueList = new ArrayList<String>();
      List<String> nameList =  new ArrayList<String>();
	  rs1.execute("select selectvalue,selectname from meeting_selectitem where fieldid="+fieldid);
	  while(rs1.next()){
		  valueList.add(rs1.getString("selectvalue"));
		  nameList.add(rs1.getString("selectname"));
	  }
	  if(valueList.size()>0){
		  rs.execute("select * from meeting_wf_relation where fieldid="+fieldid);
		  RecordSet rs2=new  RecordSet();
		  while(rs.next()){
			  String formid=rs.getString("billid");
			  String bill_fieldname=rs.getString("bill_fieldname");
			  rs1.execute("select id from workflow_billfield where billid="+formid+" and fieldname='"+bill_fieldname+"'");
			  if (rs1.next()) {
				 String billfieldid= rs1.getString("id");
				 rs2.execute("select count(1) as c from workflow_selectitem where fieldid="+billfieldid);
				 rs2.next();
				 if(rs2.getInt("c")==0){//没有值,才做插入操作
					 for (int i = 0; i < valueList.size(); i++) {
						 rs2.execute("insert into workflow_selectitem(fieldid,isbill,selectvalue,selectname,cancel,isdefault) " +
					 		"values("+billfieldid+",1,'"+valueList.get(i)+"','"+nameList.get(i)+"',0,'n') ");
					 }
				 }
			  }
		  }
	  }
  }
  
  /**
   * 获取分组中使用的元素个数
   * @param lsField
   * @return
   */
  public int getGroupCount(List lsField){
  	int count =0;
  	MeetingFieldComInfo hrmFieldComInfo = new MeetingFieldComInfo();
  	for(int i=0;lsField!=null&&i<lsField.size();i++){
  		String fieldid = (String)lsField.get(i);
  		if(hrmFieldComInfo.getIsused(fieldid).equals("1")){
  			count++;
  		}
  	}
  	return count;
  }
  
  /**
   * 删除无效附件
   * @param fu
   * @param requestName
   * @param meetingid
   * @param RecordSet
   * @return
   */
  private void removeAttachment(FileUpload fu,String fileid) {
		int deleteField_idnum = Util.getIntValue(fu.getParameter("field"+fileid+"_idnum"),0);
		if(deleteField_idnum>0){
			DocExtUtil mDocExtUtil=new DocExtUtil();
			for(int i=0;i<deleteField_idnum;i++){
				String field_del_flag = Util.null2String(fu.getParameter("field"+fileid+"_del_"+i));
				if(field_del_flag.equals("1")){
					String field_del_value = Util.null2String(fu.getParameter("field" + fileid+"_id_"+i));
					mDocExtUtil.deleteDoc(Util.getIntValue(field_del_value));
				}
			}
		}
  }
  
  /**
   * 删除无效附件
   * @param fu
   * @param requestName
   * @param meetingid
   * @param RecordSet
   * @return
   */
  private void removeAttachment(HttpServletRequest fu,String fileid) {
		int deleteField_idnum = Util.getIntValue(fu.getParameter("field"+fileid+"_idnum"),0);
		if(deleteField_idnum>0){
			DocExtUtil mDocExtUtil=new DocExtUtil();
			for(int i=0;i<deleteField_idnum;i++){
				String field_del_flag = Util.null2String(fu.getParameter("field"+fileid+"_del_"+i));
				if(field_del_flag.equals("1")){
					String field_del_value = Util.null2String(fu.getParameter("field" + fileid+"_id_"+i));
					mDocExtUtil.deleteDoc(Util.getIntValue(field_del_value));
				}
			}
		}
  }
}