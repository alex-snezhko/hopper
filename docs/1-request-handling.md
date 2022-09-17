# Guide: Request Handling
Hopper takes a simple approach to handling HTTP requests; request handlers are written as normal functions taking a `Request` object as an argument and returning a `Response` object to be propagated back to the client. These request handlers can be mounted onto routes of the server, and are invoked when an incoming request's URL matches the path they are mounted on.

`Request` objects are automatically constructed by Hopper when an incoming request is read and passed to the appropriate handler. **Note that Hopper currently reads the entirety of request bodies into memory upon receipt, so very large request bodies may cause issues for the application**.

Let's say we want to define a `POST` endpoint mounted at `/respond-with-request`, which simply responds with the request body verbatim. We can do that with
```
Hopper.serve([
  Hopper.post("/respond-with-request", req => {
    let body = Hopper.body(req)
    Hopper.text(body)
  })
])
```
Here we are accessing the request body as a string with `Hopper.body` and using `Hopper.text` to return a `text/plain` response to the client. Let's now consider a slightly more complicated scenario illustrating some more of Hopper's API:
```
Hopper.serve([
  Hopper.post("/respond-with-request", req => {
    match (Hopper.header("Content-Type", req)) {
      Some(val) => {
        // write the content type to the configured WAGI log
        Hopper.log("The content type was " ++ contentType ++ ".")
        let body = Hopper.body(req)
        // serve a text/plain response with the requestBody
        Hopper.text(body)
      },
      None => {
        // return an error response if no Content-Type is given
        Hopper.response(
          Hopper.UnsupportedMediaType,
          Map.fromList([("Content-Type", "text/plain")])
          "Missing Content-Type"
        )
      }
    }
  })
])
```

## Per-Request Statelessness
Since Hopper is built atop WAGI, each incoming request will be handled in an independent manner. That is, something like this may not do what you expect:
```
let mut numRequests = 0

Hopper.serve([
  Hopper.get("/", req => {
    numRequests += 1
    Hopper.text("This is request number " ++ toString(numRequests))
  })
])
```
This server will actually *always* respond with `This is request number 1` since a fresh copy of your code (where `numRequests = 0`) will be run for each request.

## Relevant API Portions

### Bodies
The bodies of requests and responses are accessible as strings via `Hopper.body`.

### Headers
HTTP headers of requests and responses are accessible via `Hopper.header`, case insensitive (or `Hopper.headers` to get all of the headers in a `Map`, lowercasing the names for normalization).
```
// with a request with a header Content-Type: application/json and no header named "Missing"
Hopper.header("Content-Type", req) // Some("application/json")
Hopper.header("content-type", req) // Some("application/json")
Hopper.header("Missing", req) // None

Hopper.headers(req) // { "content-type": "application/json", ... }
```
It should also be noted that WAGI currently (as of version v0.8.1) does not have support for auth, and will remove any "Authorization" or "Connection" headers from the request, so `Hopper.header("Authorization", req)` will return `None` even if the client gives this header.

### Creating Responses
Several convenience functions exist to create desired responses, with `Hopper.response` being the most generic response-creation function.
```
Hopper.text("Hello there") // response with Content-Type: text/plain
Hopper.json("{\"name\": \"val\"}") // response with Content-Type: application/json
Hopper.contentType("text/html", "<body><p>I am HTML</p></body>")
Hopper.newStatus(Hopper.BadRequest, Hopper.text("Whoops")) // response with content/headers of text response but 400 status
Hopper.newHeaders(Map.fromList([("Content-Type", "application/octet-stream")]), Hopper.text("New headers"))
Hopper.newBody("New body", Hopper.text("Old body"))
Hopper.file("asdf.txt") // response with file contents as the body (file should be in the configured WAGI volume)

// the following can be used to create redirection responses; both use status code 302 Found

// for redirecting to another path of the application
Hopper.redirectLocal("/other-path", req)
// for redirecting to any arbitrary URL
Hopper.redirectExternal("https://www.google.com")
```

### Request/Response-specific Data
Some of Hopper's API functions work with both requests and responses, but ultimately `Request`s and `Response`s differ in the data they contain; for example, requests contain the request HTTP method and URL query parameters while responses contain the HTTP status of the response. Thus, there are some functions that only work for one and not the other.
```
// for requests
// e.g. with GET /path?a=1&b=first&b=second
Hopper.method(req) // Hopper.Get
Hopper.query("a", req) // Some("1")
Hopper.query("b", req) // Some("first")
Hopper.queryList("b", req) // ["first", "second"]
Hopper.query("doesNotExist", req) // None
Hopper.queries(req) // { "a": Hopper.Val("1"), "b": Hopper.Vals(["first", "second"])}

// for responses
Hopper.status(res) // a Hopper.Status variant: Hopper.HttpOk, Hopper.Conflict, etc.
```

Next guide: [Routing](2-routing.md)
