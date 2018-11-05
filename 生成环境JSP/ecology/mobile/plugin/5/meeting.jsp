<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="weaver.general.BaseBean"%>
<%@ page import="weaver.file.FileUpload"%>
<%@ include file="/page/maint/common/initNoCache.jsp"%>
<%
	response.setHeader("Cache-Control", "no-store");
	response.setHeader("Pragrma", "no-cache");
	response.setDateHeader("Expires", 0);
	FileUpload fu = new FileUpload(request);
	String clienttype = Util.null2String(fu.getParameter("clienttype"));
	String clientlevel = Util.null2String(fu.getParameter("clientlevel"));
	String module = Util.null2String(fu.getParameter("module"));
	String scope = Util.null2String(fu.getParameter("scope"));
	String param = "clienttype=" + clienttype + "&clientlevel="+ clientlevel + "&module=" + module + "&scope=" + scope;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta http-equiv="Cache-Control" content="no-cache,must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<meta name="viewport" content="width=device-width,minimum-scale=1.0, maximum-scale=1.0" />
	<title>会议</title>
	<script src='/mobile/plugin/5/js/jquery.js'></script>
	<script src='/mobile/plugin/task/js/fastclick.min.js'></script>
	<script src="/mobile/plugin/5/js/jquery-weui.js"></script>
	<script src="/mobile/plugin/5/js/rainyxDate.js"></script>
	<link rel="stylesheet" href="/mobile/plugin/5/css/weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/jquery-weui.min.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/icon.css" />
	<link rel="stylesheet" href="/mobile/plugin/5/css/meeting.css?v=2017121801" />
</head>
<body ontouchstart id="body">
<div id="container">
	<div id="mt-calendar">
		<input id="mt-input" type="hidden"/>
	</div>
	<div id="mt-content">
		<div class="weui-pull-to-refresh__layer">
			<div class='weui-pull-to-refresh__arrow'></div>
			<div class='weui-pull-to-refresh__preloader'></div>
			<div class="down">下拉刷新</div>
			<div class="up">释放刷新</div>
			<div class="refresh">正在刷新</div>
		</div>
		<div id="mt-cells" class="weui-cells"  style="margin-top:0;">
          
        </div>
	</div>
</div>
<script type="text/javascript">
	var param = "<%=param%>";
	$(document).ready(function(){
		//FastClick.attach(document.body);
		$("#mt-calendar").calendar({
			container: "#mt-calendar",
		  	input: "#mt-input",
		  	yearPicker:false,
		  	onChange:function(p, values, displayValues){
		  		getMeetingList(values[0]);
		  	},
		  	onMonthYearChangeEnd:function(p, year, month){
		  		getMeetingNum(year,month);
		  	}
		});
		$(".toolbar-btn").click(function(){
			var type = $(this).attr("type");
			$.showLoading();
			if(type==1){//新建
				var selectDay = $(".picker-calendar-day-selected").attr("dateid");
				location = "/mobile/plugin/5/add.jsp?"+param+"&selectDay="+selectDay;
			}else if(type==2){//变更
				location = "/mobile/plugin/5/meetingchange.jsp?"+param;
			}else if(type==3){//签到
				//location = "/mobile/plugin/5/mtsignin.jsp?"+param;
				window.location.href = "emobile:sweep";
				setTimeout(function(){
					$.hideLoading();
				},2000);
			}else if(type==4){//会议室
				location = "/mobile/plugin/5/mtaddress.jsp?"+param;
				//location = "/mobile/plugin/5/mtdecision.jsp?id=104";
				//location = "/mobile/plugin/5/mtdelayed.jsp?id=118";
			}
		});
		$("#mt-content").pullToRefresh();
		$("#mt-content").on("pull-to-refresh", function(e){//下拉刷新
			getMeetingList($("#mt-input").val());
		});
		getMeetingNum(0,0);//获取会议数量
	});
	function getMeetingList(selectday){
		$.showLoading();
		$.ajax({
			url:"/mobile/plugin/5/meetingOperation.jsp",
			data:{"operation":"getMeetingList","selectday":selectday},
			dataType:"json",
			success:function(data){
				if(data.status==0){
					var temp = "";
					var meetings = data.meetings;
					if(meetings.length>0){
						for(var i=0;i<meetings.length;i++){
							var m = meetings[i];
							temp +=getMeetHtml(m);
						}
					}else{
						temp = "<div class='weui-loadmore weui-loadmore_line'><span class='weui-loadmore__tips' style='background:#f7f8fa;'>当天无会议</span></div>";
					}
					$("#mt-cells").html(temp);
				}else{
					$.alert(data.msg);
				}
			},
			complete:function(){
				$.hideLoading();
				$("#mt-content").pullToRefreshDone();
			}
		});
	}
	function getMeetingNum(year,month){
		$.ajax({
			url:"/mobile/plugin/5/meetingOperation.jsp",
			data:{"operation":"getMeetingNum","year":year,"month":month},
			dataType:"json",
			success:function(data){
				if(data.status==0){
					var meetings = data.meetings;
					for(var i=0;i<meetings.length;i++){
						var m = meetings[i];
						var date = m.date;
						var offset = m.offset;
						var className = "";
						if(offset<0){//当天以后的会议
							className = "afterDay";
						}else if(offset==0){//当天的会议
							className = "currentDay";
						}else{
							className = "beforeDay";
						}
						$(".picker-calendar-month-current").find("div[dateid='"+date+"']").find(".ddian").addClass(className).show();
					}
				}else{
					$.alert(data.msg);
				}
			},
			complete:function(){
				$.hideLoading();
			}
		});
	}
	function getMeetHtml(m){
		var statusname = "",classname = "";
		if(m.meetingover==0){
			statusname = "已结束";
			classname = "end";
		}else if(m.meetingover==1){
			statusname = "正在进行中";
			classname = "ing";
		}else if(m.meetingover==2){
			statusname = "未开始";
			classname = "nostart";
		}else if(m.meetingover==3){
			statusname = "草稿";
			classname = "draft";
		}else if(m.meetingover==4){
			statusname = "审批中";
			classname = "approval";
		}
		var temp = '<a class="weui-cell weui-cell_access" href="javascript:viewMeeting('+m.id+','+m.meetingover+')">'+
			       ' 	<div class="weui-cell__hd">'+m.begintime+'<br/>'+m.endtime+'<br/>'+m.userType+'</div>'+
			       
				   '     <div class="weui-cell__bd">'+
				   '       <p>'+m.name+'</p>'+
				   '       <p class="mt-address">'+m.roomname+'</p>'+
				   '     </div>'+
			       ' 	<div class="weui-cell__ft '+classname+'">'+statusname+'</div>'+
			       '</a>';
		return temp;
	}
	function viewMeeting(mid,meetingover){
		$.showLoading();
		if(meetingover==3){//草稿
			window.location = "/mobile/plugin/5/add.jsp?id="+mid+"&"+param;
		}else{
			window.location = "/mobile/plugin/5/detail.jsp?id="+mid+"&"+param;
		}
	}
	
	function getRequestTitle(){
		return "会议";
	}
	function getLeftButton(){ 
		return "1,返回";
	}
	function getRightButton(){ 
		return "1,";
	}
	function doRightButton(){
		return "1";
	} 
	function doLeftButton(){
		window.location = "/home.do";
		return "1";
	}
</script>	
</body>