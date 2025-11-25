<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>동아리 회원 삭제 처리</title>
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
    String empIdStr  = request.getParameter("emp_id");

    if (clubIdStr == null || empIdStr == null) {
        out.println("잘못된 요청입니다.");
    } else {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            int clubId = Integer.parseInt(clubIdStr);
            int empId  = Integer.parseInt(empIdStr);

            String sql = "DELETE FROM MEMBER_LIST WHERE club_id = ? AND emp_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, clubId);
            ps.setInt(2, empId);
            ps.executeUpdate();

            response.sendRedirect("clubDetail.jsp?club_id=" + clubId);
            return;

        } catch (Exception e) {
            e.printStackTrace();
            out.println("오류 발생: " + e.getMessage());
            out.println("<p><a href='clubDetail.jsp?club_id=" + clubIdStr + "'>뒤로가기</a></p>");
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception ignore) {}
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
    }
%>
</body>
</html>