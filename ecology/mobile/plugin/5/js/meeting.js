var popOpen = false;//是否有弹出窗口
var outUserOpen = false;//是否打开了外部人员窗口
var addressOpen = false;//是否打开了会议室详情
var outUserLoaded = false;//是否加载过外部人员
var hrmNums = 0,otherNums = 0;//参会人员数量和外来人员数量
var mtAddressList,currentId;//加载会议室会议信息
$(document).ready(function(){
	$.toast.prototype.defaults.duration = 800;//设置提示时间
	//确定会议类型选择
	$(document).on("click",".mt-type-radio",function(){
		var checkRadio = $("input[name='mttyperadio']:checked");
		if(checkRadio.length>0){
			var mttype = checkRadio.val();
			var isagenda = checkRadio.attr("isagenda");
			var name = checkRadio.attr("mtname");
			$("#meetingtypeSpan").html(name);
			$("#meetingtype").val(mttype).attr("isagenda",isagenda);
			if(mttype==1||mttype==21||mttype==41||mttype==42){
				$("#isAppraise").val("3").attr("disabled",true);
			}else{
				$("#isAppraise").val("2").attr("disabled",false);
			}
		}
		$.closePopup();
		popOpen = false;
	});
	$("#mt-ad-content").pullToRefresh();
	$("#mt-ad-content").on("pull-to-refresh", function(e){//下拉刷新
		loadAddressDetail();
	});
	$(".mt-ad-day-item").click(function(){
		$(".mt-ad-day-item").removeClass("item-current");
		$(this).addClass("item-current");
		currentDay = parseInt($(this).html());
		loadAddressDetail();
	});
});
function getLoadHtml(text){
	var loadedHtml = '<div style="background:#f0f0f0;overflow:hidden;">'+
	'	<div class="weui-loadmore">'+
	'		<i class="weui-loading"></i>'+
	'		<span class="weui-loadmore__tips" style="background:#f0f0f0;">'+text+'</span>'+
	'	</div>'+
	'</div>';
	return loadedHtml;
}
function getTipsHtml(text){
	return "<div style='background:#f0f0f0;overflow:hidden;'>" +
		   "<div class='weui-loadmore weui-loadmore_line'>" +
		   "	<span class='weui-loadmore__tips' style='background:#f0f0f0;'>"+text+"</span>" +
		   "</div></div>";
}
//打开OA内部人员详情
function openuser(u){
	var e = arguments.callee.caller.arguments[0] || window.event;
	e.stopPropagation(); 
	var url = "emobile:openUserinfo:"+u;
	window.location.href = url;
}
//打开外部人员详情
function openuserForOut(name,sex,photo,company,duties,mobilephone,type){
	var e = arguments.callee.caller.arguments[0] || window.event;
	e.stopPropagation(); 
	popOpen = true;
	if(type==1){
		outUserOpen = true;
	}
	$("#mt-udetail-userimg").attr("src",photo);
	$("#mt-udetail-lastname").html(name);
	$("#mt-udetail-jobtitle").html(duties);
	$("#mt-udetail-mobile").html("<a href='tel:"+mobilephone+"'>"+mobilephone+"</a>");
	$("#mt-udetail-company").html(company);
	$("#mt-udetail-sex").html(sex);
	$("#mt-udetail-duty").html(duties);
	$("#hrmpopupForOutDetail").popup();
}
//手机版选择人员
function selectUser(rID,rField,isMuti){//选择人员入口
	var selids = $("#"+rID).val();
	var url = 'emobile:Browser:HRMRESOURCE:'+isMuti+':'+selids+':setBrowserData:'+rID+':'+rField+':请选择';
	window.open(url);
}
//手机版选择人员回调
function setBrowserData(fieldId,fieldSpan,rtnValues,rtnNames,param){
	if(param==0){
		$("#"+fieldId).val(rtnValues);
		$("#"+fieldSpan).html(rtnNames);
		if(fieldId=="hrmmembers"){//计算参会人员数量
			hrmNums = rtnValues.split(",").length;
			countNum();
			countCost();
		}
		if(fieldId=="caller"||fieldId=="recorder"){//选择主持人 记录人 自动追加到参会人中
			var s_hrmmembers = $("#hrmmembers").val();
			var s_hrmmembersSpan = $("#hrmmembersSpan").html();
			if((","+s_hrmmembers+",").indexOf((","+rtnValues+","))<0){//不包含
				if(s_hrmmembers==""){
					s_hrmmembers = rtnValues;
					s_hrmmembersSpan = rtnNames;
				}else{
					s_hrmmembers += ","+rtnValues;
					s_hrmmembersSpan += ","+rtnNames;
				}
				$("#hrmmembers").val(s_hrmmembers);
				$("#hrmmembersSpan").html(s_hrmmembersSpan);
				hrmNums = s_hrmmembers.split(",").length;
				countNum();
				countCost();
			}
		}
	}
}
//手机版选择部门
function selectDept(rID,rField,isMuti){
	var selids = $("#"+rID).val();
	var splitChar = "@@TYLLKFGF@@";
	var url = "emobile"+splitChar+"Browser"+splitChar+"/mobile/plugin/1/browser.jsp?method=listDepartment"+
	splitChar+isMuti+splitChar+selids+splitChar+"setDeptBrowserData"+splitChar+rID+
	splitChar+rField+splitChar+"请选择部门"+splitChar+""+splitChar+"UTF-8";
	window.open(url);
}
//手机版选择部门回调
function setDeptBrowserData(fieldId,fieldSpan,rtnValues,rtnNames,param){
	if(param==0){
		$("#"+fieldId).val(rtnValues);
		$("#"+fieldSpan).html(rtnNames);
	}
}
//计算应到人数
function countNum(){
	$("#totalmember").val(hrmNums+otherNums);
}
//计算会议成本
function countCost(){
	try{
		var cc_hrmmembers = $("#hrmmembers").val();
		var cc_begindate = $("#begindate").val();
		var cc_begintime = $("#begintime").val();
		var cc_enddate = $("#enddate").val();
		var cc_endtime = $("#endtime").val();
		if(cc_begindate!=""&&cc_begintime!=""&&cc_enddate!=""&&cc_endtime!=""){
			$.ajax({
				type: "post",
			    url: "/mobile/plugin/5/meetingOperation.jsp",
			    data:{"operation":"getCost","hrmmembers":cc_hrmmembers,"begindate":cc_begindate,
					 "begintime":cc_begintime,"enddate":cc_enddate,"endtime":cc_endtime}, 
			    dataType:"json",
			   	success:function(data){
			   		if(data.status==0){
			   			$("#xiaoshiSpan").html(data.hour);
			   			$("#xiaoshi").val(data.hour);
			   			
			   			$("#costSpan").html(data.cost);
			   			$("#cost").val(data.cost);
			   		}
			   	}
			});
		}
	}catch(e){
		
	}
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

//查看签到人员和回执人员列表
function viewHrmid(){
	popOpen = true;
	$("#hrmpopup").popup();
}
//查看外部人员列表
function viewHrmForOut(){
	popOpen = true;
	$("#hrmpopupForOut").popup();
}
//加载会议类型
function loadMtType(mttype){
	$.ajax({
		type: "post",
	    url: "/mobile/plugin/5/meetingOperation.jsp",
	    data:{"operation":"getMtType"}, 
	    dataType:"json",
	   	success:function(data){
	   		if(data.status==0){
	   			var temp = "";
	   			var mts = data.mtTypesList;
	   			if(mts!=null&&mts.length>0){
	   				for(var i=0;i<mts.length;i++){
	   					var mt = mts[i];
	   					var checked = "";
	   					if(mt.id==mttype){
	   						checked = "checked";
	   					}
	   					temp += '<div class="weui-cells mt-type-radio weui-cells_radio" id="mt-type-div-'+mt.id+'">'+
				   			    '  <label class="weui-cell weui-check__label" for="mt-type-'+mt.id+'">'+
				   			    '    <div class="weui-cell__bd">'+
				   			    '      <p>'+mt.name+'</p>'+
				   			    '    </div>'+
				   			    '    <div class="weui-cell__ft">'+
				   			    '      <input type="radio" mtname="'+mt.name+'" isagenda="'+mt.isagenda+'" class="weui-check" value="'+mt.id+'"'+
				   			    '		 name="mttyperadio" id="mt-type-'+mt.id+'" '+checked+'>'+
				   			    '      <span class="weui-icon-checked"></span>'+
				   			    '    </div>'+
				   			    '  </label>'+
				   			    '</div>';
	   				}
	   			}else{
	   				temp =  getTipsHtml("没有会议类型");
	   			}
	   			$("#mt-type-content").html(temp);
	   			if(mttype!=""){
	   				$("#mt-type-div-"+mttype).click();
	   			}
	   		}else{
	   			$.alert(data.msg);
	   		}
	   	},
	    complete: function(data){
	    	
		}
    });
}
//弹出会议类型选择层
function showMtType(){
	popOpen = true;
	$("#mttypepopup").popup();
}
//弹出外来人员选择层
function showOutUser(othermembers){
	popOpen = true;
	$("#hrmpopupForOut").popup();
	if(!outUserLoaded){
		loadOutUser(othermembers);
	}
}
//选择会议室
function showAddress(type,pageType){
	popOpen = true;
	$("#addresspopup").popup();
	loadAddress(type,pageType);
}
//加载会议室数据 type:1获取可用会议室 2智能匹配会议室
function loadAddress(type,pageType){
	if(type==2){
		$("#mt-address-content-1").hide();
		$("#mt-address-content-2").html(getLoadHtml("正在加载")).show();
	}else{
		$("#mt-address-content-2").hide();
		$("#mt-address-content-1").html(getLoadHtml("正在加载")).show();
	}
	var cc_hrmmembers = $.trim($("#hrmmembers").val());
	var cc_begindate = $.trim($("#begindate").val());
	var cc_begintime = $.trim($("#begintime").val());
	var cc_enddate = $.trim($("#enddate").val());
	var cc_endtime = $.trim($("#endtime").val());
	if(pageType==2){//会议变更页面选择会议室
		if(cc_begindate!=""){
			var bs = cc_begindate.split(" ");
			cc_begindate = bs[0];
			cc_begintime = bs[1];
		}
		if(cc_enddate!=""){
			var es = cc_enddate.split(" ");
			cc_enddate = es[0];
			cc_endtime = es[1];
		}
	}
	$.ajax({
		type: "post",
	    url: "/mobile/plugin/5/meetingOperation.jsp",
	    data:{"operation":"getAddressList","type":type,"caller":$("#caller").val(),
	    	"recorder":$("#recorder").val(),"hrmmembers":cc_hrmmembers,"othermembers":$("#othermembers").val(),
	    	"ccmeetingnotice":$("#ccmeetingnotice").val(),"ccmeetingminutes":$("#ccmeetingminutes").val(),
	    	"begindate":cc_begindate,"begintime":cc_begintime,"enddate":cc_enddate,"endtime":cc_endtime}, 
	    dataType:"json",
	   	success:function(data){
	   		if(data.status==0){
	   			var temp = "";
	   			mtAddressList = data.addressList;
	   			if(mtAddressList!=null&&mtAddressList.length>0){
	   				for(var i=0;i<mtAddressList.length;i++){
	   					var mt = mtAddressList[i];
	   					var cls = "";
	   					if(mt.count>0){
	   						cls = "mt-conflic";
	   					}
	   					temp += '<div class="weui-media-box weui-media-box_text '+cls+'">'+
						  '<div class="addressSelect" onclick="sureAddress('+mt.id+',\''+mt.name+'\')">'+
						  '<i class="icon icon-71"></i></div>'+
					      '<div class="weui-media-box__title" onclick="viewAddress('+i+')">'+mt.name+'</div>'+
					      '<ul class="weui-media-box__info">'+
					      '  <li class="weui-media-box__info__meta">'+mt.roomdesc+'</li>'+
					      '</ul>'+
					      '<p class="weui-media-box__desc">所属机构：'+mt.subcompanyName+'&nbsp;&nbsp;|&nbsp;&nbsp;负责人：'+
					      mt.hrmName+'&nbsp;&nbsp;|&nbsp;&nbsp;可容纳：'+mt.humnum+'人</p>'+
					    '</div>';
	   				}
	   			}else{
	   				temp = getTipsHtml("没有会议室");
	   			}
	   			$("#mt-address-content-"+type).html(temp);
	   		}else{
	   			$.alert(data.msg);
	   		}
	   	},
	    complete: function(data){
	    	
		}
    });
}
//加载外来人员数据
function loadOutUser(othermembers){
	$.ajax({
		type: "post",
	    url: "/mobile/plugin/5/meetingOperation.jsp",
	    data:{"operation":"getOutUsers"}, 
	    dataType:"json",
	   	success:function(data){
	   		if(data.status==0){
	   			var temp = "";
	   			var mts = data.outUsers;
	   			if(mts!=null&&mts.length>0){
	   				if(othermembers!=""){
	   					othermembers = ","+othermembers+",";
	   				}
	   				for(var i=0;i<mts.length;i++){
	   					var mt = mts[i];
	   					var checked = "";
	   					if(othermembers.indexOf(","+mt.id+",")>-1){
	   						checked = "checked";
	   					}
	   					temp += '<div class="weui-cells mt-outuser-checkbox weui-cells_checkbox">'+
				   			    '  <label class="weui-cell weui-check__label" for="mt-outuser-'+mt.id+'">'+
				   			    '    <div class="weui-cell__hd">'+
				   			    '		<input type="checkbox" class="weui-check" name="mt-outuser-checkbox" '+
				   			    '			id="mt-outuser-'+mt.id+'" username="'+mt.name+'" value="'+mt.id+'" '+checked+'>'+
				   			    '		<i class="weui-icon-checked"></i>'+
				   			    '    </div>'+
				   			    '    <div class="weui-cell__bd">'+
				   			    '		<p>'+mt.name+'</p>'+
				   			    '		<p>'+mt.company+'</p>'+
				   			    '    </div>'+
				   			    '    <div class="weui-cell__ft">'+
				   			    '		'+mt.duties+
				   			    '    </div>'+
				   			    '  </label>'+
				   			    '</div>';
	   				}
	   				temp += '<div class="btn-wrapper">'+
	   						'	<a href="javascript:sureOutUser()" class="weui-btn weui-btn_primary" style="color:#fff;">确定</a>'+
	   						'</div>';
	   			}else{
	   				temp =  getTipsHtml("没有外来人员");
	   			}
	   			$("#mt-outuser-content").html(temp);
	   			outUserLoaded = true;
	   		}else{
	   			$.alert(data.msg);
	   		}
	   	},
	    complete: function(data){
	    	
		}
    });
}
//确定外来人员选择
function sureOutUser(){
	var ids = "",names = "";
	$("input[name='mt-outuser-checkbox']:checked").each(function(){
		var id = $(this).val();
		var username = $(this).attr("username");
		ids += ","+id;
		names += ","+username;
	});
	if(ids!=""){
		ids = ids.substring(1);
	}
	if(names!=""){
		names = names.substring(1);
	}
	$("#othermembersSpan").html(names);
	$("#othermembers").val(ids);
	
	otherNums = ids.split(",").length;
	countNum();
	$.closePopup();
	popOpen = false;
}
//确定会议室选择
function sureAddress(id,name){
	var addressValue=$("#address").val();
	if(addressValue===''){
		$("#addressSpan").html(name);
		$("#address").val(id);
	}else{
		$("#addressSpan").html($("#addressSpan").html()+","+name);
		$("#address").val(addressValue+","+id);
	}

	$.closePopup();
	popOpen = false;
}
//查看会议室详情
function viewAddress(i){
	var mt = mtAddressList[i];
	var temp = '<div class="weui-media-box weui-media-box_text">'+
    '<div class="weui-media-box__title">'+mt.name+'</div>'+
    '<ul class="weui-media-box__info">'+
    '  <li class="weui-media-box__info__meta">'+mt.roomdesc+'</li>'+
    '</ul>'+
    '<p class="weui-media-box__desc">所属机构：'+mt.subcompanyName+'&nbsp;&nbsp;|&nbsp;&nbsp;负责人：'+
    	mt.hrmName+'&nbsp;&nbsp;|&nbsp;&nbsp;可容纳：'+mt.humnum+'人</p>'+
    '</div>';
	$("#mt-ad-detail-div").html(temp);
	popOpen = true;
	addressOpen = true;
	$("#addressDetailPopup").popup();
	currentId = mt.id;
	loadAddressDetail();
}
function loadAddressDetail(){
	var itemWidth = $(".item-current").width();
	if(currentDay>3){
		$(".mt-ad-day").scrollLeft((currentDay-3)*itemWidth);
	}
	$("#mt-cells").html(getLoadHtml("正在获取数据..."));
	$.ajax({
		type: "post",
	    url: "/mobile/plugin/5/meetingOperation.jsp",
	    data:{"operation":"getAddressMT","addressid":currentId,"currentDay":currentDay,"currentMonth":$("#currentMonth").val()}, 
	    dataType:"json",
	   	success:function(data){
	   		if(data.status==0){
	   			var meetings = data.meetings;
	   			var temp = "";
				if(meetings.length>0){
					for(var i=0;i<meetings.length;i++){
						var m = meetings[i];
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
						temp +=    '<div class="weui-cell">'+
							       ' 	<div class="weui-cell__hd">'+m.begintime+'<br/>'+m.endtime+'<div>创建人:</div></div>'+
								   '     <div class="weui-cell__bd">'+
								   '       <p>'+m.name+'</p>'+
								   '       <p class="mt-address">'+m.roomname+'</p>'+
							       '<p>'+m.create+'</p>'+
								   '     </div>'+
							       ' 	<div class="weui-cell__ft '+classname+'">'+statusname+'</div>'+
							       '</div>';
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
	   		$("#mt-ad-content").pullToRefreshDone();
	   	}
    });
}
//查看二维码
function getQRCode(){
	var addressselect = $("#addressselect").attr("data-values");
	var address = $("#address").val();
	var customizeAddress = $("#customizeAddress").val();
	if((addressselect==1&&address=="")||(addressselect==2&&customizeAddress=="")){
		$.alert("请先选择会议室");
		return;
	}
	$("#mt-qrcode-content").html(getLoadHtml("正在生成二维码..."));
	popOpen = true;
	$("#qrcodepopup").popup();
	$.ajax({
		type: "post",
	    url: "/mobile/plugin/5/meetingOperation.jsp",
	    data:{"operation":"getQRCode","addressselect":addressselect,"address":address,"customizeAddress":customizeAddress}, 
	    dataType:"json",
	   	success:function(data){
	   		if(data.status==0){
	   			var temp = '<img src="'+data.imgFilePath+'"/>';
	   			//'<div class="downQRCode" onclick="downQRCode(\''+data.imgFilePath+'\')"><i class="icon icon-114 mt-submit-btn"></i>下载到手机</div>';
	   			$("#mt-qrcode-content").html(temp);
	   			$("#mt-qrcode-address").html($("#addressSpan").html());
	   		}else{
	   			$.alert(data.msg);
	   		}
	   	}
    });
}
//查看二维码
function getQRCode2(addressselect,address,customizeAddress){
	if(addressselect==0){//数据库保存的是0是内部会议室
		addressselect = 1;
	}else{
		addressselect = 2;
	}
	$("#mt-qrcode-content").html(getLoadHtml("正在生成二维码..."));
	popOpen = true;
	$("#qrcodepopup").popup();
	$.ajax({
		type: "post",
		url: "/mobile/plugin/5/meetingOperation.jsp",
		data:{"operation":"getQRCode","addressselect":addressselect,"address":address,"customizeAddress":customizeAddress}, 
		dataType:"json",
		success:function(data){
			if(data.status==0){
				var temp = '<img src="'+data.imgFilePath+'"/>';
				//'<div class="downQRCode" onclick="downQRCode(\''+data.imgFilePath+'\')"><i class="icon icon-114 mt-submit-btn"></i>下载到手机</div>';
				$("#mt-qrcode-content").html(temp);
				$("#mt-qrcode-address").html($("#addressSpan").html());
			}else{
				$.alert(data.msg);
			}
		}
	});
}
//下载二维码
function downQRCode(path){
	location = "/download.do?path="+path+"&from=meeting_qrcode&filename=meeting_qrcode.png";
}
//
function downLoadAttach(fileid,filename){
	location = "/download.do?url="+fileid+"&filename="+filename;
}
//展示创建议程弹出层
function showTopic(index,type){
	resetTopic(index,type);
	popOpen = true;
	$("#topicpopup").popup();
}
//重置议程新增界面的值
function resetTopic(index,type){
	var tc_xuhao = "";
	var tc_subject = "";
	var tc_hrmids = "";
	var tc_hrmspans = "";
	var tc_jcd = "";
	var tc_startdate = selectDay;
	var tc_enddate = selectDay;
	var tc_starttime = $("#begintime").val()||"09:00";
	var tc_endtime = $("#endtime").val()||"22:00";
	if(index!=-1){
		tc_xuhao = $("#tc_xuhao_"+index).val();
		tc_subject = $("#tc_subject_"+index).val();
		tc_hrmids = $("#tc_hrmids_"+index).val();
		tc_hrmspans = $("#tc_hrmspans_"+index).val();
		tc_jcd = $("#tc_jcd_"+index).val();
		tc_startdate = $("#tc_startdate_"+index).val();
		tc_enddate = $("#tc_enddate_"+index).val();
		tc_starttime = $("#tc_starttime_"+index).val();
		tc_endtime = $("#tc_endtime_"+index).val();
	}
	$("#tc_index").val(index);
	$("#tc_xuhao").val(tc_xuhao);
	$("#tc_subject").val(tc_subject);
	$("#tc_hrmids").val(tc_hrmids);
	$("#tc_hrmspans").html(tc_hrmspans);
	$("#tc_jcd").val(tc_jcd);
	$("#tc_startdate").val(tc_startdate);
	$("#tc_enddate").val(tc_enddate);
	$("#tc_starttime").val(tc_starttime);
	$("#tc_endtime").val(tc_endtime);
	//设置时间范围
	var a = $("#begindate").val();
	var c = $("#enddate").val();
	if(type==2){
		var change_begindate = $.trim($("#begindate").val());
		var change_enddate = $.trim($("#enddate").val());
		try{
			var bs = change_begindate.split(" ");
			var es = change_enddate.split(" ");
			a = bs[0];
			c = es[0];
		}catch(e){
			
		}
	}
	$("#tc_startdate").attr("min",a).attr("max",c);
	$("#tc_enddate").attr("min",a).attr("max",c);
}
//执行保存议程动作
var topicIndex = 0;
function addTopic(type){//type 1:新建页面添加 2：变更页面添加
	var tc_index = $("#tc_index").val();
	var tc_xuhao = $("#tc_xuhao").val();
	var tc_subject = $("#tc_subject").val();
	var tc_hrmids = $("#tc_hrmids").val();
	var tc_hrmspans = $("#tc_hrmspans").html();
	var tc_jcd = $("#tc_jcd").val();
	var tc_startdate = $("#tc_startdate").val();
	var tc_enddate = $("#tc_enddate").val();
	var tc_starttime = $("#tc_starttime").val();
	var tc_endtime = $("#tc_endtime").val();
	
	if(tc_subject==""){
		$.alert("请输入议题",function(){
			$("#tc_subject").focus();
		});
		return;
	}
//	if(tc_hrmids==""){
//		$.alert("请选择决策人",function(){
//			selectUser('tc_hrmids','tc_hrmidsSpan',0);
//		});
//		return;
//	}
	if(compDateTime(tc_startdate,tc_starttime,tc_enddate,tc_endtime)){
		$.alert("议程开始时间不能大于结束时间");
		return;
	}
	
	var mt_begindate = $.trim($("#begindate").val());
	var mt_begintime = $.trim($("#begintime").val());
	var mt_enddate = $.trim($("#enddate").val());
	var mt_endtime = $.trim($("#endtime").val());
	if(type==2){
		var change_begindate = $.trim($("#begindate").val());
		var change_enddate = $.trim($("#enddate").val());
		if(change_begindate==""||change_enddate==""){
			$.alert("会议开始时间和结束时间不能为空");
			return;
		}
		var bs = change_begindate.split(" ");
		var es = change_enddate.split(" ");
		mt_begindate = bs[0];
		mt_begintime = bs[1];
		mt_enddate = es[0];
		mt_endtime = es[1];
	}
	if(mt_begindate==""||mt_begintime==""||mt_enddate==""||mt_endtime==""){
		$.alert("会议开始时间和结束时间不能为空");
		return;
	}
	if(compDateTime2(mt_begindate,mt_begintime,tc_startdate,tc_starttime)){
		$.alert("议程开始时间不能小于会议开始时间");
		return;
	}
	if(compDateTime2(tc_enddate,tc_endtime,mt_enddate,mt_endtime)){
		$.alert("议程结束时间不能大于会议结束时间");
		return;
	}
	
	var temp =  '<div class="weui-cell weui-cell_access mt-topic-add-div" id="topic_item_'+topicIndex+'">'+
				'	<div class="weui-cell__hd" onclick="deleteTopic('+topicIndex+')">'+
				'		<div class="mt-topic-bgimg"><i class="icon icon-26"></i></div>'+
				'	</div>'+
				'	<div class="weui-cell__bd">'+tc_subject+'</div>'+
				'	<div class="weui-cell__ft" onclick="showTopic('+topicIndex+','+type+')">'+tc_starttime+'-'+tc_endtime+'</div>'+
				'	<input type="hidden" name="tc_xuhao" id="tc_xuhao_'+topicIndex+'" value="'+tc_xuhao+'"/>'+
				'	<input type="hidden" name="tc_subject" id="tc_subject_'+topicIndex+'" value="'+tc_subject+'"/>'+
				'	<input type="hidden" name="tc_hrmids" id="tc_hrmids_'+topicIndex+'" value="'+tc_hrmids+'"/>'+
				'	<input type="hidden" name="tc_hrmspans" id="tc_hrmspans_'+topicIndex+'" value="'+tc_hrmspans+'"/>'+
				'	<input type="hidden" name="tc_jcd" id="tc_jcd_'+topicIndex+'" value="'+tc_jcd+'"/>'+
				'	<input type="hidden" name="tc_startdate" id="tc_startdate_'+topicIndex+'" value="'+tc_startdate+'"/>'+
				'	<input type="hidden" name="tc_enddate" id="tc_enddate_'+topicIndex+'" value="'+tc_enddate+'"/>'+
				'	<input type="hidden" name="tc_starttime" id="tc_starttime_'+topicIndex+'" value="'+tc_starttime+'"/>'+
				'	<input type="hidden" name="tc_endtime" id="tc_endtime_'+topicIndex+'" value="'+tc_endtime+'"/>'+
				'</div>';
	if(tc_index==-1){
		$(".mt-add-topic").append(temp);
	}else{
		$("#topic_item_"+tc_index).after(temp);
		$("#topic_item_"+tc_index).remove();
	}
	$.closePopup();
	popOpen = false;
	topicIndex++;
}
//删除议程
function deleteTopic(index){
	$.confirm("确定删除该议程吗？",function(){
		$("#topic_item_"+index).remove();
	});
}
//加载议程数据
function loadTopic(){
	$.showLoading();
	$.ajax({
		type: "post",
	    url: "/mobile/plugin/5/meetingOperation.jsp",
	    data:{"operation":"loadTopic","meetingid":meetingid}, 
	    dataType:"json",
	   	success:function(data){
	   		if(data.status==0){
	   			topicLoaded = true;
	   			var topicList = data.topicList;
	   			var temp = "";
	   			if(topicList.length>0){
	   				for(var i=0;i<topicList.length;i++){
	   					var topic = topicList[i];
	   					var teindex = "e_"+topic.id;
	   					temp +=  '<div class="weui-cell weui-cell_access mt-topic-add-div" id="topic_item_'+teindex+'">'+
			   					'	<div class="weui-cell__hd" onclick="deleteTopic(\''+teindex+'\')">'+
			   					'		<div class="mt-topic-bgimg"><i class="icon icon-26"></i></div>'+
			   					'	</div>'+
			   					'	<div class="weui-cell__bd">'+topic.subject+'</div>'+
			   					'	<div class="weui-cell__ft" onclick="showTopic(\''+teindex+'\',2)">'+topic.starttime+'-'+topic.endtime+'</div>'+
			   					'	<input type="hidden" name="tc_xuhao" id="tc_xuhao_'+teindex+'" value="'+topic.xuhao+'"/>'+
			   					'	<input type="hidden" name="tc_subject" id="tc_subject_'+teindex+'" value="'+topic.subject+'"/>'+
			   					'	<input type="hidden" name="tc_hrmids" id="tc_hrmids_'+teindex+'" value="'+topic.hrmids+'"/>'+
			   					'	<input type="hidden" name="tc_hrmspans" id="tc_hrmspans_'+teindex+'" value="'+topic.hrmspans+'"/>'+
			   					'	<input type="hidden" name="tc_jcd" id="tc_jcd_'+teindex+'" value="'+topic.jcd+'"/>'+
			   					'	<input type="hidden" name="tc_startdate" id="tc_startdate_'+teindex+'" value="'+topic.startdate+'"/>'+
			   					'	<input type="hidden" name="tc_enddate" id="tc_enddate_'+teindex+'" value="'+topic.enddate+'"/>'+
			   					'	<input type="hidden" name="tc_starttime" id="tc_starttime_'+teindex+'" value="'+topic.starttime+'"/>'+
			   					'	<input type="hidden" name="tc_endtime" id="tc_endtime_'+teindex+'" value="'+topic.endtime+'"/>'+
			   					'</div>';
	   				}
	   				$("#mt-topicList-div").append(temp);
	   			}
	   			var attachList = data.topicAttatchList;
	   			var temp2 = "";
	   			if(attachList.length>0){
	   				for(var i=0;i<attachList.length;i++){
	   					var attach = attachList[i];
	   					temp2 += '<div class="weui-cell weui-cell_access" onclick="downLoadAttach('+attach.fileid+',\''+attach.filename+'\')">'+
	   							'	<div class="weui-cell__bd">'+attach.filename+'</div>'+
	   							'	<div class="weui-cell__ft">'+attach.filesize+'</div>'+
	   							'</div>';
	   				}
	   				$("#mt-topicAttachList-div").append(temp2).show();
	   			}else{
	   				$("#mt-topicAttachList-div").hide();
	   			}
	   		}else{
	   			$.alert(data.msg);
	   		}
	   	},
	    complete: function(data){
	    	$.hideLoading();
		}
    });
}
//检查时间 ctype 1,2,3,4 开始日期、时间、结束日期、时间 checktype 1:会议信息 2:议程信息 3:会议室查询
function checkTime(obj,ctype,checktype){
	var cc_begindate = $("#begindate").val();
	var cc_begintime = $("#begintime").val();
	var cc_enddate = $("#enddate").val();
	var cc_endtime = $("#endtime").val();
	if(checktype==2){
		cc_begindate = $("#tc_startdate").val();
		cc_begintime = $("#tc_starttime").val();
		cc_enddate = $("#tc_enddate").val();
		cc_endtime = $("#tc_endtime").val();
	}
	if(cc_begindate==""||cc_enddate==""){
		return;
	}
//	if(cc_begindate==cc_enddate){
//		if(cc_begintime!=""&&cc_endtime!=""){
//			if(comptime(cc_begindate,cc_begintime,cc_endtime)){
//				if(ctype==2){
//					$.alert("开始时间不能大于结束时间");
//					$(obj).val(cc_endtime);
//				}else if(ctype==4){
//					$.alert("结束时间不能小于开始时间");
//					$(obj).val(cc_begintime);
//				}
//			}
//		}
//	}else if(compdate(cc_begindate,cc_enddate)){//
//		if(ctype==1){
//			$.alert("开始日期不能大于结束日期");
//			$(obj).val(cc_enddate);
//		}else if(ctype==3){
//			$.alert("结束日期不能小于开始日期");
//			$(obj).val(cc_begindate);
//		}
//	}
	if(checktype==1){
		countCost();
	}
}
function submitMT(saveType){// saveType 1保存 2提交
	var meetingtype = $.trim($("#meetingtype").val());
	if(meetingtype==""){
		$.alert("请选择会议类型",function(){
			showMtType();
		});
		return;
	}
	var name = $.trim($("#name").val());
	if(name==""){
		$.alert("请输入会议名称",function(){
			$("#name").focus();
		});
		return;
	}
	var caller = $.trim($("#caller").val());
	if(caller==""){
		$.alert("请选择会议主持人",function(){
			selectUser('caller','callerSpan',0);
		});
		return;
	}
	var hrmmembers = $.trim($("#hrmmembers").val());
	if(hrmmembers==""){
		$.alert("请选择会议参与人",function(){
			selectUser('hrmmembers','hrmmembersSpan',1);
		});
		return;
	}
	var a = $.trim($("#begindate").val());
	var b = $.trim($("#begintime").val());
	var c = $.trim($("#enddate").val());
	var d = $.trim($("#endtime").val());
	if(a==""||b==""||c==""||d==""){
		$.alert("会议时间不能为空");
		return;
	}
	if(compDateTime(a,b,c,d)){
		$.alert("开始日期时间不能大于结束日期时间");
		return;
	}
	var addressselect = $("#addressselect").attr("data-values");
	var address = $.trim($("#address").val());
	var customizeAddress = $.trim($("#customizeAddress").val());
	if(addressselect==1&&address==""){
		$.alert("请选择会议室",function(){
			showAddress(2,1);
		});
		return;
	}
	if(addressselect==2&&customizeAddress==""){
		$.alert("请输入自定义会议地点",function(){
			$("#customizeAddress").focus();
		});
		return;
	}
	var isagenda = $("#meetingtype").attr("isagenda");
	if(isagenda==1){//必须包含会议议程
		if($(".mt-topic-add-div").length<=0){
			$.alert("该会议类型必须要关联会议议程",function(){
				$("#mt-add-topic-btn").click();
			});
			return;
		}
	}
	if(addressselect==1&&checkAddress(address,a,b,c,d,"")==1){
		$.alert("该会议室存在冲突,请重新选择");
		return;
	}
	var confirmText = "确定提交会议?";
	if(saveType===1){
		confirmText = "确定保存会议";
	}
	$.confirm(confirmText,function(){
		$.showLoading();
		$("#meetingForm").ajaxSubmit({
			dataType:"json",
			data:{"operation":"saveMT","roomType":addressselect,
				"remindTypeNew":$("#remindTypeNew").attr("data-values"),"saveType":saveType
				},
			success:function(data){
				if(data.status==0){
					if(data.formid&&data.formid == "85"){
						$.ajax({
				  			type: "post",
				  			url: '/mobile/plugin/5/BillMeetingOperation.jsp',
				  			data: {"src":"submit","iscreate":1,"MeetingID":data.meetingid,
				  				"approvewfid":data.approvewfid,"viewmeeting":1,"formid":data.formid},
				  			success:function(){
				  				
				  			}
						});
					}
					$.toast("会议创建成功");
					location = "/mobile/plugin/5/detail.jsp?id="+data.meetingid;
				}else{
					$.hideLoading();
					$.alert(data.msg);
				}
			},
			error:function(data){
				$.alert(data);
				$.hideLoading();
			}
		});
	});
}
//校验会议室是否存在冲突 0校验失败 1已存在 2不存在
function checkAddress(address,a,b,c,d,checkMTID){
	var ifExitsAddress = 0;
	$.ajax({
		type:"post",
		url:"/mobile/plugin/5/meetingOperation.jsp",
		data:{"operation":"checkAddress","address":address,"a":a,"b":b,"c":c,"d":d,"meetingid":checkMTID},
		dataType:"json",
		async:false,
		success:function(data){
			if(data.status==0){
				if(data.count>0){
					ifExitsAddress = 1;
				}else{
					ifExitsAddress = 2;
				}
			}else{
				//$.alert("校验会议室是否冲突失败:"+data.msg);
			}
		}
	});
	return ifExitsAddress;
}
function checkTime2(obj,type){
//	var begindate = $("#begindate").val();
//	var enddate = $("#enddate").val();
//	if(type==1&&begindate==""){
//		$("#begindate").val(enddate);
//		return;
//	}
//	if(type==2&&enddate==""){
//		$("#enddate").val(begindate);
//		return;
//	}
//	var bs = begindate.split(" ");
//	var es = enddate.split(" ");
//	if(compDateTime(bs[0],bs[1],es[0],es[1])){
//		if(type==1){
//			$.alert("开始时间不能大于结束时间",function(){
//				$("#begindate").val(enddate);
//			});
//		}else{
//			$.alert("结束时间不能小于开始时间",function(){
//				$("#enddate").val(begindate);
//			});
//		}
//	}
}
//日期比较 a>b true else false
function compdate(a, b) {
    var arr = a.split("-");
    var starttime = new Date(arr[0], arr[1]-1, arr[2]);
    var starttimes = starttime.getTime();

    var arrs = b.split("-");
    var lktime = new Date(arrs[0], arrs[1]-1, arrs[2]);
    var lktimes = lktime.getTime();

    if (starttimes > lktimes) {
        return true;
    }
    else
        return false;
}
//时间比较 a>b true else false
function comptime(d,a,b) {
    var arr = d.split("-");
    
    var time1 = a.split(":");
    var time2 = b.split(":");
    
    var starttime = new Date(arr[0], arr[1]-1, arr[2],time1[0],time1[1]);
    var starttimes = starttime.getTime();

    var lktime = new Date(arr[0], arr[1]-1, arr[2],time2[0],time2[1]);
    var lktimes = lktime.getTime();

    if (starttimes > lktimes) {
        return true;
    }
    else
        return false;
}
//日期时间比较 a+" "+b >=c+" "+d true else false
function compDateTime(a,b,c,d){
	try{
	    var arr1 = a.split("-");
	    var time1 = b.split(":");
	    var arr2 = c.split("-");
	    var time2 = d.split(":");
	    
	    var starttime = new Date(arr1[0], arr1[1]-1, arr1[2],time1[0],time1[1]);
	    var starttimes = starttime.getTime();
	
	    var endtime = new Date(arr2[0], arr2[1]-1, arr2[2],time2[0],time2[1]);
	    var endtimes = endtime.getTime();
	
	    if (starttimes >=endtimes) {
	        return true;
	    }
	    else
	        return false;
	}catch(e){
		return true;
	}
}
//日期时间比较 a+" "+b >c+" "+d true else false
function compDateTime2(a,b,c,d){
	try{
		var arr1 = a.split("-");
		var time1 = b.split(":");
		var arr2 = c.split("-");
		var time2 = d.split(":");
		
		var starttime = new Date(arr1[0], arr1[1]-1, arr1[2],time1[0],time1[1]);
		var starttimes = starttime.getTime();
		
		var endtime = new Date(arr2[0], arr2[1]-1, arr2[2],time2[0],time2[1]);
		var endtimes = endtime.getTime();
		
		if (starttimes>endtimes) {
			return true;
		}
		else
			return false;
	}catch(e){
		return true;
	}
}
function getDaysInMonth(year,month){
	month = parseInt(month,10);
	var temp = new Date(year,month,0);
	return temp.getDate();
}