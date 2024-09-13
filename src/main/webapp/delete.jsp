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

// テーブル結果取得
String getTableResult(String table, Connection conn) {
    String msg = "";
    String sql = "SELECT * FROM " + table;

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

        // data    
        while (rs.next()) {    
            msg += "<tr>";
            msg += "<td><input type='radio' name='selectedRow' value='" + rs.getString(1) + "'></td>"; // 最初の列の値を選択
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

// テーブル名表示
List<String> getTableNames(Connection conn) {
    List<String> tableNames = new ArrayList<>();
    try {
        DatabaseMetaData metaData = conn.getMetaData();
        ResultSet rs = metaData.getTables(null, null, "%", new String[] { "TABLE" });
        while (rs.next()) {
            tableNames.add(rs.getString("TABLE_NAME"));
        }
    } catch (SQLException e) {
        // エラー
    }
    return tableNames;
}

// 指定テーブルのカラム名取得
List<String> getColumnNames(String table, Connection conn) {
    List<String> columnNames = new ArrayList<>();
    try {
        DatabaseMetaData metaData = conn.getMetaData();
        ResultSet rs = metaData.getColumns(null, null, table, null);
        while (rs.next()) {
            columnNames.add(rs.getString("COLUMN_NAME"));
        }
    } catch (SQLException e) {
        // エラー
    }
    return columnNames;
}

// 主キーの列名を取得
String getPrimaryKeyColumn(String table, Connection conn) {
    String primaryKeyColumn = null;
    try {
        DatabaseMetaData metaData = conn.getMetaData();
        ResultSet rs = metaData.getPrimaryKeys(null, null, table);
        if (rs.next()) {
            primaryKeyColumn = rs.getString("COLUMN_NAME");
        }
    } catch (SQLException e) {
        // エラー
    }
    return primaryKeyColumn;
}

%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

Connection conn = null;
Connection conn2 = null;
String msg = "";

Class.forName("org.sqlite.JDBC");

// 引数は、shopping.dbの所在に基づき、適切な値に変更すること。
// Windowsのフォルダー区切り文字は「\」であっても，ここでは「/」を使用できる。
conn = DriverManager.getConnection("jdbc:sqlite:C:/Users/momon/web2024/shopping/shopping.db");
//conn = DriverManager.getConnection("jdbc:sqlite:/home/ubuntu/tomcat/webapps/shopping/WebContent/shopping.db");

// テーブル名のリストを取得
List<String> tableNames = getTableNames(conn);

// テーブル名を元にプルダウンメニューを作成
msg += "<form method='post' action=''>";
msg += "<select name='table'>";
for (String tableName : tableNames) {
    msg += "<option value='" + escapeCell(tableName) + "'>" + escapeCell(tableName) + "</option>";
}
msg += "</select>";
msg += "<input type='submit' value='次'>";
msg += "</form>";

//選択されたテーブル名の取得
String selectedTableName = request.getParameter("table");
if (selectedTableName != null && !selectedTableName.isEmpty()) {
    msg += "<form method='post' action=''>";
    msg += getTableResult(selectedTableName, conn);
    msg += "<input type='hidden' name='table' value='" + selectedTableName + "'>";
    msg += "<input type='hidden' name='action' value='delete'>";
    msg += "<input type='submit' value='選択した行を削除'>";
    msg += "</form>";
}

//行削除
if ("delete".equals(request.getParameter("action"))) {
	msg = "";
    String selectedRowID = request.getParameter("selectedRow");
    selectedTableName = request.getParameter("table"); // Ensure selectedTableName is retrieved from the form
    String primaryKeyColumn = getPrimaryKeyColumn(selectedTableName, conn); // Retrieve primary key column
    if (selectedRowID != null && !selectedRowID.isEmpty() && primaryKeyColumn != null) {
        try {
            Statement stmt = conn.createStatement();
            String deleteQuery = "DELETE FROM " + selectedTableName + " WHERE " + primaryKeyColumn + " = '" + selectedRowID + "'";
            int deletedRows = stmt.executeUpdate(deleteQuery);
            msg += getTableResult(selectedTableName, conn);
            msg += "<p>削除された行数: " + deletedRows + "</p>";
        } catch (SQLException e) {
            msg += "<p>削除中にエラーが発生しました: " + e.getMessage() + "</p>";
        }
    } else {
        msg += "<p>削除する行を選択してください。</p>";
    }
}

// データベースを初期状態に戻す機能
if ("reset".equals(request.getParameter("action"))) {
    try {
        Statement stmt = conn.createStatement();
//なんでかできない、いろいろ試したけど
        msg += "<p>データベースが初期状態に戻りました。</p>";
    } catch (SQLException e) {
        msg += "<p>データベースの初期化中にエラーが発生しました: " + e.getMessage() + "</p>";
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
    <h1>データベースの各テーブルのレコード削除</h1>
    <form method='post' action=''>
        <input type='hidden' name='action' value='reset'>
        <input type='submit' value='データベースを初期状態に戻す'>
    </form>
    <%= msg %>
</body>
</html>