package weaver.interfaces.workflow.action;

 import org.apache.http.HttpEntity;
 import org.apache.http.HttpResponse;
 import org.apache.http.client.entity.UrlEncodedFormEntity;
 import org.apache.http.message.BasicNameValuePair;
import org.apache.http.client.HttpClient;
 import org.apache.http.client.methods.HttpPost;
 import org.apache.http.impl.client.DefaultHttpClient;
 import org.apache.http.util.EntityUtils;
 import weaver.conn.RecordSet;
 import weaver.general.BaseBean;
 import weaver.general.Util;
 import weaver.soa.workflow.request.RequestInfo;


 import java.io.IOException;

 import java.io.UnsupportedEncodingException;
 import java.text.SimpleDateFormat;
 import java.util.*;

/**
 * @author wyz
 * <br>
 * @Date 2018/9/27
 * <br>
 * @Description: ITSM集成
 */
public class ITSMAction implements Action {



    class WorkflowType{
        private int id;
        private String name;
        private int type;
        private int wfid;
        private int nodeid;

        public WorkflowType(int id,String name, int type, int wfid, int nodeid) {
            this.id=id;
            this.name = name;
            this.type = type;
            this.wfid = wfid;
            this.nodeid = nodeid;
        }

        public WorkflowType() {
        }

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getType() {
            return type;
        }

        public void setType(int type) {
            this.type = type;
        }

        public int getWfid() {
            return wfid;
        }

        public void setWfid(int wfid) {
            this.wfid = wfid;
        }

        public int getNodeid() {
            return nodeid;
        }

        public void setNodeid(int nodeid) {
            this.nodeid = nodeid;
        }
    }

    /***
     * 编号	流程名称	请求种类	来源系统	workflowid	nodeid	节点名称
     *
     * 1	信息系统业务中断申请流程	变更申请	OA	641	3965	"1、发起人填写实际中断时间
     * "
     *  2	系统程序变更申请流程	变更申请	OA	20762	20874	"2、执行人办理
     * "
     * 3	计算机特殊权限开通申请流程	服务请求	OA	455	3104	"相关人员确认办理
     * "
     * 4	信息系统测试设备登记流程	服务请求	OA	456	3090	"4、发起人测试完毕清除设备配置
     * "
     * 5	信息系统账号变更申请流程	服务请求	OA	320482	430219	"5、信息科技中心相关人员办理
     * "
     * @param
     * @
     */
    public List<WorkflowType>  initData(){
        List<WorkflowType> list=Arrays.asList(
                new WorkflowType(1,"信息系统业务中断申请流程",2,641,3965),
                new WorkflowType(2,"系统程序变更申请流程",2,20762,20874),
                new WorkflowType(3,"计算机特殊权限开通申请流程",1,455,3104),
                new WorkflowType(4,"信息系统测试设备登记流程",1,456,3090),
                new WorkflowType(5,"信息系统账号变更申请流程",1,320482,430219)
        );

        return list;
    }



    @Override
    public String execute(RequestInfo request) {

        BaseBean baseBean=new BaseBean();
        baseBean.writeLog("ITSMAction-----Start"+request.getRequestid());
        List<WorkflowType> workflowTypes = initData();
        String workflowid=request.getWorkflowid();
        String requestid=request.getRequestid();
        int nodeid=-1;
        int sort=-1;
        int orderType=2;
        for (WorkflowType workflowType : workflowTypes) {
            if(workflowid.equals(workflowType.getWfid()+"")){
                nodeid=workflowType.getNodeid();
                sort=workflowType.getId();
                orderType=workflowType.getType();
                break;
            }
        }
        baseBean.writeLog("ITSMAction---nodeid"+nodeid+"wfid"+workflowid);
        String detailUrl = Util.null2String(baseBean.getPropValue("ITSMAction", "detailUrl"));
        String propValue = Util.null2String(baseBean.getPropValue("ITSMAction", "url"));
        String url="http://10.60.138.234/itsm/yiliAction/createOrder";
        if(!"".equals(propValue)){
            url=propValue;
        }
         String dtUrl="http://10.60.137.45";
        if(!"".equals(detailUrl)){
            dtUrl=detailUrl;
        }
        dtUrl+="workflow/request/ViewRequest.jsp?requestid="+requestid;
        baseBean.writeLog("url"+url);
        String requestname="";
        RecordSet rs=new RecordSet();
        if(request.getRequestManager()!=null)
          requestname = request.getRequestManager().getRequestname();
        if("".equals(requestname)){
            rs.execute("select requestname from workflow_requestbase where requestid="+request.getRequestid());
            if(rs.next()){
                requestname=rs.getString(1);
            }
        }
        String changeType="20";
        //受理人
        String acceptUser=getWorkCode(request.getRequestManager().getUser().getUID());
        if(Util.getIntValue(request.getRequestManager().getRequestlevel())>0){
            changeType="10";
        }

        String createId=getWorkCode(getCreate(requestid));

        String createDate="";

        String nowDate="";
        try {
            Date date= new Date();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            nowDate=sdf.format(date);
        }catch (Exception e){
            baseBean.writeLog(e);
        }

        String[] acceptData = getAcceptData(requestid, nodeid + "");

        String RECEIVEDATE=acceptData[1];
        String OPERATEDATE=acceptData[2];




        HttpClient client=new DefaultHttpClient();

        HttpPost post = new HttpPost(url);

        BasicNameValuePair[] params = {new BasicNameValuePair("title", requestname),// urlfrom
                new BasicNameValuePair("sort", sort+""),
                new BasicNameValuePair("orderType", orderType+""),
                new BasicNameValuePair("reqUser", createId),
                new BasicNameValuePair("acceptUser", acceptUser),
                new BasicNameValuePair("changeType", changeType),
                new BasicNameValuePair("closeCode", ""),
                new BasicNameValuePair("effectDegree", "10"),
                new BasicNameValuePair("createDate", getCreareDate(requestid)),
                new BasicNameValuePair("acceptDate", RECEIVEDATE),
                new BasicNameValuePair("reqDate", RECEIVEDATE),
                new BasicNameValuePair("solveDate", OPERATEDATE),
                new BasicNameValuePair("closeDate", nowDate),
                new BasicNameValuePair("approvalDate", RECEIVEDATE),
                new BasicNameValuePair("channel", "1"),//固定1
                new BasicNameValuePair("createUser", createId),
                new BasicNameValuePair("detailUrl", dtUrl),
                new BasicNameValuePair("isBreakSla","0"),
                new BasicNameValuePair("actionUser",acceptUser)
        };

        for (BasicNameValuePair param : params) {
            baseBean.writeLog(param);
        }

        HttpEntity httpEntity=null;
        try {
              httpEntity=new UrlEncodedFormEntity(Arrays.asList(params),"UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        post.setEntity(httpEntity);

        try {
            HttpResponse response = client.execute(post);
            String str=Util.null2String(EntityUtils.toString(response.getEntity(),"UTF-8"));
            for (int i = 0; i <3 ; i++) {
                if( response.getStatusLine().getStatusCode()==200&&str.indexOf("\"success\":true")>-1){
                    return "1";
                }else{
                    baseBean.writeLog("返回数据"+str);
                    baseBean.writeLog("iTSM code"+ response.getStatusLine().getStatusCode());
                    response = client.execute(post);
                    str=Util.null2String(EntityUtils.toString(response.getEntity(),"UTF-8"));
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }


        return "0";
    }

    /***
     * 根据userid获取用户编号
     * @param userid
     * @return
     */
    public String getWorkCode(int userid){

        RecordSet rs=new RecordSet();
        rs.executeSql("select WORKCODE from HRMRESOURCE where id="+userid);
        rs.next();
       return rs.getString(1);

    }

    /**
     * 获取创建人ID
     * @param requestid
     * @return
     */
    public int getCreate(String requestid){
        RecordSet rs=new RecordSet();
        rs.executeSql("select CREATER from workflow_Requestbase where requestid="+requestid);
        rs.next();
        return rs.getInt(1);

    }

    /**
     * 获取创建时间
     * @param requestid
     * @return
     */
    public String getCreareDate(String requestid){
        RecordSet rs=new RecordSet();
        rs.executeSql("select CREATEDATE,CREATETIME from workflow_Requestbase where requestid="+requestid);
        rs.next();
        return rs.getString(1)+" "+rs.getString(2);
    }



    public String[] getAcceptData(String requestid,String nodeid){
        RecordSet rs=new RecordSet();
        rs.executeQuery("select userid,RECEIVEDATE,RECEIVETIME,OPERATEDATE,OPERATETIME from" +
                " workflow_currentoperator where requestid=? and nodeid=?",requestid,nodeid);
        rs.next();
        String [] params=new String[3];
        params[0]=rs.getString("userid");
        params[1]=rs.getString("RECEIVEDATE")+" "+rs.getString("RECEIVETIME");
        params[2]=rs.getString("OPERATEDATE")+" "+rs.getString("OPERATETIME");
        return params;

    }









}
