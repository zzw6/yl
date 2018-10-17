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
import weaver.conn.RecordSetTrans;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.*;

/**
 * @author wyz
 * <br>
 * @Date 2018/9/27
 * <br>
 * @Description: ITSM集成
 */
public class ProvisionUserAction implements Action {


    BaseBean baseBean = new BaseBean();

    void writeLog(String str) {
        baseBean.writeLog(str);
    }

    String requestid = "";

    @Override
    public String execute(RequestInfo request) {
        baseBean.writeLog("ProvisionUserAction-----Start" + request.getRequestid());
        requestid = request.getRequestid();
        String propValue = Util.null2String(baseBean.getPropValue("ITSMAction", "userurl"));
        String url = "http://10.114.1.11:7777/yili-ws/ProvisionUser";
        if (!"".equals(propValue)) {
            url = propValue;
        }
        baseBean.writeLog("url" + url);
        RecordSetTrans rs = request.getRequestManager().getRsTrans();
        if (rs == null) {
            rs = new RecordSetTrans();
        }

        try {

            ResourceComInfo rc = new ResourceComInfo();
            rs.executeQuery("select * from formtable_main_213_dt1 where mainid=(select id from formtable_main_213 where requestid=?)");
            int rowno = 0;
            while (rs.next()) {
                rowno++;
                int name = rs.getInt("xm");
                String ygbm = Util.null2String(rs.getString("ygbm"));
                String id = rs.getString("id");
                int sqlx = rs.getInt("sqlx");
                writeLog("name:" + name);
                String workCode = getWorkCode(name);
                String operateType = "add";
                switch (sqlx) {
                    case 0:
                        operateType = "add";
                        break;
                    case 1:
                        operateType = "disable";
                        break;
                    case 2:
                        operateType = "enable";
                        break;
                }

                BasicNameValuePair[] params = {
                        new BasicNameValuePair("keyType", "empno"),
                        new BasicNameValuePair("AccountOrEmpNo", workCode),
                        new BasicNameValuePair("operateType", operateType),
                        new BasicNameValuePair("appName", "OA"),
                };

                if (!push(url, params)) {
                    writeLog("第" + rowno + "行明细报错" + "id:" + id);
                    return "0";
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        }


        return "1";
    }

    public Boolean push(String url, BasicNameValuePair[] params) {
        HttpClient client = new DefaultHttpClient();
        HttpPost post = new HttpPost(url);
        for (BasicNameValuePair param : params) {
            baseBean.writeLog(param);
        }
        HttpEntity httpEntity = null;
        try {
            httpEntity = new UrlEncodedFormEntity(Arrays.asList(params), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        post.setEntity(httpEntity);
        try {
            HttpResponse response = client.execute(post);
            String str = Util.null2String(EntityUtils.toString(response.getEntity(), "UTF-8"));
            for (int i = 0; i < 3; i++) {
                if (response.getStatusLine().getStatusCode() == 200 && str.indexOf("success") > -1) {
                    return true;
                } else {
                    baseBean.writeLog("requestid=" + requestid);
                    baseBean.writeLog("返回数据" + str);
                    baseBean.writeLog("iTSM code" + response.getStatusLine().getStatusCode());
                    response = client.execute(post);
                    str = Util.null2String(EntityUtils.toString(response.getEntity(), "UTF-8"));
                    writeLog("error" + str);
                    return false;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return true;
    }


    /***
     * 根据userid获取用户编号
     * @param userid
     * @return
     */
    public String getWorkCode(int userid) {

        RecordSet rs = new RecordSet();
        rs.executeSql("select WORKCODE from HRMRESOURCE where id=" + userid);
        rs.next();
        return rs.getString(1);

    }


}
