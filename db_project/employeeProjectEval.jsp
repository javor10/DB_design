<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>직원 프로젝트 및 평가 이력 조회</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");

    // --- DB 접속 정보 (필요하면 아이디/비번만 수정) ---
    String url      = "jdbc:mysql://localhost:3306/database_design?serverTimezone=UTC&characterEncoding=UTF-8&useSSL=false";
    String dbUser   = "devuser";   // 또는 root 등
    String dbPass   = "1234";

    String empIdParam = request.getParameter("emp_id");
%>

<h2>직원 프로젝트 참여 및 평가 이력 조회</h2>

<form method="get" action="employeeProjectEval.jsp">
    직원 ID(emp_id):
    <input type="text" name="emp_id" value="<%= (empIdParam == null ? "" : empIdParam) %>" />
    <input type="submit" value="조회" />
</form>
<hr>

<%
    if (empIdParam != null && empIdParam.trim().length() > 0) {
        Connection conn = null;
        PreparedStatement psEmp = null;
        PreparedStatement psProj = null;
        PreparedStatement psEval = null;
        ResultSet rsEmp = null;
        ResultSet rsProj = null;
        ResultSet rsEval = null;

        try {
            int empId = Integer.parseInt(empIdParam.trim());

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            // 1. 직원 기본 정보 조회
            String sqlEmp =
                "SELECT emp_id, name, dept, hire_date, edu_level " +
                "FROM EMPLOYEE " +
                "WHERE emp_id = ?";
            psEmp = conn.prepareStatement(sqlEmp);
            psEmp.setInt(1, empId);
            rsEmp = psEmp.executeQuery();

            if (!rsEmp.next()) {
%>
                <p>해당 직원 ID(<%= empId %>)에 대한 정보가 없습니다.</p>
<%
            } else {
%>
                <h3>[직원 기본 정보]</h3>
                <table border="1" cellpadding="5">
                    <tr>
                        <th>직원 ID</th>
                        <th>이름</th>
                        <th>부서</th>
                        <th>입사일</th>
                        <th>학력(전공)</th>
                    </tr>
                    <tr>
                        <td><%= rsEmp.getInt("emp_id") %></td>
                        <td><%= rsEmp.getString("name") %></td>
                        <td><%= rsEmp.getString("dept") %></td>
                        <td><%= rsEmp.getDate("hire_date") %></td>
                        <td><%= rsEmp.getString("edu_level") %></td>
                    </tr>
                </table>
                <br>

<%
                // 2. 프로젝트 참여 이력 조회 (PROJECT_ASSIGNMENT + PROJECT)
                String sqlProj =
                    "SELECT PA.proj_id, P.proj_name, " +
                    "       PA.assign_start_date, PA.assign_end_date, PA.assign_rote " +
                    "FROM PROJECT_ASSIGNMENT PA " +
                    "JOIN PROJECT P ON PA.proj_id = P.proj_id " +
                    "WHERE PA.emp_id = ? " +
                    "ORDER BY PA.assign_start_date";
                psProj = conn.prepareStatement(sqlProj);
                psProj.setInt(1, empId);
                rsProj = psProj.executeQuery();
%>
                <h3>[프로젝트 참여 이력]</h3>
<%
                if (!rsProj.isBeforeFirst()) {
%>
                    <p>참여한 프로젝트 이력이 없습니다.</p>
<%
                } else {
%>
                    <table border="1" cellpadding="5">
                        <tr>
                            <th>프로젝트 ID</th>
                            <th>프로젝트명</th>
                            <th>투입 시작일</th>
                            <th>투입 종료일</th>
                            <th>역할</th>
                        </tr>
<%
                    while (rsProj.next()) {
%>
                        <tr>
                            <td><%= rsProj.getInt("proj_id") %></td>
                            <td><%= rsProj.getString("proj_name") %></td>
                            <td><%= rsProj.getDate("assign_start_date") %></td>
                            <td><%= rsProj.getDate("assign_end_date") %></td>
                            <td><%= rsProj.getString("assign_rote") %></td>
                        </tr>
<%
                    } // while
%>
                    </table>
<%
                } // 프로젝트 이력 if
%>
                <br>

<%
                // 3. 평가 요약 이력 조회 (EVALUATION + PROJECT + EVALUATION_DETAIL)
                String sqlEvalSummary =
                    "SELECT E.eval_id, E.proj_id, P.proj_name, " +
                    "       E.eval_date, E.eval_type, " +
                    "       SUM(D.earned_score) AS total_score " +
                    "FROM EVALUATION E " +
                    "JOIN PROJECT P ON E.proj_id = P.proj_id " +
                    "LEFT JOIN EVALUATION_DETAIL D ON E.eval_id = D.eval_id " +
                    "WHERE E.evaluatee_id = ? " +
                    "GROUP BY E.eval_id, E.proj_id, P.proj_name, E.eval_date, E.eval_type " +
                    "ORDER BY E.eval_date DESC";
                psEval = conn.prepareStatement(sqlEvalSummary);
                psEval.setInt(1, empId);
                rsEval = psEval.executeQuery();
%>
                <h3>[본인 평가 이력 (요약)]</h3>
<%
                if (!rsEval.isBeforeFirst()) {
%>
                    <p>등록된 평가 이력이 없습니다.</p>
<%
                } else {
%>
                    <table border="1" cellpadding="5">
                        <tr>
                            <th>평가 ID</th>
                            <th>프로젝트명</th>
                            <th>평가일</th>
                            <th>평가 유형(PM/PEER/CUSTOMER)</th>
                            <th>총점 (4개 항목 합산)</th>
                        </tr>
<%
                    while (rsEval.next()) {
%>
                        <tr>
                            <td><%= rsEval.getInt("eval_id") %></td>
                            <td><%= rsEval.getString("proj_name") %></td>
                            <td><%= rsEval.getDate("eval_date") %></td>
                            <td><%= rsEval.getString("eval_type") %></td>
                            <td><%= rsEval.getInt("total_score") %></td>
                        </tr>
<%
                    } // while
%>
                    </table>
<%
                } // 평가 요약 if

                // ----- 평가 상세 이력 (항목별 점수/코멘트) -----
                // EVALUATION + PROJECT + EVALUATION_DETAIL + EVALUATION_LIST
                String sqlEvalDetail =
                    "SELECT E.eval_id, P.proj_name, E.eval_date, E.eval_type, " +
                    "       L.eval_list_id, L.eval_name, L.max_score, " +
                    "       D.earned_score, D.comment_in " +
                    "FROM EVALUATION E " +
                    "JOIN PROJECT P ON E.proj_id = P.proj_id " +
                    "JOIN EVALUATION_DETAIL D ON E.eval_id = D.eval_id " +
                    "JOIN EVALUATION_LIST L ON D.eval_list_id = L.eval_list_id " +
                    "WHERE E.evaluatee_id = ? " +
                    "ORDER BY E.eval_date DESC, E.eval_id, L.eval_list_id";

                PreparedStatement psEvalDetail = null;
                ResultSet rsEvalDetail = null;

                try {
                    psEvalDetail = conn.prepareStatement(sqlEvalDetail);
                    psEvalDetail.setInt(1, empId);
                    rsEvalDetail = psEvalDetail.executeQuery();
%>
                    <br>
                    <h3>[본인 평가 이력 (상세 – 항목별)]</h3>
<%
                    if (!rsEvalDetail.isBeforeFirst()) {
%>
                        <p>상세 평가 이력이 없습니다.</p>
<%
                    } else {
%>
                        <table border="1" cellpadding="5">
                            <tr>
                                <th>평가 ID</th>
                                <th>프로젝트명</th>
                                <th>평가일</th>
                                <th>유형</th>
                                <th>평가항목</th>
                                <th>항목 최대점수</th>
                                <th>획득 점수</th>
                                <th>코멘트</th>
                            </tr>
<%
                        while (rsEvalDetail.next()) {
%>
                            <tr>
                                <td><%= rsEvalDetail.getInt("eval_id") %></td>
                                <td><%= rsEvalDetail.getString("proj_name") %></td>
                                <td><%= rsEvalDetail.getDate("eval_date") %></td>
                                <td><%= rsEvalDetail.getString("eval_type") %></td>
                                <td><%= rsEvalDetail.getString("eval_name") %></td>
                                <td><%= rsEvalDetail.getInt("max_score") %></td>
                                <td><%= rsEvalDetail.getInt("earned_score") %></td>
                                <td><%= rsEvalDetail.getString("comment_in") %></td>
                            </tr>
<%
                        } // while
%>
                        </table>
<%
                    } // 상세 이력 if
                } finally {
                    if (rsEvalDetail != null) try { rsEvalDetail.close(); } catch (Exception ignore) {}
                    if (psEvalDetail != null) try { psEvalDetail.close(); } catch (Exception ignore) {}
                }

            } // 직원 존재 if

        } catch (Exception e) {
            e.printStackTrace();
%>
            <p>오류 발생: <%= e.getMessage() %></p>
<%
        } finally {
            if (rsEmp != null)  try { rsEmp.close(); }  catch (Exception ignore) {}
            if (rsProj != null) try { rsProj.close(); } catch (Exception ignore) {}
            if (rsEval != null) try { rsEval.close(); } catch (Exception ignore) {}
            if (psEmp != null)  try { psEmp.close(); }  catch (Exception ignore) {}
            if (psProj != null) try { psProj.close(); } catch (Exception ignore) {}
            if (psEval != null) try { psEval.close(); } catch (Exception ignore) {}
            if (conn != null)   try { conn.close(); }   catch (Exception ignore) {}
        }
    } // if empIdParam
%>

</body>
</html>