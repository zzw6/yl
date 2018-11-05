<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/page/maint/common/initNoCache.jsp" %>
<%@ page import="weaver.general.*"%>
<jsp:useBean id="RequestComInfo" class="weaver.workflow.request.RequestComInfo" scope="page" />
<jsp:useBean id="DocComInfo" class="weaver.docs.docs.DocComInfo" scope="page" />
<jsp:useBean id="CustomerInfoComInfo" class="weaver.crm.Maint.CustomerInfoComInfo" scope="page" />
<jsp:useBean id="cmutil" class="weaver.workrelate.util.CommonTransUtil" scope="page"/>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rs1" class="weaver.conn.RecordSet" scope="page" />
<%
	//System.out.println("===========================add.jsp=============================");
	String taskId = Util.null2String(request.getParameter("taskId"));
	boolean canedit = true;
    String currentdate = TimeUtil.getCurrentDateString();
	String name = "";
	String level = "";
	String remark = Util.convertDbInput(request.getParameter("remark"));
	String risk = Util.convertDbInput(request.getParameter("risk"));
	String difficulty = Util.convertDbInput(request.getParameter("difficulty"));
	String assist = Util.convertDbInput(request.getParameter("assist"));
	String tag = Util.toScreen(request.getParameter("tag"),user.getLanguage());
	String principalid = Util.null2String(request.getParameter("principalid"));
	if(principalid.equals("")) principalid = user.getUID()+"";
	String begindate = Util.null2String(request.getParameter("begindate"));
	String enddate = Util.null2String(request.getParameter("enddate"));
	String taskids = Util.null2String(request.getParameter("taskids"));
	String goalids = Util.null2String(request.getParameter("goalids"));
	String docids = Util.null2String(request.getParameter("docids"));
	String wfids = Util.null2String(request.getParameter("requestids"));
	String meetingids = Util.null2String(request.getParameter("meetingids"));
	String crmids = Util.null2String(request.getParameter("crmids"));
	String projectids = Util.null2String(request.getParameter("projectids"));
	String fileids = Util.null2String(request.getParameter("fileids"));
	String parentid = Util.null2String(request.getParameter("parentid"));
	String parentname = Util.null2String(request.getParameter("pName"));
	if(!parentid.equals("")){ 
		rs.executeSql("select id,name,principalid,status from TM_TaskInfo where (deleted=0 or deleted is null) and id="+parentid);
		if(rs.next()){
			parentname = Util.null2String(rs.getString("name"));
		}
	}
	String tododate = Util.null2String(request.getParameter("tododate"));
	String todo = "4";
	
	boolean showgoal = weaver.workrelate.util.TransUtil.isgoal();
//00100577 
	// Modify by wh 2015年9月29日 月报计划转督办任务 start-->
    String name_wh = Util.null2String(request.getParameter("name_wh"));
	if(!"".equals(name_wh)){
	   name_wh = java.net.URLDecoder.decode(name_wh,"UTF-8");
	}
	String startdate_wh = Util.null2String(request.getParameter("startdate_wh")).trim();
	String enddate_wh = Util.null2String(request.getParameter("enddate_wh")).trim();
	String result_wh = Util.null2String(request.getParameter("result_wh"));
    if(!"".equals(result_wh)){
	   result_wh = java.net.URLDecoder.decode(result_wh,"UTF-8");
	   result_wh = result_wh.replace("\n","");
	   result_wh = result_wh.replace("\t","");
	   result_wh = result_wh.replace("\r","");
       remark = result_wh.trim();
	}

	// Modify by wh 2015年9月29日 月报计划转督办任务 end-->

	//lq 会议转任务
	String decisionid = Util.null2String(request.getParameter("decisionid"));
	String decisionStartDate = "";
	String decisionEndDate = "";
	String decisionStartTime = "";
	String decisionEndTime= "";
	String decisionhrmid1= "";	//执行人 对应任务 参与人
	String decisionhrmid2= "";	//检查人 对应任务 负责人
	String meetingId= "";
	String decisionTitle = "";
	String tasktype = "1";//任务类型 1:领导交办  2:会议转办  3:重点工作  4:流程转办  5:邮件转办  
	//会议批量转任务   by lq 2015-10-23 start
	String isManyPeople = "0"; //责任人是否为多人
	String meetingName = ""; //会议名称
	String operation = "add"; //请求执行操作
	//会议批量转任务   by lq 2015-10-23 end
	//议程id是否为空
	if(!"".equals(decisionid)){
		
		String decSql = "select md.id,md.meetingid,md.coding,md.subject,md.hrmid01,md.hrmid02,md.begindate,md.begintime,md.enddate "+
						",md.endtime,mt.name from Meeting_Decision md,meeting mt  where mt.id = md.meetingid and md.id ="+decisionid;
		rs.executeSql(decSql);
		if(rs.next()){
			 decisionStartDate = Util.null2String(rs.getString("begindate"));
			 decisionEndDate = Util.null2String(rs.getString("enddate"));
			 decisionStartTime = Util.null2String(rs.getString("begintime"));
			 decisionEndTime= Util.null2String(rs.getString("endtime"));
			 decisionhrmid1= Util.null2String(rs.getString("hrmid01"));
			 decisionhrmid2= Util.null2String(rs.getString("hrmid02"));
			 meetingId= Util.null2String(rs.getString("meetingid"));
			 decisionTitle = Util.null2String(rs.getString("subject"));
			 meetingName = Util.null2String(rs.getString("name"));
			 
			 //会议批量转任务   by lq 2015-10-23 start
			 
			 //判断责任人是否为多人
			 if(decisionhrmid2.indexOf(",")>0){
				//多选 单选 按钮控制
				isManyPeople = "1";
				//设置保存操作
				operation = "adds";
				//当责任人为多人时 参与人清空
				decisionhrmid1="";
			 }
			 
			 //任务标题为 ：会议名称 + 决议标题 
			 if(!meetingName.equals("")){				
				decisionTitle = meetingName + "_" +decisionTitle;
			 }
			 
			 //会议批量转任务    by lq 2015-10-23 end
			 tasktype = "2";
		}
		
		//负责人赋值
		if(!decisionhrmid2.equals("")){
			principalid = decisionhrmid2;
		}
		
	}
	
	if(!wfids.equals("")){
		name = RequestComInfo.getRequestname(wfids);
		if(!wfids.startsWith(",")) wfids = "," + wfids;
		if(!wfids.endsWith(",")) wfids += ",";
	}else if(!docids.equals("")){
		name = DocComInfo.getDocname(docids);
		if(!docids.startsWith(",")) docids = "," + docids;
		if(!docids.endsWith(",")) docids += ",";
	}else if(!crmids.equals("")){
		name = CustomerInfoComInfo.getCustomerInfoname(crmids);
		if(!crmids.startsWith(",")) crmids = "," + crmids;
		if(!crmids.endsWith(",")) crmids += ",";
	}else if(!decisionTitle.equals("")){
		//lq 任务名称复制为决议标题
		name = decisionTitle;
	}
	//zhw 2013-07-29 saveType:0原有的新增功能,1:从门户任务元素的创建,2:任务界面点击标题新建
	int saveType = Util.getIntValue(request.getParameter("saveType"),0);
	String sorttype = Util.fromScreen3(request.getParameter("sorttype"), user.getLanguage());
	String datetype = Util.fromScreen3(request.getParameter("datetype"), user.getLanguage());
	if(sorttype.equals("5")&&!datetype.equals("")){
		todo = datetype;
	}
	String currentDate = TimeUtil.getCurrentDateString();
	String yesterday = TimeUtil.dateAdd(currentDate,-1);
	String tomorrow = TimeUtil.dateAdd(currentDate,1);
	if(sorttype.equals("2")){
		if(datetype.equals("1")){
			enddate = yesterday;
		}else if(datetype.equals("2")){
			enddate = currentDate;
		}else if(datetype.equals("3")){
			enddate = tomorrow;
		}else if(datetype.equals("4")){
			enddate = TimeUtil.dateAdd(tomorrow,1);
		}else if(datetype.equals("5")){
			enddate = "";
		}else if(!decisionid.equals("")){
			
			//开始结束日期赋值
			begindate = decisionStartDate;
			currentdate = decisionStartDate;
			enddate = decisionEndDate;
		}
	}
	if(sorttype.equals("3")){
		level = datetype;
	}
	if(level.equals("5")) level="0";

// Modify by wh 2015年9月29日 月报计划转督办任务,日期赋值 start-->
    if(!"".equals(startdate_wh)){
	   currentdate = startdate_wh;
	}
	if(!"".equals(enddate_wh)){
	   enddate = enddate_wh;
	}
	if(!"".equals(name_wh)){
	   tasktype = "3";//重点工作
	}
	
// Modify by wh 2015年9月29日 月报计划转督办任务,日期赋值 start-->	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>新建任务</title>
		<link rel="stylesheet" href="/workrelate/css/ui/jquery.ui.all.css" />
		<link rel="stylesheet" href="../css/main.css" />
		<script language="javascript" src="/workrelate/js/jquery-1.8.3.min.js"></script>
		<script language="javascript" src="../js/jquery.fuzzyquery.min.js"></script>
		<script type="text/javascript" src="/wui/common/jquery/plugin/jquery.overlabel_wev8.js"></script>
		<script src="/workrelate/js/jquery.ui.core.js"></script>
		<script src="/workrelate/js/jquery.ui.widget.js"></script>
		<script src="/workrelate/js/jquery.ui.datepicker.js"></script>
		<script src="/workrelate/js/jquery.textarea.autoheight.js"></script>
		<script src="/workrelate/js/util.js"></script>
		<script language="javascript" src="/js/init_wev8.js"></script>
		<link rel="stylesheet" href="/workrelate/css/perfect-scrollbar.css" rel="stylesheet" />
      	<script language="javascript" src="/workrelate/js/jquery.mousewheel.js"></script>
      	<script language="javascript" src="/workrelate/js/perfect-scrollbar.js"></script>
		<style type="text/css">
			.addtitle{width:auto;line-height:40px;float: left;
				margin-left: 10px;font-weight: bold;font-size: 14px;
			}
			.btn_operate_add{margin-top:10px;margin-right: 5px;width:90px;
						text-align: center;line-height: 18px;cursor: pointer;float: left;
						color:#808080;margin-left: 3px;margin-bottom: 0px;
						border: 1px #D2D2D2 solid;}
			.btn_hover_add{
				background:#eee;
			}			
			<%if(saveType==1){ %>
				.addtitle{
					color:#fff;
				}
				.btn_operate_add{
					color:#fff;border:1px solid #fff;
				}
				.btn_hover_add{
					background:#2d71bd;
				}
			<%}%>
			.operatepanel{width: auto;height: 40px;float: right;margin-right: 5px;}
			*{font-family: 'Microsoft YaHei'}
			.input_def{overflow: hidden;resize:none;word-break:break-all;}
			.input_def{word-wrap:break-word;word-break:break-all;width: 90%;height:23px;line-height: 23px;border: 1px #fff solid;padding-left: 0px;border-radius: 0px;-moz-border-radius: 0px;-webkit-border-radius: 0px;}
			.input_over{border:0px;border-bottom: 1px #F0F0F0 solid;background: none;}
			.input_focus{border:0px;border-bottom: 1px #1A8CFF solid;background: none;box-shadow:0px 0px 0px #1A8CFF;-moz-box-shadow:0px 0px 0px #1A8CFF;-webkit-box-shadow:0px 0px 0px #1A8CFF;}
			
			.content_def{width: 90%;min-height:0px;height:24px;line-height: 24px;resize:none;overflow: hidden;word-break:break-all;background: none;
				border:0px;border-bottom: 1px #fff solid;padding: 0px;padding-left: 0px;border-radius: 0px;-moz-border-radius: 0px;-webkit-border-radius: 0px;text-align: left;}
			.content_def p{padding: 0px;margin: 0px;}
			.content_over{border:0px;border-bottom: 1px #fff solid;background: none;}
			.content_focus{border:0px;border-bottom: 1px #1A8CFF solid;background: none;box-shadow:0px 0px 0px #1A8CFF;-moz-box-shadow:0px 0px 0px #1A8CFF;-webkit-box-shadow:0px 0px 0px #1A8CFF;}
			.btn_cancel{
				width: 16px; 
				height: 16px; 
				margin-top:12px;
				margin-bottom: 0px; 
				margin-left:10px; 
				float: right; 
				position: relative; 
				cursor: pointer; 
				background-image: url("../images/16_close.png");
			}
		</style>
		<!--[if IE]> 
		<style type="text/css">
			.input_def{line-height: 180% !important;}
		</style>
		<![endif]-->
	<%@ include file="/secondwev/common/head.jsp" %>
	</head>
	<body>
		<form id="form1" name="form1" action="Operation.jsp" method="post">
		<!--会议批量转任务  提交操作赋值   by lq 2015-10-23 -->
		<input type="hidden" id="operation" name="operation" value="<%=operation%>"/>
		<input type="hidden" id="sorttype" name="sorttype" value="5"/>
		<input type="hidden" id="relateadd" name="relateadd" value="1"/>
		<input type="hidden" id="datetype" name="datetype" value=""/>
		<input type="hidden" id="saveType" name="saveType" value="0"/>
		<input type="hidden" id="lev" name="lev" value="<%=level %>"/>
		<input type="hidden" id="tasktype" name="tasktype" value="<%=tasktype %>"/>		
		<div id="main" style="width: 100%;height: 100%">
		<div id="rightinfo" style="width: 100%;height: 100%;position: relative;">
			<div style="width: 100%;height: 40px;position: relative;overflow:hidden;
				<%if(saveType==1){ %>background:#4f81bd !important;<%}else{ %>background:#fcfcfc !important;<%} %>
			">
				<div class="addtitle">
					新建任务
				</div>
				<div id="operatepanel" class="operatepanel">
					<%if(saveType==0||saveType==100||saveType==200){%>
						<div class="btn_operate_add" onclick="doSubmit(<%=saveType %>)">提交</div>
						<div class="btn_operate_add" onclick="dialog.closeByHand();">关闭</div>
					<%}else if(saveType==1){ %>
						<div class="btn_operate_add" onclick="doSubmit(1)">提交</div>
						<div class="btn_operate_add" onclick="doSubmit(2)">保存并新建</div>
						<div class="btn_operate_add" onclick="doSubmit(3)">保存并完善详情</div>
					<%}else if(saveType==2){ %>
						<div class="btn_operate_add" onclick="doSubmit(4)">提交</div>
						<%if("".equals(decisionid)){%>
						<div class="btn_operate_add" onclick="doSubmit(5)">保存并新建</div>
						<%}%>
					<%}%>
					<%if(saveType==1){ %>
					<div class="btn_cancel" onclick="doCancel()" title="点击关闭"></div>
					<%} %>
				</div>
			</div>
			<div id="maininfo" style="width:100%;height:600px;border-top:1px #E8E8E8 solid;position: relative;overflow: hidden;" class="scroll1" align="center">
				<div id="dtitle0" class="dtitle" title="点击收缩"><div class="dtxt">基本信息</div></div>
				<div style="min-height:230px">
				<table class="datatable contenttable" cellpadding="0" cellspacing="0" border="0" align="center">
					<colgroup><col width="20%" /><col width="80%" /></colgroup>
					<tbody>		
						<tr>
							<td class="title">名称</td>
							<td class="data">
								<!-- Modify by wh 2015年9月29日 月报计划转督办任务 加入if判断 start-->
						  		<input type="text" class="input_def" id="taskName" name="taskName" style="font-weight: bold;font-size: 16px;" <%if(!"".equals(name_wh)){%>value="<%=name_wh%>" <%}else{%>  value="<%=name %>" <%}%>/>
                                <!-- Modify by wh 2015年9月29日 月报计划转督办任务 end-->
						  	</td>
						</tr>
						<!-- 
						<tr>
							<td class="title">标记todo</td>
							<td id="todo_td" class="data" style="padding-top: 2px;padding-left: 5px;">
							  	<a id="todo1" class="slink <%if("1".equals(todo)){%>sdlink<%}%>" href="javascript:setTodo(1)">今天</a>
							  	<a id="todo2" class="slink <%if("2".equals(todo)){%>sdlink<%}%>" href="javascript:setTodo(2)">明天</a>
							  	<a id="todo3" class="slink <%if("3".equals(todo)){%>sdlink<%}%>" href="javascript:setTodo(3)">即将</a>
							  	<a id="todo4" class="slink <%if("4".equals(todo)){%>sdlink<%}%>" href="javascript:setTodo(4)">不标记</a>
							  	<a id="todo5" class="slink <%if("5".equals(todo)){%>sdlink<%}%>" href="javascript:setTodo(5)">备注</a>
						  		
						  	</td>
						</tr>
						 -->
						 <input type="hidden" id="todo" name="todo" value="<%=todo %>"/>
				  		<tr>
							<td class="title">上级任务</td>
							<td class="data">
								<input type="hidden" id="parentid_val" name="parentid" value="<%=parentid %>"/>
						  		<input id="parentid" class="add_input" _init="1" _searchwidth="150" _searchtype="ptask"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_parentid" onClick="onShowParentid('<%=taskId %>')"></div>
						  	</td>
						</tr>
						<tr>
						  	<td class="title">描述</td>
						  	<td class="data">
						  		<textarea class="content_def" id="remark" name="remark" style="">
								<%=remark%>
								</textarea>
								<script>
								document.getElementById("remark").value="<%=remark%>";
								</script>
						  	</td>
						</tr>
						<tr>
							<td class="title">责任人</td>
							<td class="data">
								<input type="hidden" id="principalid_val" name="principalid" value="<%=principalid %>"/>
								<div class="txtlink showcon txtlink<%=principalid %>" onmouseover="showdel(this)" onmouseout="hidedel(this)">
									<%if(!principalid.equals("0") && !principalid.equals("")){ %>
									<div style="float: left;"><%=cmutil.getHrm(principalid) %></div>
									<%} %>
								</div>
						  		<input id="principalid" class="add_input" _init="1" _searchwidth="80" _searchtype="hrm"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_hrm" onClick="onShowHrm('principalid')"></div>
						  	</td>
						</tr>
						<tr>
							<td class="title">参与人</td>
							<td class="data">
								<span id = "divtest">
								<%
									//参与人赋值
									if(!decisionhrmid1.equals("0") &&!decisionhrmid1.equals("")){
										principalid = decisionhrmid1;
										String idArray[] = decisionhrmid1.split(",");
										for(int i=0 ;i<idArray.length;i++){
											String tempid = idArray[i];
											if(!"".equals(tempid)){
											%>
											<div class="txtlink showcon txtlink<%=tempid %>" onmouseover="showdel(this)" onmouseout="hidedel(this)">
												
												<div style="float: left;"><%=cmutil.getHrm(tempid) %></div>
												
											</div>
											<%
											}
										}		
									%>
									</span >
						  		<input id="partnerid" class="add_input" _init="1" _searchwidth="80" _searchtype="hrm"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_hrm" onclick="onShowHrms('partnerid')"></div>
									<input type="hidden" id="partnerid_val" name="partnerid" value="<%=","+decisionhrmid1+","%>"/>
								<%}else{%>
									<input id="partnerid" class="add_input" _init="1" _searchwidth="102" _searchtype="hrm"/>
									<div class="btn_add"></div>
									<div class="btn_browser browser_hrm" onclick="onShowHrms('partnerid')"></div>
						  		<input type="hidden" id="partnerid_val" name="partnerid" value=","/>
								<%}%>
						  	</td>
						</tr>
						<tr>
							<td class="title">时间是否生效</TD>
							<td style="width: 100px;">
							<select class=inputstyle id = "timestatus" name=timestatus size=1>
								<option value="1">是</option>
								<option value="0" selected>否</option>
							</select>
							</td>
						</tr>
						<tr >
							<td class="title">计划开始日期</TD>
							<td class="data">
							<%
							if(!"".equals(remark)){
								String sql = "SELECT * FROM Meeting WHERE id = '"+meetingId+"'";
								rs1.execute(sql);
								if(rs1.next()){
									currentdate = rs1.getString("decisiondate");
								}
							}
							%>
									<input type="text" readonly="readonly" class="input_def " style="width: 100px;" id="begindate" name="begindate" 
									 value="<%=currentdate %>"  size="30" _defhide="1"/>
							</td>
						</tr>
						<tr>
							<td class="title">计划结束日期</td>
							<td class="data">
								<input type="text" readonly="readonly" class="input_def" style="width: 100px;" id="enddate" name="enddate" value="<%=enddate %>"  size="30"/>
							</td>
						</tr>
						<tr  >
							<!-- <td class="title" >是否限时完成</TD>
							<td class="data">
								<select class=inputstyle name=islimit size=1>
								<option value="1" selected>是</option>
								<option value="0">否</option>
							</select>
							</td> -->
						</tr>
						<tr id = "limitdatetr" >
							<td class="title">排期反馈日期</TD>
							<td class="data">
								<input type="text" readonly="readonly" class="input_def " style="width: 100px;" id="limitdate" name="limitdate" value="" size="30" _defhide="1"/>
							</td>
						</tr>
						<tr id = "resultfbdatetr" >
							<td class="title">结果反馈日期</TD>
							<td class="data">
								<input type="text" readonly="readonly" class="input_def " style="width: 100px;" id="resultfbdate" name="resultfbdate" value="" size="30" _defhide="1"/>
							</td>
						</tr>
						<tr id="reltrtag" _type="tag">
							<td class="title">任务标签</TD>
							<td class="data">
								<%if(!tag.equals("")){%>
								<div class="txtlink txtlink<%=tag %>" onmouseover="showdel(this)" onmouseout="hidedel(this)">
									<div style="float: left;"><%=tag %></div>
									<div class="btn_del" onclick="delItem('tag','<%=tag %>')"></div>
									<div class="btn_wh"></div>
								</div>
								<%
									tag = ","+tag+",";
								}else{
									tag = ",";
								}
								%>
						  		<input id="tag" class="add_input" _init="1" _searchwidth="102" _searchtype="tag"/>
						  		<div class="btn_add"></div>
						  		<input type="hidden" id="tag_val" name="tag" value="<%=tag %>"/>
						  	</td>
						</tr>
						<tr>
							<td class="title">分享给</TD>
							<td class="data">
						  		<input id="sharerid" class="add_input" _init="1" _searchwidth="102" _searchtype="hrm"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_hrm" onClick="onShowHrms('sharerid')"></div>
						  		<input type="hidden" id="sharerid_val" name="sharerid" value=","/>
						  	</td>
						</tr>
						<tr>
						  	<td class="title">风险点</TD>
						  	<td class="data">
						  		<textarea class="content_def" id="risk" name="risk" style=""></textarea>
						  	</td>
						</tr>
						<tr>
						  	<td class="title">难度点</TD>
						  	<td class="data">
						  		<textarea class="content_def" id="difficulty" name="difficulty" style=""></textarea>
						  	</td>
						</tr>
						<tr>
						  	<td class="title">需协助点</TD>
						  	<td class="data">
						  		<textarea class="content_def" id="assist" name="assist" style=""></textarea>
						  	</td>
						</tr>
					</tbody>
		  		</table>
		  		</div>
		  		<div <%if(saveType==1 || !"".equals(decisionid)) {%>style="display:none;"<%} %>>
		  		<div id="dtitle1" class="dtitle" title="点击收缩"><div class="dtxt">相关信息</div></div>
		  		<div style="min-height:230px;">
		  		<table id="relateTable"  class="datatable contenttable" cellpadding="0" cellspacing="0" border="0" align="center">
					<colgroup><col width="20%"/><col width="80%"/></colgroup>
					<tbody>
						<tr>
							<td class="title">相关任务</td>
							<td class="data">
						  		<input id="taskids" class="add_input" _init="1" _searchwidth="160" _searchtype="task"/>
						  		<div class="btn_add"></div>
						  		<input type="hidden" id="taskids_val" name="taskids" value=","/>
						  	</td>
						</tr>
						
						<%if(showgoal){ %>
						<tr>
							<td class="title">相关目标</td>
							<td class="data">
						  		<input id="goalids" class="add_input" _init="1" _searchwidth="160" _searchtype="goal"/>
						  		<div class="btn_add"></div>
						  		<input type="hidden" id="goalids_val" name="goalids" value=","/>
						  	</td>
						</tr>
						<%} %>
						
						<tr>
							<td class="title">相关文档</td>
							<td class="data">
								<%
									List docidList = Util.TokenizerString(docids,",");
									if(docids.equals("")) docids = ",";
									for(int i=0;i<docidList.size();i++){
										if(!"0".equals(docidList.get(i)) && !"".equals(docidList.get(i))){
								%>
								<div class="txtlink txtlink<%=docidList.get(i) %>" onmouseover="showdel(this)" onmouseout="hidedel(this)">
									<div style="float: left;"><%=cmutil.getDocName((String)docidList.get(i)) %></div>
									<%if(canedit){ %>
									<div class="btn_del" onclick="delItem('docids','<%=docidList.get(i) %>')"></div>
									<div class="btn_wh"></div>
									<%} %>
								</div>
								<% 		} 
									}
								%>
						  		<input id="docids" class="add_input" _init="1" _searchwidth="160" _searchtype="doc"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_doc" onclick="onShowDoc('docids')"></div>
						  		<input type="hidden" id="docids_val" name="docids" value="<%=docids %>"/>
						  	</td>
						</tr>
						<tr>
							<td class="title">相关流程</td>
							<td class="data">
								<%
									List wfidList = Util.TokenizerString(wfids,",");
									if(wfids.equals("")) wfids = ",";
									for(int i=0;i<wfidList.size();i++){
										if(!"0".equals(wfidList.get(i)) && !"".equals(wfidList.get(i))){
								%>
								<div class="txtlink txtlink<%=wfidList.get(i) %>" onmouseover="showdel(this)" onmouseout="hidedel(this)">
									<div style="float: left;"><%=cmutil.getRequestName((String)wfidList.get(i)) %></div>
									<%if(canedit){ %>
									<div class="btn_del" onclick="delItem('wfids','<%=wfidList.get(i) %>')"></div>
									<div class="btn_wh"></div>
									<%} %>
								</div>
								<% 		} 
									}
								%>
						  		<input id="wfids" class="add_input" _init="1" _searchwidth="160" _searchtype="wf"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_wf" onclick="onShowWF('wfids')"></div>
						  		<input type="hidden" id="wfids_val" name="wfids" value="<%=wfids %>"/>
						  	</td>
						</tr>
						<tr>
							<td class="title">相关客户</td>
							<td class="data">
								<%
									List crmidList = Util.TokenizerString(crmids,",");
									if(crmids.equals("")) crmids = ",";
									for(int i=0;i<crmidList.size();i++){
										if(!"0".equals(crmidList.get(i)) && !"".equals(crmidList.get(i))){
								%>
								<div class="txtlink txtlink<%=crmidList.get(i) %>" onmouseover="showdel(this)" onmouseout="hidedel(this)">
									<div style="float: left;"><%=cmutil.getCustomer((String)crmidList.get(i)) %></div>
									<%if(canedit){ %>
									<div class="btn_del" onclick="delItem('crmids','<%=crmidList.get(i) %>')"></div>
									<div class="btn_wh"></div>
									<%} %>
								</div>
								<% 		} 
									}
								%>
						  		<input id="crmids" class="add_input" _init="1" _searchwidth="160" _searchtype="crm"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_crm" onclick="onShowCRM('crmids')"></div>
						  		<input type="hidden" id="crmids_val" name="crmids" value="<%=crmids %>"/>
						  	</td>
						</tr>
						<tr>
							<td class="title">相关项目</td>
							<td class="data">
								<%
									List projectidList = Util.TokenizerString(projectids,",");
									if(projectids.equals("")) projectids = ",";
									for(int i=0;i<projectidList.size();i++){
										if(!"0".equals(projectidList.get(i)) && !"".equals(projectidList.get(i))){
								%>
								<div class="txtlink txtlink<%=projectidList.get(i) %>" onmouseover="showdel(this)" onmouseout="hidedel(this)">
									<div style="float: left;"><%=cmutil.getProject((String)projectidList.get(i)) %></div>
									<%if(canedit){ %>
									<div class="btn_del" onclick="delItem('projectids','<%=projectidList.get(i) %>')"></div>
									<div class="btn_wh"></div>
									<%} %>
								</div>
								<% 		} 
									}
								%>
						  		<input id="projectids" class="add_input" _init="1" _searchwidth="160" _searchtype="proj"/>
						  		<div class="btn_add"></div>
						  		<div class="btn_browser browser_proj" onclick="onShowProj('projectids')"></div>
						  		<input type="hidden" id="projectids_val" name="projectids" value="<%=projectids %>"/>
						  	</td>
						</tr>
						<tr>
							<td class="title">相关附件</td>
							<td id="filetd" class="data">
						  		<div id="uploadDiv" class="upload" mainId="82" subId="357" secId="1108" maxsize="60"></div>
							</td>
						</tr>
					</tbody>
				</table>
				</div>
				</div>
				<%if(saveType!=1) {%>
					<div style="width: 100%;height:60px;">&nbsp;</div>
				<%} %>
			</div>
			
			<div id="dftitle" _index="" class="dtitle" onclick="showdtitle()" style="position: absolute;top: 41px;left: 0px;display: none;">
				<div id="dfhead" class="dtxt"></div>
			</div>
		</div>
		</div>
		</form>
<script language="javascript">

	var tempval = "";
	var tempbdate = "<%=begindate%>";
	var tempedate = "<%=enddate%>";
	var uploader;
	var dialog;
	if("<%=saveType%>"==100||"<%=saveType%>"==200){
		dialog = parent.getDialog(window);
	}
	$(document).ready(function(){
		<%if(!"".equals(decisionid)){%>
			//初始化是否限时完成
			$("#islimit").val(0);
		<%}%>
		
		$("#dtitle1").click(function(){
			$("#relateTable").toggle();
		});
		
		if('<%=parentid%>'!=""){
			var tempText = transName("parentid","<%=parentid%>","<%=parentname%>");
			$("#parentid").before(tempText);
		}
		
		$("textarea").textareaAutoHeight({ minHeight:20 });
		//var textarea= document.getElementById("taskName"); 
		//$("#taskName").height(textarea.scrollHeight);
		
		//日期控件绑定
		$.datepicker.setDefaults( {
			"dateFormat": "yy-mm-dd",
			"dayNamesMin": ['日','一', '二', '三', '四', '五', '六'],
			"monthNamesShort": ['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'],
			"changeMonth": true,
			"changeYear": true} );
		$( "#begindate" ).datepicker({
			"onSelect":function(){
				if($("#begindate").val()!="" && $("#enddate").val()!="" && !compdate($("#begindate").val(),$("#enddate").val())){
					alert("开始日期不能大于结束日期!");
					$("#begindate").val(tempbdate);
					return;
				}else{
					if($("#begindate").val()!="" && $("#limitdate").val()!="" && !compdate($("#begindate").val(),$("#limitdate").val())){
					alert("开始日期不能大于限时截止日期!");
					$("#begindate").val(tempbdate);
					return;
				    }else{
					
				    }
				}
				if($.trim($("#begindate").val())==""){
					$("#begindate").parents("tr").hide();
					$("#rb_begindate").show();
				}
			}
		}).datepicker("setDate","<%=currentdate%>");
		$( "#enddate" ).datepicker({
			"onSelect":function(){
				if($("#begindate").val()!="" && $("#enddate").val()!="" && !compdate($("#begindate").val(),$("#enddate").val())){
					alert("结束日期不能小于开始日期!");
					$("#enddate").val(tempedate);
					return;
				}else{
					
				}
			}
		}).datepicker("setDate","<%=enddate%>");
		$( "#limitdate" ).datepicker({
			"onSelect":function(){
					if($("#begindate").val()!="" && $("#limitdate").val()!="" && !compdate($("#begindate").val(),$("#limitdate").val())){
					alert("限时截止日期不能小于开始日期!");
					
					return;
				}else{
					
				}
			}
		}).datepicker("setDate","");
		$( "#resultfbdate" ).datepicker({
			"onSelect":function(){
					
			}
		}).datepicker("setDate","");
		//分类信息收缩展开动作绑定
		/**
		$("div.dtitle").bind("click",function(){
			if($(this).attr("_click")!=0){
				var table = $(this).next("table.contenttable");
				table.toggle();
				if(table.css("display")=="none"){
					$(this).attr("title","点击展开");
				}else{
					$(this).attr("title","点击收缩");
				}
			}
		});
		*/

		//表格行背景效果及操作按钮控制绑定
		$("table.datatable").find("tr").bind("click mouseenter",function(){
			$(".btn_add").hide();$(".btn_browser").hide();
			$(this).addClass("tr_over");
			$(this).find(".input_def").addClass("input_over");
			$(this).find("div.content_def").addClass("content_over");
			if($(this).find("input.add_input").css("display")=="none"){
				$(this).find("div.btn_add").show();
				$(this).find("div.btn_browser").show();
			}
		}).bind("mouseleave",function(){
			$(this).removeClass("tr_over");
			$(this).find(".input_def").removeClass("input_over");
			$(this).find("div.content_def").removeClass("content_over");
			if($(this).find("input.add_input").css("display")=="none"){
				$(this).find("div.btn_add").hide();
				$(this).find("div.btn_browser").hide();
			}
		});

		//输入添加按钮事件绑定
		$("div.btn_add").bind("click",function(){
			$(this).hide();
			$(this).nextAll("div.btn_browser").hide();
			$(this).prevAll("div.showcon").hide();
			$(this).prevAll("input.add_input").show().focus();
			$(this).prevAll("div.btn_select").show()
		});

		//单行文本输入框事件绑定
		$(".input_def").bind("mouseover",function(){
			$(this).addClass("input_over");
		}).bind("mouseout",function(){
			$(this).removeClass("input_over");
		}).bind("focus",function(){
			$(this).addClass("input_focus");
			tempval = $(this).val();
			//document.onkeydown=keyListener2;
			if($(this).attr("id")=="name"){
				//document.onkeyup=keyListener4;
			}
		}).bind("blur",function(){
			$(this).removeClass("input_focus");
			//doUpdate(this,1);
			//document.onkeydown=null;
			//document.onkeyup=null;
		});
		
		//多行文本输入框事件绑定
		$(".content_def").bind("mouseover",function(){
			$(this).addClass("content_over");
		}).bind("mouseout",function(){
			$(this).removeClass("content_over");
		}).bind("focus",function(){
			$(this).addClass("content_focus");
			tempval = $(this).html();
		}).bind("blur",function(){
			$(this).removeClass("content_focus");
			//doUpdate(this,2);
		});

		$("div.btn_operate_add").bind("mouseover",function(){
			$(this).addClass("btn_hover_add");
		}).bind("mouseout",function(){
			$(this).removeClass("btn_hover_add");
		});

		//联想输入框事件绑定
		$("input.add_input").bind("focus",function(){
			if($(this).attr("_init")==1){
				$(this).FuzzyQuery({
					url:"/workrelate/task/data/GetData.jsp",
					record_num:5,
					filed_name:"name",
					searchtype:$(this).attr("_searchtype"),
					divwidth: $(this).attr("_searchwidth"),
					updatename:$(this).attr("id"),
					updatetype:"str",
					currentid:"<%=taskId%>"
				});
				$(this).attr("_init",0);
			}
		}).bind("blur",function(e){
			if($(this).attr("id")=="tag" && $(this).val()!=""){
			}else{
				$(this).val("");
			}
			$(this).hide();
			$(this).nextAll("div.btn_add").show();
			$(this).nextAll("div.btn_browser").show();
			$(this).prevAll("div.showcon").show();
			//document.onkeydown=null;
		});

		$("#maininfo").scroll(function(){
			var tp = 0;
			for(var i=1;i>-1;i--){//设置标题（相关信息等）始终显示在当前页面
				if(tp>=0){
					tp = $("#dtitle"+i).position().top;
					if(tp<0){
						$("#dfhead").html($("#dtitle"+i).children("div.dtxt").html());
						$("#dftitle").attr("_index",i).show();
					}
				}
			}
			if(tp>=0) $("#dftitle").hide();
		});
		
		bindUploaderDiv($("#uploadDiv"),"relatedacc","");


		$('#maininfo').perfectScrollbar({"wheelSpeed": 40,"suppressScrollX":true});
		setHeight();

	});
	$(document).bind("click",function(e){
		var target=$.event.fix(e).target;
		if($(target).parents(".fuzzyquery_main_div").length==0 && $("#tag").val()!=""){
			selectUpdate("tag",$("#tag").val(),$("#tag").val(),"str");
		}
		if($("#tag").val()!="") $("#tag").val("");
	});
	
	function setHeight(){
		$("#maininfo").height($("#main").height()-40);
		$('#maininfo').perfectScrollbar("update");
	}
	$(window).resize(function(){
		setHeight();
	});
	function doSubmit(type){
		var name = $("#taskName").val();
		var timestatus = $("#timestatus option:selected").val();
		var islimit = $("#islimit option:selected").val();
		if(name==""){
			alert("任务名称不能为空！");
			$("#taskName").focus();
			return;
		}
		if(timestatus=="1"){
		  if ($("#begindate").val() == "" || $("#enddate").val() == "") {
		  alert("时间生效时，开始日期和结束日期不能为空!");
					return;
		  }
		 }
		  if(islimit=="1"){
		  if ($("#limitdate").val() == "" ) {
		  alert("限时时间生效时，限时时间不能为空!");
					return;
		  }
		  }
		showload();
		$("#saveType").val(type);
		submitform();
	}
	function submitform(){
		var oUploader=window[jQuery("#uploadDiv").attr("oUploaderIndex")];	
		try{
			if(oUploader.getStats().files_queued==0) //如果没有选择附件则直接提交
				exeFeedback();
	   		else 
	     		oUploader.startUpload();
		}catch(e) {
			exeFeedback();
		}	
	}
	function exeFeedback(){
		jQuery("#datetype").val(jQuery("#todo").val());
		jQuery("#form1").submit();
	}
	function showload(){
		jQuery("#operate_panel").html("<img src='../images/loading2.gif' style='margin-top:5px;' align='absMiddle'/>");
	}
	
	function doCancel(){
		if(<%=saveType==1%>){
			parent.closeShadowBox();
		}
	}
	function setTodo(value){
		$("#todo_td").children(".slink").removeClass("sdlink");
		$("#todo"+value).addClass("sdlink");
		$("#todo").val(value);
	}
	function setLevel(value){
		$("#level_td").children(".slink").removeClass("sdlink");
		$("#level"+value).addClass("sdlink");
		$("#lev").val(value);
	}
	
	document.onkeydown=keyListener;
	function keyListener(e){
	    e = e ? e : event;   
	    if(e.keyCode == 13){
	    	var target=$.event.fix(e).target;
	    	if($(target).attr("id")=="tag" && $(target).val()!=""){
				selectUpdate("tag",$(target).val(),$(target).val(),"str");
				$(target).blur();
			}
	    }    
	}
	//选择内容后执行更新
	function selectUpdate(fieldname,id,name,type){
		if(id==null || typeof(id)=="undefined") return;
		var addtxt = "";
		var addids = "";
		var addvalue = "";
		if(fieldname == "principalid"){
			if(id==$("#"+fieldname+"_val").val()){
				return;
			}else{
				$("#"+fieldname+"_val").val(id);
			}
			addtxt = transName(fieldname,id,name);
			addids = id;
		}else if(fieldname == "parentid"){
			if(id==$("#"+fieldname+"_val").val()){
				return;
			}else{
				$("#"+fieldname+"_val").val(id);
				//$("#showsubtr").hide();
			}
			addtxt = transName(fieldname,id,name);
			addids = id;
		}else 
		<%if(!decisionhrmid1.equals("0") &&!decisionhrmid1.equals("")){%>
			if(fieldname == "partnerid"){
			//lq	返回人员信息 页面显示 和赋值		
			if(id && name){			
				var ids = id.split(",");
				var names = name.split(",");				
				var vals = $("#"+fieldname+"_val").val();
				for(var i=0;i<ids.length;i++){
					
						addids += ids[i] + ",";
						addvalue += ids[i] + ",";
						addtxt += transName(fieldname,ids[i],names[i]);					
				}			
			}
			$("#"+fieldname+"_val").val(id);
			$("#divtest").empty();
			$("#divtest").html(addtxt);
		}else
		<%}%>		
		{
			var ids = id.split(",");
			var names = name.split(",");
			var vals = $("#"+fieldname+"_val").val();
			for(var i=0;i<ids.length;i++){
				if(vals.indexOf(","+ids[i]+",")<0 && $.trim(ids[i])!=""){
					addids += ids[i] + ",";
					addvalue += ids[i] + ",";
					addtxt += transName(fieldname,ids[i],names[i]);
				}
			}
			$("#"+fieldname+"_val").val(vals+addids);
			if(fieldname != "partnerid" && fieldname != "sharerid") addids = vals+addids;
		}
		if(fieldname == "principalid" || fieldname=="parentid" ) $("#"+fieldname).prev("div.txtlink").remove();
		<%if(!decisionhrmid1.equals("0") &&!decisionhrmid1.equals("")){%>
			if(fieldname != "partnerid")
		<%}%>
			$("#"+fieldname).before(addtxt);
		if(!startWith(fieldname,"_")){
			if(fieldname != "partnerid" && fieldname != "sharerid" && fieldname != "principalid" && fieldname != "parentid" && addvalue=="") return;
			//exeUpdate(fieldname,addids,type,"",addvalue);
		}
	}
	function delItem(fieldname,fieldvalue){
		$("#"+fieldname).prevAll("div.txtlink"+fieldvalue).remove();
		if(fieldname=="docids"||fieldname=="wfids"||fieldname=="meetingids"
				||fieldname=="sharerid"||fieldname=="partnerid"
				||fieldname=="crmids"||fieldname=="projectids"||fieldname=="taskids"||fieldname=="goalids"
				||fieldname=="tag"||startWith(fieldname,"_")){
			var vals = $("#"+fieldname+"_val").val();
			var _index = vals.indexOf(","+fieldvalue+",")
			if(_index>-1 && $.trim(fieldvalue)!=""){
				vals = vals.substring(0,_index+1)+vals.substring(_index+(fieldvalue+"").length+2);
				$("#"+fieldname+"_val").val(vals);
				if(!startWith(fieldname,"_")){
					//exeUpdate(fieldname,vals,'str',fieldvalue);
				}
			}
		}else{
			//exeUpdate(fieldname,fieldvalue,'del');
		}
	}
	function transName(fieldname,id,name){
		var delname = fieldname;
		if(startWith(fieldname,"_")) fieldname = fieldname.substring(1);
		var restr = "";
		if(fieldname=="principalid" || fieldname=="parentid"){
			restr += "<div class='txtlink showcon txtlink"+id+"' onmouseover='showdel(this)' onmouseout='hidedel(this)'>";
		}else{
			restr += "<div class='txtlink txtlink"+id+"' onmouseover='showdel(this)' onmouseout='hidedel(this)'>";
		}
		restr += "<div style='float: left;'>";
			
		if(fieldname=="principalid" || fieldname=="partnerid" || fieldname=="sharerid"){
			restr += "<a href='/hrm/resource/HrmResource.jsp?id="+id+"' target='_blank'>"+name+"</a>";
		}else if(fieldname=="docids"){
			restr += "<a href=javaScript:openFullWindowHaveBar('/docs/docs/DocDsp.jsp?id="+id+"') >"+name+"</a>";
		}else if(fieldname=="wfids"){
			restr += "<a href=javaScript:openFullWindowHaveBar('/workflow/request/ViewRequest.jsp?requestid="+id+"') >"+name+"</a>";
		}else if(fieldname=="crmids"){
			restr += "<a href=javaScript:openFullWindowHaveBar('/CRM/data/ViewCustomer.jsp?log=n&CustomerID="+id+"') >"+name+"</a>";
		}else if(fieldname=="projectids"){
			restr += "<a href=javaScript:openFullWindowHaveBar('/proj/process/ViewTask.jsp?taskrecordid="+id+"') >"+name+"</a>";
		}else if(fieldname=="taskids" || fieldname=="parentid"){
			restr += "<a href=javaScript:openFullWindowHaveBar('/workrelate/task/data/Main.jsp?taskid="+id+"&comfrom=portal') >"+name+"</a>";
		}else if(fieldname=="goalids"){
			restr += "<a href=javaScript:showGoal("+id+") >"+name+"</a>";
		}else if(fieldname=="tag"){
			restr += name;
		}
		
		restr +="</div>";
		if(fieldname!="principalid"){
			restr +="<div class='btn_del' onclick=\"delItem('"+delname+"','"+id+"')\"></div>";
			restr +="<div class='btn_wh'></div>";
		}
		restr +="</div>";
		return restr;
	}
	function onShowHrm(fieldname) {
	    var datas = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/hrm/resource/ResourceBrowser.jsp");
	    if (datas) {
		    var fieldvalue = "";
		    if(datas.id=="") fieldvalue=0;
		    selectUpdate(fieldname,datas.id,datas.name,'add');
	    }
	}
	function onShowHrms(fieldname) {
	    var selectIds = $("#partnerid_val").val();
	    var datas = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/hrm/resource/MutiResourceBrowser.jsp?selectedids="+selectIds);
	    if (datas) {
			//debugger;
		    var fieldvalue = "";
		    if(datas.id=="") fieldvalue=0;
		    selectUpdate(fieldname,datas.id,datas.name,'add');
	    }
	}
	function onShowDoc(fieldname) {
	 var obj = new Object();
	    var datas = window.showModalDialog("/docs/DocBrowserMain.jsp?url=/docs/docs/MutiDocBrowser.jsp",obj,"dialogWidth=700px;dialogHeight=600px");
	    if (datas) {
		    var fieldvalue = "";
		    if(datas.id=="") fieldvalue=0;
		    selectUpdate(fieldname,datas.id,datas.name,'str');
	    }
	}
	function onShowWF(fieldname) {
	var obj = new Object();
	    var datas = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/workflow/request/MultiRequestBrowser.jsp",obj,"dialogWidth=700px;dialogHeight=600px");
	    if (datas) {
		    var fieldvalue = "";
		    if(datas.id=="") fieldvalue=0;
		    selectUpdate(fieldname,datas.id,datas.name,'str');
	    }
	}
	function onShowCRM(fieldname) {
	 var obj = new Object();
	    var datas = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/CRM/data/MutiCustomerBrowser.jsp",obj,"dialogWidth=700px;dialogHeight=600px");
	    if (datas) {
		    var fieldvalue = "";
		    if(datas.id=="") fieldvalue=0;
		    selectUpdate(fieldname,datas.id,datas.name,'str');
	    }
	}
	function onShowProj(fieldname) {
	 var obj = new Object();
	    var datas = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/proj/data/MultiTaskBrowser.jsp",obj,"dialogWidth=700px;dialogHeight=600px");
	    if (datas) {
		    var fieldvalue = "";
		    if(datas.id=="") fieldvalue=0;
		    selectUpdate(fieldname,datas.id,datas.name,'str');
	    }
	}
	//显示删除按钮
	function showdel(obj){
		$(obj).find("div.btn_del").show();
		$(obj).find("div.btn_wh").hide();
	}
	//隐藏删除按钮
	function hidedel(obj){
		$(obj).find("div.btn_del").hide();
		$(obj).find("div.btn_wh").show();
	}
	function onShowParentid(taskid){
		openWin("/systeminfo/BrowserMain.jsp?url=/workrelate/task/data/parentTaskBrowser.jsp?taskid="+taskid);
	}
	function updateParent(datas){
		if(datas.id==""){
			selectUpdate("parentid",datas.id,datas.name,'del');
		}else{
			selectUpdate("parentid",datas.id,datas.name,'str');
		}
	}
	function openWin(url,showw,showh){
		if(showw==null || typeof(showw)=="undefined") showw = 500;
		if(showh==null || typeof(showh)=="undefined") showh = 600;
		var redirectUrl = url ;
		var height = screen.height;
		var width = screen.width;
		var top = (height-showh)/2-40;
		var left = (width-showw)/2;
		var szFeatures = "top="+top+"," ; 
		szFeatures +="left="+left+"," ;
		szFeatures +="width="+showw+"," ;
		szFeatures +="height="+showh+"," ; 
		szFeatures +="directories=no," ;
		szFeatures +="status=yes," ;
		szFeatures +="menubar=no," ;
	  	szFeatures +="scrollbars=yes," ;
		szFeatures +="resizable=yes" ; //channelmode
	 	window.open(redirectUrl,"",szFeatures) ;
	}
	//$("#relateTable").hide();
</script>
<%@ include file="/workrelate/task/util/uploader.jsp" %>
</body>
</html>