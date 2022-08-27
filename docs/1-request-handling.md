

### Headers
HTTP headers are accessible via `Hopper.header`, case insensitive. `Hopper.header` can be used both on request and response objects.
```
// with a request with a header Content-Type: application/json and no header named "Missing"
Hopper.header("Content-Type", req) // Some("application/json")
Hopper.header("content-type", req) // Some("application/json")
Hopper.header("Missing", req) // None
```
It should also be noted that WAGI (at least as of version v0.8.1) will remove the headers "Authorization" or "Connection" from the request as per recommendation in CGI v1.1 section 4.1.18, so `Hopper.header("Authorization", req)` will always return `None`. Hopper is not recommended for security-sensitive applications, but if an authentication solution is needed in a pinch you may use a workaround such as sending an "Auth" header instead.