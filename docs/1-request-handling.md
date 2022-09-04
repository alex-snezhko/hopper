# Guide: Request Handling
Hopper takes a simple approach to handling requests; request handlers are written as normal functions taking a `Request` object as an argument and returning a `Response` object. These request handlers can be mounted at a route path on the server, and when an incoming request's URL matches the path of the request handler, it is invoked (more on routing later).

`Request` objects are automatically constructed by Hopper when an incoming request is read and passed to the appropriate handler. **Note that the entirety of the request data is loaded into memory, so be careful when writing endpoints that may take large request bodies**.

Let's say we want to define a `POST` endpoint mounted at `/respond-with-request`, which simply responds with the request body verbatim. We can do that with
```
Hopper.serve([
  Hopper.post("/respond-with-request", req => {
    let body = Hopper.body(req)
    let responseStatus = Hopper.HttpOk
    let headers = Map.fromList([("Content-Type", "text/plain")])
    Hopper.response(responseStatus, headers, body)
  })
])
```
Here we are accessing the request body as a string with `Hopper.body` and using `Hopper.response` to return a `text/plain` response to the client. Let's now consider a slightly more complicated scenario illustrating some more of Hopper's API:
```
Hopper.serve([
  Hopper.post("/respond-with-request", req => {
    // get the request's Content-Type header, or assume text/plain if not given
    let contentType = match (Hopper.header("Content-Type", req)) {
      Some(val) => val,
      None => "text/plain"
    }
    // write the content type to the configured WAGI log
    Hopper.log("The content type was " ++ contentType ++ ".")

    let body = Hopper.body(req)
    // serve a text/plain response with the requestBody
    Hopper.text(body)
  })
])
```

## Statelessness
Since Hopper is built atop WAGI, each incoming request will be handled in a stateless manner. That is, something like this may not do what you expect:
```
let mut numRequests = 0

Hopper.serve([
  Hopper.get("/", req => {
    numRequests += 1
    Hopper.text("This is request number " ++ toString(numRequests))
  })
])
```
This server will actually always respond with `This is request number 1` since a fresh copy of your code (where `numRequests = 0`) will be run for each request.

## Relevant API Portions

### Bodies
The bodies of requests and responses are accessible as strings via `Hopper.body`. Hopper also includes some built-in body parsing functions, including parsing url-encoded or multipart forms. More on this in the [forms guide](x-html-forms.md).

### Headers
HTTP headers of requests and responses are accessible via `Hopper.header`, case insensitive (or `Hopper.headers` to get all of the headers in a `Map`, lowercasing the names for normalization).
```
// with a request with a header Content-Type: application/json and no header named "Missing"
Hopper.header("Content-Type", req) // Some("application/json")
Hopper.header("content-type", req) // Some("application/json")
Hopper.header("Missing", req) // None

Hopper.headers(req) // { "content-type": Some("application/json"), ... }
```
It should also be noted that WAGI currently (as of version v0.8.1) does not have support for authorization, and will remove any "Authorization" or "Connection" headers from the request, so `Hopper.header("Authorization", req)` will return `None` even if this header is given. Hopper is not recommended for security-sensitive applications, but if an authentication solution is needed in a pinch you may use a workaround such as sending an "Auth" header instead.

### Creating Responses
Several convenience functions exist to create desired responses, with `Hopper.response` being the most generic response-creation function.
```
Hopper.text("Hello there") // response with Content-Type: text/plain
Hopper.json("{\"name\": \"val\"}") // response with Content-Type: application/json
Hopper.contentType("text/html", "<body><p>I am HTML</p></body>")
Hopper.newStatus(Hopper.BadRequest, Hopper.text("Whoops")) // response with content of text response but 400 status
```

### Request/Response-specific Data
Some of Hopper's API functions work with both requests and responses, but ultimately `Request`s and `Response`s differ in the data they contain; for example, requests contain the request HTTP method and URL query parameters while responses contain the HTTP status of the response. Thus, there are some functions that only work for one and not the other.
```
// for requests
// e.g. GET /path?a=1&b=first&b=second
Hopper.method(req) // Hopper.Get
Hopper.query("a", req) // Some(Hopper.SingleVal("1"))
Hopper.query("b", req) // Some(Hopper.MultiVal(["first", "second"]))
Hopper.query("doesNotExist", req) // None
Hopper.queries(req) // { "a": Hopper.SingleVal("1"), "b": Hopper.MultiVal(["first", "second"])}

// for responses
Hopper.status(res) // a Hopper.Status variant: Hopper.HttpOk, Hopper.Conflict, etc.
```

Next guide: [Routing](2-routing.md)
