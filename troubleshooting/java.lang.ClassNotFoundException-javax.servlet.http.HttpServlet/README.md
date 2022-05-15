# Can't access uploaded plugin: java.lang.ClassNotFoundException: javax.servlet.http.HttpServlet

## Error

Uploading a plugin works fine, but when you access it you get a HTTP error 500:

![]()

Let's look at the last part of this traceback:

```
HTTP Status 500 – Internal Server Error

Type Exception Report

Message Error instantiating servlet class [com.example.MyServlet]

Description The server encountered an unexpected condition that prevented it from fulfilling the request.

Exception

...

java.lang.ClassNotFoundException: javax.servlet.http.HttpServlet
	org.apache.catalina.loader.WebappClassLoaderBase.loadClass(WebappClassLoaderBase.java:1449)
...

Note The full stack trace of the root cause is available in the server logs.
Apache Tomcat/10.0.20
```

## Solving this problem

To compile for Tomcat 10.x you need to change the imports in the `build.gradle` file, to include `jakarta.*` imports:

**Tomcat 9:**

```
dependencies {
  // Java Servlet 4.0 API
  // https://mvnrepository.com/artifact/javax.servlet/javax.servlet-api
  providedCompile 'javax.servlet:javax.servlet-api:4.0.1'
  providedCompile 'org.json:json:20080701'
}
```

**Tomcat 10:**

```
dependencies {
  // Java Servlet 4.0 API
  // https://mvnrepository.com/artifact/javax.servlet/javax.servlet-api
  providedCompile 'jakarta.servlet:jakarta.servlet-api:4.0.1'
  providedCompile 'org.json:json:20080701'
}
```

## References

 - https://stackoverflow.com/questions/66711660/tomcat-10-x-throws-java-lang-noclassdeffounderror-on-javax-servlet
 - https://stackoverflow.com/questions/65703840/tomcat-casting-servlets-to-javax-servlet-servlet-instead-of-jakarta-servlet-http/65704617#65704617