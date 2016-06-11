<%-- 
    Document   : display
    Created on : Mar 1, 2016, 6:35:12 PM
    Author     : imran
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>My Web App</title>
    </head>
    <body>
        <% boolean loggedin = (boolean)request.getAttribute("authorize"); %>
        <div>
            <h3>Hello <%=request.getParameter("username")%>!</h3><br>
            <%if (loggedin) {%>
            <b style="color:green">You are logged in.<br></b>
            <%} else {%>
            <b style="color:red">Your login failed.</b><br>
            <%}%>
        </div>
    </body>
</html>
