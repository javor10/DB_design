<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>휴가 신청</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");

    // 공통 DB 설정
    String url = "jdbc:mysql://localhost:3306/database_design?serverTimezone=UTC&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true";
    String user = "devuser";
    String password = "1234";

    String method = request.getMethod();
    String message = null;

    if ("POST".equalsIgnoreCase(method)) {
        String empIdStr = request.getParameter("emp_id");
        String startDate = request.getParameter("start_date");
        String endDate = request.getParameter("end_date");
        String reason = request.getParameter("reason");

        if (empIdStr == null || empIdStr.trim().isEmpty()
                || startDate == null || startDate.trim().isEmpty()
                || endDate == null || endDate.trim().isEmpty()
                || reason == null || reason.trim().isEmpty()) {
            message = "모든 값을 입력해주세요.";
        } else {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, password);

                // 1) emp_id로 leave_id 찾기
                String findLeaveSql = "SELECT leave_id FROM `LEAVE` WHERE emp_id = ?";
                ps = conn.prepareStatement(findLeaveSql);
                ps.setInt(1, Integer.parseInt(empIdStr));
                rs = ps.executeQuery();

                Integer leaveId = null;
                if (rs.next()) {
                    leaveId = rs.getInt("leave_id");
                }
                rs.close();
                ps.close();

                if (leaveId == null) {
                    message = "해당 직원의 휴가 계정(LEAVE)이 없습니다. 관리자에게 문의하세요.";
                } else {
                    // 2) LEAVE_REQUEST INSERT (request_status = '대기')
                    String insertSql = "INSERT INTO LEAVE_REQUEST (leave_id, start_date, end_date, reason, request_status) " +
                                       "VALUES (?, ?, ?, ?, '대기')";
                    ps = conn.prepareStatement(insertSql);
                    ps.setInt(1, leaveId);
                    ps.setString(2, startDate);
                    ps.setString(3, endDate);
                    ps.setString(4, reason);

                    int row = ps.executeUpdate();
                    if (row > 0) {
                        message = "휴가 신청이 완료되었습니다.";
                    } else {
                        message = "휴가 신청에 실패했습니다.";
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                message = "오류 발생: " + e.getMessage();
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception ignore) {}
                if (ps != null) try { ps.close(); } catch (Exception ignore) {}
                if (conn != null) try { conn.close(); } catch (Exception ignore) {}
            }
        }
    }
%>

<h2>휴가 신청 화면</h2>

<% if (message != null) { %>
    <p><b><%= message %></b></p>
<% } %>

<form method="post" action="leaveRequestForm.jsp">
    <label>사번(emp_id): </label>
    <input type="number" name="emp_id" required><br><br>

    <label>시작일(start_date): </label>
    <input type="date" name="start_date" required><br><br>

    <label>종료일(end_date): </label>
    <input type="date" name="end_date" required><br><br>

    <label>사유(reason): </label>
    <input type="text" name="reason" required><br><br>

    <button type="submit">휴가 신청</button>
</form>

<p>
    <a href="leaveApprovalList.jsp">[관리자용 승인 리스트 보기]</a>
</p>

</body>
</html>