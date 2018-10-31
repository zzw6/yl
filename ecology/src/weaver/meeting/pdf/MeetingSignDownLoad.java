package weaver.meeting.pdf;

import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import java.awt.Color;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.meeting.MeetingSign;

public class MeetingSignDownLoad extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		BaseBean bb = new BaseBean();
		String filename = this.CreatePdfSign(request);
		if(!"".equals(filename))
		try {
			String path = weaver.general.GCONST.getRootPath() + "signfile" + File.separatorChar + "meetingSignPDF.pdf";
			if (!"".equals(path)) {
				File file = new File(path);
				if (file.exists()) {
					InputStream ins = null;
					BufferedInputStream bins = null;
					OutputStream outs = null;
					BufferedOutputStream bouts = null;
					try {

						ins = new FileInputStream(path);
						bins = new BufferedInputStream(ins);//放到缓冲流里面 
						outs = response.getOutputStream();//获取文件输出IO流 
						bouts = new BufferedOutputStream(outs);
						response.setContentType("application/x-download");//设置response内容的类型 
						response.setHeader("Content-disposition", "attachment;filename=\"" + java.net.URLEncoder.encode(filename+".pdf","UTF-8") + "\"");//设置头部信息 
						int bytesRead = 0;
						byte[] buffer = new byte[8192];
						//开始向网络传输文件流 
						while ((bytesRead = bins.read(buffer, 0, 8192)) != -1) {
							bouts.write(buffer, 0, bytesRead);
						}
						bouts.flush();//这里一定要调用flush()方法 
						ins.close();
						bins.close();
						outs.close();
						bouts.close();
					} catch (Exception ef) {
						bb.writeLog("MeetingSignDownLoad doGet Exception" + ef);
					} finally {

						if (ins != null)
							ins.close();
						if (bins != null)
							bins.close();
						if (outs != null)
							outs.close();
						if (bouts != null)
							bouts.close();
					}

				} 
			}
		} catch (IOException e) {
			bb.writeLog("MeetingSignDownLoad doGet Exception" + e);
		}
	}
	
	public String CreatePdfSign(HttpServletRequest request) {
		String meetingid = Util.null2String(request.getParameter("meetingid"));
		String userid = Util.null2String(request.getParameter("userid"));
		String depid = Util.null2String(request.getParameter("depid"));
		String status = Util.null2String(request.getParameter("status"));
		BaseBean bb = new BaseBean();
		RecordSet rs = null;
		MeetingSign ms = null;
		FileOutputStream out = null;
		String meetingname = "";
		try {
			rs = new RecordSet();
			ms = new MeetingSign();
			ms.setType("1");
			String filePath = weaver.general.GCONST.getRootPath() + "signfile" + File.separatorChar;
			weaver.file.FileManage.createDir(filePath);
			File file = new File(filePath + "meetingSignPDF.pdf");
			Document document = new Document(PageSize.A4, 10, 10, 10, 10);
			out = new FileOutputStream(file);
			PdfWriter writer = PdfWriter.getInstance(document, out);
			document.open();

			BaseFont bfChinese = BaseFont.createFont("STSong-Light","UniGB-UCS2-H", BaseFont.NOT_EMBEDDED);//设置中文字体
			
			int CELLHIGHT = 25;//行高
			rs.executeProc("Meeting_SelectByID",meetingid);
			rs.next();
			meetingname=rs.getString("name");
			String addressselect = rs.getString("addressselect");
			String address=rs.getString("address");
			String customizeAddress = Util.null2String(rs.getString("customizeAddress"));
			String begindate=rs.getString("begindate") + " " + rs.getString("begintime");
			String enddate=rs.getString("enddate") + " " + rs.getString("endtime");
			String addressName = "";
			if("0".equals(addressselect)){
				rs.executeSql("select name from MeetingRoom where id = '"+address+"'");
				if(rs.next()){
					addressName = Util.null2String(rs.getString("name"));
				}
			}else{
				addressName = customizeAddress;
			}
			//中文，加粗
			Font titlefont = new Font(bfChinese, 18, Font.BOLD); //标题字体
			Font headfont = new Font(bfChinese, 8, Font.BOLD);//首行字体
			Font contentfont = new Font(bfChinese, 8, Font.HELVETICA);//内容字体

			Paragraph title = new Paragraph(meetingname+" - 会议签到情况", titlefont);
			title.setAlignment(Element.ALIGN_CENTER);//居中
			document.add(title);
			Paragraph title1 = new Paragraph("\n");
			document.add(title1);
			//创建表格对象
			PdfPTable table = new PdfPTable(2);
			int[] cellsWidth = { 5, 10};
			table.setWidths(cellsWidth);
			table.setWidthPercentage(100);
			table.getDefaultCell().setHorizontalAlignment(Element.ALIGN_CENTER);
			table.getDefaultCell().setVerticalAlignment(Element.ALIGN_MIDDLE);
			table.getDefaultCell().setFixedHeight(CELLHIGHT);
			//设置表格边框颜色
			table.getDefaultCell().setBackgroundColor(new Color(0, 0, 0));
			//设置单元格的边距间隔等
			table.getDefaultCell().setPadding(0);
			table.getDefaultCell().setBorderWidth(0);
			//单元格对象
			PdfPCell cell = null;
			Paragraph cel = null;
			
			/*begin 基本信息*/
			cel = new Paragraph("会议名称", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setColspan(1);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			table.addCell(cell);
			
			cel = new Paragraph(meetingname, contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			table.addCell(cell);
			
			cel = new Paragraph("开始时间", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setColspan(1);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			table.addCell(cell);
			
			cel = new Paragraph(begindate, contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			table.addCell(cell);
			
			cel = new Paragraph("结束时间", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setColspan(1);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			table.addCell(cell);
			
			cel = new Paragraph(enddate, contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			table.addCell(cell);
			
			cel = new Paragraph("会议地点", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setColspan(1);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			table.addCell(cell);
			
			cel = new Paragraph(addressName, contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			table.addCell(cell);
			//////////////////////////////////////////////////////////////////////////////
			
			///会议签到情况start
			StringBuffer sqlStr = new StringBuffer();
			sqlStr.append("select a.memberid,a.membertype ");
			sqlStr.append(" from Meeting_Member2 a,hrmresource b  ");
			sqlStr.append(" where a.memberid = b.id ");
			sqlStr.append(" and a.meetingid = " + meetingid);
			if(!"".equals(userid)){
				sqlStr.append(" and a.memberid = " + userid);
			}
			if(!"".equals(depid)){
				sqlStr.append(" and b.departmentid = " + depid);
			}
			if(!"".equals(status)){
				if("0".equals(status)){
					sqlStr.append("  and a.memberid not in (select members from uf_meetingsignin where meetingid = "+ meetingid +")  ");
				}else{
					sqlStr.append(" and a.memberid in (select members from uf_meetingsignin where meetingid = "+ meetingid +") " );
				}
			}
			sqlStr.append(" order by a.id asc");
			rs.executeSql(sqlStr.toString());
			//创建表格对象
			PdfPTable attachTable = new PdfPTable(5);
			int[] attachcellsWidth = new int[5];
			for(int z =0 ; z<5; z++){
				attachcellsWidth[z] = 10;
			}
			attachTable.setWidths(attachcellsWidth);
			attachTable.setWidthPercentage(100);
			attachTable.getDefaultCell().setHorizontalAlignment(Element.ALIGN_CENTER);
			attachTable.getDefaultCell().setVerticalAlignment(Element.ALIGN_MIDDLE);
			attachTable.getDefaultCell().setFixedHeight(CELLHIGHT);
			//设置表格边框颜色
			attachTable.getDefaultCell().setBackgroundColor(new Color(0, 0, 0));
			//设置单元格的边距间隔等
			attachTable.getDefaultCell().setPadding(0);
			attachTable.getDefaultCell().setBorderWidth(0);
			//单元格对象
			cel = new Paragraph("会议签到记录", headfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(5);
			cell.setMinimumHeight(CELLHIGHT);
			attachTable.addCell(cell);
			
			cel = new Paragraph("姓名", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			attachTable.addCell(cell);
			
			cel = new Paragraph("部门", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			attachTable.addCell(cell);
			
			cel = new Paragraph("状态", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			attachTable.addCell(cell);
			
			cel = new Paragraph("签到日期", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			attachTable.addCell(cell);
			
			cel = new Paragraph("签到时间", contentfont);
			cel.setAlignment(Element.ALIGN_CENTER);
			cell = new PdfPCell(cel);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setColspan(1);
			cell.setMinimumHeight(CELLHIGHT);
			cell.setBackgroundColor(new Color(248, 248, 248)); //背景颜色
			attachTable.addCell(cell);
			
			while(rs.next()){
				String memberid = Util.null2String(rs.getString("memberid"));
				String membertype = Util.null2String(rs.getString("membertype"));
				String lastname = ms.getResourceOrCrmName1(memberid, membertype);
				String depname = ms.getDeptmentName(memberid, membertype);
				String statusName = ms.getMeetingSignin(meetingid, memberid);
				String signDate = ms.getMeetingSigninDate(meetingid, memberid);
				String signTime = ms.getMeetingSigninTime(meetingid, memberid);
				cel = new Paragraph(lastname, contentfont);
				cel.setAlignment(Element.ALIGN_CENTER);
				cell = new PdfPCell(cel);
				cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
				cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
				cell.setColspan(1);
				cell.setMinimumHeight(CELLHIGHT);
				attachTable.addCell(cell);
				
				cel = new Paragraph(depname, contentfont);
				cel.setAlignment(Element.ALIGN_CENTER);
				cell = new PdfPCell(cel);
				cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
				cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
				cell.setColspan(1);
				cell.setMinimumHeight(CELLHIGHT);
				attachTable.addCell(cell);
				
				cel = new Paragraph(statusName, contentfont);
				cel.setAlignment(Element.ALIGN_CENTER);
				cell = new PdfPCell(cel);
				cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
				cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
				cell.setColspan(1);
				cell.setMinimumHeight(CELLHIGHT);
				attachTable.addCell(cell);
				
				cel = new Paragraph(signDate, contentfont);
				cel.setAlignment(Element.ALIGN_CENTER);
				cell = new PdfPCell(cel);
				cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
				cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
				cell.setColspan(1);
				cell.setMinimumHeight(CELLHIGHT);
				attachTable.addCell(cell);
				
				cel = new Paragraph(signTime, contentfont);
				cel.setAlignment(Element.ALIGN_CENTER);
				cell = new PdfPCell(cel);
				cell.setHorizontalAlignment(Element.ALIGN_CENTER);//设置内容水平居中显示
				cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
				cell.setColspan(1);
				cell.setMinimumHeight(CELLHIGHT);
				attachTable.addCell(cell);
			}
			/*end 结束*/
			document.add(table);
			document.add(attachTable);
			document.close();
		} catch (Exception e) {
			bb.writeLog("MeetingSignDownLoad CreatePdfSign Exception" + e);
			return "";
		} finally {
			if (out != null) {

				try {
					//关闭输出文件流
					out.close();
				} catch (IOException e1) {
					bb.writeLog("MeetingSignDownLoad CreatePdfSign Exception" + e1);
					return "";
				}
			}
		}
		
		return meetingname;
	}

	public void DeletePdf(String fileName) throws Exception {
		File file = new File(fileName);
		if (file.exists()) {
			file.delete();
		}
	}
}
