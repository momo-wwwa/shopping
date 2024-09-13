<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>商品検索</title>
</head>
<!--  検索をかけ、選んだ商品をカートに追加する 検索を書ける関数、カートに入れる関数が必要になる-->
<body>
    <h1>商品検索</h1>
    <form method="post" action="searchResult.jsp">
        商品名: <input type="text" name="productName"><br>
        カテゴリ: <input type="text" name="category"><br>
        <input type="submit" value="検索">
    </form>
</body>
</html>