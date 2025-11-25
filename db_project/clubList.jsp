<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>동아리 목록</title>
</head>
<body>
<h2>동아리 목록</h2>
<p><a href="index.jsp">[메인으로]</a></p>

<%
    request.setCharacterEncoding("UTF-8");

    String url = "jdbc:mysql://localhost:3306/database_design"
               + "?serverTimezone=UTC&characterEncoding=UTF-8"
               + "&useSSL=false&allowPublicKeyRetrieval=true";
    String user = "devuser";   // 네 MySQL 계정
    String password = "1234";  // 네 비번

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);

        String sql =
            "SELECT C.club_id, C.club_name, C.category, C.established_date, C.is_active, " +
            "       E.name AS president_name, " +
            "       COUNT(ML.emp_id) AS member_cnt " +
            "FROM CLUB C " +
            "LEFT JOIN EMPLOYEE E ON C.emp_id = E.emp_id " +     // 회장(담당자)
            "LEFT JOIN MEMBER_LIST ML ON C.club_id = ML.club_id " +
            "GROUP BY C.club_id, C.club_name, C.category, C.established_date, C.is_active, E.name " +
            "ORDER BY C.club_id";

        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
%>

<table border="1" cellpadding="5" cellspacing="0">
    <tr>
        <th>동아리ID</th>
        <th>동아리명</th>
        <th>카테고리</th>
        <th>개설일</th>
        <th>활성여부</th>
        <th>회장(담당자)</th>
        <th>회원 수</th>
        <th>상세보기</th>
    </tr>
<%
        while (rs.next()) {
            int clubId = rs.getInt("club_id");
%>
    <tr>
        <td><%= clubId %></td>
        <td><%= rs.getString("club_name") %></td>
        <td><%= rs.getString("category") %></td>
        <td><%= rs.getDate("established_date") %></td>
        <td><%= rs.getString("is_active") %></td>
        <td><%= rs.getString("president_name") %></td>
        <td><%= rs.getInt("member_cnt") %></td>
        <td>
            <a href="clubDetail.jsp?club_id=<%= clubId %>">상세보기</a>
        </td>
    </tr>
<%
        }
%>
</table>

<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("오류 발생: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>

</body>
</html>