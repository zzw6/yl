<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ taglib uri="/WEB-INF/tld/browser.tld" prefix="brow"%>
<%@ include file="/systeminfo/init_wev8.jsp"%>
<%@ page import="weaver.general.Util"%>
<%@ page import="weaver.general.BaseBean"%>
<%@ page import="weaver.conn.RecordSet"%>
<%@ page import="weaver.hrm.*"%>
<!-- 添加人员浮动卡片 -->
<%-- <%@ include file="/hrm/resource/simpleHrmResource_wev8.jsp" %> --%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.apache.commons.httpclient.util.DateUtil"%>
<jsp:useBean id="TimeUtils" class="com.weavernorth.util.TimeUtils" scope="page" />

<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet2" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="BaseBean" class="weaver.general.BaseBean" scope="page" />
<jsp:useBean id="SystemEnv" class="weaver.systeminfo.SystemEnv" scope="page" />
<jsp:useBean id="SubCompanyComInfo"	class="weaver.hrm.company.SubCompanyComInfo" scope="page" />
<HTML>
<HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>

<script type='text/javascript'	src='/js/jquery-autocomplete/lib/jquery.bgiframe.min_wev8.js'></script>
<script type='text/javascript'	src='/js/jquery-autocomplete/jquery.autocomplete_wev8.js'></script>
<script type='text/javascript'	src='/js/jquery-autocomplete/browser_wev8.js'></script>

<link rel="stylesheet" type="text/css"	href="/js/jquery-autocomplete/jquery.autocomplete_wev8.css" />
<link rel="stylesheet" type="text/css"	href="/js/jquery-autocomplete/browser_wev8.css" />
<script type='text/javascript'	src='/js/messagejs/simplehrm_wev8.js'></script>
<script type='text/javascript'	src='/js/messagejs/messagejs_wev8.js'></script>

<!--  -->
<script language="javascript" src="/qrcode/js/jquery.qrcode-0.7.0_wev8.js"></script>
<script src="/qrcode/js/html5shiv_wev8.js"></script>
<script src="/qrcode/js/excanvas.compiled_wev8.js"></script>
<script type="text/javascript" src="/js/messagejs/simplehrm_wev8.js" ></script>
<script src="/js/messagejs/messagejs_wev8.js" type="text/javascript"></script>
<!--  -->
</HEAD>
<body scroll="no">
<%!
private String getHrmHtml_bak(String hrmIds){
	String html = "";
	RecordSet recordSet = new RecordSet();
	//处理外来人员id
	String sqlHrmIds = "'"+hrmIds.replace(",","','")+"'";
	String  sql = "";
	sql += " select t1.*,t2.departmentmark from hrmresource t1,hrmdepartment t2 where t1.id in ("+ sqlHrmIds +") and t1.departmentid = t2.id ";
	
	recordSet.executeSql(sql);
	
	while(recordSet.next()){
		String id = recordSet.getString("id");
		String lastname = recordSet.getString("lastname");
		String departmentmark = recordSet.getString("departmentmark");
		/*
		//单独页面显示人员信息
		html += "<span class=\"e8_showNameClass\">";
		//html += "<a onclick=\"pointerXY(event);\" href=\"javaScript:openhrm("+id+");\">"+lastname+"</a>";
		//<a onclick="pointerXY(event);" href="javaScript:openhrm(1);">
		//<a href="/hrm/resource/HrmResource.jsp?id=496" target="_blank">李娜</a>
		html += "<a href=\"/hrm/resource/HrmResource.jsp?id="+id+"\" target=\"_blank\">"+lastname+"</a>";
		//html += "<span id=\""+id+"\" class=\"e8_delClass\" style=\"visibility: hidden; opacity: 1;\">x</span>";
		html += "</span>";
		
		//html += "<span class=\"e8_showNameClass\">"+lastname+"</span> &nbsp;";
		*/
		//本页显示人员卡片
		html += "<span class=\"e8_showNameClass\">";		
		html += "<a onclick=\"pointerXY(event);\" href=\"javaScript:openhrm("+id+");\">"+lastname+"</a>";		
		html += "</span>";
		
	}
	return html;
}

private String getHrmHtml(String hrmIds){
	
	String sqlHrmIdArray[] = hrmIds.split(",");
	String html = "";
	String reHrmIds = ""; 
	String addIds = ",";
	RecordSet recordSet = new RecordSet();
	
	for(int i=0;i<sqlHrmIdArray.length;i++){
		String hrmid = sqlHrmIdArray[i];
		if(!hrmid.equals("") && (reHrmIds+",").indexOf(","+hrmid+",")==-1){
			
			String  sql =  " select t1.*,t2.departmentmark from hrmresource t1,hrmdepartment t2 where t1.id = '"+ hrmid +"' and t1.departmentid = t2.id ";
					 
			//日志输出sql语句
			//BaseBean.writeLog("查询sql:"+sql);
			recordSet.executeSql(sql);
			
			if(recordSet.next()){
				String id = recordSet.getString("id");
				String lastname = recordSet.getString("lastname");
				String departmentmark = recordSet.getString("departmentmark");
				html += "<span class=\"e8_showNameClass\">";		
				html += "<a onclick=\"pointerXY(event);\" href=\"javaScript:openhrm("+id+");\">"+lastname+"</a>";		
				html += "</span>";
				
				//记录人员id
				reHrmIds +=","+id;
			}	
		}
		
	}
	return html;	
}


private String getOutHrmHtml(String hrmIds){
	String html = "";
	RecordSet recordSet = new RecordSet();
	//处理外来人员id
	String sqlHrmIds = "'"+hrmIds.replace(",","','")+"'";
	String  sql = "";
	sql += " select id,name,sex,company,mobilephone,remark,isclose,modedatacreater from uf_meeting_out_hum ";
	sql += " where id in ("+ sqlHrmIds +") ";
	System.out.println(sql);	
	recordSet.executeSql(sql);
	
	while(recordSet.next()){
		//id
		String id = recordSet.getString("id");
		//名称
		String lastname = recordSet.getString("name");
		//性别
		String sex = recordSet.getString("sex");
		//公司
		String company = recordSet.getString("company");
		//电话
		String mobilephone = recordSet.getString("mobilephone");
		//是否关闭
		String isclose = recordSet.getString("isclose");
		
		html += "<span class=\"e8_showNameClass\">";				
		//html += "<a href=\"/hrm/resource/HrmResource.jsp?id="+id+"\" target=\"_blank\">"+lastname+"</a>";		
		html += "<a onclick=\"javaScript:showOutHrmInfoById("+id+");\" href=\"#\">"+lastname+"</a>";
		//html += lastname;
		html += "</span>";

	}
	return html;
}
 %>
	<%
	BaseBean.writeLog("==============MeetingBaseInfo.jsp.jsp start1=============");
		
		//是否显示会议议程
		boolean isshow = true;
		User c_user = HrmUserVarify.getUser (request,response) ;
		if(c_user == null)  
		{
			out.println("<script>location.href =\"/notice/noright.jsp\";</script>");
			return ;
		}
		String userId = c_user.getUID()+""; 
		String subcompanyid = "5";
		String meetingId = Util.null2String(request.getParameter("id"));
		
		String fujian111 = "," + TimeUtils.replaceRepStr(Util.null2String(request.getParameter("fujian"))) + ",";

		//标识是否可以查看会议信息
		boolean canview=false;
		//会议名称 		
		String name = "";
		//会议时间：**日**时-**日**时（共计*小时）
		String begindate = "";
		String begintime = "";
		String enddate = "";
		String endtime = "";
		String xiaoshi = "";
		//主持人：**    记录人：**     创建人：***	
		String caller = "";
		String recorder = "";
		String contacter = "";
		//参会人：
		String hrmmembers = "";
		//其他人员：
		String othermembers = "";
		//会议地点：
		String addressselect = "";
		String address = "";
		String customizeAddress = "";
		//会议议程：
		String meeting_topic = "";
		//会议要求：
		String desc_n = "";
		//会议成本：
		String cost = "";
		//会议通知抄送人：         会议纪要抄送人：
		String ccmeetingnotice  = "";
		String ccmeetingminutes  = "";
		//相关附件：
		String accessorys = "";
		
		if(!meetingId.equals("")){
			
			//查询会议信息 select * from meeting where id = 45433
			String sql = " select * from meeting where id = "+meetingId;
			BaseBean.writeLog("getMeetingSql:"+sql);
			RecordSet.executeSql(sql);
			if(RecordSet.next()){
				canview=true;
				//会议名称 		
				 name = Util.null2String(RecordSet.getString("name"));
				//会议时间：**日**时-**日**时（共计*小时）
				 begindate = Util.null2String(RecordSet.getString("begindate"));
				 begintime = Util.null2String(RecordSet.getString("begintime"));
				 enddate = Util.null2String(RecordSet.getString("enddate"));
				 endtime = Util.null2String(RecordSet.getString("endtime"));
				 xiaoshi = Util.null2String(RecordSet.getString("xiaoshi"));
				//主持人：**    记录人：**     创建人：***	
				 caller = Util.null2String(RecordSet.getString("caller"));
				 recorder = Util.null2String(RecordSet.getString("recorder"));
				 contacter = Util.null2String(RecordSet.getString("contacter"));
				//参会人：
				 hrmmembers = Util.null2String(RecordSet.getString("hrmmembers"));				 
				//其他人员：
				 othermembers = Util.null2String(RecordSet.getString("othermembers"));
				//会议地点：
				 addressselect = Util.null2String(RecordSet.getString("addressselect"));
				 address = Util.null2String(RecordSet.getString("address"));
				 customizeAddress = Util.null2String(RecordSet.getString("customizeAddress"));
				//会议议程：
				 meeting_topic = Util.null2String(RecordSet.getString("meeting_topic"));
				//会议要求：
				//desc_n = Util.null2String(RecordSet.getString("desc_n"));
				desc_n = Util.null2String(RecordSet.getString("desc_n")).replaceAll("'","\\'");
					if(desc_n.indexOf("<br>")==-1)
					desc_n = Util.forHtml(desc_n);
				//会议成本：
				 cost = Util.null2String(RecordSet.getString("cost"));
				//会议通知抄送人：         会议纪要抄送人：
				 ccmeetingnotice  = Util.null2String(RecordSet.getString("ccmeetingnotice"));
				 ccmeetingminutes  = Util.null2String(RecordSet.getString("ccmeetingminutes"));
				//相关附件：
				 accessorys = Util.null2String(RecordSet.getString("accessorys"));	
			}
		}
		
		//查询
		if(!canview){		
			out.println("<script>location.href =\"/notice/noright.jsp\";</script>");
			return;
		}
		
	
	%>
	
	<wea:layout type="2col">
		<wea:group context="会议信息" attributes="{'class':\"e8_title e8_title_1\",'groupDisplay':'none','itemAreaDisplay':''}">
			<wea:item><span name='mark'>会议名称</span></wea:item>
			<wea:item>
				<!-- 
				<brow:browser name="workflowid" viewType="0" hasBrowser="true"
					hasAdd="false"
					browserUrl="/systeminfo/BrowserMain.jsp?url=/workflow/workflow/WorkflowBrowser_frm.jsp?isTemplate=0&iswfec=1"
					isMustInput="1" isSingle="true" hasInput="true"
					completeUrl="/data.jsp?type=workflowBrowser&isTemplate=0"
					width="300px" browserValue="" browserSpanValue="" />
				 -->
				 <%=name%>
			</wea:item>
			<wea:item><span name='mark'>会议时间</span></wea:item>
			<wea:item>
			<%--
				<%=begindate%>&nbsp;日&nbsp;<%=begintime %>&nbsp;时&nbsp;-&nbsp;&nbsp;<%=enddate%>&nbsp;日&nbsp;<%=endtime %> 时（共计<%=xiaoshi %>小时）
			--%>
				<%=begindate%>&nbsp;&nbsp;<%=begintime %>&nbsp;&nbsp;—&nbsp;&nbsp;<%=enddate%>&nbsp;&nbsp;<%=endtime %> （共计<%=xiaoshi %>小时）	
			</wea:item>
			
			<wea:item><span name='mark'>主持人</span></wea:item>
			<wea:item>
				<%=getHrmHtml(caller)%>
			</wea:item>
			
			<wea:item><span name='mark'>记录人</span></wea:item>
			<wea:item>
				<%=getHrmHtml(recorder)%>
			</wea:item>
			
			<wea:item><span name='mark'>创建人</span></wea:item>
			<wea:item>
				<%=getHrmHtml(contacter)%>
			</wea:item>
			
			<wea:item><span name='mark'>参会人</span></wea:item>
			<wea:item>
				<%=getHrmHtml(hrmmembers)%>
			</wea:item>
			
			<wea:item><span name='mark'>外来人员</span></wea:item>
			<wea:item>
				<%=getOutHrmHtml(othermembers)%>
			</wea:item>
			
			<wea:item><span name='mark'>会议地点</span></wea:item>
			<wea:item>
				<%
					if(addressselect.equals("0")||"".equals(addressselect)){
						String getMeetingRoom = "select * from meetingroom where  id in ("+address+")";
						new weaver.general.BaseBean().writeLog(getMeetingRoom);
						RecordSet2.executeSql(getMeetingRoom);
						String meetingRoom = "";
						while (RecordSet2.next()){
							meetingRoom +=","+Util.null2String(RecordSet2.getString("name"));
						}

						if(!"".equals(meetingRoom))
						    meetingRoom=meetingRoom.substring(1);
				%>
						<%=meetingRoom%>
				<%	
					}else if(addressselect.equals("1")){
				%>
						<%=customizeAddress%>
				<%	
					}
				%>
				
				<!-- 
				//会议地点：
				 addressselect = Util.null2String(RecordSet.getString("addressselect"));
				 address = Util.null2String(RecordSet.getString("address"));
				 customizeAddress = Util.null2String(RecordSet.getString("customizeAddress"));
				 -->
			</wea:item>
				
			
			<wea:item><span name='mark'>会议要求</span></wea:item>
			<wea:item>
				<%=desc_n%>
			</wea:item>
			
			<wea:item><span name='mark'>会议成本</span></wea:item>
			<wea:item>
				<%=cost%>
			</wea:item>
			
			<wea:item><span name='mark'>会议通知抄送人</span></wea:item>
			<wea:item>
				<%=getHrmHtml(ccmeetingnotice)%>
			</wea:item>
			
			<wea:item><span name='mark'>会议纪要抄送人</span></wea:item>
			<wea:item>
				<%=getHrmHtml(ccmeetingminutes)%>
			</wea:item>
			
			<wea:item><span name='mark'>会议通知附件</span></wea:item>
			<wea:item>
			<%
				String getFileSql = "select t1.imagefilename,t1.docid,t1.imagefileid,t2.filesize from docimagefile t1,imagefile t2 where t1.docid in( "+accessorys+") and t2.imagefileid = t1.imagefileid";
				RecordSet2.executeSql(getFileSql);
				String fileDownHtml = "";
				while(RecordSet2.next()){
					String fileName = Util.null2String(RecordSet2.getString("imagefilename"));
					String docid = Util.null2String(RecordSet2.getString("docid"));
					String imagefileid = Util.null2String(RecordSet2.getString("imagefileid"));
					//kb
					Long filesize = Long.valueOf(Util.null2String(RecordSet2.getString("filesize")))/1000;
					fileDownHtml +="<div>";
					fileDownHtml +="	<span>"+fileName+"</span>";
					fileDownHtml +="	<SPAN id=selectDownload>";
					fileDownHtml +="		<BUTTON accessKey=1 class=e8_btn_cancel onclick=\"downloads('"+imagefileid+"')\" type=button > 下载 </BUTTON>"; 
					fileDownHtml +="	</SPAN>";
					fileDownHtml +="</div>";
					
				}
				
			 %>
				<%=fileDownHtml%>
				<!-- 
				<div>
					<span>10-1-60-soapui-project.xml</span>
					<SPAN id=selectDownload>
						<BUTTON accessKey=1 class=e8_btn_cancel onclick="downloads('2455162')" type=button ><U>1</U>-下载 (77K)</BUTTON> 
					</SPAN>
				</div>
				 -->
			</wea:item>
			
				
		</wea:group>
		
		
		<%if(isshow){%>
			<wea:group context="会议议程" attributes="{'class':\"e8_title e8_title_1\",'groupDisplay':'','itemAreaDisplay':''}">
				<wea:item>
				<div>			
					<TABLE class="ListStyle" cellspacing=1  cols=7 id="oTable">
						<COLGROUP>
							<!--<COL width="5%">-->
							<COL width="40%">
							<COL width="5%">
							<!--<COL width="10%">-->
							<COL width="15%">
							
							<COL width="10%">
							<COL width="10%">
							<COL width="10%">
							<COL width="10%">
						<TBODY>
						<TR class="HeaderForXtalbe" >
							<!--<Th>序号</Th>-->
							<Th>议题</Th>
							<Th>决议人</Th>
							<!-- <Th>公开</Th>-->
							<Th>决策点</Th>
							<Th>开始日期</Th>
							<Th>开始时间</Th>
							<Th>结束日期</Th>
							<Th>结束时间</Th>
						</TR>						
						<%
							//查询会议议程 t.xuhao,t.subject,t.jcd,t.isopen,t.hrmids,t.starttime,t.endtime
							String getTopicSql = "select * from meeting_topic where meetingid = "+meetingId+" order by xuhao,id";
							RecordSet2.executeSql(getTopicSql);
							String topicHtml = "";
							while(RecordSet2.next()){
								//议题
								String subject = Util.null2String(RecordSet2.getString("subject"));
								//序号
								String xuhao = Util.null2String(RecordSet2.getString("xuhao"));
								//决策人
								String hrmids = Util.null2String(RecordSet2.getString("hrmids"));
								//是否公开
								String isopen = Util.null2String(RecordSet2.getString("isopen"));
								//决策点
								String jcd = Util.null2String(RecordSet2.getString("jcd"));														
								//开始时间
								String startTime = Util.null2String(RecordSet2.getString("starttime"));
								//结束时间
								String endTime = Util.null2String(RecordSet2.getString("endtime"));
								//开始时间
								String tempStartDate = Util.null2String(RecordSet2.getString("startdate"));
								//结束时间
								String tempEndDate = Util.null2String(RecordSet2.getString("enddate"));
								
								topicHtml +="<TR class=\"DataDark\" >";
								/*
								topicHtml +="<td style=\"word-break:break-all;\" >"+xuhao+"</td>";
								*/
								topicHtml +="<td style=\"word-break:break-all;\" >"+subject+"</td>";
								topicHtml +="<td style=\"word-break:break-all;\" >"+getHrmHtml(hrmids)+"</td>";
								/*
								if(isopen.equals("1")){
									topicHtml +="<td style=\"word-break:break-all;\" >是</td>";
								}else{
									topicHtml +="<td style=\"word-break:break-all;\" >否</td>";
								}
								*/
								topicHtml +="<td style=\"word-break:break-all;\" >"+jcd+"</td>";
								
								topicHtml +="<td style=\"word-break:break-all;\" >"+tempStartDate+"</td>";
								topicHtml +="<td style=\"word-break:break-all;\" >"+startTime+"</td>";
								topicHtml +="<td style=\"word-break:break-all;\" >"+tempEndDate+"</td>";
								topicHtml +="<td style=\"word-break:break-all;\" >"+endTime+"</td>";								
								topicHtml +="</TR>";
							}
						%>
						<%=topicHtml%>
						
					</TABLE>
					<TABLE class="ListStyle" cellspacing=1  cols=7 id="oTable">
						<COLGROUP>
							<COL width="5%">
							<COL width="95%">
							
						<TBODY>
						<TR class="HeaderForXtalbe" >
							<!--<Th>序号</Th>-->
							<Th>附件</Th>
							
						</TR>						
						<%
							//查询会议议程附件 t.xuhao,t.fujian --改
							String getTopicSql1 = "select * from Meeting_Topic_attach where meetingid = "+meetingId+" order by xuhao";
							
							RecordSet2.executeSql(getTopicSql1);
							String topicHtml1 = "";
							while(RecordSet2.next()){
								//附件
								String fujian = Util.null2String(RecordSet2.getString("fujian"));								
								//序号
								String xuhao = Util.null2String(RecordSet2.getString("xuhao"));
								String attachDownHtml = "";
								if(!fujian.equals("")){
									//查询附件信息
									String getAttachSql = "select t1.imagefilename,t1.docid,t1.imagefileid,t2.filesize from docimagefile t1,imagefile t2 where t1.docid in( "+fujian+") and t2.imagefileid = t1.imagefileid";
									RecordSet.executeSql(getAttachSql);
									BaseBean.writeLog("getAttachSql(查询附件信息)"+getAttachSql);
									while(RecordSet.next()){
										String fileName = Util.null2String(RecordSet.getString("imagefilename"));
										String docid = Util.null2String(RecordSet.getString("docid"));
										String imagefileid = Util.null2String(RecordSet.getString("imagefileid"));
										
										String newStr = "";
										
										if(fujian111.contains(docid)){
											newStr = "<img align=\"absbottom\" src=\"/meeting/image/new.png\" style=\" margin-left: 15px;\" width=\"25px\" height=\"25px\" border=\"0\"/>";
										}
										//kb
										Long filesize = Long.valueOf(Util.null2String(RecordSet.getString("filesize")))/1000;
										attachDownHtml +="<div>";
										attachDownHtml +="	<span>"+fileName+ newStr + " </span>";
										attachDownHtml +="	<SPAN id=selectDownload>";
										attachDownHtml +="		<BUTTON accessKey=1 class=e8_btn_cancel onclick=\"downloads('"+imagefileid+"')\" type=button > 下载 </BUTTON>"; 
										attachDownHtml +="	</SPAN>";
										attachDownHtml +="</div>";
										
									}
								}
																
								topicHtml1 +="<TR class=\"DataDark\" >";
								topicHtml1 +="<td style=\"word-break:break-all;\" >"+xuhao+"</td>";
								topicHtml1 +="<td style=\"word-break:break-all;\" >"+attachDownHtml+"</td>";														
								topicHtml1 +="</TR>";
							}
							BaseBean.writeLog("topicHtml1:"+topicHtml1);
						%>
						<%=topicHtml1%>
						
					</TABLE>	
				</div>
				</wea:item>
			</wea:group>			
		<%}%>
		
	</wea:layout>
	<%
	//回执按钮涉及id
	//根据当前人员id和会议id查询出当前人员是否需要回执
	String getReceiptSql = "select * from Meeting_Member2 where meetingid = "+meetingId+" and memberid = "+userId;
	RecordSet2.executeSql(getReceiptSql);
	String receiptId = "";
	if(RecordSet2.next()){
		//回执记录id
		receiptId = Util.null2String(RecordSet2.getString("id"));						
	}
	//判断会议是否已经结束（会议决议是否填写）结束后不显示回执
	//判断条件 1.	会议时间结束 2.	会议状态结束	
	
	//查询会议结束时间和会议状态
	String getMeetingSql = "select mt.isdecision,mt.enddate,mt.endtime,mt.meetingstatus from meeting mt where id = "+meetingId;
	BaseBean.writeLog("getMeetingSql:"+getMeetingSql);	

	RecordSet2.executeSql(getMeetingSql);
	String isdecision = "";
	String endDate = "";
	String meetingStatus = "";
	if(RecordSet2.next()){
		//会议决议状态 1 保存 2提交
		isdecision = Util.null2String(RecordSet2.getString("isdecision"));		
		//会议状态
		meetingStatus = Util.null2String(RecordSet2.getString("meetingstatus"));	
		//会议结束时间
		endDate = Util.null2String(RecordSet2.getString("enddate"))+" "+Util.null2String(RecordSet2.getString("endtime"));
	}
	
	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");;//设置日期格式
	Date nowDate = new Date();
	//会议结束时间
	Date endTime = new Date();
	try {           
		endTime = df.parse(endDate);			
	} catch (Exception exception) {
		exception.printStackTrace();
	}
	
	BaseBean.writeLog("isdecision(会议决议状态 1 保存 2提交)"+!isdecision.equals("2")+":"+isdecision);
	BaseBean.writeLog("receiptId:"+!receiptId.equals("")+":"+receiptId);
	BaseBean.writeLog("meetingStatus(会议状态 2正常)"+meetingStatus.equals("2")+":"+meetingStatus);
	BaseBean.writeLog("endDate(会议结束时间)"+endDate+":"+endTime);
	BaseBean.writeLog("nowDate(现在时间)"+nowDate);
	if(!receiptId.equals("")&& !isdecision.equals("2") && meetingStatus.equals("2") && (endTime.getTime() > nowDate.getTime())){
	%>
	
	<div style="text-align: center;width: 100%">
		<button class="e8_btn_cancel" style="padding-left: 3px !important; width: 60px; padding-right: 3px !important; background:#2690E3;color:#FFFFFF " onclick="onShowReHrm(<%=receiptId %>,<%=meetingId %>,'<%=hrmmembers %>')" type="button">
		回执
		</button>
	</div>
	
	<%
	}
	
	BaseBean.writeLog("==============MeetingBaseInfo.jsp.jsp end=============");	
	%>
	
	
	<!--浮动显示div -->
	<!-- 这里改了z-index(+2),因为UE编辑器会遮住弹窗 123-->
<div id="mainsupports" style="z-index:1999;background-color:#e4e4e4;display:none;position:absolute">
	<table width="455px" height="293px" border="0" align="center" style="vertical-align: middle;" cellpadding="0" cellspacing="0">
		<tr>
			<td width="198px" valign="top" height="293px">
				<a id='resourceimghref' href="javascript:void(0);" onclick="return getImageResult(this);" onFocus="this.blur()"><img id='resourceimg' src="/images/messageimages/temp/loading_wev8.gif" border=0 width="100%" height="100%" onError="initSrc()"></a>
				<div style="position:absolute;top: 243px;background-image:url('/images/messageimages/temp/divbg_wev8.png');">
					<table style="width: 198px;height: 50px;text-align: center;vertical-align: middle;">
						<tr>
							<td><img src="/images/messageimages/temp/msn_wev8.png" onmouseover="javascript:this.src='/images/messageimages/temp/msnhot_wev8.png';" onmouseout="javascript:this.src='/images/messageimages/temp/msn_wev8.png';" onclick="javascript:openmessage();" title="<%=SystemEnv.getHtmlLabelName(16635,user.getLanguage())%>"></td>
							<td><img src="/images/messageimages/temp/email_wev8.png" onmouseover="javascript:this.src='/images/messageimages/temp/emailhot_wev8.png';" onmouseout="javascript:this.src='/images/messageimages/temp/email_wev8.png';" onclick="javascript:openemail();" title="<%=SystemEnv.getHtmlLabelName(2051,user.getLanguage())%>"></td>
							<td><img src="/images/messageimages/temp/workplan_wev8.png" onmouseover="javascript:this.src='/images/messageimages/temp/workplanhot_wev8.png';" onmouseout="javascript:this.src='/images/messageimages/temp/workplan_wev8.png';" onclick="javascript:doAddWorkPlan();" title="<%=SystemEnv.getHtmlLabelName(18481,user.getLanguage())%>"></td>
							<td><img src="/images/messageimages/temp/cowork_wev8.png" onmouseover="javascript:this.src='/images/messageimages/temp/coworkhot_wev8.png';" onmouseout="javascript:this.src='/images/messageimages/temp/cowork_wev8.png';" onclick="javascript:doAddCoWork();" title="<%=SystemEnv.getHtmlLabelName(18034,user.getLanguage())%>"></td>
						</tr>
					</table>
				</div>
			</td>
			<td valign="top">
				<div style="position:absolute;top: -17px;left: 438px">
					<img id="closetext" style="cursor: hand;"src="/images/messageimages/temp/closeicno_wev8.png" onclick="javascript:closediv();"/>
				</div>
				<div id="showSQRCodeDiv" style="text-align: left;position:absolute;top: -20px;left: 350px; " onclick="createQCode()"></div>	
				<table width="257px" height="293px" border="0" style="padding-left: 16px;padding-top: 0px" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
					<tr height="40px">
						<td>
							<div>
								<img id="isonline" src="/images/messageimages/temp/online_wev8.png" width="19" height="19" style="vertical-align:top;">&nbsp;<span class="STYLE4" id="result1"></span>&nbsp;<span class="STYLE6" id="result2"></span> &nbsp;<span class="STYLE6" id="result13"></span>&nbsp;&nbsp;&nbsp;&nbsp;
								<img src="/images/messageimages/temp/qcode_wev8.png" width="19" height="19" style="vertical-align:middle;cursor: hand;" onclick="createQCode()">
							</div>
						</td>
					</tr>
					<tr style="height:1px!important;" class="Spacing">
						<td><div class="intervalDivClass"></div></td>
					</tr>
					<tr style="height:4px!important;">
						<td></td>
					</tr>
					<tr>
						<td>
							<table height="203px">
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(18939,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result6"></span>
									</td>
								</tr>
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(141,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result9"></span>
									</td>
								</tr>
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(6086,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result10"></span>
									</td>
								</tr>
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(596,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result7"></span>
									</td>
								</tr>
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(602,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result11"></span>
									</td>
								</tr>
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(422,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result3"></span>
									</td>
								</tr>
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(421,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result4"></span>
									</td>
								</tr>
								<tr>
									<td style="WORD-WRAP: break-word;TEXT-VALIGN: left;word-break:break-all;">
										<span class="STYLE6"><%=SystemEnv.getHtmlLabelName(71,user.getLanguage())%>&nbsp;:&nbsp;&nbsp;&nbsp;</span>
										<span class="STYLE61" id="result5"></span>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr height="42px">
						<td align="right" valign="middle" style="padding-right: 12px">
							<span class="STYLE6" id="result0"></span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>
	
	
	<%-- 
	<jsp:include page="/hrm/resource/simpleHrm.jsp"></jsp:include>
	//D:\Runtime_Environment\ecology8\Resin_yili_20161123\webapps\ecology\hrm\resource\simpleHrmResource_wev8.jsp 
	//D:\Runtime_Environment\ecology8\Resin_yili_20161123\webapps\ecology\workflow\design\simpleHrm.jsp
	 --%>
<script language="javascript">
//为显示人员div
var languageid = '<%=c_user.getLanguage()%>'
	
$(document).ready(function(){
	debugger;
	//改变css样式，字体改为14px，加粗
	//$("td.fieldName").css("font-weight","bold");
	//$("td.fieldName").css("font-size","14px");
	$("span[name='mark']").css("font-weight","bold");
	$("span[name='mark']").css("font-size","14px");
		
	$("span.e8_grouptitle").css("font-size","14px");
	$("span.e8_grouptitle").css("font-weight","bold");
	$("span.e8_grouptitle").css("color","#000000");
});

//回执调用方法
function onShowReHrm(recorderid,meetingid,hrmmembers){
	//showDialog("/meeting/data/MeetingReHrm.jsp?recorderid="+recorderid+"&meetingid="+meetingid,"会议参与回执", 400, 450);
	showDialog("/meeting/data/MeetingOthTab.jsp?toflag=newReHrm&recorderid="+recorderid+"&meetingid="+meetingid+"&hrmmembers="+hrmmembers,"<%=SystemEnv.getHtmlLabelName(2103, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(430, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(2108, user.getLanguage())%>", 600, 500);
	//showDialog("/meeting/data/MeetingOthTab.jsp?toflag=ReHrm&recorderid="+recorderid+"&meetingid="+meetingid,"<%=SystemEnv.getHtmlLabelName(2103, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(430, user.getLanguage())+(user.getLanguage()==8?" ":"")+SystemEnv.getHtmlLabelName(2108, user.getLanguage())%>", 600, 500);
}

function showDialog(url, title, w,h){
	if(window.top.Dialog){
		diag_vote = new window.top.Dialog();
	} else {
		diag_vote = new Dialog();
	}
	diag_vote.currentWindow = window;
	diag_vote.Width = w;
	diag_vote.Height = h;
	diag_vote.Modal = true;
	diag_vote.Title = title;
	diag_vote.URL = url;
	diag_vote.show();
}	

function downloads(files)
{
	document.location.href="/weaver/weaver.file.FileDownload?fileid="+files+"&download=1&meetingid=<%=meetingId%>";
}

function showOutHrmInfoById(hrmId) {
	//alert(hrmId);
	if(hrmId){
		var url = "/weavernorth/meeting/ShowOutHumInfo.jsp?1=1&outHrmId="+hrmId;	
		//openDialog("外来人员信息",url);
		var dlg=new window.top.Dialog();//定义Dialog对象
	    dlg.currentWindow = window;
		dlg.Model=true;
		dlg.Width=450;
		dlg.Height=100;
		dlg.URL=url;
		dlg.Title="外来人员信息";
		dlg.show();
	}
	
}
</script>
</body>
</html>