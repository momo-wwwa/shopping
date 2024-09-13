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
			//data	
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

//テーブル名取得
List<String> getTableNames(Connection conn) {
    List<String> tableNames = new ArrayList<>();
    try {
        DatabaseMetaData metaData = conn.getMetaData();
        ResultSet rs = metaData.getTables(null, null, "%", new String[] { "TABLE" });
        while (rs.next()) {
            tableNames.add(rs.getString("TABLE_NAME"));
        }
    } catch (SQLException e) {
        // エラーハンドリング
    }
    return tableNames;
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
//conn = DriverManager.getConnection("jdbc:sqlite:/home/ubuntu/tomcat/webapps/shopping/WebContent/shopping.db");

List<String> tableNames = getTableNames(conn);


//テーブル名を元にプルダウンメニューを作成
msg += "<form method='post' action=''>";
msg += "<select name='table'>";
for (String tableName : tableNames) {
 msg += "<option value='"; 
	msg +=tableName; 
	msg += "\'>" ;
	msg += escapeCell(tableName) ;
	msg += "</option>";
}
msg += "</select>";
msg += "<input type='submit' value='次'>";
msg += "</form>";

String selectedTable = request.getParameter("table");
if (selectedTable != null && !selectedTable.isEmpty()) {
    msg += getTableResult(selectedTable, conn);
    
    // 新しいレコードを追加するフォームを表示
    msg += "<form method='post' action=''>";
    msg += "<input type='hidden' name='table' value='" + selectedTable + "'>";
    msg += "<input type='hidden' name='action' value='add'>";
    msg += "<h3>新しいレコードを追加</h3>";
    
    // カラム名を取得して入力フィールドを作成
    try {
        ResultSetMetaData md = conn.createStatement().executeQuery("SELECT * FROM " + selectedTable).getMetaData();
        int cols = md.getColumnCount();
        for (int i = 1; i <= cols; i++) {
            msg += "<label>" + escapeCell(md.getColumnLabel(i)) + ": <input type='text' name='col" + i + "'></label><br>";
        }
    } catch (SQLException e) {
        msg += "フィールドの生成中にエラーが発生しました: " + e.getMessage();
    }

    msg += "<input type='submit' value='追加'>";
    msg += "</form>";
}

//追加実装
if ("add".equals(request.getParameter("action"))) {
	msg = "";
    String selectedTableName = request.getParameter("table"); 
    try {
        ResultSetMetaData md = conn.createStatement().executeQuery("SELECT * FROM " + selectedTableName).getMetaData();
        int cols = md.getColumnCount();
        String columns = "";
        String values = "";
        
        for (int i = 1; i <= cols; i++) {
            String colName = md.getColumnLabel(i);
            String colValue = request.getParameter("col" + i);
            if (colValue != null && !colValue.isEmpty()) {
                if (!columns.isEmpty()) {
                    columns += ", ";
                    values += ", ";
                }
                columns += colName;
                values += "'" + colValue + "'";
            }
        }
        
        if (!columns.isEmpty() && !values.isEmpty()) {
            String insertQuery = "INSERT INTO " + selectedTableName + " (" + columns + ") VALUES (" + values + ")";
            Statement stmt = conn.createStatement();
            stmt.executeUpdate(insertQuery);
            msg += getTableResult(selectedTable, conn);
            msg += "<p>新しいレコードが追加されました。</p>";
        } else {
            msg += "<p>すべてのフィールドに値を入力してください。</p>";
        }
    } catch (SQLException e) {
        msg += "<p>レコードの追加中にエラーが発生しました: " + e.getMessage() + "</p>";
    }
}

conn.close();
%>
<!DOCTYPE html>
<html>
 <head>
  <meta charset="UTF-8">
  <title>データベースの各テーブルの状況</title>
 </head>
 <body>
  <h1>データベースの各テーブルの状況</h1>
  <%= msg %>
 </body>
</html>
<%-- ToDo:

--%>
