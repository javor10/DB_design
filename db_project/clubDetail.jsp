<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>동아리 상세 / 회원 관리</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");

    String url = "jdbc:mysql://localhost:3306/database_design"
               + "?serverTimezone=UTC&characterEncoding=UTF-8"
               + "&useSSL=false&allowPublicKeyRetrieval=true";
    String user = "devuser";
    String password = "1234";

    String clubIdStr = request.getParameter("club_id");
    if (clubIdStr == null || clubIdStr.trim().length() == 0) {
%>
    잘못된 접근입니다. (club_id 없음)
    <p><a href="clubList.jsp">[동아리 목록으로]</a></p>
</body>
</html>
<%
        return;
    }

    int clubId = Integer.parseInt(clubIdStr);

    Connection conn = null;
    PreparedStatement psClub = null;
    PreparedStatement psMembers = null;
    ResultSet rsClub = null;
    ResultSet rsMembers = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);

        // 1) 동아리 기본 정보
        String sqlClub =
            "SELECT C.club_id, C.club_name, C.category, C.established_date, C.is_active, " +
            "       E.name AS president_name " +
            "FROM CLUB C " +
            "LEFT JOIN EMPLOYEE E ON C.emp_id = E.emp_id " +
            "WHERE C.club_id = ?";

        psClub = conn.prepareStatement(sqlClub);
        psClub.setInt(1, clubId);
        rsClub = psClub.executeQuery();

        if (!rsClub.next()) {
%>
    해당 동아리가 존재하지 않습니다.
    <p><a href="clubList.jsp">[동아리 목록으로]</a></p>
</body>
</html>
<%
            return;
        }
%>

<h2>동아리 상세 정보</h2>
<p><a href="clubList.jsp">[동아리 목록으로]</a></p>

<table border="1" cellpadding="5" cellspacing="0">
    <tr><th>동아리ID</th><td><%= rsClub.getInt("club_id") %></td></tr>
    <tr><th>동아리명</th><td><%= rsClub.getString("club_name") %></td></tr>
    <tr><th>카테고리</th><td><%= rsClub.getString("category") %></td></tr>
    <tr><th>개설일</th><td><%= rsClub.getDate("established_date") %></td></tr>
    <tr><th>활성여부</th><td><%= rsClub.getString("is_active") %></td></tr>
    <tr><th>회장(담당자)</th><td><%= rsClub.getString("president_name") %></td></tr>
</table>

<br>
<h3>회원 목록</h3>
<%
        // 2) 회원 목록 (MEMBER_LIST + EMPLOYEE 조인)
        String sqlMembers =
            "SELECT ML.emp_id, ML.role, ML.joined_date, " +
            "       E.name, E.dept " +
            "FROM MEMBER_LIST ML " +
            "JOIN EMPLOYEE E ON ML.emp_id = E.emp_id " +
            "WHERE ML.club_id = ? " +
            "ORDER BY ML.role, ML.emp_id";

        psMembers = conn.prepareStatement(sqlMembers);
        psMembers.setInt(1, clubId);
        rsMembers = psMembers.executeQuery();
%>

<table border="1" cellpadding="5" cellspacing="0">
    <tr>
        <th>직원ID</th>
        <th>이름</th>
        <th>부서</th>
        <th>역할</th>
        <th>입부일</th>
        <th>삭제</th>
    </tr>
<%
        while (rsMembers.next()) {
            int empId = rsMembers.getInt("emp_id");
%>
    <tr>
        <td><%= empId %></td>
        <td><%= rsMembers.getString("name") %></td>
        <td><%= rsMembers.getString("dept") %></td>
        <td><%= rsMembers.getString("role") %></td>
        <td><%= rsMembers.getDate("joined_date") %></td>
        <td>
            <form action="clubMemberDelete.jsp" method="post" style="margin:0;">
                <input type="hidden" name="club_id" value="<%= clubId %>">
                <input type="hidden" name="emp_id" value="<%= empId %>">
                <input type="submit" value="회원 삭제"
                       onclick="return confirm('직원ID <%= empId %> 회원을 삭제하시겠습니까?');">
            </form>
        </td>
    </tr>
<%
        }
%>
</table>

<br>
<h3>회원 추가</h3>
<form action="clubMemberAdd.jsp" method="post">
    <input type="hidden" name="club_id" value="<%= clubId %>">
    직원ID: <input type="text" name="emp_id" required>
    역할: <input type="text" name="role" value="회원">
    입부일: <input type="date" name="joined_date">
    <input type="submit" value="회원 추가">
</form>

<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("오류 발생: " + e.getMessage());
    } finally {
        if (rsMembers != null) try { rsMembers.close(); } catch (Exception ignore) {}
        if (psMembers != null) try { psMembers.close(); } catch (Exception ignore) {}
        if (rsClub != null) try { rsClub.close(); } catch (Exception ignore) {}
        if (psClub != null) try { psClub.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>

</body>
</html>