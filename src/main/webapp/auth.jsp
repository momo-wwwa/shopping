<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*" %>
<%
//杉若が担当
// HTTPパラメータ
//   u=ユーザ名 : ログイン用ユーザ名
//   p=パスワード : ログイン用パスワード
//   o : ログアウト
// セッションパラメータ
//   id : ユーザID
//   disp : 表示名

// リクエスト・レスポンスとも文字コードをUTF-8に
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

// DB接続
Class.forName("org.sqlite.JDBC");

// 変数定義
//   DB関連
Connection conn = null;
Statement state = null;
PreparedStatement pstate = null;
ResultSet rs = null;

//   HTTPパラメータ
String loginname = request.getParameter("u");
String password = request.getParameter("p");
String logout = request.getParameter("o");

//   その他
String sql = "";
String msg = "";
boolean authenticated = false; // すでに認証されているか，ログイン成功ならtrue
String displayname = "";
int user_id = -1;
boolean wrongway = true; // falseにするとPreparedStatementを使用

if (loginname == null) {
	loginname = "";
}
if (password == null) {
	password = "";
}

if (!loginname.isEmpty() && !password.isEmpty()) {
	// ユーザ名・パスワートによるログイン処理
	msg += "[DEBUG] loginname = " + loginname + ", password = " + password + "<hr>";

	// DB接続
	// 引数は，auth.dbの所在に基づき，適切な値に変更すること．
	conn = DriverManager.getConnection("jdbc:sqlite:C:/Users/momon/web2024/shopping/auth.db");
	// conn = DriverManager.getConnection("jdbc:sqlite:/home/ubuntu/tomcat/webapps/shopping/WebContent/auth.db");

	// 問い合わせ
	if (wrongway) {
		// 悪いやり方(SQLインジェクションが成功する)
		sql = "select user_id,displayname from users where loginname=\'"
		+ loginname + "\' and password=\'"
		+ password + "\'";
		state = conn.createStatement();
		rs = state.executeQuery(sql);
		msg += "[DEBUG] " + sql + "<hr>";
	} else {
		// プリペアドステートメントを使用(SQLインジェクションは成功しない)
		sql = "select user_id,displayname from users where loginname=? and password=?";
		pstate = conn.prepareStatement(sql);
		pstate.setString(1, loginname);
		pstate.setString(2, password);
		rs = pstate.executeQuery();
		msg += "[DEBUG] " + sql + " (using PreparedStatement)<hr>";
		// 実際に呼び出されるSQL文を獲得するのは，簡単でないらしい...
	}

	// 該当するレコードがあればログイン成功
	if (rs.next()) {
		authenticated = true;
		user_id = rs.getInt("user_id");
		displayname = rs.getString("displayname");
		session.setAttribute("id", user_id); // sessionは暗黙オブジェクト
		session.setAttribute("disp", displayname);
	} else {
		msg += "ユーザ名またはパスワードが間違っています。<hr>";
	}

	// DB接続終了
	if (state != null) {
		state.close();
		state = null;
	}
	if (pstate != null) {
		pstate.close();
		pstate = null;
	}
	if (conn != null) {
		conn.close();
		conn = null;
	}
} else if (session.getAttribute("id") != null) {
	// ログイン済みのとき
	authenticated = true;
	user_id = (int)session.getAttribute("id");
	displayname = (String)session.getAttribute("disp");
}

// ログアウト処理
if (authenticated == true && logout != null) {
	authenticated = false;
	user_id = -1;
	displayname = "";
	session.removeAttribute("id");
	session.removeAttribute("disp");
	// session.invalidate();
	msg = "ログアウトしました。<hr>";
}
%>
<!DOCTYPE html>
<% if (authenticated) { %>
<html>
	<head>
		<meta charset="UTF-8">
		<title>ようこそ</title>
	</head>
	<!-- ユーザーIDが0の場合、管理者用ページを開く-->
	<%if (user_id == 0) { %>
		<body>
		<h1>ようこそ，<%= displayname %>さん！</h1>
		<%= msg %>
		<ul>
			<li><a href="create.jsp">追加</a></li>
			<li><a href="showone.jsp">閲覧</a></li>
			<li><a href="updata.jsp">更新</a></li>
			<li><a href="delete.jsp">削除</a></li>
		</ul>
		</body>
	<!-- ユーザーIDが0より大きい場合、利用客用ページを開く-->
	<% } else if(user_id > 0) { %>
		<body>
			<h1>ようこそ，<%= displayname %>さん！</h1>
			<%= msg %>
			<ul>
				<li><a href="search.jsp">商品検索する</a></li>
				<li><a href="cart.jsp">カートを見る</a></li>
				<li><a href="<%= request.getRequestURI() %>">商品を購入する</a></li>
				<li><a href="<%= request.getRequestURI() %>?o">ログアウトする</a></li>
			</ul>
		</body>
	<% } %>
</html>
<% } else { %>
<html>
	<head>
		<meta charset="UTF-8">
		<title>ログインしてください</title>
	</head>
	<body>
		<h1>ログインしてください</h1>
		<%= msg %>
		<form action="<%= request.getRequestURI() %>" method="post">
			ユーザ名：<input type="text" name="u" size="20" value="<%= loginname %>"><br>
			パスワード：<input type="text" name="p" size="20" value="<%= password %>"><br>
			<input type="submit">
		</form>
	</body>
</html>
<!-- ユーザ名に「taro」，パスワードに「password」を入力すると，和大 太郎さんとしてログインできます。 -->
<!-- ユーザ名に「hanako」，パスワードに「pasuwado」を入力すると，和歌山 花子さんとしてログインできます。 -->
<!-- ユーザ名に「Admin」，パスワードに「' OR '1'='1」を入力すると，Adminのパスワードを知らない人でも管理者としてログインできてしまう? (SQLインジェクション)-->
<% } %>
