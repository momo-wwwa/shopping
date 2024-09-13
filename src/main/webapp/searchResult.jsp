<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.sql.*" %>

<%
	Integer user_id = (Integer) session.getAttribute("id");
	
	if(user_id == null){
		response.sendRedirect("auth.jsp");
		return;
	}
%>


<%!
String escapeCell(String s) {
    if (s == null || s.equals("")) {
        return "&nbsp;";
    }
    return s;
}

String getTableResult(String table, Connection conn, String productname) {
    String msg = "";
    String sql = "SELECT * FROM " + table + " WHERE name LIKE ?";

    try {
        PreparedStatement state = conn.prepareStatement(sql);
        state.setString(1, "%" + productname + "%"); // 部分一致を実現
        ResultSet rs = state.executeQuery();
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount(); 
        
        msg += "<h2>" + escapeCell(table) + "</h2>\n";
        msg += "<form method='post' action=''>"; // フォームをここで開始
        msg += "<table border=\"1\">\n";

        // 表頭
        msg += "<tr><th>&nbsp;</th>";
        for (int i = 2; i <= 4; i++) {
            msg += "<th>" + escapeCell(md.getColumnLabel(i)) + "</th>";
        }
        msg += "</tr>\n";

        // data
        while (rs.next()) {
            msg += "<tr>";
            msg += "<td><input type='radio' name='selectedRow' value='" + rs.getString(1) + "'></td>";  // 最初の列の値を選択
   
            for (int i = 2; i <= 4; i++) {
                msg += "<td>" + escapeCell(rs.getString(i)) + "</td>";
            }
            msg += "<input type='hidden' name='selectedRow6' value='" + rs.getString(6) + "'>";
            msg += "<input type='hidden' name='selectedRow7' value='" + rs.getString(7) + "'>";
            msg += "</tr>\n";
        }

        msg += "</table>\n";
        msg += "<input type='hidden' name='action' value='add'>";
        msg += "<label>個数: <input type='text' name='quantity'></label><br>";
        msg += "<input type='submit' value='カートに入れる'>";
        msg += "</form>"; // フォームをここで終了
    } catch (SQLException e) {
        msg += "データベースの問い合わせでエラーが発生しました: " + e.getMessage();
    }

    return msg;
}
%>

<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

Connection conn = null;
String msg = "";

try {
    Class.forName("org.sqlite.JDBC");
    String productname = request.getParameter("productName"); // 引継ぎ
    conn = DriverManager.getConnection("jdbc:sqlite:C:/Users/momon/web2024/shopping/shopping.db");

    if (productname != null && !productname.isEmpty()) {
        msg += getTableResult("products", conn, productname);
    }

    if ("add".equals(request.getParameter("action"))) {
        String selectedRow = request.getParameter("selectedRow");
        String selectedRow6 = request.getParameter("selectedRow6");
        String selectedRow7 = request.getParameter("selectedRow7");
        String quantity = request.getParameter("quantity");

        // デバッグ用メッセージ
        msg += "<p>選択された商品ID: " + selectedRow + "</p>";
        msg += "<p>入力された個数: " + quantity + "</p>";

        if (selectedRow != null && !selectedRow.isEmpty() && quantity != null && !quantity.isEmpty()) {
            try {
                // chosenproducts テーブルに挿入
                String insertQuery = "INSERT INTO chosenproducts (product_id, quantity, user_id, deleted, created_at) VALUES (?, ?, ?, ?, ?)";//4つに増やす
                PreparedStatement pstmt = conn.prepareStatement(insertQuery);
                pstmt.setInt(1, Integer.parseInt(selectedRow)); // 選択された product_id
                pstmt.setInt(2, Integer.parseInt(quantity)); // 入力された quantity
                pstmt.setInt(3, user_id); // user_id にデフォルト値を設定（必要に応じて変更）
                pstmt.setString(4, selectedRow6); // rs.getString(6) の値
                pstmt.setString(5, selectedRow7); // rs.getString(7) の値

                int rowsAffected = pstmt.executeUpdate();

                if (rowsAffected > 0) {
                    msg += "<p>選択された商品がカートに追加されました。</p>";
                } else {
                    msg += "<p>選択された商品の追加に失敗しました。</p>";
                }
            } catch (SQLException e) {
                msg += "<p>レコードの追加中にエラーが発生しました: " + e.getMessage() + "</p>";
            }
        } else {
            msg += "<p>商品を選択し、個数を入力してください。</p>";
        }
    }
} catch (Exception e) {
    msg += "<p>エラー: " + e.getMessage() + "</p>";
} finally {
    if (conn != null) {
        try {
            conn.close();
        } catch (SQLException e) {
            msg += "<p>データベース接続のクローズ中にエラーが発生しました: " + e.getMessage() + "</p>";
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>検索結果</title>
</head>
<body>
 <h1>検索結果</h1>
  <%= msg %><br>
  <form method="post" action="auth.jsp">
        <input type="submit" value="戻る"><br>
    </form>
  
</body>
</html>
