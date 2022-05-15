<%@ page contentType="text/html; charset=utf-8" %><html><body>
JSP: Hello JSP World!<br>
<%= pageContext.getServletContext().getServerInfo() %><br>
java.vm.name: <%= System.getProperty("java.vm.name") %><br>
java.vm.vendor: <%= System.getProperty("java.vm.vendor") %><br>
java.vm.version: <%= System.getProperty("java.vm.version") %><br>
</body></html>