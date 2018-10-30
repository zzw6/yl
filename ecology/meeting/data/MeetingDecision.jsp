
<%@ page language="java" contentType="text/html; charset=UTF-8" %> <%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="Util" class="weaver.general.Util" scope="page" />
<jsp:useBean id="ResourceComInfo" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>
<jsp:useBean id="CustomerInfoComInfo" class="weaver.crm.Maint.CustomerInfoComInfo" scope="page" />
<jsp:useBean id="CapitalComInfo" class="weaver.cpt.capital.CapitalComInfo" scope="page"/>
<jsp:useBean id="DocComInfo" class="weaver.docs.docs.DocComInfo" scope="page" />
<jsp:useBean id="meetingTransMethod" class="weaver.meeting.Maint.MeetingTransMethod" scope="page"/>
<jsp:useBean id="RequestComInfo" class="weaver.workflow.request.RequestComInfo" scope="page"/>
<jsp:useBean id="meetingSetInfo" class="weaver.meeting.Maint.MeetingSetInfo" scope="page"/>
<jsp:useBean id="ProjectInfoComInfo" class="weaver.proj.Maint.ProjectInfoComInfo" scope="page" />
<jsp:useBean id="ProjectTaskApprovalDetail" class="weaver.proj.Maint.ProjectTaskApprovalDetail" scope="page" />
<jsp:useBean id="DocImageManager" class="weaver.docs.docs.DocImageManager" scope="page" />

<%@ include file="/cowork/uploader.jsp" %>

<%
String userid = ""+user.getUID();
String logintype = ""+user.getLogintype();
int isgoveproj = Util.getIntValue(IsGovProj.getPath(),0);//0:非政务系统，1：政务系统
String submit = Util.null2String(request.getParameter("submit"));
String edit = Util.null2String(request.getParameter("edit"));


char flag=Util.getSeparator() ;
String ProcPara = "";

String meetingid = Util.null2String(request.getParameter("meetingid"));

RecordSet.executeSql("select * from meeting where id ="+meetingid);
RecordSet.next();

String meetingtype=RecordSet.getString("meetingtype");
String meetingname=RecordSet.getString("name");
String caller=RecordSet.getString("caller");
String contacter=RecordSet.getString("contacter");
//会议决议 获取记录人id  by lq 2015-10-22
String recorder=RecordSet.getString("recorder");


String address=RecordSet.getString("address");
String begindate=RecordSet.getString("begindate");
String begintime=RecordSet.getString("begintime");
String enddate=RecordSet.getString("enddate");

String endtime=RecordSet.getString("endtime");
String desc=RecordSet.getString("desc_n");
String creater=RecordSet.getString("creater");
String createdate=RecordSet.getString("createdate");

String createtime=RecordSet.getString("createtime");
String approver=RecordSet.getString("approver");
String approvedate=RecordSet.getString("approvedate");
String approvetime=RecordSet.getString("approvetime");

String isapproved=RecordSet.getString("isapproved");
String isdecision=RecordSet.getString("isdecision");
String decision=RecordSet.getString("decision");
String decisiondocid=Util.null2String(RecordSet.getString("decisiondocid"));
decisiondocid = "-1".equals(decisiondocid)?"":decisiondocid;

String projectid=RecordSet.getString("projectid");//获得项目id
String totalmember=RecordSet.getString("totalmember");
String othermembers=RecordSet.getString("othermembers");
String othersremark=RecordSet.getString("othersremark");

String shareuser = RecordSet.getString("shareuser"); //会议决议共享人
ArrayList shareuserList = Util.TokenizerString(shareuser,",");
String shareuserNames = "";
for(int i=0;i<shareuserList.size();i++){
	shareuserNames+= meetingTransMethod.getMeetingResource(""+shareuserList.get(i)) + ",";
}

boolean ismanager=false;
boolean ismember=false;
int userPrm=1;

if(userid.equals(contacter)&&!userid.equals(caller)){
   userPrm = meetingSetInfo.getContacterPrm();
} else if(userid.equals(creater)&&!userid.equals(caller)){
   userPrm = meetingSetInfo.getCreaterPrm();
} else if(userid.equals(caller)){
	userPrm = meetingSetInfo.getCallerPrm();
	if(userPrm != 3) userPrm = 3;
}

if(userPrm == 3 || userid.equals(caller) || userid.equals(approver) ){
    ismanager=true;
}

	String sql = " select name,caller,contacter,recorder,hrmmembers,ccmeetingnotice,ccmeetingminutes,shareuser from meeting where id = '"+meetingid+"'";


//会议决议 权限判断 修改为 创建人和记录人可创建  lq  2015-10-22 start
//caller 主持人 contacter 创建人

//添加创建人和会议记录人 拥有创建会议决议提交权限
if(contacter.equals(userid) || recorder.equals(userid)){
	ismanager=true;    	
}

//会议决议 权限判断 修改为 创建人和记录人可创建  lq  2015-10-22 end

String Sql="";
if ("oracle".equals(RecordSet.getDBType()) || "db2".equals(RecordSet.getDBType()))
{
    Sql="select memberid from Meeting_Member2 where meetingid="+meetingid+" and ( membermanager="+userid+" or ','||othermember||',' like '%,"+userid+",%' )";
}
else
{
    Sql="select memberid from Meeting_Member2 where meetingid="+meetingid+" and ( membermanager="+userid+" or ','+othermember+',' like '%,"+userid+",%' )";
}
rs.executeSql(Sql);
if(rs.next()) {
	ismember=true;
}


	String sqlzz = " select name,caller,contacter,recorder,hrmmembers,ccmeetingnotice,ccmeetingminutes,shareuser from meeting where id = '"+meetingid+"'";

	new weaver.general.BaseBean().writeLog("查询人员是否可以查看会议sql："+sqlzz);
	String hrmIds="";
	RecordSet.executeSql(sql);
	//如果查询到数据说明可以查看会议
	if(RecordSet.next()){
		hrmIds = ","+Util.null2String(RecordSet.getString("caller"))
				+","+Util.null2String(RecordSet.getString("contacter"))
				+","+Util.null2String(RecordSet.getString("recorder"))
				+","+Util.null2String(RecordSet.getString("hrmmembers"))
				+","+Util.null2String(RecordSet.getString("ccmeetingnotice"))
				+","+Util.null2String(RecordSet.getString("ccmeetingminutes"))
				+","+Util.null2String(RecordSet.getString("shareuser"))+",";

	}

	new weaver.general.BaseBean().writeLog("hrmIds："+hrmIds);

	String url="/systeminfo/BrowserMain.jsp?url=/hrm/resource/MutiResourceBrowser.jsp?ids="+hrmIds+"&resourceids=";

%>

<HTML><HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<link rel="stylesheet" href="/css/ecology8/request/requestTopMenu_wev8.css" type="text/css" />
<LINK href="/wui/theme/ecology8/jquery/js/e8_zDialog_btn_wev8.css" type=text/css rel=STYLESHEET>
<LINK href="/css/ecology8/request/seachBody_wev8.css" type=text/css rel=STYLESHEET>
<script type="text/javascript" src="/js/weaver_wev8.js"></script>
<script language="javascript" src="/js/ecology8/meeting/meetingbase_wev8.js"></script>
<script type="text/javascript" src="/js/ecology8/request/titleCommon_wev8.js"></script>
<script language=javascript src="/js/weaverTable_wev8.js"></script>
<script language=javascript src="/js/ecology8/request/e8.browser_wev8.js"></script>
</HEAD>
<%
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(2108,user.getLanguage());
String needfav ="1";
String needhelp ="";

String needcheck="";
int decisionrows=0;
%>
<BODY>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
if(ismanager){
RCMenu += "{"+SystemEnv.getHtmlLabelName(615,user.getLanguage())+",javascript:doSave(1),_self} " ;
RCMenuHeight += RCMenuHeightStep ;
}
RCMenu += "{"+SystemEnv.getHtmlLabelName(86,user.getLanguage())+",javascript:doSave(2),_self} " ;
RCMenuHeight += RCMenuHeightStep ;
RCMenu += "{"+SystemEnv.getHtmlLabelName(309,user.getLanguage())+",javascript:btn_cancle(),_self} " ;
RCMenuHeight += RCMenuHeightStep ;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
	   <td>
		</td>
		<td class="rightSearchSpan" style="text-align:right; ">
			<%if(ismanager){%>
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(615, user.getLanguage())%>"
				 class="e8_btn_top middle"
				onclick="doSave(1)">
			<%}%>
			<input type="button"
				value="<%=SystemEnv.getHtmlLabelName(86, user.getLanguage())%>"
				class="e8_btn_top middle" onclick="doSave(2)">
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage()) %>" class="cornerMenu middle"></span>
		</td>
	</tr>
</table>
<div id="tabDiv" >
	<span id="hoverBtnSpan" class="hoverBtnSpan">
			<span></span>
	</span>
</div>
<div class="advancedSearchDiv" id="advancedSearchDiv">
</div>
<div class="zDialog_div_content" style="overflow-x: hidden;">
<FORM id=weaver name=weaver action="/meeting/data/MeetingDecisionOperation.jsp" method=post enctype="multipart/form-data">
<input class="inputstyle" type="hidden" name="method" value="edit">
<input class="inputstyle" type="hidden" name="meetingid" value="<%=meetingid%>">
<input class="inputstyle" type="hidden" name="decisionrows" value="0">
<INPUT type="hidden" name="f_weaver_belongto_userid" value="<%=userid %>">
<wea:layout type="2col">
	<wea:group context="<%=SystemEnv.getHtmlLabelName(154,user.getLanguage())%>" >
        <wea:item>
        <%=SystemEnv.getHtmlLabelName(2170,user.getLanguage())%>
        <div style="font-style:italic;color:red;">(输入内容请限制在500字，超过字数请以附件的形式上传)</div>
        </wea:item>
        <wea:item>
			<TEXTAREA class="inputStyle" NAME=decision ROWS=10 STYLE="width:100%"><%=Util.toScreenToEdit(decision,user.getLanguage())%></TEXTAREA>		  
		</wea:item>
		</wea:group>
		<wea:group context="<%=SystemEnv.getHtmlLabelName(22078, user.getLanguage())%>" >
		<%if(meetingSetInfo.getTpcDoc() == 1) {%>
               <!-- 相关文档 -->
            <wea:item><%=SystemEnv.getHtmlLabelName(857,user.getLanguage())%></wea:item>
	        <wea:item>
				<brow:browser viewType="0" name="decisiondocid" browserValue="<%=decisiondocid.trim()%>" 
					browserOnClick="" browserUrl="/docs/DocBrowserMain.jsp?url=/docs/docs/DocBrowser.jsp"
					hasInput="true"  isSingle="true" hasBrowser = "true" isMustInput='1' width="300px" 
					completeUrl="/data.jsp?type=9" linkUrl="/docs/docs/DocDsp.jsp?id=" 
					browserSpanValue="<%=("".equals(decisiondocid.trim()))?"":Util.toScreen(DocComInfo.getDocname(decisiondocid),user.getLanguage())%>"></brow:browser>
			</wea:item>
           <%} %>
            <!-- 会议决议共享人 -->
            <wea:item><%="会议决议共享人"%></wea:item>
	        <wea:item>
				<brow:browser viewType="0" name="shareuser" browserValue="<%=shareuser.trim()%>" 
						browserOnClick="" browserUrl="<%=url%>"
						hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='1'  width="300px"
						completeUrl="/data.jsp" linkUrl="javascript:openhrm($id$)" 
						browserSpanValue="<%=shareuserNames%>"></brow:browser>
			</wea:item>
           <%if(meetingSetInfo.getTpcWf() == 1) {%>
               <!-- 相关流程 -->
                <%
			       	String wfids=  Util.null2String(RecordSet.getString("decisionwfids"));
					String wfsname="";
			       	if(!wfids.equals("")){
						ArrayList wfids_muti = Util.TokenizerString(wfids,",");
						for(int i=0;i<wfids_muti.size();i++){
							wfsname += RequestComInfo.getRequestname(wfids_muti.get(i).toString()) + ",";
						}
					}%>
            <wea:item><%=SystemEnv.getHtmlLabelName(1044,user.getLanguage())%></wea:item>
            <wea:item>
				  <brow:browser viewType="0" name="decisionwfids" browserValue="<%=wfids %>" 
					browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/workflow/request/MultiRequestBrowser.jsp?resourceids="
					hasInput="false"  isSingle="false" hasBrowser = "true" isMustInput='1' width="300px" 
					completeUrl="/data.jsp" linkUrl="/workflow/request/ViewRequest.jsp?requestid==#id#&id=#id#" 
					browserSpanValue="<%=wfsname%>"></brow:browser>
            </wea:item>
           <%} %>
           <%if(meetingSetInfo.getTpcCrm() == 1) {%>
			<!-- 相关客户 -->
			<wea:item attributes="{'display':\"<%if(isgoveproj!=0){ %>none<%}%>\"}" ><%=SystemEnv.getHtmlLabelName(783,user.getLanguage())%></wea:item>
			<wea:item attributes="{'display':\"<%if(isgoveproj!=0){ %>none<%}%>\"}" >
				<%
				String relatedcus=  Util.null2String(RecordSet.getString("decisioncrmids"));
				String crmNames = "";
				if(!relatedcus.equals("")){
					ArrayList arrs = Util.TokenizerString(relatedcus,",");
					for(int i=0;i<arrs.size();i++){
						crmNames += CustomerInfoComInfo.getCustomerInfoname(arrs.get(i).toString()) + ",";
						
					}
				}%>	
				<brow:browser viewType="0" name="decisioncrmids" browserValue="<%=relatedcus %>" 
				browserOnClick="" browserUrl="<%="/systeminfo/BrowserMain.jsp?url=/CRM/data/MutiCustomerBrowser.jsp?resourceids="%>"
				hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='1' width="300px"
				completeUrl="/data.jsp?type=18" linkUrl="/CRM/data/ViewCustomer.jsp?CustomerID=#id#&id=#id#" 
				browserSpanValue="<%=crmNames%>"></brow:browser>
			</wea:item>
            <%} %>
           <%if(meetingSetInfo.getTpcPrj() == 1) {%>
               <!-- 相关项目 -->
                <%
			     	String projectIDs=  Util.null2String(RecordSet.getString("decisionprjids"));
					String prjnames = "";
					if(!projectIDs.equals("")){
			       		ArrayList arrs = Util.TokenizerString(projectIDs,",");
				  		for(int i=0;i<arrs.size();i++){
							prjnames += ProjectInfoComInfo.getProjectInfoname(arrs.get(i).toString()) + ",";
						}
					}%>
            <wea:item><%=SystemEnv.getHtmlLabelName(782,user.getLanguage())%></wea:item>
            <wea:item>
				  <brow:browser viewType="0" name="decisionprjids" browserValue="<%=projectIDs%>" 
					browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/proj/data/MultiProjectBrowser.jsp?projectids="
					hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='1' width="300px"
					completeUrl="/data.jsp?type=8" linkUrl="/proj/data/ViewProject.jsp?ProjID=#id#&id=#id#" 
					browserSpanValue="<%=prjnames%>"></brow:browser>
            </wea:item>
            <%} %>
           <%if(meetingSetInfo.getTpcTsk() == 1) {%>
               <!-- 相关项目任务 -->
			    <wea:item attributes="{'display':\"<%if(isgoveproj!=0){ %>none<%}%>\"}" ><%=SystemEnv.getHtmlLabelNames("522,1332",user.getLanguage())%></wea:item>
				<wea:item attributes="{'display':\"<%if(isgoveproj!=0){ %>none<%}%>\"}" >
               <%
			    	String decisiontskids=  Util.null2String(RecordSet.getString("decisiontskids"));
					String relatedprjnames = "";
					if(isgoveproj==0&&!decisiontskids.equals("")){
			       		ArrayList arrs = Util.TokenizerString(decisiontskids,",");
				  		for(int i=0;i<arrs.size();i++){
							relatedprjnames += Util.toScreen(ProjectTaskApprovalDetail.getTaskSuject(arrs.get(i).toString()),user.getLanguage()) + ",";
						}
					}%>
				 <brow:browser viewType="0" name="decisiontskids" browserValue="<%=decisiontskids %>" 
					browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/proj/data/MultiTaskBrowser.jsp?resourceids="
					hasInput="false"  isSingle="false" hasBrowser = "true" isMustInput='1' width="300px"
					completeUrl="/data.jsp?type=NO" linkUrl="/proj/process/ViewTask.jsp?taskrecordid=#id#&id=#id#" 
					browserSpanValue="<%=relatedprjnames%>"></brow:browser>
                </wea:item>
            <%} %>
           <%if(meetingSetInfo.getTpcAttch() == 1) {%>
				<wea:item><%=SystemEnv.getHtmlLabelName(22194,user.getLanguage())%></wea:item>
               <%
					if(!meetingSetInfo.getTpcAttchCtgry().equals("")){//如果设置了目录，则取值
					 	String relateddoc=  Util.null2String(RecordSet.getString("decisionatchids"));
					    ArrayList arrayaccessorys = Util.TokenizerString(relateddoc,",");
				        String[] categoryArr = Util.TokenizerString2(meetingSetInfo.getTpcAttchCtgry(),",");
				        String mainId = categoryArr[0];
				        String subId = categoryArr[1];
				        String secId = categoryArr[2];
				        String maxsize = "";
				        RecordSet.executeSql("select maxUploadFileSize from DocSecCategory where id="+secId);
					    RecordSet.next();
					    maxsize = Util.null2String(RecordSet.getString(1));
						
						if(!mainId.equals("")&&!subId.equals("")&&!secId.equals("")){
						%>
						<wea:item>
						<input type="hidden" name="decisionatchids" id="decisionatchids" value=""/>
					     <input type="hidden" id="edit_relatedacc" name="edit_relatedacc" value="<%=relateddoc%>"/>
					     <input type="hidden" id="delrelatedacc" name="delrelatedacc" value=""/>	
				         <%int linknum=-1;
				         for(int i=0;i<arrayaccessorys.size();i++){
				            rs.executeSql("select id,docsubject,accessorycount from docdetail where id="+arrayaccessorys.get(i));
				            
				          	if(rs.next()){
				          		linknum++;
				          	  String showid = Util.null2String(rs.getString(1)) ;
				              String tempshowname= Util.toScreen(rs.getString(2),user.getLanguage()) ;
				              int accessoryCount=rs.getInt(3);
				
				              DocImageManager.resetParameter();
				              DocImageManager.setDocid(Integer.parseInt(showid));
				              DocImageManager.selectDocImageInfo();
				
				              String docImagefileid = "";
				              long docImagefileSize = 0;
				              String docImagefilename = "";
				              String fileExtendName = "";
				              int versionId = 0;
				
				              if(DocImageManager.next()){
				                //DocImageManager会得到doc第一个附件的最新版本
				                docImagefileid = DocImageManager.getImagefileid();
				                docImagefileSize = DocImageManager.getImageFileSize(Util.getIntValue(docImagefileid));
				                docImagefilename = DocImageManager.getImagefilename();
				                fileExtendName = docImagefilename.substring(docImagefilename.lastIndexOf(".")+1).toLowerCase();
				                versionId = DocImageManager.getVersionId();
				              }
				              if(accessoryCount>1){
				                fileExtendName ="htm";
				              }
				
				             String imgSrc=AttachFileUtil.getImgStrbyExtendName(fileExtendName,20);
								%>
									<%=imgSrc%>
									<%if(accessoryCount==1 && (fileExtendName.equalsIgnoreCase("xls")||fileExtendName.equalsIgnoreCase("doc")||fileExtendName.equalsIgnoreCase("xlsx")||fileExtendName.equalsIgnoreCase("docx"))){%>
				            <a  style="cursor:hand" onclick="opendoc('<%=showid%>','<%=versionId%>','<%=docImagefileid%>');return false"><%=docImagefilename%></a>&nbsp
				          <%}else{%>
				            <a style="cursor:hand" onclick="opendoc1('<%=showid%>');return false"><%=tempshowname%></a>&nbsp
									<%}
				          if(accessoryCount==1){%>
				              <span id = "selectDownload">
				                <%
				                  //boolean isLocked=SecCategoryComInfo1.isDefaultLockedDoc(Integer.parseInt(showid));
				                  //if(!isLocked){
				                %>
				                  <input type="button" class="e8_btn_cancel" accessKey=1  onclick='onDeleteAcc("span_id_<%=linknum%>","<%=showid%>")' value="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage()) %>"/>
					                  <span id="span_id_<%=linknum%>" name="span_id_<%=linknum%>" style="display: none">
					                    <B><FONT COLOR="#FF0033">√</FONT></B>
					                  </span>
				                <%//}%>
				              </span>
								<%}%>
								<br>
								<%}
				          	}%>
								<div id="uploadDiv" mainId="<%=mainId%>" subId="<%=subId%>" secId="<%=secId%>" maxsize="<%=maxsize%>" style="margin-top: 0px"></div>
							</wea:item>
						<%} else {%>
						<wea:item><font color="red"><%=SystemEnv.getHtmlLabelName(17616,user.getLanguage())+SystemEnv.getHtmlLabelName(92,user.getLanguage())+SystemEnv.getHtmlLabelName(15808,user.getLanguage())%>!</font></wea:item>
						<%}
					}else{%>
					 <wea:item><font color="red"><%=SystemEnv.getHtmlLabelName(17616,user.getLanguage())+SystemEnv.getHtmlLabelName(92,user.getLanguage())+SystemEnv.getHtmlLabelName(15808,user.getLanguage())%>!</font></wea:item>
					<%}%> 
		   <%} %>
        </wea:group>
		<wea:group context="<%=SystemEnv.getHtmlLabelName(2171,user.getLanguage())%>" >
			<wea:item type="groupHead">
				<input class="addbtn" accesskey="A" onclick="addRow();" title="<%=SystemEnv.getHtmlLabelName(611,user.getLanguage())%>" type="button">
				<input class="delbtn" accesskey="E" onclick="deleteRow1();" title="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage())%>" type="button">
			</wea:item>
			<wea:item attributes="{\"isTableList\":true}">
			  <TABLE class="ListStyle LayoutTable" cellspacing=1 cellpadding=1  cols=7 id="oTable">

				<TBODY>
				<tr class="header">
					<th width=4%>&nbsp;</th>
					<th width=6%><%=SystemEnv.getHtmlLabelName(714,user.getLanguage())%></th>
					<th width=30%><%=SystemEnv.getHtmlLabelName(229,user.getLanguage())%></th>
					<!--列名称修改  by lq 2015-10-21 start-->
					<th width=10%>责任人 </th>
					<!--列名称修改  by lq 2015-10-21 end-->
					<th width=30%>决议描述 </th>
				</tr>
		 
		<%
		RecordSet.executeProc("Meeting_Decision_SelectAll",meetingid);
		while(RecordSet.next()){
		%>
				<tr class="DataDark">
					<td class="Field"><input  type='checkbox' name='check_node' value='0'></td>
					<td class="Field">
						<input type='input' style=width:99%  name='coding_<%=decisionrows%>' value="<%=RecordSet.getString("coding")%>">
					</td>
					<td class="Field">
						<!--修改为多行文本框   lq 2016-1-14  start-->
						<textarea name='subject_<%=decisionrows%>' style="width:99%;height:60px;"><%=RecordSet.getString("subject")%></textarea>
						<!--修改为多行文本框   lq 2016-1-14  end-->
					</td>
					<td class="Field">
						<%
							//会议批量转任务  修改为人员多选框  by lq 2015-10-22  start
							//String hrmid02= ResourceComInfo.getResourcename(RecordSet.getString("hrmid02"))
							ArrayList hrms02 = Util.TokenizerString(RecordSet.getString("hrmid02"),",");
							String hrmid02Names = "";
							for(int i=0;i<hrms02.size();i++){
								hrmid02Names+= meetingTransMethod.getMeetingResource(""+hrms02.get(i)) + ",";
							}
							//会议批量转任务  修改为人员多选框  by lq 2015-10-22  end
						%>
						<brow:browser viewType="0" name="<%="hrmid02_"+decisionrows%>" browserValue="<%=RecordSet.getString("hrmid02")%>" 
						browserOnClick="" browserUrl="/systeminfo/BrowserMain.jsp?url=/hrm/resource/MutiResourceBrowser.jsp?resourceids=" 
						hasInput="true"  isSingle="false" hasBrowser = "true" isMustInput='1'  width="100px"
						completeUrl="/data.jsp" linkUrl="javascript:openhrm($id$)" 
						browserSpanValue="<%=hrmid02Names%>"></brow:browser>

					</td>
					<td class="Field">
						<textarea name='remark_<%=decisionrows%>' style="width:99%;height:60px;"><%=RecordSet.getString("remark")%></textarea>
					</td>
				</tr>
		<%
		decisionrows = decisionrows +1;
		}
		%>
				</TBODY>
			  </TABLE>	
		</wea:item>
	</wea:group>
</wea:layout>
<div style="height:20px;"></div>
</div>
<div id="zDialog_div_bottom" class="zDialog_div_bottom">
	<wea:layout type="2col">
		<wea:group context="">
			<wea:item type="toolbar">
				<input type="button"
										value="<%=SystemEnv.getHtmlLabelName(309, user.getLanguage())%>"
										id="zd_btn_cancle" class="zd_btn_cancle" onclick="btn_cancle()">
			</wea:item>
		</wea:group>
	</wea:layout>
</div>
<script language="JavaScript" src="/js/addRowBg_wev8.js" >   
</script>  
<script language=javascript>  

rowindex = "<%=decisionrows%>";
var rowColor="" ;
function addRow()
{
	ncol = jQuery(oTable).find("TR:first").find("TH").length;
	rowColor = getRowBg();
	oRow = oTable.insertRow(-1);
	oRow.className = "DataDark";
	
	for(j=0; j<ncol; j++) {
		oCell = oRow.insertCell(-1);
		oCell.style.height=24;
		oCell.style.background= rowColor;
		oCell.className="Field";
		switch(j) {
			case 0:
				var oDiv = document.createElement("div");
				var sHtml = "<input type='checkbox' name='check_node' value="+rowindex+">";
				oDiv.innerHTML = sHtml;
				oCell.appendChild(oDiv);
				break;
			case 1:
				//var oDiv = document.createElement("div");
				var sHtml = "<input type='input' style=width:99%  name='coding_"+rowindex+"' value='"+(rowindex*1+1)+"'>";
				//oDiv.innerHTML = sHtml;
				//oCell.appendChild(oDiv);
				oCell.innerHTML = sHtml;
				break;
			case 2:
				//var oDiv = document.createElement("div");
				//var sHtml = "<input type='input' style=width:99%  name='subject_"+rowindex+"'>";
				//改为多行文本框  2016-1-14  lq  start
				var sHtml = "<textarea name='subject_"+rowindex+"' style=\"width:99%;height:60px;\"></textarea>"
				//改为多行文本框  2016-1-14  lq  end
				//oDiv.innerHTML = sHtml;
				//oCell.appendChild(oDiv);
				oCell.innerHTML = sHtml;
				break;
			case 3:
				var oDiv = document.createElement("div");
				oDiv.id = "hrmid02_"+rowindex+"div";
				oCell.appendChild(oDiv);
				//会议批量转任务  修改为人员多选框  by lq 2015-10-22
				addHrmidsBrowser("hrmid02_"+rowindex,"hrmid02_"+rowindex+"div");
				
				break;
			case 4:
				var sHtml = "<textarea name='remark_"+rowindex+"' style=\"width:99%;height:60px;\"></textarea>"
				oCell.innerHTML = sHtml;
				break;
		}
	}
	rowindex = rowindex*1 +1;
	jQuery("body").jNice();
	var tr = jQuery("table.LayoutTable tr[class!=intervalTR]");
	tr.each(function(){
		if(!jQuery(this).hasClass("intervalTR")){
			jQuery(this).hover(function(){
				jQuery(this).addClass("Selected");
				//jQuery(this).next("tr.Spacing").find("div").addClass("intervalHoverClass");		
			},function(){
				jQuery(this).removeClass("Selected");	
				//jQuery(this).next("tr.Spacing").find("div").removeClass("intervalHoverClass");	
			});
		}
	});
}

function deleteRow1()
{	
	var checkedNum=0;
	var rowsum1 = $("[name='check_node']").length;
	for(i=rowsum1; i >= 1;i-- ){
		if($("[name='check_node']")[i -1].checked){
			checkedNum++;
		}
	}
	if(checkedNum==0){
		window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(15543,user.getLanguage())%>");
		return;
	}else{
		window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(16344, user.getLanguage())%>", function (){
			dodeleteRow1();	
		});
	}
}


function dodeleteRow1()
{
	//len = document.forms[0].elements.length;
	//var i=0;
	
	var rowsum1 = $("[name='check_node']").length;
	//for(i=len-1; i >= 0;i--) {
	//	if (document.forms[0].elements[i].name=='check_node')
	//		rowsum1 += 1;
	//}
	//for(i=len-1; i >= 0;i--) {
	//	if (document.forms[0].elements[i].name=='check_node'){
	//		if(document.forms[0].elements[i].checked==true) {
	//			oTable.deleteRow(rowsum1 - 1);
	//		}
	//		rowsum1 -=1;
	//	}
	//
	//}
	for(i=rowsum1; i >= 1;i-- ){
		if($("[name='check_node']")[i -1].checked){
			oTable.deleteRow(i);
		}
	}

}

function doSave(savemethod){
    if(savemethod===1){
        jQuery("#shareuser_browserbtn").click();
    }
    if (savemethod==1) savemethod = "submit" ;
    if (savemethod==2) savemethod = "edit" ;
    var parastr = "<%=needcheck%>" ;
    len = document.forms[0].elements.length;
	var i=0;
	for(i=len-1; i >= 0;i--) {
		if (document.forms[0].elements[i].name=='check_node')
			parastr+=",begindate_"+document.forms[0].elements[i].value;
			parastr+=",enddate_"+document.forms[0].elements[i].value;
	}
	if(parastr!="") parastr=parastr.substring(1);
	
	    enableAllmenu(); 
		document.weaver.method.value=savemethod;
		document.weaver.decisionrows.value=rowindex;
		 var oUploader=window[jQuery("#uploadDiv").attr("oUploaderIndex")];
		try{
		    if(oUploader.getStats().files_queued==0) 
		   	doSaveAfterAccUpload();
		    else 
		    oUploader.startUpload();
		}catch(e){
			doSaveAfterAccUpload();
		}
	
}
function doSaveAfterAccUpload(){
	 document.weaver.submit();
}


function onShowHrm(spanname,inputename,needinput){
	data = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/hrm/resource/ResourceBrowser.jsp");
	if (data!=null){
		if (data.id != ""){
			jQuery("#"+spanname).html("<a href=javaScript:openhrm("+data.id+"); onclick='pointerXY(event);'>"+data.name+"</A>");
			jQuery("input[name="+inputename+"]").val(data.id);
		}else{
			if (needinput == "1"){
				jQuery("#"+spanname).html("<IMG src='/images/BacoError_wev8.gif' align=absMiddle>");
			}else{
				jQuery("#"+spanname).html("");
			}
			jQuery("input[name="+inputename+"]").val("");
		}
	}
}

function onShowMHrm(spanname,inputename){
		tmpids = jQuery("input[name="+inputename+"]").val();
		data = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/hrm/resource/MutiResourceBrowser.jsp?resourceids="+tmpids);
		if (data!=null){
				if (data.id != ""){
					ids = data.id.split(",");
					names =data.name.split(",");
					sHtml = "";
					for( var i=0;i<ids.length;i++){
						if(ids[i]!=""){
							sHtml = sHtml+"<a href=javaScript:openhrm("+ids[i]+"); onclick='pointerXY(event);'>"+names[i]+"</A> &nbsp;";
						}
					}
					jQuery("input[name="+inputename+"]").val(data.id.substr(1));
					jQuery("#"+spanname).html(sHtml);
					
				}else{
					jQuery("#"+spanname).html("");
					jQuery("input[name="+inputename+"]").val("");
				}
		}
}

function onShowMCrm(spanname,inputename){
		tmpids = jQuery("input[name="+inputename+"]").val();
		data = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/CRM/data/MutiCustomerBrowser.jsp?resourceids="+tmpids);
				if (data.id != ""){
					ids = data.id.split(",");
					names =data.name.split(",");
					sHtml = "";
					for( var i=0;i<ids.length;i++){
						if(ids[i]!=""){
						sHtml = sHtml+"<a href=/CRM/data/ViewCustomer.jsp?CustomerID="+ids[i]+" target=\'_blank\'>"+names[i]+"</a>&nbsp;";
						}
					}
					jQuery("input[name="+inputename+"]").val(data.id.substr(1));
					jQuery("#"+spanname).html(sHtml);
					
				}else{
					jQuery("#"+spanname).html("");
					jQuery("input[name="+inputename+"]").val("");
				}
}

function onShowDoc(spanname,inputename){
	data = window.showModalDialog("/docs/DocBrowserMain.jsp?url=/docs/docs/DocBrowser.jsp");
	if (data!=null){
		jQuery("#"+spanname).html("<a href='/docs/docs/DocDsp.jsp?id="+data.id+"' target=\'_blank\'>"+data.name+"</a>");
		jQuery("input[name="+inputename+"]").val(data.id+"");
	}	
}

//附件删除
function onDeleteAcc(delspan,delid){
	 var delrelatedacc=jQuery("#delrelatedacc").val();
	 var relatedacc=jQuery("#edit_relatedacc").val();
	 relatedacc=","+relatedacc;
	 delrelatedacc=","+delrelatedacc;
	 if(jQuery("#"+delspan).is(":hidden")){
		delrelatedacc=delrelatedacc+delid+",";
		var index=relatedacc.indexOf(","+delid+",");
		relatedacc=relatedacc.substr(0,index+1)+relatedacc.substr(index+delid.length+2);
		jQuery("#"+delspan).show();    
	 }else{
		var index=delrelatedacc.indexOf(","+delid+",");
		delrelatedacc=delrelatedacc.substr(0,index+1)+delrelatedacc.substr(index+delid.length+2);
						         
		relatedacc=relatedacc+delid+",";
						         
		jQuery("#"+delspan).hide(); 
	}
		jQuery("#edit_relatedacc").val(relatedacc.substr(1,relatedacc.length));
		jQuery("#delrelatedacc").val(delrelatedacc.substr(1,delrelatedacc.length));
} 

function btn_cancle(){
	 var parentWin = parent.parent.getParentWindow(window.parent);
     parentWin.diag_vote.close();
}
jQuery(document).ready(function(){
	if(jQuery("#uploadDiv").length>0)
     	bindUploaderDiv(jQuery("#uploadDiv"),"decisionatchids"); 
	resizeDialog(document);
});
</script>

</body>
<SCRIPT language="javascript" defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src="/js/JSDateTime/WdatePicker_wev8.js"></script>
<SCRIPT language="javascript" src="/js/selectDateTime_wev8.js"></script>
</html>
