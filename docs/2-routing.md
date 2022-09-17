# Guide: Routing
Hopper's routing system works by attaching route paths to each request handler; upon each incoming request, Hopper attempts to find the best match for the request based on its URL and HTTP method (if multiple exact matches exist the first one found will be used). For requests where no exact match is found:
- If the request's URL is not matched, by default a request handler always responding with `404 Not Found` response will be used instead.
- If the URL matches a path on the server but the request method is incorrect (e.g. if for `/resource` a GET and POST handler are defined but a `PUT /resource` request is received), by default a request handler always responding with `405 Method Not Allowed` will be used instead.

`Hopper.serve` is a function taking various routes mapping paths to request handlers, and can be thought of as the root of the server in which the given routes are nested. `Hopper.get` is an example of a route mapper for mapping `GET` requests at a path to a request handler.
```
Hopper.serve([
  Hopper.get("/best-resource", req => Hopper.text("Grain")),
  Hopper.get("/worst-resource", req => Hopper.text("Brick"))
])
```
Let's compile and run this in WAGI and try various requests:

A valid request:
```
$ curl -vX GET http://localhost:3000/best-resource
[...]
< HTTP/1.1 200 OK
< content-type: text/plain
< content-length: 6
< date: Sun, 04 Sep 2022 22:14:26 GMT
< 
Grain
```

Wrong HTTP method for a resource:
```
$ curl -vX POST http://localhost:3000/best-resource
[...]
< HTTP/1.1 405 Method Not Allowed
< allow: GET
< content-type: text/plain
< content-length: 32
< date: Sun, 04 Sep 2022 22:13:52 GMT
< 
Method not allowed for this URL
```

A path that hasn't been defined:
```
$ curl -vX GET http://localhost:3000/invalid-path
[...]
< HTTP/1.1 404 Not Found
< content-type: text/plain
< content-length: 24
< date: Sun, 04 Sep 2022 22:16:11 GMT
< 
Requested URL not found
```
Hopper uses regular expression matching to match routes, so all path strings given to route mappers like `Hopper.get` will actually be used like regular expressions in matching (with some minor preprocessing done on them before being used for matching). So something like `Hopper.get("/i(L|-l)ove(R|-r)egex(es)?", ...)` will match both `GET /iLoveRegex` and `GET /i-love-regexes`. A single leading and/or trailing forward-slash in a path string is also inconsequential (e.g. `Hopper.get("/best-resource/", ...)` and `Hopper.get("best-resource", ...)` will match the same requests).

## Path Parameters
We can define special portions of our path as if they were "parameters" to our request handlers, which will be filled out by the URL of the request. For example, consider an example defining a dynamic path parameter:
```
Hopper.serve([
  Hopper.get("/say-hello/<name>", req => {
    let name = Hopper.param("name", req)
    Hopper.text(name ++ " says hello!")
  })
])
```
Path parameters are denoted between angle brackets, and their "argument" values can be fetched with `Hopper.param`. Now let's try spinning up the server and making a request:
```
$ curl http://localhost:3000/say-hello/Alex
Alex says hello!
```
By default, path parameters match against the regex `\w+` (a non-empty string of alphanumeric characters). However, this can be overridden by adding parentheses with a regex after the parameter name. For example, if we wanted to modify our example to allow names that have hyphens in them (popular with French names, for example), we could change our string to `"/say-hello/<name([\\w-]+)>"` (note the use of a double-backslash to escape a literal backslash character).

## Scopes
Often times it is convenient to logically group together routes by a route prefix. We can accomplish this by using route "scopes"
```
Hopper.serve([
  Hopper.scope("/best", [
    Hopper.get("/resource", req => Hopper.text("Grain")),
    Hopper.get("/band", req => Hopper.text("Iron Maiden"))
  ])
])
```
Now `GET /best/resource` and `GET /best/band` are valid routes. The path string values given for scopes abide by the same matching rules as terminal matchers like `Hopper.get`. Additionally, regex matching for scopes is "greedy"; for example, with the scope:
```
Hopper.scope("/.*", [
  Hopper.get("/end", ...)
])
```
`GET /some-stuff/end` would *not* match to the `Hopper.get("/end", ...)` request handler and instead give a `Not Found` response, since the `/.*` in the scope would consume the whole path.

## Relevant API Portions

### Route Mapper Methods
Routes can be defined for single request methods or multiple request methods. `Hopper.get` can be used to define a handler for `GET` requests, `Hopper.post` for `POST` requests, and so on for `GET`, `POST`, `PUT`, `DELETE`, `HEAD`, `PATCH`, `OPTIONS`, and `TRACE`.

`Hopper.route` can be used to define a route on an arbitrary request method, `Hopper.methodsRoute` for multiple allowed methods, and `Hopper.all` for all methods.

### Path parameters
Path parameters can be fetched with `Hopper.param`. It is assumed that a path parameter with the given name should exist on the route or a parent scope's route, otherwise an exception will be thrown.

### Serving
`Hopper.serve` has several variations (`Hopper.serveWith[...]`), which can be used to apply special application-wide options/middleware if desired. In addition to housing logic for core services like parsing requests, the `serve[...]` functions can also be thought of as owning their own scopes mounted at `/`.
```
Hopper.serve(...) // uses default options
Hopper.serveWithMiddleware(middleware, ...) // applies middleware to all routes
Hopper.serveWithOptions([
  // to define a custom handler to run when a request URL does not match any routes
  // (it is recommended that this handler return a Hopper.NotFound status)
  Hopper.NotFoundHandler(req => ...),

  // to define a custom handler to run when a request URL matches a route
  // but not any of the methods defined for the route
  // (it is recommended that this handler return a Hopper.MethodNotAllowed status
  // and set an "Allow" header with the allowed methods)
  Hopper.MethodNotAllowedHandler((allowedMethods, req) => ...)
], ...)
// combination of above two (naming will be done in a more efficient way once
// optional arguments are added to Grain)
Hopper.serveWithMiddlewareAndOptions(middleware, options, ...)
```

Next guide: [Middleware](3-middleware.md)