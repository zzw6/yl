$/ecology_8.000/data.jsp(V190)
$/ecology_8.000/meeting/data/AjaxMeetingOperation.jsp(V22)  //chkRoom 检验 后续修改
$/ecology_8.000/meeting/data/ChkMeetingRoom.jsp(V3),v4  // 和上面一样的逻辑 后续处理
$/ecology_8.000/meeting/data/EditMeeting.jsp(V37) //已处理
$/ecology_8.000/meeting/data/ViewMeeting.jsp(V34) //提醒无需处理
$/ecology_8.000/meeting/data/NewMeeting.jsp(V38)  // 已处理 逻辑多
$/ecology_8.000/meeting/data/MeetingOperation.jsp(V44)  //客户做了开发 后续再看
$/ecology_8.000/meeting/defined/wfAction.jsp(V6)  //	RecordSet1.execute("update workflow_base set custompage='/meeting/template/MeetingSubmitRequestJs.jsp',custompage4Emoble='/meeting/template/MeetingSubmitRequestJs4Mobile.jsp' where id="+id);



$/ecology_8.000/meeting/Maint/MutilMeetingRoomBrowser.jsp(V1)  //已更新
$/ecology_8.000/meeting/Maint/MutilMeetingRoomBrowserAjax.jsp(V1)  //已更新
$/ecology_8.000/meeting/Maint/MutilMeetingRoomBrowserChld.jsp(V1)  //已更新


$/ecology_8.000/meeting/report/GetRoomMeetingList.jsp(V22)


$/ecology_8.000/meeting/template/MeetingSubmitRequestJs.jsp(V1)
$/ecology_8.000/meeting/template/MeetingSubmitRequestJs4Mobile.jsp(V1)
$/ecology_8.000/mobile/plugin/1/js/view/1_wev8.js(V147) //提醒
$/ecology_8.000/src/weaver/meeting/action/WFMeetingAction.java(V9)


$/ecology_8.000/src/weaver/meeting/Maint/MeetingInterval.java(V41)  //伊利没有这一段

$/ecology_8.000/src/weaver/meeting/Maint/MeetingRoomComInfo.java(V4) // 没法改 差距太大 其他用到的地方改回来吧

$/ecology_8.000/src/weaver/meeting/Maint/MeetingRoomReport.java(V14)  //没有这个玩意

$/ecology_8.000/src/weaver/meeting/Maint/MeetingTransMethod.java(V31) 

$/ecology_8.000/src/weaver/meeting/MeetingUtil.java(V13) //没有使用

$/ecology_8.000/src/weaver/meeting/search/SearchComInfo.java(V4)



$/ecology_8.000/src/weaver/mobile/webservices/workflow/WorkflowServiceUtil.java(V145)

$/ecology_8.000/src/weaver/splitepage/transform/SptmForMeeting.java(V6)


//xz 0206

$/ecology_8.000/workflow/request/AddBillMeeting.jsp(V56)
$/ecology_8.000/workflow/request/ManageBillMeeting.jsp(V52)
$/ecology_8.000/workflow/request/WorkflowManageSign1.jsp(V84)
$/ecology_8.000/workflow/request/WorkflowManageRequestDetailBodyBill.jsp(V137)
$/ecology_8.000/workflow/request/WorkflowManageRequestDetailBody.jsp(V112)
$/ecology_8.000/workflow/request/WorkflowManageRequestBodyAction.jsp(V172)
$/ecology_8.000/workflow/request/WorkflowManageRequestBody.jsp(V66)
$/ecology_8.000/workflow/request/WorkflowAddRequestHtml.jsp(V98)
$/ecology_8.000/workflow/request/WorkflowAddRequestBodyAction.jsp(V167)
$/ecology_8.000/workflow/request/WorkflowAddRequestBody.jsp(V77)
$/ecology_8.000/workflow/workflow/editoperatorgroup_inner.jsp(V18)
$/ecology_8.000/workflow/workflow/addoperatorgroup_inner.jsp(V20)

使用QC185697脚本
  
$/ecology_8.000/sql/for Oracle/sql201605270601.sql(V1)  //标签
$/ecology_8.000/sql/for Oracle/sql201605260303.sql(V1)  //修改billfield
$/ecology_8.000/sql/for Oracle/sql201605170303.sql(V1)  //升级之前备份meeting表 meetingroom表
$/ecology_8.000/sql/for Oracle/sql201605130603.sql(V1)  //MEETING_UPDATE==MEETING_UPDATE.sql
$/ecology_8.000/sql/for Oracle/sql201605130503.sql(V1)  //MEETING_INSERT== MEETING_INSERT.sql
$/ecology_8.000/sql/for Oracle/sql201604210401.sql(V1)  //标签

存储过程修改备案
$/ecology_8.000/sql/SQLServer/meeting/Meeting_Insert.sql(V1)
$/ecology_8.000/sql/SQLServer/meeting/Meeting_Update.sql(V1)
$/ecology_8.000/sql/Oracle/meeting/MEETING_INSERT.sql(V1)
$/ecology_8.000/sql/Oracle/meeting/MEETING_UPDATE.sql(V1)

 $/ecology_8.000/sql/for Oracle/sql201605170303.sql(V2) //修改错误存储过程

 /

 【1610建模回归测试】自定义浏览框单选页面，查询条件中，自定义多选浏览框，选择多个值后，执行搜索，会合并成一个值，只有一个删除图标，附图。  注意一下
 
$/ecology_8.000/meeting/Maint/MutilMeetingRoomBrowserAjax.jsp(V2)
$/ecology_8.000/meeting/Maint/MutilMeetingRoomBrowserChld.jsp(V2)


$/ecology_8.000/meeting/data/ChkMeetingRoom.jsp(V4)


________________________________________
刘鸣枭 <lmx>, 2016/11/24: 

文件已更新至８０ｓ＼８０ｏ。问题２已解决。

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/24: ＼
问题４：新建编辑页面选择多个会议室后，在会议室选择框中点击第一个会议室后面的删除ｘ按钮，保存后，删除的会议室还在，后面的会议室反而被删除了。
问题５：会议系统表单和自定义表单流程页面选择多个会议室后，再打开会议室浏览框页面，右侧已选没有显示已选择的会议室．
问题６：自定义会议审批流程提交时，删除某个冲突的会议室，再提交，弹出的会议室冲突校验提示框中并没有去除已删除的冲突会议室，仍然显示在冲突会议室中，而没删除的冲突会议室反而没显示在冲突会议室中．
问题７：将会议地点会议室管理员作为会议审批流程的节点操作者，新建会议选择多个会议室时，提交会提示找不到节点操作者．（其实选择的会议室是有负责人字段的）
问题８：手机端新建会议流程页面会议室不支持多选．请修改．
  

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/24: 
解决问题4、6
$/ecology_8.000/src/weaver/meeting/defined/MeetingFieldManager.java(V10)
解决问题7
$/ecology_8.000/src/weaver/workflow/request/RequestNodeFlow.java(V220)
________________________________________
刘鸣枭 <lmx>, 2016/11/24: 
问题９：周期会议会议室冲突时向创建人发送的系统默认工作流中备注里面的会议室后面有多余逗号。
  

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/24: 

文件已更新至８０ｓ＼８０ｏ。ｃｌａｓｓ文件编译成功．问题４已解决．问题７已解决。

问题６更新代码重新测试，问题依然存在．

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/24: 

解决问题8
$/ecology_8.000/src/weaver/mobile/webservices/workflow/WorkflowServiceUtil.java(V146)

________________________________________
刘鸣枭 <lmx>, 2016/11/25: 

文件更新至８０ｓ＼８０ｏ．ｃｌａｓｓ文件编译成功．问题８已解决．

脚本在８０ｓ＼８０ｏ执行成功．测试８０ｏ环境上自定义表单流程会议室支持多选．

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 
问题１０：手机端自定义表单＼系统表单流程会议室冲突时的提示框中会议室显示乱码．

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 
修复问题10
$/ecology_8.000/meeting/data/ChkMeetingRoom.jsp(V4)

________________________________________
刘鸣枭 <lmx>, 2016/11/25: 

文件更新至８０ｓ＼８０ｏ.问题１０已解决。

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 

$/ecology_8.000/src/weaver/meeting/defined/MeetingFieldManager.java(V11)
$/ecology_8.000/workflow/request/WorkflowManageRequestBodyAction.jsp(V174)

________________________________________
刘鸣枭 <lmx>, 2016/11/25: 

文件更新至８０ｓ＼８０ｏ.ｃｌａｓｓ文件已编译成功。

问题１１：ｐｃ端自定义会议表单流程提交后页面一直显示：页面加载中，请稍后...的提示，页面一致无法提交过去。

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 
$/ecology_8.000/workflow/request/WorkflowManageRequestBodyAction.jsp(V175)

________________________________________
刘鸣枭 <lmx>, 2016/11/25: 
文件更新至８０ｓ＼８０ｏ.问题６＼１１已解决。

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 

为客户单独合并以下文件  其它文件全部取本QC中的标准文件
$/Z中银国际证券/data.jsp(V1)
$/Z中银国际证券/workflow/request/WorkflowAddRequestBody.jsp(V1)
$/Z中银国际证券/workflow/request/WorkflowAddRequestHtml.jsp(V1)
$/Z中银国际证券/workflow/request/WorkflowManageSign1.jsp(V1)
$/Z中银国际证券/src/weaver/mobile/webservices/workflow/WorkflowServiceUtil.java(V1)
$/Z中银国际证券/src/weaver/workflow/request/RequestNodeFlow.java(V1)

$/Z中银国际证券/data.jsp(V2)
$/Z中银国际证券/workflow/request/WorkflowAddRequestBody.jsp(V2)
$/Z中银国际证券/workflow/request/WorkflowAddRequestHtml.jsp(V2)
$/Z中银国际证券/workflow/request/WorkflowManageSign1.jsp(V2)
$/Z中银国际证券/src/weaver/mobile/webservices/workflow/WorkflowServiceUtil.java(V2)
$/Z中银国际证券/src/weaver/workflow/request/RequestNodeFlow.java(V2)
  

________________________________________
刘鸣枭 <lmx>, 2016/11/25: 

客户测试环境：\\192.168.7.180\weaver\ecology\
http://192.168.7.180:8080/

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 

现将以上所有标准文件更新至客户测试环境，更新完毕后再更新客户单独修改文件。

客户为ｏｒａｃｌｅ环境，执行标准的ｏｒａｃｌｅ脚本
________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 

问题１２：客户环境新建会议提交时报错。标准没有问题。
  

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 
$/Z中银国际证券/meeting/data/MeetingOperation.jsp(V1)
$/Z中银国际证券/meeting/data/MeetingOperation.jsp(V2)

________________________________________
刘鸣枭 <lmx>, 2016/11/25: 
文件更新至测试环境，问题１２已解决。

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 


问题１３：客户环境会议系统表单流程创建节点保存后或者审批节点直接查看会议地点（可编辑字段），多个会议室只有一个删除按钮。自定义表单流程没有这个问题。标准没有问题。


________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 

$/Z中银国际证券/js/workflow/wfbrow_wev8.js(V1)
$/Z中银国际证券/js/workflow/wfbrow_wev8.js(V2)
$/ecology_8.000/js/workflow/wfbrow_wev8.js(V171)
________________________________________
刘鸣枭 <lmx>, 2016/11/25: 

客户文件更新至测试环境，测试会议流程中会议地点浏览框右侧记住选择的会议室。

标准文件更新至８０ｓ＼８０ｏ，问题５已解决。

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/25: 
客户手机端环境地址：http://192.168.7.180:89

在手机端测试新建会议系统表单（普通＼周期会议）＼自定义表单（普通＼周期会议）多会议室冲突正确，多会议室选择删除显示正确。
________________________________________
刘耀霞 <liuyaoxia>, 2016/11/28: 

$/ecology_8.000/src/weaver/common/util/taglib/BrowserTag.java(V52)

________________________________________
刘鸣枭 <lmx>, 2016/11/28: 

以上标准文件Ｅ８标准环境上已有，更新至客户测试环境（检测文件版本连续）。class文件编译成功。

问题１３已解决。

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/28: 

标准Ｅ８　８０ｓ＼８０ｏ及对应的ｍｏｂｉｌｅ环境测试完毕。

客户环境测试完毕。提交打包。
客户环境在：\\192.168.7.180\weaver\ecology  

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/28: 
中银国际证券ZYGJZQecology20161128-005

  

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/28: 

由于００５的包里面有些文件用的标准的，重新将客户修改的文件覆盖打包出去。

中银国际证券ZYGJZQecology20161129-006

________________________________________
刘耀霞 <liuyaoxia>, 2016/11/29: 
KB8100161100

________________________________________
吴谦 <wq>, 2016/12/1: 

当前给客户打包的是正确的（客户单独修改的，标准１７１版本写的有ｂｕｇ少个＝号）
相当于标准的：
$/ecology_8.000/js/workflow/wfbrow_wev8.js(V172)   
171版本有bug，特此说明

________________________________________
刘鸣枭 <lmx>, 2016/12/6: 
此文件已全部更新到８０ｓ＼８０ｏ。（ｖ１７２ｃｋ改的，在这个ｑｃ231657中打包。）

________________________________________
刘耀霞 <liuyaoxia>, 2016/12/23: 













1)PC端，会议室占用情况的显示逻辑及每个会议室的会议预定情况的显示逻辑，会议室字段由单会议室改成多会议室；

2)PC端，s查询会议功能，查询条件及显示结果列表，会议室字段由单会议室改成多会议室；

3)PC端，会议延时调整功能，显示列表，会议室字段由单会议室改成多会议室；
//已处理

4)PC端，会议变更，可变更的会议室字段由单会议室变为多会议室；
//已处理
5)PC端，创建会议，会议室选择由单会议室变为多会议室；
//完成

6)PC端，创建会议生成会议室二维码功能，由原来的单会议室生成逻辑改为多会议室生成逻辑；

7)PC端，由会议模块生成的提醒邮件，涉及到会议室字段的相关代码改造。

8)移动端，参加会议，手机扫码逻辑更改。

9)移动端，根据参会人员签到情况判定会议室是否释放逻辑更改。

10)移动端，会议结束前，

11)，是否延时会议的判定逻辑更改。

12)移动端，创建会议，会议室选择由单会议室变为多会议室。

13)移动端，创建会议生成会议室二维码功能，由原来的单会议室生成逻辑改为多会议室生成逻辑；

14)移动端，由会议模块生成的E-message相关提醒，涉及到会议室字段的相关代码更改


//多会议室的时候怎么区别内部会议室和外部会议室



// mobile/plugin/5/meetingOperation.jsp 选择地点浏览按钮

http://110.16.74.104:89/