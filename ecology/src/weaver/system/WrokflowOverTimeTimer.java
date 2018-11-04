package weaver.system;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;

import weaver.mobile.plugin.ecology.service.PushNotificationService;
import weaver.workflow.request.wfAgentCondition;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import weaver.WorkPlan.CreateWorkplanByWorkflow;
import weaver.conn.RecordSet;
import weaver.conn.RecordSetTrans;
import weaver.crm.Maint.CustomerInfoComInfo;
import weaver.general.BaseBean;
import weaver.general.SendMail;
import weaver.general.StaticObj;
import weaver.general.TimeUtil;
import weaver.general.Util;
import weaver.hrm.User;
import weaver.hrm.resource.ResourceComInfo;
import weaver.interfaces.workflow.action.Action;
import weaver.sms.SMSManager;
import weaver.sms.SmsCache;
import weaver.soa.workflow.WorkFlowInit;
import weaver.soa.workflow.bill.BillBgOperation;
import weaver.soa.workflow.request.RequestService;
import weaver.systeminfo.SystemEnv;
import weaver.wechat.SaveAndSendWechat;
import weaver.wechat.util.WechatPropConfig;
import weaver.workflow.mode.FieldInfo;
import weaver.workflow.msg.PoppupRemindInfoUtil;
import weaver.workflow.request.ComparatorUtilBean;
import weaver.workflow.request.OverTimeSetBean;
import weaver.workflow.request.RequestAddShareInfo;
import weaver.workflow.request.RequestCheckAddinRules;
import weaver.workflow.request.RequestComInfo;
import weaver.workflow.request.RequestManager;
import weaver.workflow.request.RequestNodeFlow;
import weaver.workflow.request.SendMsgAndMail;
import weaver.workflow.request.SubWorkflowTriggerService;
import weaver.workflow.request.WFForwardManager;
import weaver.workflow.request.WFLinkInfo;
import weaver.workflow.request.WFPathUtil;
import weaver.workflow.webservices.WorkflowBaseInfo;
import weaver.workflow.webservices.WorkflowMainTableInfo;
import weaver.workflow.webservices.WorkflowRequestInfo;
import weaver.workflow.webservices.WorkflowRequestTableField;
import weaver.workflow.webservices.WorkflowRequestTableRecord;
import weaver.workflow.webservices.WorkflowService;
import weaver.workflow.webservices.WorkflowServiceImpl;
import weaver.workflow.workflow.WorkflowComInfo;
import weaver.worktask.request.RequestCreateByWF;

/**
 * 工作流超时检查




 * User: mackjoe
 * Date: 2006-4-17
 * Time: 17:19:27
 */
public class WrokflowOverTimeTimer extends BaseBean implements ThreadWork{
    private RecordSet rs;
    private RecordSet rs1;
    private RecordSet rs2;
    private RecordSet rs3;
    private RecordSet rs4;
    private RecordSet rs5;
    private RecordSet rs8;
    private PoppupRemindInfoUtil poppupRemindInfoUtil;
    private ResourceComInfo resource;
    private CustomerInfoComInfo crminfo;
	private OverTimeSetBean overTimeBean;
    private ArrayList operatorsWfEnd;
    private Log log;
    private User user;
    private ArrayList wfremindusers;
    private ArrayList wfusertypes;
    private ArrayList nextnodeids;
    private ArrayList nextnodetypes;
    private ArrayList nextlinkids;
    private ArrayList nextlinknames;
    private ArrayList operatorshts;
    private ArrayList nextnodeattrs;
    private ArrayList nextnodepassnums;
    private ArrayList linkismustpasss;
    private String innodeids="";
    private RequestComInfo requestcominfo;
    private SaveAndSendWechat saveAndSendWechat;//微信提醒(QC:98106)
	private ArrayList operator89List = new ArrayList();//add by liaodong for qc80034  start
    public static final Map<String,String> messageMap=new ConcurrentHashMap<String, String>();
    public WrokflowOverTimeTimer() {
        rs=new RecordSet();
        rs1=new RecordSet();
        rs2=new RecordSet();
        rs3=new RecordSet();
        rs4=new RecordSet();
        rs5=new RecordSet();
        rs8=new RecordSet();
        operatorsWfEnd = new ArrayList();
        wfremindusers = new ArrayList();
        wfusertypes = new ArrayList();
        log= LogFactory.getLog("WrokflowOverTimeTimer");
        poppupRemindInfoUtil = new PoppupRemindInfoUtil();//xwj for td3450 20060111
        try{
            resource=new ResourceComInfo();
            crminfo=new CustomerInfoComInfo();
			overTimeBean=new OverTimeSetBean();
			saveAndSendWechat=new SaveAndSendWechat();//微信提醒(QC:98106)
            user=new User();
            requestcominfo = new RequestComInfo();
        }catch(Exception e){
             e.printStackTrace();
        }
    }

    /**
     * 超时处理
     */
    public void doThreadWork() {
        RecordSet rs = new RecordSet();
        
      //获取系统短信签名,是否是长短信,分割字数
        String sign=Util.null2String(SmsCache.getSmsSet().getSign());
        String signPos=SmsCache.getSmsSet().getSignPos();
        
            //获得数据库服务器当前时间
            String nowdatetime = TimeUtil.getCurrentTimeString();
            String sql="";
            if (rs5.getDBType().equals("oracle")) {
                sql = "select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') nowdatetime from dual";
            } else {
                sql = "select convert(char(10),getdate(),20)+' '+convert(char(8),getdate(),108) nowdatetime";
            }
            rs5.executeSql(sql);
            if (rs5.next()) {
                nowdatetime = rs5.getString("nowdatetime");
            }
            sql="select distinct requestid,nodeid,workflowid,workflowtype from workflow_currentoperator where workflowtype<>1 and isremark='0' and " +
                    "(EXISTS (select 1 from workflow_nodelink t1 where t1.wfrequestid is null and EXISTS (select 1 from workflow_base t2 where t1.workflowid=t2.id and (t2.istemplate is null or t2.istemplate<>'1')) and (t1.nodepasshour>0 or t1.nodepassminute>0 or (t1.dateField is not null and t1.dateField != '')) and workflow_currentoperator.nodeid=t1.nodeid) or " +//路径设置的超时节点




                    "EXISTS (select 1 from workflow_nodelink t1 where EXISTS (select 1 from workflow_base t2 where t1.workflowid=t2.id and (t2.istemplate is null or t2.istemplate<>'1')) and (t1.nodepasshour>0 or t1.nodepassminute>0 or (t1.dateField is not null and t1.dateField != '')) and workflow_currentoperator.nodeid=t1.nodeid and workflow_currentoperator.requestid=t1.wfrequestid)) "+    //前台界面设置的超时




                    "and (isreminded is null or isprocessed is null or isreminded_csh is null) group by requestid,nodeid,workflowid,workflowtype order by requestid asc ,nodeid";
            rs.executeSql(sql);
            while(rs.next()){
                int requestid=rs.getInt("requestid");
                int nodeid=Util.getIntValue(rs.getString("nodeid"));
                int workflowid=Util.getIntValue(rs.getString("workflowid"));
                int workflowtype=Util.getIntValue(rs.getString("workflowtype"));
                ArrayList userlist=new ArrayList();
                ArrayList usertypelist=new ArrayList();
                ArrayList agenttypelist=new ArrayList();
                ArrayList agentorbyagentidlist=new ArrayList();
                ArrayList isremindedlist=new ArrayList();
                ArrayList isreminded_cshlist=new ArrayList();
                ArrayList isprocessedlist=new ArrayList();
                ArrayList currentdatetimelist=new ArrayList();
                ArrayList idlist=new ArrayList();
                boolean isCanSubmit = true;
                sql="select * from workflow_currentoperator where workflowtype<>1 and isremark='0' and (isreminded is null or isprocessed is null or isreminded_csh is null) and requestid="+requestid+" and nodeid="+nodeid+" order by requestid desc,id";
				rs5.executeSql(sql);
                while(rs5.next()){
                    String currentdatetimes=rs5.getString("receivedate")+" "+rs5.getString("receivetime");
                    String userids=rs5.getString("userid");
                    String usertypes=rs5.getString("usertype");
                    String agenttypes=rs5.getString("agenttype");
                    String agentorbyagentids=rs5.getString("agentorbyagentid");
                    String isremindeds=rs5.getString("isreminded");
                    String isreminded_cshs=rs5.getString("isreminded_csh");//超时后提醒




                    String isprocesseds=rs5.getString("isprocessed");
                    String ids=rs5.getString("id");
                    
                    WFForwardManager wfforwardMgr = new WFForwardManager();
                    wfforwardMgr.setWorkflowid(workflowid);
                    wfforwardMgr.setNodeid(nodeid);
                    wfforwardMgr.setIsremark("0");
                    wfforwardMgr.setRequestid(requestid);
                    wfforwardMgr.setBeForwardid(Util.getIntValue(ids));
                    wfforwardMgr.getWFNodeInfo();
                    
                    if (!wfforwardMgr.getCanSubmit()) {
                        isCanSubmit = false;
                        break;
                    }
                    
                    userlist.add(userids);
                    usertypelist.add(usertypes);
                    agenttypelist.add(agenttypes);
                    agentorbyagentidlist.add(agentorbyagentids);
                    isremindedlist.add(isremindeds);
                    isreminded_cshlist.add(isreminded_cshs);
                    isprocessedlist.add(isprocesseds);
                    currentdatetimelist.add(currentdatetimes);
                    idlist.add(ids);
                }
                
                if (!isCanSubmit) continue;
                
                //会签特殊处理,为会签时,只取第一个用户来进行节点流转检查,并获得超时设置信息(因为其它用户获得的信息一样,不重复获取了)
                if(userlist.size()>0){
                int userid=Util.getIntValue((String)userlist.get(0));
                int usertype=Util.getIntValue((String)usertypelist.get(0));
                int isreminded=Util.getIntValue((String)isremindedlist.get(0),0);
                int isreminded_csh=Util.getIntValue((String)isreminded_cshlist.get(0),0);
                int isprocessed=Util.getIntValue((String)isprocessedlist.get(0),0);
                String currentdatetime=(String)currentdatetimelist.get(0);
                int nextlinkid=getNextNode(requestid,nodeid,userid,usertype);
                int language=7;
                user.setUid(userid);
                user.setLogintype((usertype+1)+"");
				user.setLastname(resource.getLastname(userid+""));
                sql="select * from HrmResource where id="+userid;
                rs1.executeSql(sql);
                if(rs1.next()){
                    language=Util.getIntValue(rs1.getString("systemlanguage"),7);
                    user.setLanguage(language);
                }
                sql="select nodeid,isremind,nodepasshour,nodepassminute,remindhour,remindminute,FlowRemind,MsgRemind,MailRemind,ChatsRemind,ProcessorOpinion,"+//微信提醒(QC:98106)
                        "isnodeoperator,iscreater,ismanager,isother,remindobjectids,isautoflow,flownextoperator,flowobjectids,destnodeid"+
                        ",dateField,timeField"+
                        ",CustomWorkflowid"+
                        ",flowobjectreject,flowobjectsubmit"+
                        ",selectnodepass " +
                        ",InfoCentreRemind,InfoCentreRemind_csh,CustomWorkflowid_csh " +
                        " from workflow_nodelink where id="+nextlinkid ;
                //System.out.println(requestid+"|"+nodeid+"sql:"+sql);
                sql = "select * from workflow_nodelink where id="+nextlinkid ;
                //log.debug(nodeid+"sql:"+sql);
                rs1.executeSql(sql);
                if(rs1.next()){
                    int isremind=Util.getIntValue(rs1.getString("isremind"),0);
                    int nodepasshour=Util.getIntValue(rs1.getString("nodepasshour"),0);
                    int nodepassminute=Util.getIntValue(rs1.getString("nodepassminute"),0);
                    
                    String dateField = Util.null2String(rs1.getString("dateField"));
                    String timeField = Util.null2String(rs1.getString("timeField"));
                    
                    int remindhour=Util.getIntValue(rs1.getString("remindhour"),0);
                    int remindminute=Util.getIntValue(rs1.getString("remindminute"),0);
                    int FlowRemind=Util.getIntValue(rs1.getString("FlowRemind"),0);
                    int MsgRemind=Util.getIntValue(rs1.getString("MsgRemind"),0);
                    int MailRemind=Util.getIntValue(rs1.getString("MailRemind"),0);
                    int ChatsRemind=Util.getIntValue(rs1.getString("ChatsRemind"),0); //微信提醒(QC:98106)
                    int isnodeoperator=Util.getIntValue(rs1.getString("isnodeoperator"),0);
                    int iscreater=Util.getIntValue(rs1.getString("iscreater"),0);
                    int ismanager=Util.getIntValue(rs1.getString("ismanager"),0);
                    int isother=Util.getIntValue(rs1.getString("isother"),0);
                    int isautoflow=Util.getIntValue(rs1.getString("isautoflow"),0);
                    int flownextoperator=Util.getIntValue(rs1.getString("flownextoperator"),0);
                    int nodeid_tmp = Util.getIntValue(rs1.getString("nodeid"),0);
                    String remindobjectids=Util.null2String(rs1.getString("remindobjectids"));
                    String flowobjectids=Util.null2String(rs1.getString("flowobjectids"));
                    int destnodeid=Util.getIntValue(rs1.getString("destnodeid"));
                    String ProcessorOpinion=Util.null2String(rs1.getString("ProcessorOpinion"));
                    
                    String flowobjectreject=Util.null2String(rs1.getString("flowobjectreject"));//流程退回




                    String flowobjectsubmit=Util.null2String(rs1.getString("flowobjectsubmit"));//流程提交
                    
                    //超时后提醒




                    int isremind_csh=Util.getIntValue(rs1.getString("isremind_csh"),0);
                    int remindhour_csh=Util.getIntValue(rs1.getString("remindhour_csh"),0);
                    int remindminute_csh=Util.getIntValue(rs1.getString("remindminute_csh"),0);
                    int FlowRemind_csh=Util.getIntValue(rs1.getString("FlowRemind_csh"),0);
                    int MsgRemind_csh=Util.getIntValue(rs1.getString("MsgRemind_csh"),0);
                    int MailRemind_csh=Util.getIntValue(rs1.getString("MailRemind_csh"),0);
                    int isnodeoperator_csh=Util.getIntValue(rs1.getString("isnodeoperator_csh"),0);
                    int iscreater_csh=Util.getIntValue(rs1.getString("iscreater_csh"),0);
                    int ismanager_csh=Util.getIntValue(rs1.getString("ismanager_csh"),0);
                    int isother_csh=Util.getIntValue(rs1.getString("isother_csh"),0);
                    String remindobjectids_csh=Util.null2String(rs1.getString("remindobjectids_csh"));
                    
                    int selectnodepass=Util.getIntValue(rs1.getString("selectnodepass"),0); //节点超时类型 
                    int InfoCentreRemind=Util.getIntValue(rs1.getString("InfoCentreRemind"),0);//消息提醒
                    int InfoCentreRemind_csh=Util.getIntValue(rs1.getString("InfoCentreRemind_csh"),0);
                    int CustomWorkflowid=Util.getIntValue(rs1.getString("CustomWorkflowid"),0);
                    int CustomWorkflowid_csh=Util.getIntValue(rs1.getString("CustomWorkflowid_csh"),0);
                    
                    
                    sql="select nodepasshour,nodepassminute,ProcessorOpinion,dateField,timeField from workflow_NodeLink where wfrequestid="+requestid+" and destnodeid="+destnodeid+" and nodeid="+nodeid_tmp;
                    //System.out.println(sql);
                    rs2.executeSql(sql);
                    if(rs2.next()){
                        nodepasshour=Util.getIntValue(rs2.getString("nodepasshour"),0);
                        nodepassminute=Util.getIntValue(rs2.getString("nodepassminute"),0);
                        //ProcessorOpinion=Util.null2String(rs2.getString("ProcessorOpinion"));
                        dateField = Util.null2String(rs1.getString("dateField"));
                        timeField = Util.null2String(rs1.getString("timeField"));
                        if(isautoflow==0){
                            isautoflow=1;
                            flownextoperator=1;
                        }
                    }
                    
                    String dateValue="";
                    if(!"".equals(dateField)){
                    	dateValue = getDateValue(requestid, dateField, timeField);
                    }
                    boolean dateProcess = false;
                    long timedifference =0;
                    if(!"".equals(dateValue)){
                    	
                    	try {
                    		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    		java.util.Date d1 = sdf.parse(nowdatetime);
                    		java.util.Date d2 = sdf.parse(dateValue);
                    		dateProcess = d1.after(d2);
                    		timedifference = d1.getTime() - d2.getTime();
                    		if(timedifference<0)timedifference=0;
                    		else timedifference = timedifference/1000;
                    		
						} catch (Exception e) {
							e.printStackTrace();
						}
                    }
                    
					if(ProcessorOpinion.trim().equals("")) ProcessorOpinion=SystemEnv.getHtmlLabelName(22263,language);
                    long remindsecond=0;
                    long processsecond=nodepasshour*3600+nodepassminute*60;
                    
                    if(selectnodepass==2){
                    	processsecond = timedifference;
                    }

                    long remindsecond_csh=processsecond+remindhour_csh*3600+remindminute_csh*60;//超时后提醒时间




                    
                    if(nodepasshour>=remindhour){
                        if(nodepassminute>=remindminute){
                            remindsecond=(nodepasshour-remindhour)*3600+(nodepassminute-remindminute)*60;
                        }else{
                            remindsecond=(nodepasshour-remindhour-1)*3600+(60+nodepassminute-remindminute)*60;
                        }
                    }
                    //System.out.println("超时processsecond："+processsecond+"====remindsecond:"+remindsecond+"===dateProcess:"+dateProcess+"===requestid:"+requestid);
                   
                    /***********************************************************************************************/
                    //超时提醒--begin

                    if(isreminded==0 && (overTimeBean.getOverTime(currentdatetime,nowdatetime)>=remindsecond || dateProcess)){
                        if(isremind==1){//启用超时提醒
                            String remindusers="";
                            String usertypes="";
                            boolean mailsend=false;
                            boolean msgsend=false;
                            boolean wfsend=false;
                            boolean chatssend=false;//微信提醒(QC:98106)
                            boolean wfcreate = false;
                            wfremindusers=new ArrayList();
                            wfusertypes=new ArrayList();
                            if(FlowRemind==1){//流程提醒方式
                                PoppupRemindInfoUtil popUtil=new PoppupRemindInfoUtil();
                                if(isnodeoperator==1){//本节点操作人本人
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        //本节点操作人提醒
                                        if(userid>0){
                                            //popUtil.addPoppupRemindInfo(userid,10,""+usertype,requestid);
                                            if((","+remindusers).indexOf(","+userid+",")<0){
                                                remindusers+=userid+",";
                                                usertypes+=usertype+",";
                                            }
                                        }
                                        //代理人提醒




                                        if(agenttype>0 && agentorbyagentid>0){
                                            //popUtil.addPoppupRemindInfo(agentorbyagentid,10,"0",requestid);
                                            if((","+remindusers).indexOf(","+agentorbyagentid+",")<0){
                                                remindusers+=agentorbyagentid+",";
                                                usertypes+="0,";
                                            }
                                        }
                                    }
                                }
                                if(iscreater==1){//创建人




                                    sql="select creater,creatertype from workflow_requestbase where requestid="+requestid;
                                    rs2.executeSql(sql);
                                    if(rs2.next()){
                                        int creatertmp=Util.getIntValue(rs2.getString("creater"),0);
                                        //popUtil.addPoppupRemindInfo(creatertmp,10,Util.getIntValue(rs2.getString("creatertype"),0)+"",requestid);
                                        if((","+remindusers).indexOf(","+creatertmp+",")<0){
                                            remindusers+=creatertmp+",";
                                            usertypes+=rs2.getString("creatertype")+",";
                                        }
                                    }
                                }
                                if(ismanager==1){//本节点操作人经理
                                    int managerid=0;
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        if(usertype==0){
                                            managerid=Util.getIntValue(resource.getManagerID(userid+""),0);
                                        }else{
                                            managerid=Util.getIntValue(crminfo.getCustomerInfomanager(userid+""),0);
                                        }
                                        if(managerid>0){
                                             //popUtil.addPoppupRemindInfo(managerid,10,"0",requestid);
                                            if((","+remindusers).indexOf(","+managerid+",")<0){
                                                remindusers+=managerid+",";
                                                usertypes+="0,";
                                            }
                                        }
                                    }
                                }
                                if(isother==1){//指定对象
                                    ArrayList remindobjectlist=Util.TokenizerString(remindobjectids,",");
                                    for(int i=0;i<remindobjectlist.size();i++){
                                        int tempid=Util.getIntValue((String)remindobjectlist.get(i));
                                        //popUtil.addPoppupRemindInfo(tempid,10,"0",requestid);
                                        if((","+remindusers).indexOf(","+tempid+",")<0){
                                            remindusers+=tempid+",";
                                            usertypes+="0,";
                                        }
                                    }
                                }
                                if(remindusers.length()>1){
                                    String tempremindusers=remindusers.substring(0,remindusers.length()-1);
                                    String tempusertypes=usertypes.substring(0,usertypes.length()-1);
                                    ArrayList templist=Util.TokenizerString(tempremindusers,",");
                                    ArrayList tempusertypelist=Util.TokenizerString(tempusertypes,",");
                                    wfremindusers=templist;
                                    wfusertypes=tempusertypelist;
                                    rs2.executeSql("update workflow_currentoperator set wfreminduser='"+tempremindusers+"',wfusertypes='"+tempusertypes+"' where isremark='0' and requestid="+requestid);
                                    for(int i=0;i<templist.size();i++){
                                        if(wfsend){
                                            popUtil.addPoppupRemindInfo(Util.getIntValue((String)templist.get(i)),10,(String)tempusertypelist.get(i),requestid,requestcominfo.getRequestname(requestid+""));
                                        }else{
                                            wfsend=popUtil.addPoppupRemindInfo(Util.getIntValue((String)templist.get(i)),10,(String)tempusertypelist.get(i),requestid,requestcominfo.getRequestname(requestid+""));
                                        }
                                    }
                                }else{
                                    wfsend=true;
                                }
                            }

                            /***********************************************************************************************/
                             if(MsgRemind==1){//短信提醒
                                String sendmessage=SystemEnv.getHtmlLabelName(18910,language);
                                String creater="";
                                int creatertype=0;
                                ArrayList smstemplist=new ArrayList();
                                sql="select creater,creatertype,requestname from workflow_requestbase where requestid="+requestid;
                                rs2.executeSql(sql);
                                if(rs2.next()){
                                    creater=rs2.getString("creater");
                                    creatertype=Util.getIntValue(rs2.getString("creatertype"),0);
                                    sendmessage=SystemEnv.getHtmlLabelName(18015,language)+"("+rs2.getString("requestname")+")"+SystemEnv.getHtmlLabelName(18911,language);
                                }
                                SMSManager smsManager = new SMSManager();
                                if(smsManager.isValid()||true){
                                     if(isnodeoperator==1){//本节点操作人本人
                                        //本节点操作人提醒
                                        for(int k=0;k<userlist.size();k++){
                                            int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                            int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                            userid=Util.getIntValue((String)userlist.get(k));
                                            usertype=Util.getIntValue((String)usertypelist.get(k));
                                            if(userid>0 && usertype==0){
                                                String recMobile = resource.getLoginID(""+userid);
                                                if(recMobile !=null && !recMobile.trim().equals("")){
                                                    if(smstemplist.indexOf(recMobile)<0){
                                                        smstemplist.add(recMobile);
                                                        //smsManager.sendSMS(recMobile,sendmessage);
                                                        if((","+remindusers).indexOf(","+userid+",")<0)
                                                        remindusers+=userid+",";
                                                    }
                                                }
                                            }
                                            //代理人提醒




                                            if(agenttype>0 && agentorbyagentid>0){
                                                String recMobile = resource.getLoginID(""+agentorbyagentid);
                                                if(recMobile !=null && !recMobile.trim().equals("")){
                                                    if(smstemplist.indexOf(recMobile)<0){
                                                        smstemplist.add(recMobile);
                                                        //smsManager.sendSMS(recMobile,sendmessage);
                                                        if((","+remindusers).indexOf(","+agentorbyagentid+",")<0)
                                                        remindusers+=agentorbyagentid+",";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if(iscreater==1 && creatertype==0){//创建人




                                        String recMobile = resource.getLoginID(""+creater);
                                        if(recMobile !=null && !recMobile.trim().equals("")){
                                            if(smstemplist.indexOf(recMobile)<0){
                                                smstemplist.add(recMobile);
                                                //smsManager.sendSMS(recMobile,sendmessage);
                                                if((","+remindusers).indexOf(","+creater+",")<0)
                                                    remindusers+=creater+",";
                                            }
                                        }
                                    }
                                    if(ismanager==1){//本节点操作人经理
                                        int managerid=0;
                                        for(int k=0;k<userlist.size();k++){
                                            int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                            int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                            userid=Util.getIntValue((String)userlist.get(k));
                                            usertype=Util.getIntValue((String)usertypelist.get(k));
                                            if(usertype==0){
                                                managerid=Util.getIntValue(resource.getManagerID(userid+""),0);
                                            }else{
                                                managerid=Util.getIntValue(crminfo.getCustomerInfomanager(userid+""),0);
                                            }
                                            String recMobile = resource.getLoginID(""+managerid);
                                            if(recMobile !=null && !recMobile.trim().equals("")){
                                                if(smstemplist.indexOf(recMobile)<0){
                                                    smstemplist.add(recMobile);
                                                    //smsManager.sendSMS(recMobile,sendmessage);
                                                    if((","+remindusers).indexOf(","+managerid+",")<0)
                                                        remindusers+=managerid+",";
                                                }
                                            }
                                        }
                                    }
                                     if(isother==1){//指定对象
                                        ArrayList remindobjectlist=Util.TokenizerString(remindobjectids,",");
                                        for(int i=0;i<remindobjectlist.size();i++){
                                            String recMobile = resource.getLoginID((String)remindobjectlist.get(i));
                                             if(recMobile !=null && !recMobile.trim().equals("")){
                                                if(smstemplist.indexOf(recMobile)<0){
                                                    smstemplist.add(recMobile);
                                                    //smsManager.sendSMS(recMobile,sendmessage);
                                                    if((","+remindusers).indexOf(","+remindobjectlist.get(i)+",")<0)
                                                    remindusers+=remindobjectlist.get(i)+",";
                                                }
                                            }
                                        }
                                    }
                                    if(smstemplist.size()<1){
                                        msgsend=true;
                                    }
                                    //sendmessage = "0".equals(signPos) ? (sign + sendmessage) : (sendmessage + sign);
                                    PushNotificationService service = new PushNotificationService();
                                    Map<String, String> para = new HashMap();
                                    String type = Util.null2String(this.getPropValue("YiliMessage", "type"));
                                    if ("".equals(type)) {
                                        type = "30";
                                    }
                                    String yiliUrl = Util.null2String(this.getPropValue("YiliMessage", "url"));
                                    String charset = Util.null2String(this.getPropValue("YiliMessage", "charset"));

                                    if("".equals(yiliUrl)){
                                        yiliUrl="/OverTime.jsp";
                                    }
                                    if("".equals(charset)){
                                        charset="GBK";
                                    }

                                    para.put("module", "-2");
                                    para.put("messagetypeid", type);
                                    for(int i=0;i<smstemplist.size();i++){
//                                        if(msgsend){
//
//                                            smsManager.sendSMS((String)smstemplist.get(i),sendmessage);
//                                        }else{
//                                            msgsend=smsManager.sendSMS((String)smstemplist.get(i),sendmessage);
//                                        }
                                        writeLog("service.准备发送()"+(String)smstemplist.get(i)+"发送内容"+sendmessage+"type"+type);

                                        writeLog("发送完成"+requestid+"sendmessage"+sendmessage+"type"+type);
                                        try {
                                            para.put("url",yiliUrl+"?requestid="+requestid);
                                        }catch (Exception e){
                                            writeLog(e);
                                        }
                                        service.push((String)smstemplist.get(i),sendmessage, 1, para);
                                        writeLog("service.发送完成()"+yiliUrl+"?message="+sendmessage);
                                        msgsend=true;
                                    }
                                }else{
                                    msgsend=true;
                                }
                            }
                            /***********************************************************************************************/
                            //微信提醒(QC:98106
                            if(ChatsRemind==1){//微信提醒
                            	System.out.println("进入超时提醒");
                                String sendmessage=SystemEnv.getHtmlLabelName(18910,language);
                                String creater="";
                                int creatertype=0; 
                                sql="select creater,creatertype,requestname from workflow_requestbase where requestid="+requestid;
                                rs2.executeSql(sql);
                                if(rs2.next()){
                                    creater=rs2.getString("creater");
                                    creatertype=Util.getIntValue(rs2.getString("creatertype"),0);
                                    sendmessage=SystemEnv.getHtmlLabelName(18015,language)+"("+rs2.getString("requestname")+")"+SystemEnv.getHtmlLabelName(18911,language);
                                }
                                WechatPropConfig wechatPropConfig = new WechatPropConfig();
                                if(wechatPropConfig.isUseWechat()){
                                    if(isnodeoperator==1){//本节点操作人本人
                                        //本节点操作人提醒
                                        for(int k=0;k<userlist.size();k++){
                                            int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                            int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                            userid=Util.getIntValue((String)userlist.get(k));
                                            usertype=Util.getIntValue((String)usertypelist.get(k));
                                            if(userid>0 && usertype==0){  
                                                        if((","+remindusers).indexOf(","+userid+",")<0){
                                                        remindusers+=userid+",";
                                                    } 
                                            }
                                            //代理人提醒




                                            if(agenttype>0 && agentorbyagentid>0){ 
                                                        if((","+remindusers).indexOf(","+agentorbyagentid+",")<0){
                                                        remindusers+=agentorbyagentid+",";
                                                    }
                                            }  
                                        }
                                    }
                                    if(iscreater==1 && creatertype==0){//创建人 
                                                if((","+remindusers).indexOf(","+creater+",")<0){
                                                    remindusers+=creater+","; 
                                        }
                                    }
                                    if(ismanager==1){//本节点操作人经理
                                        int managerid=0;
                                        for(int k=0;k<userlist.size();k++){
                                            int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                            int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                            userid=Util.getIntValue((String)userlist.get(k));
                                            usertype=Util.getIntValue((String)usertypelist.get(k));
                                            if(usertype==0){
                                                managerid=Util.getIntValue(resource.getManagerID(userid+""),0);
                                            }else{
                                                managerid=Util.getIntValue(crminfo.getCustomerInfomanager(userid+""),0);
                                            } 
                                                    if((","+remindusers).indexOf(","+managerid+",")<0){
                                                        remindusers+=managerid+","; 
                                            }
                                        }
                                    }
                                    if(isother==1){//指定对象
                                        ArrayList remindobjectlist=Util.TokenizerString(remindobjectids,",");
                                        for(int i=0;i<remindobjectlist.size();i++){ 
                                                    if((","+remindusers).indexOf(","+remindobjectlist.get(i)+",")<0){
                                                    remindusers+=remindobjectlist.get(i)+","; 
                                            }
                                        }
                                    }
                                    if(remindusers.length()>0){
                                    	chatssend=true;
                                    }
                                   Map map= new HashMap();
                 		           map.put("detailid",requestid);
                 		           saveAndSendWechat.setHrmid(remindusers);
                 		           saveAndSendWechat.setMsg(sendmessage);
                 		           saveAndSendWechat.setMode(1);
                 		           saveAndSendWechat.setParams(map);
                 		           saveAndSendWechat.send(); 
                                }else{
                                	chatssend=true;
                                }
                            }
                            //微信提醒(QC:98106
                            /***********************************************************************************************/
                            if(MailRemind==1){//邮件提醒
                                String mailtoaddress="";
                                String mailrequestname = SystemEnv.getHtmlLabelName(18910,language);
                                String mailobject=SystemEnv.getHtmlLabelName(18910,language);
                                String creater="";
                                int creatertype=0;
                                sql="select creater,creatertype,requestname from workflow_requestbase where requestid="+requestid;
                                rs2.executeSql(sql);
                                if(rs2.next()){
                                    creater=rs2.getString("creater");
                                    creatertype=Util.getIntValue(rs2.getString("creatertype"),0);
                                    mailrequestname = SystemEnv.getHtmlLabelName(18015,language)+"("+rs2.getString("requestname")+")"+SystemEnv.getHtmlLabelName(18911,language);
                                    mailobject=SystemEnv.getHtmlLabelName(18910,language)+"("+rs2.getString("requestname")+")";
                                }
                                if(isnodeoperator==1){//本节点操作人本人
                                    //本节点操作人提醒
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        if(userid>0){
                                            if(usertype==0){
                                                String tempmail=resource.getEmail(""+userid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+userid+",")<0)
                                                        remindusers+=userid+",";
                                                    }
                                                }
                                            }else{ //客户
                                                String tempmail=crminfo.getCustomerInfoEmail(""+userid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+userid+",")<0)
                                                        remindusers+=userid+",";
                                                    }
                                                }
                                            }
                                        }
                                        //代理人提醒




                                        if(agenttype>0 && agentorbyagentid>0){
                                            if(usertype==0){
                                                String tempmail=resource.getEmail(""+agentorbyagentid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+agentorbyagentid+",")<0)
                                                        remindusers+=agentorbyagentid+",";
                                                    }
                                                }
                                            }else{//客户
                                                String tempmail=crminfo.getCustomerInfoEmail(""+agentorbyagentid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+agentorbyagentid+",")<0)
                                                        remindusers+=agentorbyagentid+",";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                if(iscreater==1){//创建人




                                    if(creatertype==0){
                                        String tempmail=resource.getEmail(creater);
                                        if(tempmail!=null && !tempmail.trim().equals("")){
                                            if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                mailtoaddress+=tempmail+",";
                                                if((","+remindusers).indexOf(","+creater+",")<0)
                                                    remindusers+=creater+",";
                                            }
                                        }
                                    }else{//客户
                                        String tempmail=crminfo.getCustomerInfoEmail(creater);
                                        if(tempmail!=null && !tempmail.trim().equals("")){
                                            if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                mailtoaddress+=tempmail+",";
                                                if((","+remindusers).indexOf(","+creater+",")<0)
                                                    remindusers+=creater+",";
                                            }
                                        }
                                    }
                                }
                                if(ismanager==1){//本节点操作人经理
                                    int managerid=0;
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        if(usertype==0){
                                            managerid=Util.getIntValue(resource.getManagerID(userid+""),0);
                                        }else{
                                            managerid=Util.getIntValue(crminfo.getCustomerInfomanager(userid+""),0);
                                        }
                                        if(managerid>0){
                                            String tempmail=resource.getEmail(""+managerid);
                                            if(tempmail!=null && !tempmail.trim().equals("")){
                                                if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                    mailtoaddress+=tempmail+",";
                                                    if((","+remindusers).indexOf(","+managerid+",")<0)
                                                        remindusers+=managerid+",";
                                                }
                                            }
                                        }
                                    }
                                }
                                if(isother==1){//指定对象
                                    ArrayList remindobjectlist=Util.TokenizerString(remindobjectids,",");
                                    for(int i=0;i<remindobjectlist.size();i++){
                                        String tempmail=resource.getEmail((String)remindobjectlist.get(i));
                                        if(tempmail!=null && !tempmail.trim().equals("")){
                                            if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                mailtoaddress+=tempmail+",";
                                                if((","+remindusers).indexOf(","+remindobjectlist.get(i)+",")<0)
                                                    remindusers+=remindobjectlist.get(i)+",";
                                            }
                                        }
                                    }
                                }
                                if(!"".equals(mailtoaddress)){
                                        mailtoaddress = mailtoaddress.substring(0,mailtoaddress.length()-1);
                                        SendMail sm = new SendMail();
                                        SystemComInfo systemComInfo = new SystemComInfo();
                                        String defmailserver = systemComInfo.getDefmailserver();
                                        String defneedauth = systemComInfo.getDefneedauth();
                                        String defmailuser = systemComInfo.getDefmailuser();
                                        String defmailpassword = systemComInfo.getDefmailpassword();
                                        String defmailfrom=systemComInfo.getDefmailfrom();
                                        sm.setMailServer(defmailserver);
                                        if (defneedauth.equals("1")) {
                                        sm.setNeedauthsend(true);
                                        sm.setUsername(defmailuser);
                                        sm.setPassword(defmailpassword);
                                        } else{
                                        sm.setNeedauthsend(false);
                                        }
                                        /*try {
                                              mailrequestname = new String(mailrequestname.getBytes("UTF-8"),"iso-8859-1");
                                        } catch (UnsupportedEncodingException e){
                                            e.printStackTrace();
                                        }*/
                                        mailsend=sm.sendhtml(defmailfrom, mailtoaddress, null, null,mailobject , mailrequestname, 3, "3");
                                }
                                
                            }
                            
                            if(InfoCentreRemind==1){//超时前信息中心提醒




                            	System.out.println("InfoCentreRemind:"+InfoCentreRemind+"  CustomWorkflowid:"+CustomWorkflowid);
                            	if(CustomWorkflowid>0){
                                	String requestname="";
                                    sql="select t.requestid,t.requestname,t1.userid  from workflow_currentoperator t1,workflow_requestbase t where t1.requestid=t.requestid and t.requestid="+requestid+" and t1.nodeid="+nodeid+" and isremark='0' ";
                                    rs8.executeSql(sql);
                                    if(rs8.next()){
                                    	requestname=Util.null2String(rs8.getString("requestname"));
										String remark = "相关流程：<a href='/workflow/request/ViewRequest.jsp?requestid="+requestid+"&isovertime=0'>"+requestname+"</a>";
										requestname = " 流程{"+requestname+"}将超时";
										docreateWorkflow(CustomWorkflowid+"","1",requestname,remark);
										wfcreate = true;
                                   }
                            	}
                            }
                            //微信提醒(QC:98106)
                            if(remindusers.length()>0 && ((FlowRemind==1 && wfsend) || (MsgRemind==1 && msgsend) || (MailRemind==1 && mailsend)) || (InfoCentreRemind==1 && wfcreate)|| (ChatsRemind==1 && chatssend)){
                                sql="update workflow_currentoperator set isreminded='1' where isremark='0' and requestid="+requestid;
                                rs2.executeSql(sql);
                                log.debug(sql);
                            }
                        }
                    }
                    //超时提醒--end
                    /***********************************************************************************************/
                    
                    //超时处理--begin
                    if(isprocessed==0 && (processsecond>0 && overTimeBean.getOverTime(currentdatetime,nowdatetime)>=processsecond || dateProcess)){
                        
                    	if(isautoflow==1){//启用超时处理
                    		System.out.println("requestid:"+requestid+"   isautoflow:"+isautoflow+"  flownextoperator:"+flownextoperator);
                            if(flownextoperator==1){//自动流转
                                if(!hasNeedInputField(requestid,workflowid,nodeid)){
                                    log.debug("超时处理:自动流转至下一操作者---begin");
									AutoFlowNextNode(requestid,nodeid,userlist,usertypelist,agenttypelist,agentorbyagentidlist,workflowtype,ProcessorOpinion);
                                    for(int i=0;i<idlist.size();i++){
                                    sql="update workflow_currentoperator set isreminded='1',isprocessed='2' where id="+idlist.get(i)+" and requestid="+requestid;
                                    rs2.executeSql(sql);
                                    }
                                    log.debug("超时处理:自动流转至下一操作者---end");
                                }else{
                                    for(int i=0;i<idlist.size();i++){
                                        sql="update workflow_currentoperator set isreminded='1',isprocessed='3' where id="+idlist.get(i)+" and requestid="+requestid;
                                        rs2.executeSql(sql);
                                    }
                                }
                            }else if(flownextoperator==2){
                            	
                            }else if(flownextoperator==3){//流程退回




                            	if(!"".equals(flowobjectreject)){
                            		FlowNode(requestid, userid, ProcessorOpinion, "", Integer.parseInt(flowobjectreject));
                            		writeLog("超时退回 :requestid="+requestid);
                            	}
                            	
                            }else if(flownextoperator==4){//流程提交
                            	if(!"".equals(flowobjectsubmit)){
                            		WorkflowNodeFlow  wnf = new WorkflowNodeFlow();
                            		wnf.setRequestid(requestid);
                                    wnf.setNodeid(nodeid);
                                    wnf.setFlowobjectsubmit(Integer.parseInt(flowobjectsubmit));
                                    //wnf.setNodetype(nodetype);
                                    wnf.setWorkflowid(workflowid);
                                    wnf.setWorkflowtype(workflowtype);
                                    wnf.setUserid(userid);
                                    wnf.setUsertype(usertype);
                                    wnf.setUser(user);
                                    wnf.setRemark(ProcessorOpinion);
                                    //wnf.setCreater(creater);
                                    //wnf.setCreatertype(creatertype);
                                    //wnf.setIsbill(isbill);
                                    //wnf.setBillid(billid);
                                    //wnf.setFormid(formid);
                                   // wnf.setBilltablename(billtablename);
                                    boolean flag = wnf.flowNextNode();
                                    
                                    //System.out.println("超时提交至目标节点:requestid="+requestid+" flag:"+flag);
                                    writeLog("超时提交至目标节点:requestid="+requestid);
                            	}
                            }else{//指定干预对象
                                //log.debug("超时处理:流转至干预对象---begin");
                                //System.out.println("flowobjectids:"+flowobjectids);
                                ArrayList flowobjectlist=Util.TokenizerString(flowobjectids,",");
                                setOperator(flowobjectlist,requestid,workflowid,workflowtype,nodeid);
                                Calendar today = Calendar.getInstance();
                                String currentdate = Util.add0(today.get(Calendar.YEAR), 4) + "-" +
                                        Util.add0(today.get(Calendar.MONTH) + 1, 2) + "-" +
                                        Util.add0(today.get(Calendar.DAY_OF_MONTH), 2);

                                String currenttime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
                                        Util.add0(today.get(Calendar.MINUTE), 2) + ":" +
                                        Util.add0(today.get(Calendar.SECOND), 2);
                                //获得数据库服务器当前时间
                                if(rs5.getDBType().equals("oracle")){
                                    sql="select to_char(sysdate,'yyyy-mm-dd') currentdate,to_char(sysdate,'hh24:mi:ss') currenttime from dual";
                                }else{
                                    sql="select convert(char(10),getdate(),20) currentdate,convert(char(8),getdate(),108) currenttime";
                                }
                                rs5.executeSql(sql);
                                if(rs5.next()){
                                    currentdate=rs5.getString("currentdate");
                                    currenttime=rs5.getString("currenttime");
                                }
                                for(int i=0;i<userlist.size();i++){
									writeWFLog(requestid,workflowid,nodeid,Util.getIntValue((String)userlist.get(i)),Util.getIntValue((String)usertypelist.get(i)),Util.getIntValue((String)agenttypelist.get(i)),Util.getIntValue((String)agentorbyagentidlist.get(i)),nodeid,currentdate,currenttime,ProcessorOpinion,"7",false,0);
                                    sql="update workflow_currentoperator set isreminded='1',isprocessed='2' where id="+idlist.get(i)+" and requestid="+requestid;
                                    rs2.executeSql(sql);
                                }
                                //log.debug("超时处理:流转至干预对象---end");
                            }

                        }else{
                            for(int i=0;i<idlist.size();i++){
                            sql="update workflow_currentoperator set isreminded='1',isprocessed='3' where id="+idlist.get(i)+" and requestid="+requestid;
                            rs2.executeSql(sql);
                            }
                        }
                    }
                    //超时处理--end
                    
                  //超时后提醒--begin
                    if(isreminded_csh==0 && remindsecond_csh>processsecond && overTimeBean.getOverTime(currentdatetime,nowdatetime)>=remindsecond_csh){
                        //writeLog("超时后提醒:requestid="+requestid+" remindsecond_csh="+remindsecond_csh+" processsecond="+processsecond+" isremind_csh="+isremind_csh);
                        if(isremind_csh==1){//启用超时提醒
                            String remindusers="";
                            String usertypes="";
                            boolean mailsend=false;
                            boolean msgsend=false;
                            boolean wfsend=false;
                            boolean wfcreate = false;
                            wfremindusers=new ArrayList();
                            wfusertypes=new ArrayList();
                            if(FlowRemind_csh==1){//流程提醒方式
                                PoppupRemindInfoUtil popUtil=new PoppupRemindInfoUtil();
                                if(isnodeoperator_csh==1){//本节点操作人本人
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        //本节点操作人提醒
                                        if(userid>0){
                                            //popUtil.addPoppupRemindInfo(userid,10,""+usertype,requestid);
                                            if((","+remindusers).indexOf(","+userid+",")<0){
                                                remindusers+=userid+",";
                                                usertypes+=usertype+",";
                                            }
                                        }
                                        //代理人提醒




                                        if(agenttype>0 && agentorbyagentid>0){
                                            //popUtil.addPoppupRemindInfo(agentorbyagentid,10,"0",requestid);
                                            if((","+remindusers).indexOf(","+agentorbyagentid+",")<0){
                                                remindusers+=agentorbyagentid+",";
                                                usertypes+="0,";
                                            }
                                        }
                                    }
                                }
                                if(iscreater_csh==1){//创建人




                                    sql="select creater,creatertype from workflow_requestbase where requestid="+requestid;
                                    rs2.executeSql(sql);
                                    if(rs2.next()){
                                        int creatertmp=Util.getIntValue(rs2.getString("creater"),0);
                                        //popUtil.addPoppupRemindInfo(creatertmp,10,Util.getIntValue(rs2.getString("creatertype"),0)+"",requestid);
                                        if((","+remindusers).indexOf(","+creatertmp+",")<0){
                                            remindusers+=creatertmp+",";
                                            usertypes+=rs2.getString("creatertype")+",";
                                        }
                                    }
                                }
                                if(ismanager_csh==1){//本节点操作人经理
                                    int managerid=0;
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        if(usertype==0){
                                            managerid=Util.getIntValue(resource.getManagerID(userid+""),0);
                                        }else{
                                            managerid=Util.getIntValue(crminfo.getCustomerInfomanager(userid+""),0);
                                        }
                                        if(managerid>0){
                                             //popUtil.addPoppupRemindInfo(managerid,10,"0",requestid);
                                            if((","+remindusers).indexOf(","+managerid+",")<0){
                                                remindusers+=managerid+",";
                                                usertypes+="0,";
                                            }
                                        }
                                    }
                                }
                                if(isother_csh==1){//指定对象
                                    ArrayList remindobjectlist=Util.TokenizerString(remindobjectids_csh,",");
                                    for(int i=0;i<remindobjectlist.size();i++){
                                        int tempid=Util.getIntValue((String)remindobjectlist.get(i));
                                        //popUtil.addPoppupRemindInfo(tempid,10,"0",requestid);
                                        if((","+remindusers).indexOf(","+tempid+",")<0){
                                            remindusers+=tempid+",";
                                            usertypes+="0,";
                                        }
                                    }
                                }
                                if(remindusers.length()>1){
                                    String tempremindusers=remindusers.substring(0,remindusers.length()-1);
                                    String tempusertypes=usertypes.substring(0,usertypes.length()-1);
                                    ArrayList templist=Util.TokenizerString(tempremindusers,",");
                                    ArrayList tempusertypelist=Util.TokenizerString(tempusertypes,",");
                                    /**
                                    wfremindusers=templist;
                                    wfusertypes=tempusertypelist;
                                    rs2.executeSql("update workflow_currentoperator set wfreminduser='"+tempremindusers+"',wfusertypes='"+tempusertypes+"' where isremark='0' and requestid="+requestid);
                                    */
                                    rs2.executeSql("update workflow_currentoperator set wfreminduser_csh='"+tempremindusers+"',wfusertypes_csh='"+tempusertypes+"' where isremark='0' and requestid="+requestid);
                                    for(int i=0;i<templist.size();i++){
                                        if(wfsend){
                                            popUtil.addPoppupRemindInfo(Util.getIntValue((String)templist.get(i)),10,(String)tempusertypelist.get(i),requestid,requestcominfo.getRequestname(requestid+""));
                                        }else{
                                            wfsend=popUtil.addPoppupRemindInfo(Util.getIntValue((String)templist.get(i)),10,(String)tempusertypelist.get(i),requestid,requestcominfo.getRequestname(requestid+""));
                                        }
                                    }
                                }else{
                                    wfsend=true;
                                }
                            }
                             /***********************************************************************************************/
                            if(MsgRemind_csh==1){//短信提醒
                                String sendmessage=SystemEnv.getHtmlLabelName(18910,language);
                                String creater="";
                                int creatertype=0;
                                ArrayList smstemplist=new ArrayList();
                                sql="select creater,creatertype,requestname from workflow_requestbase where requestid="+requestid;
                                rs2.executeSql(sql);
                                if(rs2.next()){
                                    creater=rs2.getString("creater");
                                    creatertype=Util.getIntValue(rs2.getString("creatertype"),0);
                                    sendmessage=SystemEnv.getHtmlLabelName(18015,language)+"("+rs2.getString("requestname")+")已超时";
                                }
                                SMSManager smsManager = new SMSManager();
                                if(smsManager.isValid()||true){
                                    if(isnodeoperator_csh==1){//本节点操作人本人
                                        //本节点操作人提醒
                                        for(int k=0;k<userlist.size();k++){
                                            int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                            int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                            userid=Util.getIntValue((String)userlist.get(k));
                                            usertype=Util.getIntValue((String)usertypelist.get(k));
                                            if(userid>0 && usertype==0){
                                                String recMobile = resource.getLoginID(""+userid);
                                                if(recMobile !=null && !recMobile.trim().equals("")){
                                                    if(smstemplist.indexOf(recMobile)<0){
                                                        smstemplist.add(recMobile);
                                                        //smsManager.sendSMS(recMobile,sendmessage);
                                                        if((","+remindusers).indexOf(","+userid+",")<0)
                                                        remindusers+=userid+",";
                                                    }
                                                }
                                            }
                                            //代理人提醒




                                            if(agenttype>0 && agentorbyagentid>0){
                                                String recMobile = resource.getLoginID(""+agentorbyagentid);
                                                if(recMobile !=null && !recMobile.trim().equals("")){
                                                    if(smstemplist.indexOf(recMobile)<0){
                                                        smstemplist.add(recMobile);
                                                        //smsManager.sendSMS(recMobile,sendmessage);
                                                        if((","+remindusers).indexOf(","+agentorbyagentid+",")<0)
                                                        remindusers+=agentorbyagentid+",";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if(iscreater_csh==1 && creatertype==0){//创建人




                                        String recMobile = resource.getLoginID(""+creater);
                                        if(recMobile !=null && !recMobile.trim().equals("")){
                                            if(smstemplist.indexOf(recMobile)<0){
                                                smstemplist.add(recMobile);
                                                //smsManager.sendSMS(recMobile,sendmessage);
                                                if((","+remindusers).indexOf(","+creater+",")<0)
                                                    remindusers+=creater+",";
                                            }
                                        }
                                    }
                                    if(ismanager_csh==1){//本节点操作人经理
                                        int managerid=0;
                                        for(int k=0;k<userlist.size();k++){
                                            int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                            int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                            userid=Util.getIntValue((String)userlist.get(k));
                                            usertype=Util.getIntValue((String)usertypelist.get(k));
                                            if(usertype==0){
                                                managerid=Util.getIntValue(resource.getManagerID(userid+""),0);
                                            }else{
                                                managerid=Util.getIntValue(crminfo.getCustomerInfomanager(userid+""),0);
                                            }
                                            String recMobile = resource.getLoginID(""+managerid);
                                            if(recMobile !=null && !recMobile.trim().equals("")){
                                                if(smstemplist.indexOf(recMobile)<0){
                                                    smstemplist.add(recMobile);
                                                    //smsManager.sendSMS(recMobile,sendmessage);
                                                    if((","+remindusers).indexOf(","+managerid+",")<0)
                                                        remindusers+=managerid+",";
                                                }
                                            }
                                        }
                                    }


                                    if(isother_csh==1){//指定对象
                                        ArrayList remindobjectlist=Util.TokenizerString(remindobjectids_csh,",");
                                        for(int i=0;i<remindobjectlist.size();i++){
                                            String recMobile = resource.getLoginID((String)remindobjectlist.get(i));
                                             if(recMobile !=null && !recMobile.trim().equals("")){
                                                if(smstemplist.indexOf(recMobile)<0){
                                                    smstemplist.add(recMobile);
                                                    //smsManager.sendSMS(recMobile,sendmessage);
                                                    if((","+remindusers).indexOf(","+remindobjectlist.get(i)+",")<0)
                                                    remindusers+=remindobjectlist.get(i)+",";
                                                }
                                            }
                                        }
                                    }
                                    if(smstemplist.size()<1){
                                        msgsend=true;
                                    }
                                    
                                    //sendmessage = "0".equals(signPos) ? (sign + sendmessage) : (sendmessage + sign);
                                    PushNotificationService service = new PushNotificationService();
                                    Map<String, String> para = new HashMap();
                                    String type = Util.null2String(this.getPropValue("YiliMessage", "type"));
                                    String yiliUrl = Util.null2String(this.getPropValue("YiliMessage", "url"));
                                    String charset = Util.null2String(this.getPropValue("YiliMessage", "charset"));

                                    if ("".equals(type)) {
                                        type = "30";
                                    }
                                    if("".equals(yiliUrl)){
                                        yiliUrl="/OverTime.jsp";
                                    }
                                    if("".equals(charset)){
                                        charset="GBK";
                                    }

                                    para.put("module", "-2");
                                     para.put("messagetypeid", type);
                                    for(int i=0;i<smstemplist.size();i++){

                                        // smsManager.sendSMS((String)smstemplist.get(i),sendmessage);
                                       // msgsend=smsManager.sendSMS((String)smstemplist.get(i),sendmessage);
                                        writeLog("(String)smstemplist.get(i)"+(String)smstemplist.get(i));
                                        writeLog("(String)sendmessage.get(i)"+sendmessage);
                                        writeLog("(String)para.get(i)"+ para.values().toString());
                                        try {
                                            para.put("url",yiliUrl+"?requestid="+requestid);
                                        }catch (Exception e){
                                            writeLog(e);
                                        }
                                        service.push((String)smstemplist.get(i),sendmessage, 1, para);
                                        writeLog("发送完成"+requestid+"sendmessage"+sendmessage+"type"+type);

                                    }
                                    msgsend=true;
                                }else{
                                    msgsend=true;
                                }
                            }
                            /***********************************************************************************************/
                            if(MailRemind_csh==1){//邮件提醒
                                String mailtoaddress="";
                                String mailrequestname = SystemEnv.getHtmlLabelName(18910,language);
                                String mailobject=SystemEnv.getHtmlLabelName(18910,language);
                                String creater="";
                                int creatertype=0;
                                sql="select creater,creatertype,requestname from workflow_requestbase where requestid="+requestid;
                                rs2.executeSql(sql);
                                if(rs2.next()){
                                    creater=rs2.getString("creater");
                                    creatertype=Util.getIntValue(rs2.getString("creatertype"),0);
                                    mailrequestname = SystemEnv.getHtmlLabelName(18015,language)+"("+rs2.getString("requestname")+")已超时";
                                    mailobject=SystemEnv.getHtmlLabelName(18910,language)+"("+rs2.getString("requestname")+")";
                                }
                                if(isnodeoperator_csh==1){//本节点操作人本人
                                    //本节点操作人提醒
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        if(userid>0){
                                            if(usertype==0){
                                                String tempmail=resource.getEmail(""+userid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+userid+",")<0)
                                                        remindusers+=userid+",";
                                                    }
                                                }
                                            }else{ //客户
                                                String tempmail=crminfo.getCustomerInfoEmail(""+userid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+userid+",")<0)
                                                        remindusers+=userid+",";
                                                    }
                                                }
                                            }
                                        }
                                        //代理人提醒




                                        if(agenttype>0 && agentorbyagentid>0){
                                            if(usertype==0){
                                                String tempmail=resource.getEmail(""+agentorbyagentid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+agentorbyagentid+",")<0)
                                                        remindusers+=agentorbyagentid+",";
                                                    }
                                                }
                                            }else{//客户
                                                String tempmail=crminfo.getCustomerInfoEmail(""+agentorbyagentid);
                                                if(tempmail!=null && !tempmail.trim().equals("")){
                                                    if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                        mailtoaddress+=tempmail+",";
                                                        if((","+remindusers).indexOf(","+agentorbyagentid+",")<0)
                                                        remindusers+=agentorbyagentid+",";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                if(iscreater_csh==1){//创建人




                                    if(creatertype==0){
                                        String tempmail=resource.getEmail(creater);
                                        if(tempmail!=null && !tempmail.trim().equals("")){
                                            if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                mailtoaddress+=tempmail+",";
                                                if((","+remindusers).indexOf(","+creater+",")<0)
                                                    remindusers+=creater+",";
                                            }
                                        }
                                    }else{//客户
                                        String tempmail=crminfo.getCustomerInfoEmail(creater);
                                        if(tempmail!=null && !tempmail.trim().equals("")){
                                            if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                mailtoaddress+=tempmail+",";
                                                if((","+remindusers).indexOf(","+creater+",")<0)
                                                    remindusers+=creater+",";
                                            }
                                        }
                                    }
                                }
                                if(ismanager_csh==1){//本节点操作人经理
                                    int managerid=0;
                                    for(int k=0;k<userlist.size();k++){
                                        int agenttype=Util.getIntValue((String)agenttypelist.get(k));
                                        int agentorbyagentid=Util.getIntValue((String)agentorbyagentidlist.get(k));
                                        userid=Util.getIntValue((String)userlist.get(k));
                                        usertype=Util.getIntValue((String)usertypelist.get(k));
                                        if(usertype==0){
                                            managerid=Util.getIntValue(resource.getManagerID(userid+""),0);
                                        }else{
                                            managerid=Util.getIntValue(crminfo.getCustomerInfomanager(userid+""),0);
                                        }
                                        if(managerid>0){
                                            String tempmail=resource.getEmail(""+managerid);
                                            if(tempmail!=null && !tempmail.trim().equals("")){
                                                if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                    mailtoaddress+=tempmail+",";
                                                    if((","+remindusers).indexOf(","+managerid+",")<0)
                                                        remindusers+=managerid+",";
                                                }
                                            }
                                        }
                                    }
                                }
                                if(isother_csh==1){//指定对象
                                    ArrayList remindobjectlist=Util.TokenizerString(remindobjectids_csh,",");
                                    for(int i=0;i<remindobjectlist.size();i++){
                                        String tempmail=resource.getEmail((String)remindobjectlist.get(i));
                                        if(tempmail!=null && !tempmail.trim().equals("")){
                                            if((","+mailtoaddress).indexOf(","+tempmail+",")<0){
                                                mailtoaddress+=tempmail+",";
                                                if((","+remindusers).indexOf(","+remindobjectlist.get(i)+",")<0)
                                                    remindusers+=remindobjectlist.get(i)+",";
                                            }
                                        }
                                    }
                                }
                                if(!"".equals(mailtoaddress)){
                                        mailtoaddress = mailtoaddress.substring(0,mailtoaddress.length()-1);
                                        SendMail sm = new SendMail();
                                        SystemComInfo systemComInfo = new SystemComInfo();
                                        String defmailserver = systemComInfo.getDefmailserver();
                                        String defneedauth = systemComInfo.getDefneedauth();
                                        String defmailuser = systemComInfo.getDefmailuser();
                                        String defmailpassword = systemComInfo.getDefmailpassword();
                                        String defmailfrom=systemComInfo.getDefmailfrom();
                                        sm.setMailServer(defmailserver);
                                        if (defneedauth.equals("1")) {
                                        sm.setNeedauthsend(true);
                                        sm.setUsername(defmailuser);
                                        sm.setPassword(defmailpassword);
                                        } else{
                                        sm.setNeedauthsend(false);
                                        }
                                        /*try {
                                              mailrequestname = new String(mailrequestname.getBytes("UTF-8"),"iso-8859-1");
                                        } catch (UnsupportedEncodingException e){
                                            e.printStackTrace();
                                        }*/
                                        mailsend=sm.sendhtml(defmailfrom, mailtoaddress, null, null,mailobject , mailrequestname, 3, "3");
                                }
                            }
                            
                            if(InfoCentreRemind_csh==1){//超时后信息中心提醒




                            	if(CustomWorkflowid_csh>0){
                                	String requestname="";
                                    sql="select t.requestname,t1.userid  from workflow_currentoperator t1,workflow_requestbase t where t1.requestid=t.requestid and t.requestid="+requestid+" and t1.nodeid="+nodeid+" and isremark='0' ";
                                    rs8.executeSql(sql);
                                    if(rs8.next()){
                                    	requestname=Util.null2String(rs8.getString("requestname"));
										String remark = "相关流程：<a href='/workflow/request/ViewRequest.jsp?requestid="+requestid+"&isovertime=0'>"+requestname+"</a>";
										requestname = " 流程{"+requestname+"}已超时";
										docreateWorkflow(CustomWorkflowid_csh+"","1",requestname,remark);
                                   }else{
                                	    wfcreate = true;
                                   }
                                    
                                    wfcreate = true;
                            	}
                            }
                            if((remindusers.length()>0 && ((FlowRemind_csh==1 && wfsend) || (MsgRemind_csh==1 && msgsend) || (MailRemind_csh==1 && mailsend)) ) || (InfoCentreRemind_csh==1 && wfcreate)){
                            	sql="update workflow_currentoperator set isreminded_csh='1' where isremark='0' and requestid="+requestid;
                                rs2.executeSql(sql);
                                log.debug(sql);
                            }
                        }
                    }
                    //超时后提醒--end
                    /***********************************************************************************************/
//                }else{
//                    //找不到下一节点，不做超时处理




//                    for (int i = 0; i < idlist.size(); i++) {
//                        sql = "update workflow_currentoperator set isreminded='1',isprocessed='4' where id=" + idlist.get(i) + " and requestid=" + requestid;
//                        rs2.executeSql(sql);
//                    }
                }
            }
        }
    }
    
    public String docreateWorkflow(String workflowid,String createuser,String requestname,String remark){
    	WorkflowService  wfimp=new 	WorkflowServiceImpl();
		//创建流程接口调用方式
		WorkflowRequestInfo info=new WorkflowRequestInfo();
		int userId=1;
		info.setRequestName(requestname);//此处可以自定义标题名称




		info.setCreatorId(createuser);//创建人




		info.setRemark(remark);
		WorkflowBaseInfo base=new WorkflowBaseInfo();

		RecordSet rs = new RecordSet();
	    base.setWorkflowId(workflowid);//流程id
		info.setWorkflowBaseInfo(base);
		WorkflowMainTableInfo maininfo=new WorkflowMainTableInfo();
		WorkflowRequestTableRecord[] tablre = new WorkflowRequestTableRecord[1]; 
		tablre[0]=new WorkflowRequestTableRecord();
		WorkflowRequestTableField[] wrti = new WorkflowRequestTableField[6];
		//特此重点说明：WorkflowRequestTableField[3] 3代表此类流程可编辑或必填的字段有3个 
		//①、必填的字段必须都要按照如下方式拼接进去 ；②、可编辑字段不需要都编辑进去 可选择性进行拼接 可按照实际情况进行选择；




		//wrti[0]=new WorkflowRequestTableField();
		//wrti[0].setFieldName("khnd");//字段名称 假设第一个是流程标题  这个地方就是对应数据库的字段名称
		//wrti[0].setFieldValue(khnd);//字段值  对应的值




		//wrti[0].setEdit(true);//是否能编辑




		//wrti[0].setView(true);//是否可以查看
		//wrti[0].setMand(true);//是否必填
									
		tablre[0].setWorkflowRequestTableFields(wrti);
		maininfo.setRequestRecords(tablre);
		info.setWorkflowMainTableInfo(maininfo);
	    String flags=wfimp.doCreateWorkflowRequest(info, userId);
	    
	    this.writeLog("docreateWorkflow##workflowid:"+workflowid+" requestname:"+requestname+" remark:"+remark);
		return flags;
    }

	private String getDateValue(int requestid, String dateField, String timeField) {
		String sql;
		String dateValue = "";
		String timeValue = "";
		//通过requestid查找formid
		sql="select wr.requestid,wr.workflowid,wb.id,wb.formid,wb.workflowname,wb.isbill from workflow_requestbase wr,workflow_base wb where wr.workflowid=wb.id and wr.requestid="+requestid;
		rs2.executeSql(sql);
		rs2.next();
		String formid = Util.null2String(rs2.getString("formid"));
		String isbill = Util.null2String(rs2.getString("isbill"));
		String fieldstr = "";
		if(!"".equals(timeField)){
			fieldstr = dateField+","+timeField;
		}else{
			fieldstr = dateField;
		}
		if("1".equals(isbill)){
			//通过formid,字段名 获取tablename
			sql="select b.tablename from workflow_bill b where b.id="+formid+" ";
			rs2.executeSql(sql);
			rs2.next();
			String tablename = Util.null2String(rs2.getString("tablename"));
			//通过requestid 在tablename中找到dateField的值




			sql="select "+fieldstr+" from "+tablename+" where requestid="+requestid;
		}else{
			sql = "select "+fieldstr+" from workflow_form where requestid="+requestid;
		}
		
		rs2.executeSql(sql);
		if(rs2.next()){
			dateValue = Util.null2String(rs2.getString(dateField));
			if(!"".equals(timeField)){
				timeValue = Util.null2String(rs2.getString(timeField));
			}
		}
		if(!dateValue.equals("")){
			if("".equals(timeValue)) dateValue += " 00:00:00";
	    	else dateValue += " "+timeValue+":00";
		}
		return dateValue;
	}

    /**
     * 检查是否有必填项




     * @param requestid
     * @param workflowid
     * @param nodeid
     * @return boolean
     */
    private boolean hasNeedInputField(int requestid,int workflowid,int nodeid){
    	List lstDetailFields = null;
		Map<String, String> mainTblFields = null;
        try {
			WorkflowComInfo workflowTool = new WorkflowComInfo();
			int isBill = Util.getIntValue(workflowTool.getIsBill(String.valueOf(workflowid)));
			int formID = Util.getIntValue(workflowTool.getFormId(String.valueOf(workflowid)));
			FieldInfo fieldTool = new FieldInfo();
			fieldTool.setRequestid(requestid);
			fieldTool.GetManTableField(formID, isBill, 7);
			fieldTool.GetDetailTblFields(formID, isBill, 7);
			
			mainTblFields = fieldTool.getMainFieldValues();
			lstDetailFields = fieldTool.getDetailFieldValues();
		} catch (Exception e) {
			log.info("Catch a exception during instantiate the WorkflowComInfo.", e);
			return true;
		}
        
        String sql="select a.ismode,a.showdes,b.formid,b.isbill from workflow_flownode a,workflow_base b where a.workflowid=b.id and a.workflowid="+workflowid+" and a.nodeid="+nodeid;
        rs3.executeSql(sql);
        if(rs3.next()){
            int ismode=Util.getIntValue(rs3.getString("ismode"),0);
            int showdes=Util.getIntValue(rs3.getString("showdes"),0);
            if(ismode==0 || (ismode==1 && showdes==1)){//一般模式




                sql="select fieldid from workflow_nodeform where ismandatory='1' and nodeid="+nodeid;
            }
			//add by liao dong update
            else if(ismode == 2){ //html模式
            	 sql="select fieldid from workflow_nodeform where ismandatory='1' and nodeid="+nodeid;
            }
            //end 	
					
			else{//模板模式
                sql="select fieldid from workflow_modeview where ismandatory='1' and nodeid="+nodeid;
            }
            rs3.executeSql(sql);
            while (rs3.next()) {
                String fieldid=rs3.getString("fieldid");
                //是否为主表单字段
                if(mainTblFields.containsKey(fieldid)){
                	String fieldValue = mainTblFields.get(fieldid);
                	if(fieldValue == null || "".equals(fieldValue)){
                		return true;
                	}
                }else{
                	//主表单中不存在该字段，则对多明细字段进行循环。




                	for (int i = 0; i < lstDetailFields.size(); i++) {
						List tmpList = (List)lstDetailFields.get(i);
						for (int j = 0; j < tmpList.size(); j++) {
							Map<String, String> mapDetailFields = (Map<String, String>)tmpList.get(j);
							if(!mapDetailFields.containsKey(fieldid)){
								break;
							}else{
								String fieldValue = mapDetailFields.get(fieldid);
			                	if(fieldValue == null || "".equals(fieldValue)){
			                		return true;
			                	}
							}
						}
					}
                }
            }
            
        }
        return false;
    }

    /**
     * 获得下一节点的出口id
     * @param requestid
     * @param nodeid
     * @param userid
     * @param usertype
     * @return linkid 出口id
     */
    public int getNextNode(int requestid,int nodeid,int userid,int usertype){
        // 查询当前请求的一些基本信息




        rs3.executeProc("workflow_Requestbase_SByID", requestid + "");
        int creater=0;
        int creatertype=0;
        int workflowid=0;
        int isbill=0;
        int formid=0;
        int billid=0;
        String billtablename="";
        String nodetype="";
        if(rs3.next()){
            creater = Util.getIntValue(rs3.getString("creater"), 0);
            creatertype = Util.getIntValue(rs3.getString("creatertype"), 0);
            workflowid= Util.getIntValue(rs3.getString("workflowid"), 0);
        }
        rs3.executeSql("select isbill,formid from workflow_base where id="+workflowid);
        if(rs3.next()){
            isbill=Util.getIntValue(rs3.getString("isbill"),0);
            formid=Util.getIntValue(rs3.getString("formid"),0);
        }
        rs3.executeSql("select nodetype from workflow_flownode where workflowid="+workflowid+" and nodeid="+nodeid);
        if(rs3.next()){
            nodetype=rs3.getString("nodetype");
        }
        rs3.executeSql("select tablename from workflow_bill where id="+formid);
        if(rs3.next()){
            billtablename=Util.null2String(rs3.getString("tablename"));
        }
        if(!billtablename.trim().equals("")){
            rs3.executeSql("select id from "+billtablename+" where requestid="+requestid);
            if(rs3.next()){
                billid=Util.getIntValue(rs3.getString("id"));
            }
        }
        
        int mgrID = this.updateManagerField(requestid, formid, isbill, userid);
        
        boolean hasnextnodeoperator =false;
        RequestNodeFlow requestNodeFlow = new RequestNodeFlow();
        requestNodeFlow.setRequestid(requestid);
        requestNodeFlow.setNodeid(nodeid);
        requestNodeFlow.setNodetype(nodetype);
        requestNodeFlow.setWorkflowid(workflowid);
        requestNodeFlow.setUserid(userid);
		requestNodeFlow.setIsreject(0);
        requestNodeFlow.setUsertype(usertype);
        requestNodeFlow.setCreaterid(creater);
        requestNodeFlow.setCreatertype(creatertype);
        requestNodeFlow.setIsbill(isbill);
        requestNodeFlow.setBillid(billid);
        requestNodeFlow.setFormid(formid);
        requestNodeFlow.setBilltablename(billtablename);
        requestNodeFlow.setRecordSet(rs3);
		requestNodeFlow.setIsGetFlowCodeStr(false);//超时不获取流程编号




        hasnextnodeoperator = requestNodeFlow.getNextNode();
        //还原Manager
        this.rollbackUpdatedManagerField(requestid, formid, isbill, mgrID);
        if(hasnextnodeoperator){
            return requestNodeFlow.getNextLinkid();
        }else{
            return 0;
        }
    }

    /**
     * 指定一个流程流转到下一节点
     * @param requestid
     */
    public void autoFLowNextNode(int requestid) {
        RecordSet rs = new RecordSet();
    	StringBuilder sb = new StringBuilder();
    	sb.append("SELECT DISTINCT requestid,nodeid,workflowid,workflowtype FROM workflow_currentoperator WHERE workflowtype<>1 AND isremark='0'");
    	sb.append(" AND requestid='").append(requestid).append("'");
    	sb.append(" AND (EXISTS (SELECT 1 FROM workflow_nodelink t1 WHERE t1.wfrequestid IS NULL AND EXISTS (SELECT 1 FROM workflow_base t2 WHERE t1.workflowid=t2.id AND (t2.istemplate IS NULL OR t2.istemplate<>'1')) AND workflow_currentoperator.nodeid=t1.nodeid)");
    	sb.append(" OR EXISTS (SELECT 1 FROM workflow_nodelink t1 WHERE EXISTS (SELECT 1 FROM workflow_base t2 WHERE t1.workflowid=t2.id AND (t2.istemplate IS NULL OR t2.istemplate<>'1')) AND workflow_currentoperator.nodeid=t1.nodeid and workflow_currentoperator.requestid=t1.wfrequestid))");
    	sb.append(" AND (isreminded IS NULL OR isprocessed IS NULL OR isreminded_csh IS NULL) GROUP BY requestid,nodeid,workflowid,workflowtype ORDER BY requestid desc ,nodeid");
    	rs.executeSql(sb.toString());
        while(rs.next()) {
            int nodeid = Util.getIntValue(rs.getString("nodeid"));
			int workflowid = Util.getIntValue(rs.getString("workflowid"));
			int workflowtype = Util.getIntValue(rs.getString("workflowtype"));
			ArrayList userlist = new ArrayList();
			ArrayList usertypelist = new ArrayList();
			ArrayList agenttypelist = new ArrayList();
			ArrayList agentorbyagentidlist = new ArrayList();
			ArrayList isremindedlist = new ArrayList();
			ArrayList isreminded_cshlist = new ArrayList();
			ArrayList isprocessedlist = new ArrayList();
			ArrayList currentdatetimelist = new ArrayList();
			ArrayList idlist = new ArrayList();
			boolean isCanSubmit = true;
			sb.setLength(0);
			sb.append("SELECT * FROM workflow_currentoperator WHERE workflowtype<>1 AND isremark='0' AND (isreminded IS NULL OR isprocessed IS NULL OR isreminded_csh IS NULL)");
			sb.append(" AND requestid='").append(requestid).append("' AND nodeid='").append(nodeid).append("' ORDER BY requestid DESC,id");
			rs5.executeSql(sb.toString());
			while (rs5.next()) {
				String currentdatetimes = rs5.getString("receivedate") + " "
						+ rs5.getString("receivetime");
				String userids = rs5.getString("userid");
				String usertypes = rs5.getString("usertype");
				String agenttypes = rs5.getString("agenttype");
				String agentorbyagentids = rs5.getString("agentorbyagentid");
				String isremindeds = rs5.getString("isreminded");
				String isreminded_cshs = rs5.getString("isreminded_csh");// 超时后提醒




				String isprocesseds = rs5.getString("isprocessed");
				String ids = rs5.getString("id");

				WFForwardManager wfforwardMgr = new WFForwardManager();
				wfforwardMgr.setWorkflowid(workflowid);
				wfforwardMgr.setNodeid(nodeid);
				wfforwardMgr.setIsremark("0");
				wfforwardMgr.setRequestid(requestid);
				wfforwardMgr.setBeForwardid(Util.getIntValue(ids));
				wfforwardMgr.getWFNodeInfo();

				if (!wfforwardMgr.getCanSubmit()) {
					isCanSubmit = false;
					break;
				}

				userlist.add(userids);
				usertypelist.add(usertypes);
				agenttypelist.add(agenttypes);
				agentorbyagentidlist.add(agentorbyagentids);
				isremindedlist.add(isremindeds);
				isreminded_cshlist.add(isreminded_cshs);
				isprocessedlist.add(isprocesseds);
				currentdatetimelist.add(currentdatetimes);
				idlist.add(ids);
            }

            if (!isCanSubmit) continue;

            //会签特殊处理,为会签时,只取第一个用户来进行节点流转检查,并获得超时设置信息(因为其它用户获得的信息一样,不重复获取了)
            if (userlist.size() > 0) {
	            int userid = Util.getIntValue((String) userlist.get(0));
				int usertype = Util.getIntValue((String) usertypelist.get(0));
				int isreminded = Util.getIntValue((String) isremindedlist.get(0), 0);
				int isreminded_csh = Util.getIntValue((String) isreminded_cshlist.get(0), 0);
				int isprocessed = Util.getIntValue((String) isprocessedlist.get(0), 0);
				String currentdatetime = (String) currentdatetimelist.get(0);
				int nextlinkid = getNextNode(requestid, nodeid, userid, usertype);
				int language = 7;
				user.setUid(userid);
				user.setLogintype((usertype + 1) + "");
				user.setLastname(resource.getLastname(userid + ""));
				sb.setLength(0);
				sb.append("SELECT * FROM HrmResource WHERE id='").append(userid).append("'");
				rs1.executeSql(sb.toString());
				if (rs1.next()) {
					language = Util.getIntValue(rs1.getString("systemlanguage"), 7);
					user.setLanguage(language);
				}
				sb.setLength(0);
				sb.append("SELECT * FROM workflow_nodelink WHERE id='").append(nextlinkid).append("'");
	            rs1.executeSql(sb.toString());
	            if (rs1.next()) {
	                // 自动流转
					if (!hasNeedInputField(requestid, workflowid, nodeid)) {
						AutoFlowNextNode(requestid, nodeid, userlist, usertypelist,agenttypelist,agentorbyagentidlist,workflowtype, SystemEnv.getHtmlLabelName(18849, language));
					}
	            }
	        }
        }
    }

    /**
	 * 自动流转至下一操作者




	 * 
	 * @param requestid
	 * @param nodeid
	 * @param userlist
	 * @param usertypelist
	 * @param workflowtype
	 */
    private void AutoFlowNextNode(int requestid,int nodeid,ArrayList userlist,ArrayList usertypelist,ArrayList agenttypelist,ArrayList agentorbyagentidlist,int workflowtype,String ProcessorOpinion){
        RecordSet rs = new RecordSet();
        
        Calendar today = Calendar.getInstance();
        String currentdate = Util.add0(today.get(Calendar.YEAR), 4) + "-" +
                Util.add0(today.get(Calendar.MONTH) + 1, 2) + "-" +
                Util.add0(today.get(Calendar.DAY_OF_MONTH), 2);

        String currenttime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
                Util.add0(today.get(Calendar.MINUTE), 2) + ":" +
                Util.add0(today.get(Calendar.SECOND), 2);
        //获得数据库服务器当前时间
        String sql="";
        if(rs5.getDBType().equals("oracle")){
            sql="select to_char(sysdate,'yyyy-mm-dd') currentdate,to_char(sysdate,'hh24:mi:ss') currenttime from dual";
        }else{
            sql="select convert(char(10),getdate(),20) currentdate,convert(char(8),getdate(),108) currenttime";
        }
        rs5.executeSql(sql);
        if(rs5.next()){
           currentdate=rs5.getString("currentdate");
           currenttime=rs5.getString("currenttime");
        }
        // 查询当前请求的一些基本信息




        rs3.executeProc("workflow_Requestbase_SByID", requestid + "");
        int passedgroups=0;
        int totalgroups=0;
        int creater=0;
        int creatertype=0;
        int workflowid=0;
        int nextnodeid=0;
        String nextnodetype="";
        int linkid=0;
        String status="";
        Hashtable operatorsht = new Hashtable();
        int rqMessageType=0;
        String mailrequestname = "";
        String mailMessageType = "0";
        int level=0;
        int isbill=0;
        int formid=0;
        int billid=0;
        String billtablename="";
        String nodetype="";
        if(rs3.next()){
            creater = Util.getIntValue(rs3.getString("creater"), 0);
            creatertype = Util.getIntValue(rs3.getString("creatertype"), 0);
            workflowid= Util.getIntValue(rs3.getString("workflowid"), 0);
            rqMessageType= Util.getIntValue(rs3.getString("MessageType"), 0);
            mailrequestname = Util.null2String(rs3.getString("requestname"));
            level=Util.getIntValue(rs3.getString("requestlevel"),0);
            mailMessageType = rs3.getString("mailMessageType");
            totalgroups = Util.getIntValue(rs3.getString("totalgroups"), 0);
            passedgroups = Util.getIntValue(rs3.getString("passedgroups"), 0);
            status = rs3.getString("status");
        }
        rs3.executeSql("select isbill,formid from workflow_base where id="+workflowid);
        if(rs3.next()){
            isbill=Util.getIntValue(rs3.getString("isbill"),0);
            formid=Util.getIntValue(rs3.getString("formid"),0);
            mailMessageType = rs3.getString("mailMessageType");
        }
        rs3.executeSql("select nodetype from workflow_flownode where workflowid="+workflowid+" and nodeid="+nodeid);
        if(rs3.next()){
            nodetype=rs3.getString("nodetype");
        }
        rs3.executeSql("select tablename from workflow_bill where id="+formid);
        if(rs3.next()){
            billtablename=Util.null2String(rs3.getString("tablename"));
        }
        if(!billtablename.trim().equals("")){
            rs3.executeSql("select id from "+billtablename+" where requestid="+requestid);
            if(rs3.next()){
                billid=Util.getIntValue(rs3.getString("id"));
            }
        }
        
        int mgrID = this.updateManagerField(requestid, formid, isbill, Util.getIntValue((String)userlist.get(userlist.size()-1)));
        
        boolean isWorkFlowToDoc = false;
        
        rs.executeSql("select * from workflow_addinoperate  where workflowid="+workflowid+" and isnode=1 and objid="+nodeid+" and ispreadd='0' and type=2 and customervalue='action.WorkflowToDoc' ");                                  
        if(rs.next()) {
            isWorkFlowToDoc=true;
        }
        
        //节点后自动赋值处理 START
        try {
            RequestCheckAddinRules requestCheckAddinRules = new RequestCheckAddinRules();
            requestCheckAddinRules.resetParameter();
            requestCheckAddinRules.setRequestid(requestid);
            requestCheckAddinRules.setObjid(nodeid);
            requestCheckAddinRules.setObjtype(1);
            requestCheckAddinRules.setIsbill(isbill);
            requestCheckAddinRules.setFormid(formid);
            requestCheckAddinRules.setIspreadd("0");
            requestCheckAddinRules.checkAddinRules();
        } catch (Exception erca) {
            log.error("节点后赋值处理错误:"+erca.getMessage());
        }
        
        //节点后自动赋值处理 END
        
        // 如果是提交节点, 查询通过了的组数
        String groupdetailids="";
        rs3.executeSql("select count(distinct groupid) from workflow_currentoperator where isremark = '0' and requestid=" + requestid + " and userid=" + userlist.get(0) + " and usertype=" + usertypelist.get(0));
		if (rs3.next()) passedgroups += Util.getIntValue(rs3.getString(1), 0);
		
		int oboindex = 0;
        for (int i=0; i<userlist.size(); i++) {
            int tempuserid = Util.getIntValue((String)userlist.get(i));
            int tempusertype = Util.getIntValue((String)usertypelist.get(i));
            
    		//判断该人所在组是否含有依次逐个递交的组，如果有一个，则passedgroups-1，并且进入得到下个操作者的方法
    		rs3.execute("select distinct groupdetailid,groupid from workflow_currentoperator where isremark = '0' and requestid=" + requestid + " and userid=" + tempuserid + " and usertype=" + tempusertype);
    
    		while (rs3.next())
    		{
    			rs4.execute("select * from workflow_groupdetail where id="+rs3.getInt("groupdetailid"));
    			if (rs4.next())
    			{
                    int type = rs4.getInt("type");
    				int objid = rs4.getInt("objid");
    				int leveln = rs4.getInt("signorder");
    				if (WFPathUtil.isContinuousProcessing(type) && leveln == 2)
    				{    //判断是否还有剩余节点
    					rs4.execute("select * from workflow_agentpersons where requestid="+requestid+" and (groupdetailid="+rs3.getInt("groupdetailid")+" or groupdetailid is null)");
    					if (rs4.next()&&!rs4.getString("receivedPersons").equals(""))
    					{
                            passedgroups--;
    						groupdetailids=groupdetailids.equals("")?rs3.getString("groupdetailid")+"_"+rs3.getString("groupid"):groupdetailids+","+rs3.getString("groupdetailid")+"_"+rs3.getString("groupid");
    						oboindex = i;
    					}
    				}
    
    			}
    		}
        }
        // 查询下一个节点的操作者




        boolean hasnextnodeoperator =false;
        nextnodeids = new ArrayList();
        nextnodetypes = new ArrayList();
        nextlinkids = new ArrayList();
        nextlinknames = new ArrayList();
        operatorshts = new ArrayList();
        nextnodeattrs = new ArrayList();
        nextnodepassnums = new ArrayList();
        linkismustpasss = new ArrayList();
        boolean canflowtonextnode=true;
        int nextnodeattr=0;
        WFLinkInfo wflinkinfo=new WFLinkInfo();
        RequestNodeFlow requestNodeFlow = new RequestNodeFlow();
        //System.out.println(passedgroups+"|"+totalgroups);
        if(groupdetailids.equals("")){
            //System.out.println("aaaaaaaaaaa");
            requestNodeFlow.setRequestid(requestid);
            requestNodeFlow.setNodeid(nodeid);
            requestNodeFlow.setNodetype(nodetype);
            requestNodeFlow.setWorkflowid(workflowid);
            requestNodeFlow.setUserid(Util.getIntValue((String)userlist.get(oboindex)));
            requestNodeFlow.setUsertype(Util.getIntValue((String)usertypelist.get(oboindex)));
            requestNodeFlow.setCreaterid(creater);
            requestNodeFlow.setCreatertype(creatertype);
            requestNodeFlow.setIsbill(isbill);
            requestNodeFlow.setBillid(billid);
            requestNodeFlow.setFormid(formid);
            requestNodeFlow.setBilltablename(billtablename);
            requestNodeFlow.setRecordSet(rs3);
			requestNodeFlow.setIsreject(0);
			requestNodeFlow.setIsintervenor("1");
            requestNodeFlow.getNextNodes();
            nextnodeids=requestNodeFlow.getNextnodeids();
            nextnodetypes=requestNodeFlow.getNextnodetypes();
            nextlinkids=requestNodeFlow.getNextlinkids();
            nextlinknames=requestNodeFlow.getNextlinknames();
            operatorshts=requestNodeFlow.getOperatorshts();
            nextnodeattrs=requestNodeFlow.getNextnodeattrs();
            nextnodepassnums=requestNodeFlow.getNextnodepassnums();
            linkismustpasss=requestNodeFlow.getLinkismustpasss();
            if(nextnodeids.size()>0) hasnextnodeoperator=true;
            //System.out.println(hasnextnodeoperator);
        }else{
                //System.out.println("bbbbbbbbbbbbb");
                requestNodeFlow.setRequestid(requestid);
                requestNodeFlow.setNodeid(nodeid);
                requestNodeFlow.setNodetype(nodetype);
                requestNodeFlow.setWorkflowid(workflowid);
                requestNodeFlow.setUserid(Util.getIntValue((String)userlist.get(0)));
                requestNodeFlow.setUsertype(Util.getIntValue((String)usertypelist.get(0)));
                requestNodeFlow.setCreaterid(creater);
                requestNodeFlow.setCreatertype(creatertype);
                requestNodeFlow.setIsbill(isbill);
                requestNodeFlow.setBillid(billid);
                requestNodeFlow.setFormid(formid);
                requestNodeFlow.setBilltablename(billtablename);
                requestNodeFlow.setRecordSet(rs3);
				requestNodeFlow.setIsintervenor("1");
                hasnextnodeoperator = requestNodeFlow.getNextOrderOperator(groupdetailids);
                if(hasnextnodeoperator){
                    nextnodeids.add(""+nodeid);
                    nextnodetypes.add(nextnodetype);
                    nextlinkids.add(""+requestNodeFlow.getNextLinkid());
                    operatorshts.add(requestNodeFlow.getOperators());
                    nextlinknames.add(status);
                    nextnodeattr=wflinkinfo.getNodeAttribute(nodeid);
                    nextnodeattrs.add(""+nextnodeattr);
                    nextnodepassnums.add("2");
                    linkismustpasss.add("1");
                }
        }
        if (hasnextnodeoperator) {
             //获得所有下一个节点的nodeid，用于查询流程生成计划任务设置




             String wf_nextnodeids = "";
             for(int i=0;i<nextnodeids.size();i++){
                nextnodeid = Util.getIntValue((String)nextnodeids.get(i));
                //System.out.println("nextnodeid:"+nextnodeid);
                wf_nextnodeids += (""+nextnodeid+", ");     //TD9427
                
                nextnodetype = (String) nextnodetypes.get(i);
                status = (String) nextlinknames.get(i);
                nextnodeattr = Util.getIntValue((String) nextnodeattrs.get(i), 0);
                linkid = Util.getIntValue((String) nextlinkids.get(i));
                operatorsht = (Hashtable) operatorshts.get(i);
                totalgroups = operatorsht.size();
                if (groupdetailids.equals("") && (nextnodeattr == 3 || nextnodeattr == 4))
                    canflowtonextnode = wflinkinfo.FlowToNextNode(requestid, nodeid, nextnodeid, "" + nextnodeattr, Util.getIntValue((String) nextnodepassnums.get(i)), Util.getIntValue((String) linkismustpasss.get(i)));
                //System.out.println(nodeid+"|"+nextnodeid+"|"+linkid+"|"+totalgroups);
                rs.executeSql("select * from workflow_addinoperate  where workflowid="+workflowid+" and ((isnode=0 and objid="+linkid+" and ispreadd='0') or (isnode=1 and objid="+nextnodeid+" and ispreadd='1' )) and type=2 and customervalue='action.WorkflowToDoc' ");     
                if(rs.next()){
                    isWorkFlowToDoc=true;
                }
                /*
                // 出口自动赋值处理




                try {
                    RequestCheckAddinRules requestCheckAddinRules = new RequestCheckAddinRules();
                    requestCheckAddinRules.resetParameter();
                    requestCheckAddinRules.setRequestid(requestid);
                    requestCheckAddinRules.setObjid(linkid);
                    requestCheckAddinRules.setObjtype(0);               // 1: 节点自动赋值 0 :出口自动赋值




                    requestCheckAddinRules.setIsbill(isbill);
                    requestCheckAddinRules.setFormid(formid);
                    requestCheckAddinRules.setIspreadd("0");//xwj for td3130 20051123
                    requestCheckAddinRules.checkAddinRules();
                } catch (Exception erca) {
                        log.error("出口赋值处理错误:"+erca.getMessage());
                }
                */
                RequestManager rm = new RequestManager();
                rm.setUser(user);
                rm.setWorkflowid(workflowid);
                rm.setRequestid(requestid);
                rm.setSrc("submit");
                rm.setIscreate("0");
                rm.setRequestid(requestid);
                rm.setWorkflowid(workflowid);
                rm.setIsremark(0);
                rm.setFormid(formid);
                rm.setIsbill(isbill);
                rm.setBillid(billid);
                rm.setNodeid(nodeid);
                rm.setNodetype(nodetype);
                rs.executeSql("select * from workflow_requestbase where requestid=" + requestid);
                if (rs.next()) {
                    rm.setRequestname(rs.getString("requestname"));
                    rm.setRequestlevel(rs.getString("requestlevel"));
                    rm.setMessageType(rs.getString("messageType"));
                    rm.setCreater(Util.getIntValue(rs.getString("creater")));
                    rm.setCreatertype(Util.getIntValue(rs.getString("creatertype")));
                    //是否允许退回时选择节点
                }
                
                //出口赋值




                try {
                    //linkid=Util.getIntValue((String)nextlinkids.get(n));
                    RequestCheckAddinRules requestCheckAddinRules = new RequestCheckAddinRules();
                    //add by cyril on 2008-07-28 for td:8835 事务无法开启查询,只能传入
                    //requestCheckAddinRules.setTrack(isTrack);
//                    requestCheckAddinRules.setStart(isStart);
                    requestCheckAddinRules.setNodeid(nodeid);
                    //end by cyril on 2008-07-28 for td:8835
                    requestCheckAddinRules.resetParameter();
                    requestCheckAddinRules.setRequestid(requestid);
                    requestCheckAddinRules.setWorkflowid(workflowid);
                    requestCheckAddinRules.setObjid(linkid);
                    requestCheckAddinRules.setObjtype(0);               // 1: 节点自动赋值 0 :出口自动赋值




                    requestCheckAddinRules.setIsbill(isbill);
                    requestCheckAddinRules.setFormid(formid);
                    requestCheckAddinRules.setIspreadd("0");//xwj for td3130 20051123
                    requestCheckAddinRules.setUser(user);//add by fanggsh 20061016 fot TD5121
                    String clientIp = "127.0.0.1";
                    requestCheckAddinRules.setClientIp(clientIp);//add by fanggsh 20061016 fot TD5121
                    requestCheckAddinRules.setSrc("submit");//add by fanggsh 20061016 fot TD5121
                    requestCheckAddinRules.setRequestManager(rm);
                    requestCheckAddinRules.checkAddinRules();
                    
//                    requestCheckAddinRulesMap=new HashMap();
//                    requestCheckAddinRulesMap.put("objId",""+linkid);
//                    requestCheckAddinRulesMap.put("objType","0");// 1: 节点自动赋值 0 :出口自动赋值




//                    requestCheckAddinRulesMap.put("isPreAdd","0");          
//                    requestCheckAddinRulesList.add(requestCheckAddinRulesMap);
                } catch (Exception erca) {
                    writeLog(erca);
                    log.error("出口赋值处理错误:"+erca.getMessage());
                }
                
                //节点自动赋值处理




                try {
                    //由于objtype为"1: 节点自动赋值",不为"0 :出口自动赋值"，不用改变除状态外的文档相关信息，故可不用给user、clienIp、src赋值   fanggsh TD5121
                    RequestCheckAddinRules requestCheckAddinRules = new RequestCheckAddinRules();
                    requestCheckAddinRules.resetParameter();
                   //add by cyril on 2008-07-28 for td:8835 事务无法开启查询,只能传入
//                   requestCheckAddinRules.setTrack(isTrack);
//                   requestCheckAddinRules.setStart(isStart);
                   requestCheckAddinRules.setNodeid(nodeid);
                   //end by cyril on 2008-07-28 for td:8835
                    requestCheckAddinRules.setRequestid(requestid);
                    requestCheckAddinRules.setWorkflowid(workflowid);
                    requestCheckAddinRules.setObjid(nextnodeid);
                    requestCheckAddinRules.setObjtype(1);
                    requestCheckAddinRules.setIsbill(isbill);
                    requestCheckAddinRules.setFormid(formid);
                    requestCheckAddinRules.setIspreadd("1");
                    requestCheckAddinRules.setRequestManager(rm);
                    requestCheckAddinRules.setUser(user);                                   
                    requestCheckAddinRules.checkAddinRules();
                    
//                    requestCheckAddinRulesMap=new HashMap();
//                    requestCheckAddinRulesMap.put("objId",""+nextnodeid);
//                    requestCheckAddinRulesMap.put("objType","1");// 1: 节点自动赋值 0 :出口自动赋值




//                    requestCheckAddinRulesMap.put("isPreAdd","1");         
//                    requestCheckAddinRulesList.add(requestCheckAddinRulesMap);
                } catch (Exception erca) {
                    writeLog(erca);
                    log.error("节点赋值处理错误:"+erca.getMessage());                
                }
             }
             

             try {
                 //查询流程生成计划任务（总体）设置，取得到达nextnodeids时和离开nodeid时生成计划任务的情况，生成计划任务




                 int isusedworktask = Util.getIntValue(getPropValue("worktask","isusedworktask"), 0);
                 if(isusedworktask == 1){
                        sql = "select * from workflow_createtask where wfid=" + workflowid + " and ((nodeid=" + nodeid + " and changetime=2) or (changetime=1 and nodeid in ("+wf_nextnodeids+"0)))";
                        rs.execute(sql);
                        while(rs.next()){
                            int creatertype_tmp = Util.getIntValue(rs.getString("creatertype"), 0);
                            if(creatertype_tmp == 0){
                                continue;
                            }
                            int createtaskid_tmp = Util.getIntValue(rs.getString("id"), 0);
                            int wffieldid_tmp = Util.getIntValue(rs.getString("wffieldid"), 0);
                            int taskid_tmp = Util.getIntValue(rs.getString("taskid"), 0);
                            int changemode_tmp = Util.getIntValue(rs.getString("changemode"), 0);
                            int changenodeid_tmp = Util.getIntValue(rs.getString("nodeid"), 0);
                            int changetime_tmp = Util.getIntValue(rs.getString("changetime"), 0);
                            if(changenodeid_tmp!=nodeid && (","+wf_nextnodeids+",").indexOf(","+changenodeid_tmp+",")>-1){//首先保证触发节点是操作后到达的节点，并且触发节点在到达的节点之中
                                if(changetime_tmp==1 && changemode_tmp==2){
                                    continue;
                                }
                            }
                            if(changenodeid_tmp==nodeid){//如果是离开节点
                                if(changetime_tmp==2 && changemode_tmp==2){
                                    continue;
                                }
                            }
                            RequestCreateByWF requestCreateByWF = new RequestCreateByWF();
                            requestCreateByWF.setWf_formid(formid);
                            requestCreateByWF.setWf_isbill(isbill);
                            requestCreateByWF.setWf_wfid(workflowid);
                            requestCreateByWF.setWf_requestid(requestid);
                            requestCreateByWF.setWt_creatertype(creatertype_tmp);
                            requestCreateByWF.setWt_creater(creater);
                            requestCreateByWF.setWf_fieldid(wffieldid_tmp);
                            requestCreateByWF.setWt_wtid(taskid_tmp);
                            requestCreateByWF.setCreatetaskid(createtaskid_tmp);
                            requestCreateByWF.createWT();
                     }
                 }
             } catch (Exception e) {
                e.printStackTrace();
            }
             
            //更新currentoperator
            for(int i=0;i<userlist.size();i++){
            rs3.executeSql("select distinct groupid from workflow_currentoperator where isremark = '0' and requestid=" + requestid + " and userid=" + userlist.get(i) + " and usertype=" + usertypelist.get(i)+" and nodeid="+nodeid);
            while (rs3.next()) {
                int tmpgroupid = Util.getIntValue(rs3.getString(1), 0);
                rs4.executeProc("workflow_CurOpe_UpdatebySubmit", "" +userlist.get(i) +Util.getSeparator() + requestid + Util.getSeparator() + tmpgroupid+Util.getSeparator()+nodeid+Util.getSeparator()+"0" + Util.getSeparator() + currentdate + Util.getSeparator() + currenttime);
            }
            }
            innodeids="";
            if (canflowtonextnode && (nextnodeattr == 3 || nextnodeattr == 4)) {
                innodeids = wflinkinfo.getSummaryNodes(nextnodeid, workflowid, "",requestid);
                if (innodeids.equals("")) innodeids = "0";
                rs4.executeSql("update workflow_currentoperator set isremark='2' where isremark='0' and requestid=" + requestid + " and nodeid in(" + innodeids + ")");
                rs4.executeSql("update workflow_currentoperator set isremark='2' where isremark = '5' and requestid=" + requestid + " and nodeid in(" + innodeids + ")");
            }
            //更新requestbase
            sql = " update workflow_requestbase set " +
                            " lastnodeid = " + nodeid +
                            " ,lastnodetype = '" + nodetype ;
           if (canflowtonextnode) {
                if (nextnodeattr == 1) {
                    sql += "' ,currentnodeid = " + nextnodeid +
                            " ,currentnodetype = '" + nextnodetype;
                    status = SystemEnv.getHtmlLabelName(21394, user.getLanguage());
                } else if (nextnodeattr == 2) {
                    sql += "' ,currentnodeid = " + nextnodeid +
                            " ,currentnodetype = '" + nextnodetype;
                    status = SystemEnv.getHtmlLabelName(21395, user.getLanguage());
                } else {
                    sql += "' ,currentnodeid = " + nextnodeid +
                            " ,currentnodetype = '" + nextnodetype;
                }
            } else {
                status = SystemEnv.getHtmlLabelName(21395, user.getLanguage());
            }
            sql += "' ,status = '" + status + "' " +
                            " ,passedgroups = 0" +
                            " ,totalgroups = " + totalgroups +
                            " ,lastoperator = " + userlist.get(userlist.size()-1) +
                            " ,lastoperatedate = '" + currentdate + "' " +
                            " ,lastoperatetime = '" + currenttime + "' " +
                            " ,lastoperatortype = " + usertypelist.get(usertypelist.size()-1) +
                            " where requestid = " + requestid;
            rs3.executeSql(sql);
            //操作人插入操作




            if(canflowtonextnode) setOperator(requestid,workflowid,workflowtype,nodeid);
			String temp_logtype = "2";
			if(nodetype.equals("1")){
			   temp_logtype = "0";
			}
            for(int n=0;n<nextnodeids.size();n++){
                nextnodeid=Util.getIntValue((String)nextnodeids.get(n));
                nextnodeattr = Util.getIntValue((String) nextnodeattrs.get(n), 0);
                for(int i=0;i<userlist.size();i++){
                    //处理新到达流程提醒




                    poppupRemindInfoUtil.updatePoppupRemindInfo(Util.getIntValue((String)userlist.get(i)),0,(String)usertypelist.get(i),requestid);
                    writeWFLog(requestid,workflowid,nodeid,Util.getIntValue((String)userlist.get(i)),Util.getIntValue((String)usertypelist.get(i)),Util.getIntValue((String)agenttypelist.get(i)),Util.getIntValue((String)agentorbyagentidlist.get(i)),nextnodeid,currentdate,currenttime,ProcessorOpinion,temp_logtype,canflowtonextnode,nextnodeattr);
                }
            }
			//add by liaodong for qc in 2013年11月6日 start //插入抄送日志




               if(operator89List.size()>0){
            	  writeWFLog(requestid,workflowid,nodeid,0,0,nextnodeid,currentdate,currenttime,ProcessorOpinion,"t",canflowtonextnode,nextnodeattr);
               }
        	//end
            //处理超时流程提醒
            for(int i=0;i<wfremindusers.size();i++){
                poppupRemindInfoUtil.updatePoppupRemindInfo(Util.getIntValue((String)wfremindusers.get(i)),10,(String)wfusertypes.get(i),requestid);
            }
            if (canflowtonextnode&&nextnodetype.equals("3")) {
                    String Procpara = "" + creater + Util.getSeparator() + creatertype + Util.getSeparator() + requestid;

                    if(!operatorsWfEnd.contains(creater+"_"+creatertype)){//xwj for td3450 20060111
                    	poppupRemindInfoUtil.addPoppupRemindInfo(creater,1,""+creatertype,requestid,requestcominfo.getRequestname(requestid+""));
                    }
                    //modify by xhheng @20050520 for TD1725,添加条件 isremark='0' 使能区分历史操作人和归档人




                    // 2005-03-24 Guosheng for TD1725**************************************
                    rs3.executeSql("update  workflow_currentoperator  set isremark='4'  where isremark='0' and requestid = " +  requestid);
                    rs3.executeSql("update  workflow_currentoperator  set iscomplete=1  where requestid = " +  requestid );
            }
            //将已查看操作人的查看状态置为（-1：新提交未查看）
               //TD4294  删除workflow_currentoperator表中orderdate、ordertime列 fanggsh begin
            //rs.executeSql("update workflow_currentoperator set viewtype =-1,orderdate='" + currentdate + "' ,ordertime='" + currenttime + "'  where requestid=" + requestid + " and userid<>" + userid + " and viewtype=-2");
            //rs.executeSql("update workflow_currentoperator set viewtype =-1   where requestid=" + requestid + " and userid<>" + userid + " and viewtype=-2");
               //TD4294  删除workflow_currentoperator表中orderdate、ordertime列 fanggsh end

            //将自己的查看状态置为（-2：已提交已查看）
            //by ben 2006-03-27加上nodeid的条件限制后一个节点有相同于当前操作人时只设置当前的节点




            //rs.executeSql("update workflow_currentoperator set viewtype =-2 where requestid=" + requestid + "  and userid=" + userid + " and usertype = "+usertype+" and viewtype<>-2");
            System.out.println("进入："+requestid+" nextnodeids.size:"+nextnodeids.size());
                //add by xhheng @20050125 for 消息提醒 request06 ,短信发送




            for(int i=0;i<nextnodeids.size();i++){
                nextnodeid=Util.getIntValue((String)nextnodeids.get(i));
                
				RecordSetTrans rst = new RecordSetTrans();
                try {
                	rst.setAutoCommit(false);
                    String src = "submit";
                    SendMsgAndMail sendMsgAndMail = new SendMsgAndMail();
                    
                    rs3.executeSql("select operator from workflow_requestLog where logtype in ('0','1','2','9') and nodeid="+nodeid+" and requestid="+requestid+" order by LOGID desc");
                    rs3.next();
                    int tmpuserid = Util.getIntValue(rs3.getString(1),1);
                    //User tmpuser = getUser(tmpuserid);
                    //发送短信


                    weaver.system.msg.SendMsg sendMsgtm=new weaver.system.msg.SendMsg();
                    sendMsgtm.sendMsg(rst,requestid,nextnodeid,user,src,nextnodetype);

                    // 邮件提醒
        		    sendMsgAndMail.sendMail(rst,workflowid,requestid,nextnodeid,null,null,false,src,nextnodetype,user);
        		    rst.commit();
        		    
        		    System.out.println("发送短信====================="+requestid);
    			} catch (Exception e) {
					rst.rollback();
    				System.out.println("发送短信====================="+e.getMessage());
    				writeLog("超时短信提醒："+e);
    			}
    			
	            // 处理共享信息
				try {
	                RequestAddShareInfo shareinfo = new RequestAddShareInfo();
					shareinfo.setRequestid(requestid);
	                shareinfo.SetWorkFlowID(workflowid);
	                shareinfo.SetNowNodeID(nodeid);
	                if(nextnodeid==0)
	                	shareinfo.SetNextNodeID(nodeid);
	                else
	                	shareinfo.SetNextNodeID(nextnodeid);
	                shareinfo.setIsbill(isbill);
					shareinfo.setUser(user);
	                shareinfo.SetIsWorkFlow(1);
	                shareinfo.setBillTableName(billtablename);
	                shareinfo.setHaspassnode(true);
	
					shareinfo.addShareInfo();
				}catch(Exception easi) {
				}
            }
            
            
            String hasTriggeredSubwf = "";//已触发子流程，防止死循环
            //触发子流程




            ArrayList nodeidList_sub = new ArrayList();
            ArrayList triggerTimeList_sub = new ArrayList();
            ArrayList hasTriggeredSubwfList_sub = new ArrayList();     
            
            //触发日程
            ArrayList nodeidList_wp = new ArrayList();
            ArrayList createTimeList_wp = new ArrayList();
            
            //triggerStatus  ""  成功
            //               "1" 子流程创建人无值




            String triggerStatus="";
            boolean nextNodeHasCurrentNode=false;
            for(int n=0;n<nextnodeids.size();n++){
                nextnodeid=Util.getIntValue((String)nextnodeids.get(n));
                if(nextnodeid==nodeid){
                    nextNodeHasCurrentNode=true;
                }
            }
            if(nextNodeHasCurrentNode==false && nextnodeid>0 && nextnodeid!=nodeid){
                nodeidList_sub.add(""+nodeid);
                triggerTimeList_sub.add("2");
                hasTriggeredSubwfList_sub.add(hasTriggeredSubwf);
                //triggerStatus=subwfTriggerManager.TriggerSubwf(this,nodeid,"2",hasTriggeredSubwf,user);
            }
            
            if(nextnodeids!=null && nextnodeids.size()>0 && !nextnodeids.contains(""+nodeid)){
                nodeidList_wp.add(""+nodeid);
                createTimeList_wp.add("2");//离开节点
            }
            
            for(int n=0;n<nextnodeids.size();n++){
                nextnodeid=Util.getIntValue((String)nextnodeids.get(n));
                if(nextnodeid>0&&nextnodeid!=nodeid){
                    nodeidList_sub.add(""+nextnodeid);
                    triggerTimeList_sub.add("1");
                    hasTriggeredSubwfList_sub.add(hasTriggeredSubwf);
                    //triggerStatus=subwfTriggerManager.TriggerSubwf(this,nextnodeid,"1",hasTriggeredSubwf,user);

                    //TD13304 在这里记录需要触发日程的节点和触发类型（到达节点或离开节点），到流程事务外处理
                    nodeidList_wp.add(""+nextnodeid);
                    createTimeList_wp.add("1");//到达节点
                }
            }
            
            /**
             * 触发子流程 为了防止死锁，移到事物结束后处理。子流程触发失败，不影响主流程流转




             * chujun
             * Start
             */
            try{
                if (nodeidList_sub.size() > 0) {
                    RequestManager rm = new RequestManager();
                    rm.setUser(user);
                    rm.setWorkflowid(workflowid);
                    rm.setRequestid(requestid);
                    rm.setSrc("submit");
                    rm.setIscreate("0");
                    rm.setRequestid(requestid);
                    rm.setWorkflowid(workflowid);
                    rm.setIsremark(0);
                    rm.setFormid(formid);
                    rm.setIsbill(isbill);
                    rm.setBillid(billid);
                    rm.setNodeid(nodeid);
                    rm.setNodetype(nodetype);
                    rs.executeSql("select * from workflow_requestbase where requestid=" + requestid);
                    if (rs.next()) {
                        rm.setRequestname(rs.getString("requestname"));
                        rm.setRequestlevel(rs.getString("requestlevel"));
                        rm.setMessageType(rs.getString("messageType"));
                        rm.setCreater(Util.getIntValue(rs.getString("creater")));
                        rm.setCreatertype(Util.getIntValue(rs.getString("creatertype")));
                        //是否允许退回时选择节点
                    }
                    
                    for(int i=0; i<nodeidList_sub.size(); i++){
                        int nodeid_tmp = Util.getIntValue((String)nodeidList_sub.get(i), 0);
                        String triggerTime_tmp = Util.null2String((String)triggerTimeList_sub.get(i));
                        String hasTriggeredSubwf_tmp = Util.null2String((String)hasTriggeredSubwfList_sub.get(i));
                        SubWorkflowTriggerService triggerService = new SubWorkflowTriggerService(rm, nodeid_tmp, hasTriggeredSubwf, user);
                        triggerService.triggerSubWorkflow("1", triggerTime_tmp);
                    }
                }
            }catch(Exception e){
                e.printStackTrace();
            }
            
            /**
             * 流程触发日程 TD13304
             */
            try{
                String clientip = "127.0.0.1";
                String sqlExt = "";
                for(int i=0; i<nodeidList_wp.size(); i++){
                    String nodeid_tmp = Util.null2String((String)nodeidList_wp.get(i));
                    String createTime_tmp = Util.null2String((String)createTimeList_wp.get(i));
                    sqlExt += " (nodeid="+nodeid_tmp+" and changetime="+createTime_tmp+") or";
                }
                if(!"".equals(sqlExt)){
                    CreateWorkplanByWorkflow createWorkplanByWorkflow = null;
                    sqlExt = sqlExt.substring(0, sqlExt.length()-2);
                    RecordSet rs_wp = new RecordSet();
                    rs_wp.execute("select * from workflow_createplan where wfid="+ workflowid +" and ("+sqlExt+") order by id");
                    while(rs_wp.next()){
                        int createplanid = Util.getIntValue(rs_wp.getString("id"), 0);
                        int plantypeid_tmp = Util.getIntValue(rs_wp.getString("plantypeid"), 0);
                        int creatertype_tmp = Util.getIntValue(rs_wp.getString("creatertype"), 0);
                        int wffieldid_tmp = Util.getIntValue(rs_wp.getString("wffieldid"), 0);
                        createWorkplanByWorkflow = new CreateWorkplanByWorkflow();
                        createWorkplanByWorkflow.setCreateplanid(createplanid);
                        createWorkplanByWorkflow.setWorkplantypeid(plantypeid_tmp);
                        createWorkplanByWorkflow.setWp_creatertype(creatertype_tmp);
                        createWorkplanByWorkflow.setWf_fieldid(wffieldid_tmp);
                        createWorkplanByWorkflow.setWf_formid(formid);
                        createWorkplanByWorkflow.setWf_isbill(isbill);
                        createWorkplanByWorkflow.setWf_requestid(requestid);
                        createWorkplanByWorkflow.setWf_wfid(workflowid);
                        createWorkplanByWorkflow.setUser(user);
                        createWorkplanByWorkflow.setRemoteAddr(clientip);
                        createWorkplanByWorkflow.createWorkplan();
                    }
                }
            }catch(Exception e){
                e.printStackTrace();
            }
            
            //流程归档，删除Workflow_DocSource数据
			if (canflowtonextnode&&nextnodetype.equals("3")) {
				rs3.execute("select docRightByOperator from workflow_base where id="+workflowid);
				if(rs3.next()){
					if(Util.getIntValue(rs3.getString("docRightByOperator"),0)==1){
						rs3.execute("delete from Workflow_DocSource where requestid =" + requestid );
					}
				}
			}
			
			//如果节点后附加操作为流程存为文档，那么等所有操作执行之后，来执行存为文档操作 
            if(isWorkFlowToDoc && nodeid != nextnodeid) {
                 Action action= (Action)StaticObj.getServiceByFullname("action.WorkflowToDoc", Action.class);
                 RequestService requestService=new  RequestService();
                 //String msg=action.execute(requestService.getRequest(requestid));
                 String msg=action.execute(requestService.getRequest(requestid, 999));                        
            }
        }else {
        	//还原Manager
            this.rollbackUpdatedManagerField(requestid, formid, isbill, mgrID);
		}
	}

    /**
     * 插入下一操作人




     * @param requestid
     * @param workflowid
     * @param workflowtype
     * @param nodeid
     */
    public void setOperator(int requestid,int workflowid,int workflowtype,int nodeid)
     {
    	wfAgentCondition wfAgentCondition=new wfAgentCondition();
		 operator89List = new ArrayList();//add by liaodong for qc80034 in 2013-11-07  start
         Calendar today = Calendar.getInstance();
        String currentdate = Util.add0(today.get(Calendar.YEAR), 4) + "-" +
                Util.add0(today.get(Calendar.MONTH) + 1, 2) + "-" +
                Util.add0(today.get(Calendar.DAY_OF_MONTH), 2);

        String currenttime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
                Util.add0(today.get(Calendar.MINUTE), 2) + ":" +
                Util.add0(today.get(Calendar.SECOND), 2);
         //获得数据库服务器当前时间
        String sql="";
        if(rs5.getDBType().equals("oracle")){
            sql="select to_char(sysdate,'yyyy-mm-dd') currentdate,to_char(sysdate,'hh24:mi:ss') currenttime from dual";
        }else{
            sql="select convert(char(10),getdate(),20) currentdate,convert(char(8),getdate(),108) currenttime";
        }
        rs5.executeSql(sql);
        if(rs5.next()){
           currentdate=rs5.getString("currentdate");
           currenttime=rs5.getString("currenttime");
        }
        for(int n=0;n<nextnodeids.size();n++){
            int nextnodeid=Util.getIntValue((String)nextnodeids.get(n),0);
            Hashtable operatorsht=(Hashtable)operatorshts.get(n);
            String nextnodetype=Util.null2String((String)nextnodetypes.get(n));
            int nextnodeattr=Util.getIntValue((String)nextnodeattrs.get(n),0);
            ArrayList operatorsWfNew = new ArrayList();
           char flag=Util.getSeparator();
         //操作人更新结束




            int showorder = 0;
            /*---------added by xwj for td2850 begin----*/
            TreeMap map = new TreeMap(new ComparatorUtilBean());
            Enumeration tempKeys = operatorsht.keys();
            while (tempKeys.hasMoreElements()) {
                String tempKey = (String) tempKeys.nextElement();
                ArrayList tempoperators = (ArrayList) operatorsht.get(tempKey);
                map.put(tempKey,tempoperators);
            }
            Iterator iterator = map.keySet().iterator();
            while(iterator.hasNext()) {
                String operatorgroup = (String) iterator.next();
                ArrayList operators = (ArrayList) operatorsht.get(operatorgroup);
            /*---------added by xwj for td2850 end----*/

            /* ------------ xwj for td2104 on 20050802 end------------------*/
                for (int i = 0; i < operators.size(); i++) {
                    showorder++; //xwj for td2104 on 20050802
                    String operatorandtype = (String) operators.get(i);
                    String[] operatorandtypes = Util.TokenizerString2(operatorandtype, "_");
                    String opertor = operatorandtypes[0];
                    //System.out.println(opertor);
                    String opertortype = operatorandtypes[1];
                    int groupdetailid = Util.getIntValue(operatorandtypes[2],-1);
					 //add by liaodong for qc in 2013-11-06 start
                    int typeid= Util.getIntValue(operatorandtypes[3],0);
                    //end
                    //modify by xhheng @20050109 for 流程代理
                    //代理数据检索




                    boolean isbeAgent=false;
                    String agenterId="";


                 /*-----------   xwj td2551  20050808  begin -----------*/
                 String agentCheckSql = " select * from workflow_agentConditionSet where workflowId="+ workflowid +" and bagentuid=" + opertor +
                 " and agenttype = '1'  and isproxydeal='1' " +
                 " and ( ( (endDate = '" + currentdate + "' and (endTime='' or endTime is null))" +
                 " or (endDate = '" + currentdate + "' and endTime > '" + currenttime + "' ) ) " +
                 " or endDate > '" + currentdate + "' or endDate = '' or endDate is null)" +
                 " and ( ( (beginDate = '" + currentdate + "' and (beginTime='' or beginTime is null))" +
                 " or (beginDate = '" + currentdate + "' and beginTime < '" + currenttime + "' ) ) " +
                 " or beginDate < '" + currentdate + "' or beginDate = '' or beginDate is null) order by agentbatch asc  ,id asc ";
                 rs3.execute(agentCheckSql);
                 while(rs3.next()){
                	 String agentid = rs3.getString("agentid");
						String conditionkeyid = rs3.getString("conditionkeyid");
						boolean isagentcond = wfAgentCondition.isagentcondite(""+ requestid, "" + workflowid, "" + opertor,"" + agentid, "" + conditionkeyid);
						 if(isagentcond){
							 isbeAgent=true;
							 agenterId=rs3.getString("agentuid");
							 break;
						 }
                }
                    /* -----------   xwj td2551  20050808  end -----------*/


                    //当符合代理条件时添加代理人




                    String Procpara1="";
					 //add by liaodong for qc80034 in 2013-11-07  start
                    int tempremark=0;
					if (typeid==-3){//抄送（不需提交）




						tempremark=8;
					}
					if (typeid==-4){//抄送（需提交）




						tempremark=9;
					}
                 //end

                    /*-------- xwj for td2104 on 20050802  begin --------- */
                    if(isOldOrNewFlag(requestid)){//老数据, 相对 td2104 之前
                        if(isbeAgent){
							       //add by liaodong for qc80034 in 2013-11-06 start
                                   if(tempremark==8 || tempremark==9){ //抄送的时候




									    //设置被代理人已操作




                                         String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + tempremark + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1+ flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara);
                                                //设置代理人




                                                Procpara1 = "" + requestid + flag + agenterId + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + tempremark + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1 + flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara1);
												operator89List.add(""+opertor); 
								   }else{

									   //设置被代理人已操作




                                         String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + "2" + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1+ flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara);
                                                //设置代理人




                                                Procpara1 = "" + requestid + flag + agenterId + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + "0" + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1 + flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara1);
								       
								   
								   }
                                                
                               }else{
								      //add by liaodong for qc80034 in 2013-11-06 start
                                   if(tempremark==8 || tempremark==9){ //抄送的时候




									                String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + tempremark + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1 + flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara);
												operator89List.add(""+opertor);
								   }else{
								                   String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + "0" + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1 + flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara);
								   }
                                    
                               }
                    }
                    else{
                                           if(isbeAgent){
											       //add by liaodong for qc80034 in 2013-11-06 start
                                                  if(tempremark==8 || tempremark==9){ //抄送的时候




													     //设置被代理人已操作




														String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
														+ workflowid + flag + workflowtype + flag + opertortype + flag + tempremark + flag + nextnodeid +
														flag + agenterId + flag + "1" + flag + showorder+ flag +groupdetailid;
														rs3.executeProc("workflow_CurrentOperator_I", Procpara);
														//设置代理人




														Procpara1 = "" + requestid + flag + agenterId + flag + operatorgroup + flag
														+ workflowid + flag + workflowtype + flag + opertortype + flag + tempremark + flag + nextnodeid +
														flag + opertor + flag + "2" + flag + showorder+ flag +groupdetailid;
														rs3.executeProc("workflow_CurrentOperator_I", Procpara1);
														operator89List.add(""+opertor);
								                  }else{
													    //设置被代理人已操作




                                                    String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                    + workflowid + flag + workflowtype + flag + opertortype + flag + "2" + flag + nextnodeid +
                                                    flag + agenterId + flag + "1" + flag + showorder+ flag +groupdetailid;
                                                    rs3.executeProc("workflow_CurrentOperator_I", Procpara);
                                                    //设置代理人




                                                    Procpara1 = "" + requestid + flag + agenterId + flag + operatorgroup + flag
                                                    + workflowid + flag + workflowtype + flag + opertortype + flag + "0" + flag + nextnodeid +
                                                    flag + opertor + flag + "2" + flag + showorder+ flag +groupdetailid;
                                                    rs3.executeProc("workflow_CurrentOperator_I", Procpara1);
								                  }
                                                   
                                                }else{
													   //add by liaodong for qc80034 in 2013-11-06 start
                                                  if(tempremark==8 || tempremark==9){ //抄送的时候




													    String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                    + workflowid + flag + workflowtype + flag + opertortype + flag + tempremark + flag + nextnodeid +
                                                    flag + -1 + flag + "0" + flag + showorder+ flag +groupdetailid;
                                                    //System.out.println(Procpara);
                                                    rs3.executeProc("workflow_CurrentOperator_I", Procpara);
													operator89List.add(""+opertor);
												  }else{
												       String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                    + workflowid + flag + workflowtype + flag + opertortype + flag + "0" + flag + nextnodeid +
                                                    flag + -1 + flag + "0" + flag + showorder+ flag +groupdetailid;
                                                    //System.out.println(Procpara);
                                                    rs3.executeProc("workflow_CurrentOperator_I", Procpara);
												  }
                                                   
                                                }

                    }



                    //对代理人判断提醒

                    /*--xwj for td3450 20060111 begin--*/
                    String Procpara = opertor + flag + opertortype + flag + requestid;

                    if (nextnodetype.equals("3")){


                        if(isbeAgent){
                            if(!operatorsWfEnd.contains(agenterId+"_"+opertortype)){
                                poppupRemindInfoUtil.addPoppupRemindInfo(Integer.parseInt(agenterId),1,opertortype,requestid,requestcominfo.getRequestname(requestid+""));
                                operatorsWfEnd.add(agenterId+"_"+opertortype);
                            }
                        }else{
                            if(!operatorsWfEnd.contains(opertor+"_"+opertortype)){
                                poppupRemindInfoUtil.addPoppupRemindInfo(Integer.parseInt(opertor),1,opertortype,requestid,requestcominfo.getRequestname(requestid+""));
                                operatorsWfEnd.add(opertor+"_"+opertortype);
                          }
                        }
                    }
                    else{
                       if(isbeAgent){
                            if(!operatorsWfNew.contains(agenterId+"_"+opertortype)){
                            poppupRemindInfoUtil.addPoppupRemindInfo(Integer.parseInt(agenterId),0,opertortype,requestid,requestcominfo.getRequestname(requestid+""));
                            operatorsWfNew.add(agenterId+"_"+opertortype);
                            }

                        }else{

                            if(!operatorsWfNew.contains(opertor+"_"+opertortype)){
                            poppupRemindInfoUtil.addPoppupRemindInfo(Integer.parseInt(opertor),0,opertortype,requestid,requestcominfo.getRequestname(requestid+""));
                            operatorsWfNew.add(opertor+"_"+opertortype);
                            }
                        }
                    }
                }
            }
            //操作人更新结束




            //更新当前节点表




            if(innodeids.equals("")||innodeids.equals("0")) innodeids=nodeid+"";
            rs3.executeSql("delete from workflow_nownode where nownodeid in("+innodeids+") and requestid="+requestid);
            rs3.executeSql("insert into workflow_nownode(requestid,nownodeid,nownodetype,nownodeattribute) values("+requestid+","+nextnodeid+","+nextnodetype+","+nextnodeattr+")");
        }
     }

    /**
     * 插入指定对象操作人




     * @param opertorlist
     * @param requestid
     * @param workflowid
     * @param workflowtype
     * @param nextnodeid
     */
    public void setOperator(ArrayList opertorlist,int requestid,int workflowid,int workflowtype,int nextnodeid)
     {
    	 wfAgentCondition wfAgentCondition=new wfAgentCondition();
         Calendar today = Calendar.getInstance();
        String currentdate = Util.add0(today.get(Calendar.YEAR), 4) + "-" +
                Util.add0(today.get(Calendar.MONTH) + 1, 2) + "-" +
                Util.add0(today.get(Calendar.DAY_OF_MONTH), 2);

        String currenttime = Util.add0(today.get(Calendar.HOUR_OF_DAY), 2) + ":" +
                Util.add0(today.get(Calendar.MINUTE), 2) + ":" +
                Util.add0(today.get(Calendar.SECOND), 2);
         //获得数据库服务器当前时间
        String sql="";
        if(rs5.getDBType().equals("oracle")){
            sql="select to_char(sysdate,'yyyy-mm-dd') currentdate,to_char(sysdate,'hh24:mi:ss') currenttime from dual";
        }else{
            sql="select convert(char(10),getdate(),20) currentdate,convert(char(8),getdate(),108) currenttime";
        }
        rs5.executeSql(sql);
        if(rs5.next()){
           currentdate=rs5.getString("currentdate");
           currenttime=rs5.getString("currenttime");
        }
         ArrayList operatorsWfNew = new ArrayList();
         char flag=Util.getSeparator();
         int showorder = 0;
         String operatorgroup = "0";
         for(int i=0;i<opertorlist.size();i++){
             showorder++;
             String opertor = (String)opertorlist.get(i);
             String opertortype = "0";
             int groupdetailid = -1;
             //modify by xhheng @20050109 for 流程代理
             //代理数据检索




             boolean isbeAgent=false;
             String agenterId="";


                 /*-----------   xwj td2551  20050808  begin -----------*/
                 String agentCheckSql = " select * from workflow_agentConditionSet where workflowId="+ workflowid +" and bagentuid=" + opertor +
                 " and agenttype = '1' and isproxydeal='1'  " +
                 " and ( ( (endDate = '" + currentdate + "' and (endTime='' or endTime is null))" +
                 " or (endDate = '" + currentdate + "' and endTime > '" + currenttime + "' ) ) " +
                 " or endDate > '" + currentdate + "' or endDate = '' or endDate is null)" +
                 " and ( ( (beginDate = '" + currentdate + "' and (beginTime='' or beginTime is null))" +
                 " or (beginDate = '" + currentdate + "' and beginTime < '" + currenttime + "' ) ) " +
                 " or beginDate < '" + currentdate + "' or beginDate = '' or beginDate is null) order by agentbatch asc  ,id asc ";

                 rs3.execute(agentCheckSql);
                 while(rs3.next()){
                 	String agentid = rs3.getString("agentid");
						String conditionkeyid = rs3.getString("conditionkeyid");
						//妫€鏌ュ綋鍓嶆祦绋嬩笅鐨勪唬鐞嗘槸鍚︽敮鎸佹壒娆℃潯浠躲€愬紑鍚祦绋嬩腑鐨勪唬鐞嗐€佸凡缁忔槸娴佽浆涓殑銆佹壒娆℃潯浠舵弧瓒炽€?
						boolean isagentcond = wfAgentCondition.isagentcondite(""+ requestid, "" + workflowid, "" + opertor,"" + agentid, "" + conditionkeyid);
						 if(isagentcond){
							 isbeAgent=true;
							 agenterId=rs3.getString("agentuid");
							 break;
						 }
                     
             }
                    /* -----------   xwj td2551  20050808  end -----------*/


                    //当符合代理条件时添加代理人




                    String Procpara1="";

                    /*-------- xwj for td2104 on 20050802  begin --------- */
                    if(isOldOrNewFlag(requestid)){//老数据, 相对 td2104 之前
                        if(isbeAgent){
                                                //设置被代理人已操作




                                                String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + "2" + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1+ flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara);
                                                //设置代理人 isremark=5为干扰流转




                                                Procpara1 = "" + requestid + flag + agenterId + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + "5" + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1 + flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara1);
                                            }else{
                                                String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                + workflowid + flag + workflowtype + flag + opertortype + flag + "5" + flag + -1 +
                                                flag + -1 + flag + "0" + flag + -1 + flag +groupdetailid;
                                                rs3.executeProc("workflow_CurrentOperator_I", Procpara);
                                            }
                    }
                    else{
                                                if(isbeAgent){
                                                    //设置被代理人已操作




                                                    String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                    + workflowid + flag + workflowtype + flag + opertortype + flag + "2" + flag + nextnodeid +
                                                    flag + agenterId + flag + "1" + flag + showorder+ flag +groupdetailid;
                                                    rs3.executeProc("workflow_CurrentOperator_I", Procpara);
                                                    //设置代理人




                                                    Procpara1 = "" + requestid + flag + agenterId + flag + operatorgroup + flag
                                                    + workflowid + flag + workflowtype + flag + opertortype + flag + "5" + flag + nextnodeid +
                                                    flag + opertor + flag + "2" + flag + showorder+ flag +groupdetailid;
                                                    rs3.executeProc("workflow_CurrentOperator_I", Procpara1);
                                                }else{
                                                    String Procpara = "" + requestid + flag + opertor + flag + operatorgroup + flag
                                                    + workflowid + flag + workflowtype + flag + opertortype + flag + "5" + flag + nextnodeid +
                                                    flag + -1 + flag + "0" + flag + showorder+ flag +groupdetailid;
                                                    //System.out.println(Procpara);
                                                    rs3.executeProc("workflow_CurrentOperator_I", Procpara);
                                                }

                    }

                    /*-------- xwj for td2104 on 20050802  end ---------*/

                    //将已查看操作人的查看状态置为（-1：新提交未查看）
                    //TD4294  删除workflow_currentoperator表中orderdate、ordertime列 fanggsh begin
                    //rs3.executeSql("update workflow_currentoperator set viewtype =-1,orderdate='" + currentdate + "' ,ordertime='" + currenttime + "'  where requestid=" + requestid + " and userid<>" + opertor + " and viewtype=-2");
                    //rs3.executeSql("update workflow_currentoperator set viewtype =-1   where requestid=" + requestid + " and userid=" + opertor + " and viewtype=-2");
                    //TD4294  删除workflow_currentoperator表中orderdate、ordertime列 fanggsh end

                    //将自己的查看状态置为（-2：已提交已查看）
                    //by ben 2006-03-27加上nodeid的条件限制后一个节点有相同于当前操作人时只设置当前的节点




                    //rs3.executeSql("update workflow_currentoperator set viewtype =-2 where requestid=" + requestid + "  and userid=" + opertor + " and usertype = "+opertortype+" and viewtype<>-2");
                    /*-------- xwj for td2104 on 20050802  end ---------*/

                    //对代理人判断提醒

                    /*--xwj for td3450 20060111 begin--*/
                    String Procpara = opertor + flag + opertortype + flag + requestid;

                       if(isbeAgent){
                            if(!operatorsWfNew.contains(agenterId+"_"+opertortype)){
                            poppupRemindInfoUtil.addPoppupRemindInfo(Integer.parseInt(agenterId),0,opertortype,requestid,requestcominfo.getRequestname(requestid+""));
                            operatorsWfNew.add(agenterId+"_"+opertortype);
                            }

                        }else{

                            if(!operatorsWfNew.contains(opertor+"_"+opertortype)){
                            poppupRemindInfoUtil.addPoppupRemindInfo(Integer.parseInt(opertor),0,opertortype,requestid,requestcominfo.getRequestname(requestid+""));
                            operatorsWfNew.add(opertor+"_"+opertortype);
                            }
                        }
                }
            //操作人更新结束




			
			RecordSetTrans rst = new RecordSetTrans();
			try {
				String nextnodetype = "";
				rs3.executeSql("select nodetype from workflow_flownode where workflowid="+workflowid+" and nodeid="+nextnodeid);
		        if(rs3.next()){
		        	nextnodetype=rs3.getString("nodetype");
		        }
				
				
				rst.setAutoCommit(false);
				String src = "submit";
				SendMsgAndMail sendMsgAndMail = new SendMsgAndMail();
				sendMsgAndMail.setIsIntervene("1");
				sendMsgAndMail.setInterveneOperators(opertorlist);
				//发送短信

                weaver.system.msg.SendMsg sendMsgtm=new weaver.system.msg.SendMsg();
                sendMsgtm.sendMsg(rst,requestid,nextnodeid,user,src,nextnodetype);
				// 邮件提醒
				sendMsgAndMail.sendMail(rst,workflowid,requestid,nextnodeid,null,null,false,src,nextnodetype,user);
				
				rst.commit();
				System.out.println("超时干预发送短信====================="+requestid);
			} catch (Exception e) {
				rst.rollback();
				System.out.println("超时干预发送短信====================="+e.getMessage());
				writeLog("超时干预短信提醒："+e);
			}
     }

    /*
	 * @author xwj  20050802
	 *判断当前流程是否为老数据(相对于 td2104 以前)
	 */
     public boolean isOldOrNewFlag(int requestid){
        boolean isOldWf = false;
        RecordSet  rs_ = new RecordSet();
        rs_.executeSql("select nodeid from workflow_currentoperator where requestid = " + requestid);
        while(rs_.next()){
            if(rs_.getString("nodeid") == null || "".equals(rs_.getString("nodeid")) || "-1".equals(rs_.getString("nodeid"))){
             isOldWf = true;
            }
        }
        return isOldWf;
     }
	private void writeWFLog(int requestid,int workflowid,int nodeid,int userid,int usertype,int nextnodeid,String currentdate,String currenttime,String remark,String logtype,boolean canflowtonextnode,int nextnodeattr){
		writeWFLog(requestid,workflowid,nodeid,userid,usertype,-1,-1,nextnodeid,currentdate,currenttime,remark,logtype,canflowtonextnode,nextnodeattr);
	}
    /**
     * 日志记录
     * @param requestid
     * @param workflowid
     * @param nodeid
     * @param userid
     * @param usertype
     * @param nextnodeid
     * @param currentdate
     * @param currenttime
     * @param remark
     * @param logtype
     * @param canflowtonextnode
     * @param nextnodeattr
     */
    private void writeWFLog(int requestid,int workflowid,int nodeid,int userid,int usertype,int agenttype,int agentorbyagentid,int nextnodeid,String currentdate,String currenttime,String remark,String logtype,boolean canflowtonextnode,int nextnodeattr){
        String clientip = "127.0.0.1";
        char flag=Util.getSeparator();
		String personStr = "";


		/*  ----------------       xwj for td2104 on 20050802           B E G I N     ------------------*/
		if(isOldOrNewFlag(requestid)){//老数据, 相对 td2104 之前
		   //add by liaodong for qc80034 in 2013-11-7 start
			if("t".equals(logtype)){
			     //add by liaodong for qc80034 in 2013-11-7 start
				for(int i=0;i<operator89List.size();i++){
					personStr += Util.toScreen(resource.getResourcename((String)operator89List.get(i)),usertype)+",";
				}
				//end
				rs3.executeSql("select operator  from workflow_requestLog where workflowid ="+workflowid+"  and requestid="+requestid+" and logtype != 't' and nodeid = "+nodeid+" order by operatedate,operatetime  desc ");
				if(rs3.next()){
					userid = rs3.getInt("operator");
				}
			}else{
			    if(logtype.equals("7")){
                    rs3.executeSql("select userid,usertype from workflow_currentoperator where isremark = '5' and requestid = " + requestid);
                }else{
                    rs3.executeSql("select userid,usertype from workflow_currentoperator where isremark = '0' and requestid = " + requestid);
                 }
                  while(rs3.next()){
					  // add by liaodong for qc80034 in 2013-11-06  start
					   if(!isCopyTo(rs3,operator89List)){ 
					         if("0".equals(rs3.getString("usertype"))){
						          personStr	+= Util.toScreen(resource.getResourcename(rs3.getString("userid")),user.getLanguage()) + ",";
						     } else{
						       personStr	+= Util.toScreen(crminfo.getCustomerInfoname(rs3.getString("userid")),user.getLanguage()) + ",";
						     }
					   }
						 
				 }
			}

            


						 String Procpara = "" + requestid + flag + workflowid + flag + nodeid + flag + logtype + flag
						   + currentdate + flag + currenttime + flag + userid + flag + remark + flag
						   + clientip + flag + usertype + flag + nextnodeid + flag + personStr.trim()+ flag + -1 + flag + "0" + flag + -1+flag+""+flag+"0"+ flag + ""+flag+"";
						 rs3.executeProc("workflow_RequestLog_Insert", Procpara);
		}
		else{
										String tempSQL = "";
										//int agentorbyagentid = -1;
										//int agenttype = 0;
										int showorder = 1;
								//add by liaodong for qc80034 in 2013-11-7 start
								if("t".equals(logtype)){
								    	//add by liaodong for qc80034 in 2013-11-7 start
										for(int i=0;i<operator89List.size();i++){
											personStr += Util.toScreen(resource.getResourcename((String)operator89List.get(i)),usertype)+",";
										}
										//end
										rs3.executeSql("select operator  from workflow_requestLog where workflowid ="+workflowid+"  and requestid="+requestid+" and logtype != 't' and nodeid = "+nodeid+" order by operatedate,operatetime  desc ");
										if(rs3.next()){
											userid = rs3.getInt("operator");
										}
								}else{
                                      if(logtype.equals("7")){
                                            rs3.executeSql("select userid,usertype,agentorbyagentid, agenttype from workflow_currentoperator where isremark='5' and requestid = " + requestid  + " and nodeid="+nextnodeid+" order by showorder asc");
                                        }else{
                                           rs3.executeSql("select userid,usertype,agentorbyagentid, agenttype from workflow_currentoperator where isremark in ('0','4') and requestid = " + requestid  + " and nodeid="+nextnodeid+" order by showorder asc");
                                        }
                                        //System.out.println("select userid,usertype,agentorbyagentid, agenttype from workflow_currentoperator where isremark in ('0','4') and requestid = " + requestid  + " order by showorder asc");
                                        while(rs3.next()){
											   // add by liaodong for qc80034 in 2013-11-06  start
					                          if(!isCopyTo(rs3,operator89List)){ 
												  if("0".equals(rs3.getString("usertype"))){
													if(rs3.getInt("agenttype") == 0){
														String tempPersonStr = Util.toScreen(resource.getResourcename(rs3.getString("userid")),user.getLanguage());
														if(personStr.indexOf(","+tempPersonStr+",") == -1 && personStr.indexOf(tempPersonStr+",") == -1){
														personStr	+= tempPersonStr + ",";
														}
													 }
													  else if(rs3.getInt("agenttype") == 2){
														String tempPersonStr = Util.toScreen(resource.getResourcename(rs3.getString("agentorbyagentid")),user.getLanguage()) + "->" + Util.toScreen(resource.getResourcename(rs3.getString("userid")),user.getLanguage());
														if(personStr.indexOf(","+tempPersonStr+",") == -1 && personStr.indexOf(tempPersonStr+",") == -1){
														personStr	+= tempPersonStr + ",";
														}
													  }
													 else{
													    }
													}else{
														String tempPersonStr = Util.toScreen(crminfo.getCustomerInfoname(rs3.getString("userid")),user.getLanguage());
														if(personStr.indexOf(","+tempPersonStr+",") == -1 && personStr.indexOf(tempPersonStr+",") == -1){
															personStr	+= tempPersonStr + ",";
														}
													}

					                           }
                                       
										}
								}

                                       
							/*
							tempSQL = "select agentorbyagentid, agenttype, showorder from workflow_currentoperator where nodeid = " + nodeid +
							" and requestid = " + requestid + " and userid = " + userid + " and nodeid="+nextnodeid+" order by showorder asc";
							rs3.executeSql(tempSQL);
							if(rs3.next()){
							   agentorbyagentid = rs3.getInt("agentorbyagentid");
							   agenttype = rs3.getInt("agenttype");
							   showorder = rs3.getInt("showorder");
							}
							*/
                            if(!canflowtonextnode&&(nextnodeattr==3||nextnodeattr==4)){
                                personStr= SystemEnv.getHtmlLabelName(21399,user.getLanguage())+",";
                            }
							String Procpara = "" + requestid + flag + workflowid + flag + nodeid + flag + logtype + flag
											+ currentdate + flag + currenttime + flag + userid + flag + remark + flag
											+ clientip + flag + usertype + flag + nextnodeid + flag + personStr.trim() + flag + agentorbyagentid + flag + agenttype + flag + showorder+flag+""+flag+"0"+ flag + ""+flag+"";

							rs3.executeProc("workflow_RequestLog_Insert", Procpara);

		}

		/*  ----------------   xwj for td2104 on 20050802   E N D  ------------------*/

    }

	     //add by liaodong for qc80034 in 2013-11-6 start 
	public boolean isCopyTo(RecordSet rs3,ArrayList operator89List) {
		//判断是否是抄送的数据
		   boolean isCopyTo =false;
		   String copyToUserId=rs3.getString("userid");
		   for(int i=0;i<operator89List.size();i++){
			 String cUserId =  (String) operator89List.get(i);
			 if(copyToUserId.equals(cUserId)){
				 isCopyTo = true;
				 break;
			 }
		   }
		   return isCopyTo;
	}
    
    private int updateManagerField(int requestID, int formid, int isbill, int userID) {
    	int result = 0;
    	RecordSet rs = new RecordSet();
    	String formfieldsql = "";
		if(isbill == 1){
			formfieldsql = "select fieldname from workflow_billfield where billid="+formid+" order by dsporder";
		}else{
			formfieldsql = "select fieldname from workflow_formdict where id IN (select fieldid from workflow_formfield where formid=" + formid + " and (isdetail<>'1' or isdetail is null))" ;
		}
		
		rs.executeSql(formfieldsql);
		while(rs.next()){
			String fieldname = rs.getString("fieldname");
			if ("manager".equals(fieldname)) {
				RecordSet sltRs = new RecordSet();
				String billtablename = "";
				int managerID = 0;
				
				String mgrSql = "select managerid from hrmresource where id=" + userID; 
				
				sltRs.executeSql(mgrSql);
				if (sltRs.next()) {
					managerID = Util.getIntValue(sltRs.getString("managerid"), 0);
				}
				//System.out.println("managerID=" + managerID);
				
				String sltmgsSql = "";
				String updateSql = "";
				if(isbill == 1){
					sltRs.executeSql("select tablename from workflow_bill where id = " + formid); // 查询工作流单据表的信息




					if (sltRs.next()) {
						billtablename = sltRs.getString("tablename");          // 获得单据的主表




						}
					sltRs.executeSql("select * from workflow_billfield where fieldname='manager' and billid = " + formid); // 查询工作流单据表是否存在manager字段
					if (sltRs.next()) {
						sltmgsSql = "select manager from " + billtablename + " where requestid=" + requestID;
						updateSql = "update " + billtablename + " set manager=" + managerID + " where requestid=" + requestID;
					}
				} else {
					sltmgsSql = "select manager from workflow_form where requestid=" + requestID;
					updateSql = "update workflow_form set manager=" + managerID + " where requestid=" + requestID;;
				}
				
				sltRs.execute(sltmgsSql);
				if (sltRs.next()) {
					result = Util.getIntValue(sltRs.getString("manager"), 0);
				}
				sltRs.executeSql(updateSql);
				break;
			}
		}
    	return result;
    }

    private boolean rollbackUpdatedManagerField(int requestID, int formid, int isbill, int mgrID) {
    	
    	if (mgrID == 0) return false;
    	
    	boolean result = false;
			RecordSet sltRs = new RecordSet();
			String billtablename = "";
			
			String updateSql = "";
			if(isbill == 1){
				sltRs.executeSql("select tablename from workflow_bill where id = " + formid); // 查询工作流单据表的信息




				if (sltRs.next()) {
					billtablename = sltRs.getString("tablename");          // 获得单据的主表




					}
					sltRs.executeSql("select * from workflow_billfield where fieldname='manager' and billid = " + formid); // 查询工作流单据表是否存在manager字段
					if (sltRs.next()) {
					updateSql = "update " + billtablename + " set manager=" + mgrID + " where requestid=" + requestID;
				}
			} else {
				updateSql = "update workflow_form set manager=" + mgrID + " where requestid=" + requestID;;
			}
			
			sltRs.executeSql(updateSql);
    	return true;
    }
    
    
    /**
     * 流程退回




     * @param requestid
     * @param userid
     * @param remark
     * @param
     * @param needback
     * @return
     */
    private boolean FlowNode(int requestid, int userid, String remark,String needback,int destnodeid) {
        boolean flowflag = false;
        try {
        	String src = "reject";
            RecordSet rs = new RecordSet();
            RecordSet rs1 = new RecordSet();
            RecordSet rSet6 = new RecordSet();
						RecordSet rSet7 = new RecordSet();
            WorkFlowInit wfi = new WorkFlowInit();
            WFLinkInfo wfli = new WFLinkInfo();
            rs.executeProc("workflow_Requestbase_SByID", requestid + "");
            if (rs.next()) {
                String requestname = Util.null2String(rs.getString("requestname"));
                String requestlevel = Util.null2String(rs.getString("requestlevel"));
                int workflowid = Util.getIntValue(rs.getString("workflowid"), 0);
                int nodeid = wfli.getCurrentNodeid(requestid, userid, 1);               //节点id
                String nodetype = wfli.getNodeType(nodeid);
                int currentnodeid = Util.getIntValue(rs.getString("currentnodeid"), 0);
                if (nodeid < 1) nodeid = currentnodeid;
                String currentnodetype = Util.null2String(rs.getString("currentnodetype"));
                if (nodetype.equals("")) nodetype = currentnodetype;
                rs.executeSql("select * from workflow_base where id=" + workflowid);
                if (rs.next()) {
                    String workflowtype = Util.null2String(rs.getString("workflowtype"));
                    int formid = Util.getIntValue(rs.getString("formid"));
                    int isbill = Util.getIntValue(rs.getString("isbill"));
                    String messageType = Util.null2String(rs.getString("messageType"));
                    int billid=-1;
                    rs.executeSql("select billid from workflow_form where requestid=" + requestid);
                    if (rs.next()) {
                        billid=Util.getIntValue(rs.getString("billid"));
                    }
                    rs.executeSql("select id,isremark,isreminded,preisremark,groupdetailid,nodeid from workflow_currentoperator where requestid="+requestid+" and userid="+userid+" and usertype=0 and isremark in('0','1','7','8','9') order by id");
                    if(rs.next()){
                        int isremark=rs.getInt("isremark");
                        //转发1、抄送(不需提交)9：抄送(需提交)
                        if(isremark==1||isremark==8||isremark==9){
							
                        }else{
	                        RequestManager rm = new RequestManager();
	                        rm.setUser(wfi.getUser(userid));
	                        rm.setSrc(src);
	                        rm.setIscreate("");
	                        rm.setRequestid(requestid);
	                        rm.setWorkflowid(workflowid);
	                        rm.setWorkflowtype(workflowtype);
	                        rm.setIsremark(0);
	                        rm.setFormid(formid);
	                        rm.setIsbill(isbill);
	                        rm.setBillid(billid);
	                        rm.setNodeid(nodeid);
	                        rm.setNodetype(nodetype);
	                        rm.setRequestname(requestname);
	                        rm.setRequestlevel(requestlevel);
	                        rm.setRemark(remark);
	                        rm.setMessageType(messageType);
	                        rm.setNeedwfback(needback);
	                        rm.setRejectToNodeid(destnodeid);
	                        /*
							 * 处理节点后附加操作




							 */
							RequestCheckAddinRules requestCheckAddinRules = new RequestCheckAddinRules();
							requestCheckAddinRules.resetParameter();
							//add by cyril on 2008-07-28 for td:8835 事务无法开启查询,只能传入
							requestCheckAddinRules.setTrack(false);
							requestCheckAddinRules.setStart(false);
							requestCheckAddinRules.setNodeid(nodeid);
							//end by cyril on 2008-07-28 for td:8835
							requestCheckAddinRules.setRequestid(requestid);
							requestCheckAddinRules.setWorkflowid(workflowid);
							requestCheckAddinRules.setObjid(nodeid);
							requestCheckAddinRules.setObjtype(1);               // 1: 节点自动赋值 0 :出口自动赋值




							requestCheckAddinRules.setIsbill(isbill);
							requestCheckAddinRules.setFormid(formid);
							requestCheckAddinRules.setIspreadd("0");//xwj for td3130 20051123
							requestCheckAddinRules.setRequestManager(rm);
							requestCheckAddinRules.setUser(wfi.getUser(userid));
							requestCheckAddinRules.checkAddinRules();
							
							//处理特殊字段manager
						ResourceComInfo rci = new ResourceComInfo();
					    int managerfieldid=-1;
					    String manager = "";
					    String billtablename = "";
					    //表单
					    if(isbill==0){
					    	rSet6.executeSql("select b.id from workflow_formfield a,workflow_formdict b where a.fieldid=b.id and a.isdetail is null and a.formid="+formid+" and b.fieldname='manager'");
					        if(rSet6.next()){
					        	managerfieldid=Util.getIntValue(rSet6.getString("id"));
					        }
					    }
					    //单据
					    if(isbill==1){
					    	rSet6.executeSql("select tablename from workflow_bill where id = " + formid); // 查询工作流单据表的信息




							if(rSet6.next()){
								billtablename = rSet6.getString("tablename");          // 获得单据的主表




							}
					    	rSet6.executeSql("select id from workflow_billfield where billid="+formid+" and viewtype=0 and fieldname='manager'");
					        if(rSet6.next()){
					            managerfieldid=Util.getIntValue(rSet6.getString("id"));
					        }
					    }
					    if(managerfieldid>0){
					    	String beagenter=""+userid;
					    	//获得被代理人
					    	rSet6.executeSql("select agentorbyagentid from workflow_currentoperator where usertype=0 and isremark='0' and requestid="+requestid+" and userid="+beagenter+" and nodeid="+nodeid+" order by id desc");
					    	if(rSet6.next()){
					    		int tembeagenter=rSet6.getInt(1);
					    		if(tembeagenter>0) beagenter=""+tembeagenter;
					    	}
					    	manager = rci.getManagerID(beagenter);
					 		if (manager!=null&&!"".equals(manager)) {
								if (isbill == 1 ) {
									if(billtablename!=null&&!"".equals(billtablename))
										rSet6.executeSql(" update " + billtablename + " set manager = "+manager+" where id = " + billid);
								} else {
									rSet6.executeSql("update workflow_form set manager = "+manager+" where requestid=" + requestid);
								}
							}
					    }
					    
					    BillBgOperation billBgOperation = null;
					    if (isbill == 1 && formid > 0) {
					    	billBgOperation = getBillBgOperation(rm);
					    }
					    
					    if(billBgOperation != null) {
					    	billBgOperation.billDataEdit();
                        }
					    
                        flowflag = rm.flowNextNode();
                        
                        /*
                        RecordSetTrans rst = new RecordSetTrans();
            			try {
            				String nextnodetype = "";
            				rSet6.executeSql("select nodetype from workflow_flownode where workflowid="+workflowid+" and nodeid="+destnodeid);
            		        if(rSet6.next()){
            		        	nextnodetype=rSet6.getString("nodetype");
            		        }
            				rst.setAutoCommit(false);
            				src = "reject";
            				SendMsgAndMail sendMsgAndMail = new SendMsgAndMail();
            				//发送短信




            				sendMsgAndMail.sendMsg(rst,requestid,destnodeid,user,src,nextnodetype);
            				// 邮件提醒
            				sendMsgAndMail.sendMail(rst,workflowid,requestid,destnodeid,null,null,false,src,nextnodetype,user);
            				
            				rst.commit();
            				System.out.println("退回至目标节点提醒====================="+requestid);
            			} catch (Exception e) {
            				rst.rollback();
            				System.out.println("退回至目标节点提醒====================="+e.getMessage());
            				writeLog("退回至目标节点提醒："+e);
            			}
            			*/
                        
                        if(billBgOperation != null) {
                        	billBgOperation.setFlowStatus(flowflag);
                        	flowflag = billBgOperation.billExtOperation();
                        }    
						    
                        }
                    }
                }
            }
            
        } catch (Exception e) {
        	flowflag = false;
            log.debug(e.getMessage());
        }
        return flowflag;
    }
    
    private BillBgOperation getBillBgOperation(RequestManager rm) {
    	BillBgOperation billBgOperation = null;
    	String operationpage = "";
		
		try {
			RecordSet rs = new RecordSet();
			int formid = rm.getFormid();
			
			rs.executeProc("bill_includepages_SelectByID",formid+"");
			if(rs.next()) {
		        operationpage = Util.null2String(rs.getString("operationpage")).trim();
		        if (operationpage.indexOf(".jsp") >= 0) {
		        	operationpage = operationpage.substring(0, operationpage.indexOf(".jsp"));
		        } else {
		        	operationpage = null;
		        }
		    }
			
			if (operationpage != null && !"".equals(operationpage)) {
				operationpage = "weaver.soa.workflow.bill."+operationpage;
				Class operationClass = Class.forName(operationpage);
				billBgOperation = (BillBgOperation)operationClass.newInstance();
				billBgOperation.setRequestManager(rm);
			}
		}catch (Exception e) {
			log.debug(e.getMessage());
			return null;
		}
		
    	return billBgOperation;
    }
    
    
    public User getUser(int userid){
    	User user = new User();
    	
    	RecordSet rs = new RecordSet();
    	String sql = "select * from HrmResource where id="+userid+" union select * from HrmResource where id="+userid;
    	rs.executeSql(sql);
        rs.next();
        user.setUid(rs.getInt("id"));
        user.setFirstname(rs.getString("firstname"));
        user.setLastname(rs.getString("lastname"));
        user.setAliasname(rs.getString("aliasname"));
        user.setTitle(rs.getString("title"));
        user.setTitlelocation(rs.getString("titlelocation"));
        user.setSex(rs.getString("sex"));
        String languageidweaver = rs.getString("systemlanguage");
        user.setLanguage(Util.getIntValue(languageidweaver, 0));
        user.setTelephone(rs.getString("telephone"));
        user.setMobile(rs.getString("mobile"));
        user.setMobilecall(rs.getString("mobilecall"));
        user.setEmail(rs.getString("email"));
        user.setCountryid(rs.getString("countryid"));
        user.setLocationid(rs.getString("locationid"));
        user.setResourcetype(rs.getString("resourcetype"));
        user.setContractdate(rs.getString("contractdate"));
        user.setJobtitle(rs.getString("jobtitle"));
        user.setJobgroup(rs.getString("jobgroup"));
        user.setJobactivity(rs.getString("jobactivity"));
        user.setJoblevel(rs.getString("joblevel"));
        user.setSeclevel(rs.getString("seclevel"));
        user.setUserDepartment(Util.getIntValue(rs.getString("departmentid"), 0));
        user.setUserSubCompany1(Util.getIntValue(rs.getString("subcompanyid1"), 0));
        user.setUserSubCompany2(Util.getIntValue(rs.getString("subcompanyid2"), 0));
        user.setUserSubCompany3(Util.getIntValue(rs.getString("subcompanyid3"), 0));
        user.setUserSubCompany4(Util.getIntValue(rs.getString("subcompanyid4"), 0));
        user.setManagerid(rs.getString("managerid"));
        user.setAssistantid(rs.getString("assistantid"));
        user.setPurchaselimit(rs.getString("purchaselimit"));
        user.setCurrencyid(rs.getString("currencyid"));
        user.setLogintype("1");
        user.setAccount(rs.getString("account"));
        
        return user;
    	
    }
    
    
}
