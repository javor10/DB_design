<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>휴가 승인/반려 처리</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");

    String url = "jdbc:mysql://localhost:3306/database_design?serverTimezone=UTC&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true";
    String user = "devuser";
    String password = "1234";

    String reqIdStr = request.getParameter("leave_request_id");
    String action = request.getParameter("action");

    if (reqIdStr == null || action == null) {
        out.println("잘못된 요청입니다.");
    } else {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            int reqId = Integer.parseInt(reqIdStr);

            if ("approve".equals(action)) {
                // 1) LEAVE_REQUEST 상태를 '승인'으로 변경
                String updateReq =
                    "UPDATE LEAVE_REQUEST " +
                    "SET request_status = '승인' " +
                    "WHERE leave_request_id = ?";
                ps = conn.prepareStatement(updateReq);
                ps.setInt(1, reqId);
                ps.executeUpdate();
                ps.close();

                // 2) LEAVE 사용일수 / 잔여일수 갱신
                //    DATEDIFF(end_date, start_date) + 1 사용
                String updateLeave =
                    "UPDATE `LEAVE` L " +
                    "JOIN LEAVE_REQUEST R ON L.leave_id = R.leave_id " +
                    "SET L.used_days = L.used_days + (DATEDIFF(R.end_date, R.start_date) + 1), " +
                    "    L.remaining_days = L.remaining_days - (DATEDIFF(R.end_date, R.start_date) + 1) " +
                    "WHERE R.leave_request_id = ?";
                ps = conn.prepareStatement(updateLeave);
                ps.setInt(1, reqId);
                ps.executeUpdate();
                ps.close();

            } else if ("reject".equals(action)) {
                // 반려 처리
                String updateReq =
                    "UPDATE LEAVE_REQUEST " +
                    "SET request_status = '반려' " +
                    "WHERE leave_request_id = ?";
                ps = conn.prepareStatement(updateReq);
                ps.setInt(1, reqId);
                ps.executeUpdate();
                ps.close();
            }

            // 처리 끝나면 리스트 화면으로 다시 이동
            response.sendRedirect("leaveApprovalList.jsp");
            return;

        } catch (Exception e) {
            e.printStackTrace();
            out.println("오류 발생: " + e.getMessage());
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception ignore) {}
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
    }
%>
</body>
</html>