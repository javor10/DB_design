<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>휴가 승인/반려 리스트</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");

    String url = "jdbc:mysql://localhost:3306/database_design?serverTimezone=UTC&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true";
    String user = "devuser";
    String password = "1234";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);

        String sql =
            "SELECT LR.leave_request_id, LR.leave_id, LR.start_date, LR.end_date, " +
            "       LR.reason, LR.request_status, " +
            "       L.emp_id, L.used_days, L.remaining_days, " +
            "       E.name " +
            "FROM LEAVE_REQUEST LR " +
            "JOIN `LEAVE` L ON LR.leave_id = L.leave_id " +
            "JOIN EMPLOYEE E ON L.emp_id = E.emp_id " +
            "ORDER BY LR.leave_request_id";

        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
%>

<h2>휴가 승인/반려 리스트 (관리자 화면)</h2>

<table border="1" cellspacing="0" cellpadding="5">
    <tr>
        <th>신청ID</th>
        <th>사번</th>
        <th>이름</th>
        <th>시작일</th>
        <th>종료일</th>
        <th>사유</th>
        <th>상태</th>
        <th>사용일수</th>
        <th>잔여일수</th>
        <th>승인/반려</th>
    </tr>

<%
        while (rs.next()) {
            int reqId = rs.getInt("leave_request_id");
            int empId = rs.getInt("emp_id");
            String name = rs.getString("name");
            Date startDate = rs.getDate("start_date");
            Date endDate = rs.getDate("end_date");
            String reason = rs.getString("reason");
            String status = rs.getString("request_status");
            int usedDays = rs.getInt("used_days");
            int remainingDays = rs.getInt("remaining_days");
%>
    <tr>
        <td><%= reqId %></td>
        <td><%= empId %></td>
        <td><%= name %></td>
        <td><%= startDate %></td>
        <td><%= endDate %></td>
        <td><%= reason %></td>
        <td><%= status %></td>
        <td><%= usedDays %></td>
        <td><%= remainingDays %></td>
        <td>
            <% if ("대기".equals(status)) { %>
                <form method="post" action="leaveApprovalProcess.jsp" style="display:inline;">
                    <input type="hidden" name="leave_request_id" value="<%= reqId %>">
                    <button type="submit" name="action" value="approve">승인</button>
                    <button type="submit" name="action" value="reject">반려</button>
                </form>
            <% } else { %>
                처리 완료
            <% } %>
        </td>
    </tr>
<%
        } // while
    } catch (Exception e) {
        e.printStackTrace();
%>
    <p>오류 발생: <%= e.getMessage() %></p>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
</table>

<p>
    <a href="leaveRequestForm.jsp">[직원용 휴가 신청 페이지로 이동]</a>
</p>

</body>
</html>