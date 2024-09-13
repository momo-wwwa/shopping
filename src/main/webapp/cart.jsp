<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*" %>
<%!
String escapeCell(String s) {
	if (s == null || s.equals("")) {
		return "&nbsp;";
	}
	return s;
}

String getTableResult(String table, Connection conn) {
	String msg = "";
	String sql = "select * from " + table;

	try {
		Statement state = conn.createStatement();
		ResultSet rs = state.executeQuery(sql);
		ResultSetMetaData md = rs.getMetaData();
		int cols = md.getColumnCount();

		msg += "<h2>" + escapeCell(table) + "</h2>\n";
		msg += "<table border=\"1\">\n";

		// 表頭
		msg += "<tr><th>&nbsp;</th>";
		for (int i = 1; i <= cols; i++) {
			msg += "<th>" + escapeCell(md.getColumnLabel(i)) + "</th>";
		}
		msg += "</tr>\n";

		//data（name,description,priceのみ）	
		while(rs.next()){	
		msg += "<tr>";
		msg += "<td>" + rs.getRow() + "</td>";
		for (int i = 1; i <= cols; i++) {
			msg += "<td>" + escapeCell(rs.getString(i)) + "</td>";
		}
		msg += "</tr>\n";
		
		}

		msg += "</table>\n";
	} catch (SQLException e) {
		msg += "データベースの問い合わせでエラーが発生しました";
	}

	return msg;
}
%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

Connection conn = null;
String msg = "";

Class.forName("org.sqlite.JDBC");

// 引数は、shopping.dbの所在に基づき、適切な値に変更すること。
// Windowsのフォルダー区切り文字は「\」であっても，ここでは「/」を使用できる。
conn = DriverManager.getConnection("jdbc:sqlite:C:/Users/momon/web2024/shopping/shopping.db");
//conn = DriverManager.getConnection("jdbc:sqlite:C:/pleiades/2024-03/workspace/shopping/shopping.db");

msg += getTableResult("chosenproducts", conn);
conn.close();
%>
<!DOCTYPE html>
<html>
 <head>
  <meta charset="UTF-8">
  <title>カートを見る</title>
 </head>
 <body>
  <h1>カートを見る</h1>
  <%= msg %>
 </body>
</html>
<%-- ToDo:

--%>
