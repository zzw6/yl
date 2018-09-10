delete from workflow_browserurl where id=184
/
INSERT INTO workflow_browserurl (id,labelid,fielddbtype,browserurl,tablename,columname,keycolumname,linkurl) VALUES ( 184,24168,'varchar(400)','/systeminfo/BrowserMain.jsp?url=/meeting/Maint/MutilMeetingRoomBrowser.jsp?selectedids=','MeetingRoom','name','id','/meeting/Maint/MeetingRoom.jsp?id=')
/
alter table meetingroom add images varchar2(300)
/
alter table meeting add (addressnew varchar2(4000),addressnew2 varchar2(4000))
/
update meeting set addressnew=address,addressnew2=ck_address
/
alter table meeting drop column address
/
alter table meeting rename column addressnew to address
/
alter table meeting drop column ck_address
/
alter table meeting rename column addressnew2 to ck_address
/
ALTER table MeetingRoom add  hrmids VARCHAR2(300)
/
update meetingroom set hrmids=hrmid
/
CREATE OR REPLACE PROCEDURE Meeting_Insert(meetingtype_1 integer, name_1 varchar2, caller_1 integer, contacter_1 integer, projectid_1 integer, address_1 varchar2, begindate_1 varchar2, begintime_1 varchar2, enddate_1 varchar2, endtime_1 varchar2, desc_n_1 varchar2, creater_1 integer, createdate_1 varchar2, createtime_1 varchar2, totalmember_1 integer, othermembers_1 clob, addressdesc_1 varchar2, description_1 varchar2, remindType_1 integer, remindBeforeStart_1 integer, remindBeforeEnd_1   integer, remindTimesBeforeStart_1 integer, remindTimesBeforeEnd_1 integer, customizeAddress_1 varchar2, flag out integer, msg out varchar2, thecursor IN OUT cursor_define.weavercursor) AS begin INSERT INTO Meeting (meetingtype, name, caller, contacter, projectid, address, begindate, begintime, enddate, endtime, desc_n, creater, createdate, createtime, totalmember, othermembers, addressdesc, description, remindType, remindBeforeStart, remindBeforeEnd, remindTimesBeforeStart, remindTimesBeforeEnd, customizeAddress) VALUES (meetingtype_1, name_1, caller_1, contacter_1, projectid_1, address_1, begindate_1, begintime_1, enddate_1, endtime_1, desc_n_1, creater_1, createdate_1, createtime_1, totalmember_1, othermembers_1, addressdesc_1, description_1, remindType_1, remindBeforeStart_1, remindBeforeEnd_1, remindTimesBeforeStart_1, remindTimesBeforeEnd_1, customizeAddress_1); end;
/
CREATE OR REPLACE PROCEDURE Meeting_Update(meetingid_1 integer, name_1 varchar2, caller_1  integer, contacter_1 integer, projectid_1 integer, address_1 varchar2, begindate_1 varchar2, begintime_1 varchar2, enddate_1 varchar2, endtime_1 varchar2, desc_n_1  varchar2, totalmember_1 integer, othermembers_1 clob, addressdesc_1 varchar2, description_1 varchar2, remindType_1 integer, remindBeforeStart_1 integer, remindBeforeEnd_1 integer, remindTimesBeforeStart_1 integer, remindTimesBeforeEnd_1 integer, customizeAddress_1 varchar2, flag out integer, msg out varchar, thecursor IN OUT cursor_define.weavercursor) AS begin Update Meeting set name = name_1, caller  = caller_1, contacter = contacter_1, projectid = projectid_1, address = address_1, begindate = begindate_1, begintime = begintime_1, enddate = enddate_1, endtime = endtime_1, desc_n  = desc_n_1, totalmember = totalmember_1, othermembers = othermembers_1, addressdesc = addressdesc_1, description = description_1, remindType = remindType_1, remindBeforeStart= remindBeforeStart_1, remindBeforeEnd  = remindBeforeEnd_1, remindTimesBeforeStart=remindTimesBeforeStart_1, remindTimesBeforeEnd=remindTimesBeforeEnd_1, customizeAddress = customizeAddress_1 where id = meetingid_1; end;
/
