<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/page/maint/common/initNoCache.jsp"%>
<%@ page import="weaver.file.Prop"%>
<%@ page import="weaver.general.*"%>
<%@page import="weaver.file.FileUpload"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<%
	request.setCharacterEncoding("UTF-8");
	FileUpload fu = new FileUpload(request);
	String clienttype = Util.null2String((String) fu.getParameter("clienttype"));
	String clientlevel = Util.null2String((String) fu.getParameter("clientlevel"));
	String module = Util.null2String((String) fu.getParameter("module"));
	String scope = Util.null2String((String) fu.getParameter("scope"));
	String param = "clienttype=" + clienttype + "&clientlevel="+ clientlevel + "&module=" + module + "&scope=" + scope;
	
	String principalid = user.getUID() + "";
	String dutyMan = user.getLastname();
	String currentDate = TimeUtil.getCurrentDateString();
	String parentid = Util.null2String((String) fu.getParameter("parentid"));
	String parentName = "";
	if (!parentid.equals("")) {
		rs.executeSql("select name from TM_TaskInfo where id="+ parentid + " and (deleted=0 or deleted is null)");
		if (rs.next()) {
			parentName = Util.toScreen(rs.getString("name"),user.getLanguage());
		}
	}
	int from = Util.getIntValue(fu.getParameter("from"), 1);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="author" content="Weaver E-Mobile Dev Group" />
<meta name="description" content="Weaver E-mobile" />
<meta name="keywords" content="weaver,e-mobile" />
<meta name="viewport" content="width=device-width,minimum-scale=1.0, maximum-scale=1.0" />
<script type='text/javascript' src='/mobile/plugin/task/js/jquery-1.8.3.js'></script>
<script type='text/javascript' src='/mobile/plugin/task/js/fastclick.min.js'></script>
<script language="javascript" src="/mobile/plugin/task/js/task.js"></script>
<script type='text/javascript' src='/mobile/plugin/task/js/jquery.textarea.autoheight.js'></script>
<script type='text/javascript' src='/mobile/plugin/task/js/jquery.form.js'></script>
<script type='text/javascript' src="/mobile/plugin/task/js/jquery-weui.js"></script>
<link rel="stylesheet" href="/mobile/plugin/task/css/weui.min.css" />
<link rel="stylesheet" href="/mobile/plugin/task/css/jquery-weui.min.css" />
<link rel="stylesheet" href="/mobile/plugin/task/css/icon.css" />
<link rel="stylesheet" href="/mobile/plugin/task/css/task.css" />
<link rel="stylesheet" href="/mobile/plugin/task/css/add.css" />
<style type="text/css">
#userChooseDiv {
	position: fixed;
	left: 100%;
	top: 0px;
	width: 100%;
	height: 100%;
	z-index: 99999;
}
body.hrmshow #userChooseDiv {
	left: 0;
}
#userChooseFrame {
	width: 100%;
	height: 100%;
}
</style>
<title>新建任务</title>
</head>
<body id="body" ontouchstart>
<div id="pageMain" style="bottom:0;">
	<form id="form1" name="form1" action="/mobile/plugin/task/addOperation.jsp" method="post" onsubmit="return false;">
		<div class="weui-cells weui-cells_form" style="margin-top:0">
			<div class="weui-cell">
				<div class="weui-cell__hd">
					<label class="weui-label">任务名称</label>
				</div>
				<div class="weui-cell__bd">
					<input class="weui-input" type="text" placeholder="请输入任务名称" id="taskName" name="taskName" />
				</div>
			</div>
			<div class="weui-cell weui-cell_vcode" id="parentDiv">
				<div class="weui-cell__hd">
					<label class="weui-label">上级任务</label>
				</div>
				<div class="weui-cell__bd">
					<p id="parentdiv">
						<%if (!parentName.equals("")) {%>
						<a href="javascript:viewTask(<%=parentid%>,3)"><%=parentName%></a>
						<%}%>
					</p>
					<input type="hidden" name="parentid" id="parentid" value="<%=parentid%>" />
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="selectTask();">
						<i class="weui-icon-search"></i>
					</button>
				</div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__hd">
					<label class="weui-label">描述</label>
				</div>
				<div class="weui-cell__bd">
					<textarea class="weui-textarea" placeholder="请输入任务描述" id="remark" name="remark" rows="1"></textarea>
				</div>
			</div>
			<div class="weui-cell weui-cell_vcode tag_cell">
				<div class="weui-cell__hd">
					<label class="weui-label">标签</label>
				</div>
				<div class="weui-cell__bd">
					<input type="text" class="weui-input" name="tag" placeholder="请输入任务标签" />
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="addTag();">
						<i class="icon icon-36" style="font-size:28px;"></i>
					</button>
				</div>
			</div>
		</div>
		<div class="weui-cells weui-cells_form">
			<div class="weui-cell weui-cell_vcode">
				<div class="weui-cell__hd">
					<label class="weui-label">责任人</label>
				</div>
				<div class="weui-cell__bd">
					<p id="dutyMan" onclick=""><%=dutyMan%></p>
					<input type="hidden" id="dutyManId" name="principalid" value="<%=principalid%>" />
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="selectUser('dutyManId','dutyMan',0);">
						<i class="weui-icon-search"></i>
					</button>
				</div>
			</div>
			<div class="weui-cell weui-cell_vcode">
				<div class="weui-cell__hd">
					<label class="weui-label">参与人</label>
				</div>
				<div class="weui-cell__bd">
					<p id="partenrs">&nbsp;</p>
					<input type="hidden" id="partnerids" name="partnerids" />
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="selectUser('partnerids','partenrs',1);">
						<i class="weui-icon-search"></i>
					</button>
				</div>
			</div>
			<div class="weui-cell weui-cell_vcode">
				<div class="weui-cell__hd">
					<label class="weui-label">分享给</label>
				</div>
				<div class="weui-cell__bd">
					<p id="sharers">&nbsp;</p>
					<input type="hidden" id="sharerids" name="sharerids" />
				</div>
				<div class="weui-cell__ft">
					<button class="weui-vcode-btn" onclick="selectUser('sharerids','sharers',1);">
						<i class="weui-icon-search"></i>
					</button>
				</div>
			</div>
		</div>
		<div class="weui-cells weui-cells_form">
			<div class="weui-cell weui-cell_switch">
				<div class="weui-cell__bd">时间是否生效</div>
				<div class="weui-cell__ft">
					<input class="weui-switch" name="timestatus" id="timestatus" type="checkbox" value="1" />
				</div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__hd">
					<label for="" class="weui-label">开始日期</label>
				</div>
				<div class="weui-cell__bd">
					<input class="weui-input" value="<%=currentDate %>" type="date" name="begindate" id="begindate" placeholder="选择开始日期" />
				</div>
			</div>
			<div class="weui-cell oli-weui-calendar">
				<div class="weui-cell__hd">
					<label for="" class="weui-label">结束日期</label>
				</div>
				<div class="weui-cell__bd">
					<input class="weui-input" type="date" name="enddate" id="enddate" placeholder="选择结束日期" />
				</div>
			</div>
			<div class="weui-cell oli-weui-calendar">
				<div class="weui-cell__hd">
					<label for="" class="weui-label">排期反馈日期</label>
				</div>
				<div class="weui-cell__bd">
					<input class="weui-input" type="date" name="limitdate" id="limitdate" placeholder="选择排期反馈日期" />
				</div>
			</div>
			<div class="weui-cell oli-weui-calendar">
				<div class="weui-cell__hd">
					<label for="" class="weui-label">结果反馈日期</label>
				</div>
				<div class="weui-cell__bd">
					<input class="weui-input" type="date" name="resultfbdate" id="resultfbdate" placeholder="选择结果反馈日期" />
				</div>
			</div>
		</div>
		<div class="weui-cells weui-cells_form">
			<div class="weui-cell">
				<div class="weui-cell__hd">
					<label class="weui-label">风险点</label>
				</div>
				<div class="weui-cell__bd">
					<textarea class="weui-textarea" placeholder="请输入任务风险点" name="risk" rows="1"></textarea>
				</div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__hd">
					<label class="weui-label">难度点</label>
				</div>
				<div class="weui-cell__bd">
					<textarea class="weui-textarea" placeholder="请输入任务难度点" name="difficulty" rows="1"></textarea>
				</div>
			</div>
			<div class="weui-cell">
				<div class="weui-cell__hd">
					<label class="weui-label">需协助点</label>
				</div>
				<div class="weui-cell__bd">
					<textarea class="weui-textarea" placeholder="请输入任务需协助点" name="assist" rows="1"></textarea>
				</div>
			</div>
		</div>
		<div class="btn-wrapper">
			<a href="javascript:doSubmit()" class="weui-btn weui-btn_primary" style="color:#fff;">提交</a>
		</div>
	</form>
</div>	
	<div id="userChooseDiv">
		<iframe id="userChooseFrame" src="/mobile/plugin/plus/browser/hrmBrowser.jsp" frameborder="0" scrolling="auto"> </iframe>
	</div>
	<script language="javascript">
	var param = "<%=param%>";
	var from = "<%=from%>";
	var title="新建任务";
	var browserWin = parent._BrowserWindow;
	$(document).ready(function(){
		FastClick.attach(document.body);
		//控制多行文本框自动伸缩
	    $("textarea").textareaAutoHeight({minHeight:22});
	});
	function clearParent(){
		$("#parentid").val("");
		$("#parentdiv").html("");
	}
	function selectTask(){
		openPopup("/mobile/plugin/task/taskParent.jsp?"+param);
	}
	function setTask(id,name){
		$("#parentid").val(id);
		$("#parentdiv").html("<a href='javascript:viewTask("+id+",3)''>"+name+"</a>");
		onPopupClose();
	}
	function addTag(){
		$(".tag_cell:last").after('<div class="weui-cell weui-cell_vcode tag_cell">'+
			   '<div class="weui-cell__hd"><label class="weui-label"></label></div>'+
			   '<div class="weui-cell__bd">'+
			   '	<input type="text" class="weui-input" name="tag" placeholder="请输入任务标签"/>'+
			   '</div>'+
			   '<div class="weui-cell__ft">'+
			   '   <button class="weui-vcode-btn" onclick="delTag(this);">'+
			   '		<i class="icon icon-73" style="font-size:28px;"></i>'+
			   '   </button>'+
			   '</div>'+
			   '</div>');
	}
	function delTag(obj){
		$(obj).parent().parent().remove();
	}
	function doSubmit(){//提交表单
		var name = $("#taskName").val();
		if(name==""){
			$.alert("任务名称不能为空！",function(){
				$("#taskName").focus();
			});
			return;
		}
		var timestatus = $("#timestatus").attr("checked");
		var begindate = $("#begindate").val();
		var enddate = $("#enddate").val();
		var limitdate = $("#limitdate").val();
		if(begindate!=""&&enddate!=""&&!compdate(begindate,enddate)){
			$.alert("开始日期不能大于结束日期!");
			return;
		}
		
		if(begindate!=""&&limitdate!=""&&!compdate(begindate,limitdate)){
			$.alert("开始日期不能大于排期反馈日期!");
			return;
		}
		if(timestatus=="checked"){
			if (begindate == "" || enddate == "") {
		  		$.alert("时间生效时，开始日期和结束日期不能为空!");
				return;
		 	}
		}
		$.showLoading();
		$("#form1").ajaxSubmit({
			dataType:"json",
			success:function(data){
				if(data.status==0){
					if(browserWin){
						browserWin.onAddOk(from);
					}else{
						parent.onAddOk(from);
					}
				}else{
					$.alert(data.msg);
				}
			},
			error:function(data){
				$.alert(data);
			},
			complete:function(){
				$.hideLoading();
			}
		});
	}
	function selectUser(rID,rField,isMuti){//选择人员入口
	<%if ("".equals(clienttype) || clienttype.equals("Webclient")) {%>
		top._BrowserWindow = window;
			$("#userChooseFrame")[0].contentWindow.resetBrowser({
				"fieldId" : rID,
				"fieldSpanId" : rField,
				"browserType" : (isMuti == "1") ? "1" : "2",
				"selectedIds" : $("#" + rID).val()
			});
			$(document.body).addClass("hrmshow");
	<%} else {%>
		var selids = $("#"+rID).val();
		var url = 'emobile:Browser:HRMRESOURCE:'+isMuti+':'+selids+':setBrowserData:'+rID+':'+rField+':请选择';
		showDialog2(url);
	<%}%>
	}
	function onBrowserBack(){
		$(document.body).removeClass("hrmshow");
	}
	function onBrowserOk(result){
		var fieldId = result["fieldId"];
		var fieldSpanId = result["fieldSpanId"];
		var idValue = result["idValue"];
		var nameValue = result["nameValue"];
		$("#"+fieldId).val(idValue);
		$("#"+fieldSpanId).html(nameValue);
		$(document.body).removeClass("hrmshow");
	}
	function showDialog2(url){//选择人员弹出框
		window.open(url);
	}
	</script>
</body>
</html>