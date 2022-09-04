# Guide: Routing
Hopper's routing system works by attaching route paths to each request handler; upon each incoming request, Hopper attempts to find the best match for the request based on its URL and HTTP method. For requests where no match is found:
- If no handler is found for the request's URL, a request handler always responding with `404 Not Found` response will be used instead.
- If the URL matches a path on the server but the request method is incorrect (e.g. if for `/resource` a GET and POST handler are defined but a `PUT /resource` request is received), a request handler always responding with `405 Method Not Allowed` will be used instead.
`Hopper.serve` is a function taking various route mappers, and can be thought of as the root of the server in which the given routes are nested. `Hopper.get` is an example of a route mapper for mapping `GET` requests to a request handler.
```
Hopper.serve([
  Hopper.get("/best-resource", req => {
    Hopper.text("Grain")
  }),
  Hopper.get("/worst-resource", req => {
    Hopper.text("Brick")
  })
])
```
Let's compile and run this in WAGI and try various requests:
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
Hopper uses regular expression matching to match routes, so all path strings given to route mappers like `Hopper.get` will actually be used like regular expressions in matching (with some minor preprocessing done on them before being used for matching). So something like `Hopper.get("/iLoveRegex(es)?", ...)` will match for both `GET /iLoveRegex` and `GET /iLoveRegexes`. Trailing forward-slashes in path strings (like `/best-resource/`) are also inconsequential, and will not affect route matching.

## Path Parameters
We can define special portions of our path as if they were "parameters" to our request handlers, which will be filled out by the URL of the request. For example:
```
Hopper.serve([
  Hopper.get("/say-hello/<name>", req => {
    let name = Hopper.param("name", req)
    Hopper.text(name ++ " says hello!")
  })
])
```
As you can see, path parameters are denoted between angle brackets, and their values can be gotten with `Hopper.param`. Now let's try spinning up the server and making a request:
```
$ curl http://localhost:3000/say-hello/Alex
Alex says hello!
```
By default, path parameters match against the regex `\w+`. However, this can be overridden by adding parentheses with a regex after the parameter name. For example, if we wanted to modify our example to allow names that have hyphens in them (popular with French names, for example), we could change our string to `"/say-hello/<name([\\w-]+)>"` (note the double-backslash to escape a literal backslash character).

## Scopes
Often times it makes sense to logically group together routes by a route prefix. We can accomplish this by using route "scopes"
```
Hopper.serve([
  Hopper.scope("/best", [
    Hopper.get("/resource", req => {
      Hopper.text("Grain")
    }),
    Hopper.get("/band", req => {
      Hopper.text("Iron Maiden")
    })
  ])
])
```
The string values given for scopes abide by the same matching rules as terminal matchers, with the exception that 

NOTE MAKE SURE /bests prefix is not matched

## Relevant API Portions

### Route Mapper Methods
Routes can be defined for single request methods or multiple request methods. `Hopper.get` can be used to define a handler for `GET` requests, `Hopper.post` for `POST` requests, and so on for `GET`, `POST`, `PUT`, `DELETE`, `HEAD`, `PATCH`, `OPTIONS`, and `TRACE`.

`Hopper.route` can be used to define a route on an arbitrary request method, `Hopper.methodsRoute` for multiple allowed methods, and `Hopper.all` for all methods.

Next guide: [Middleware](3-middleware.md)