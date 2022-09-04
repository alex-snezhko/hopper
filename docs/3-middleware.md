# Guide: Middleware
Hopper middlewares are a powerful way to extend Hopper and/or enable code reuse in your project. Middlewares are simply functions which take a request handler as input and produce a new request handler based on it. As the name implies, middlewares sit between your request handlers and the client, and have the ability to transform requests before they reach your request handlers, modify responses before being sent to the client, or perform side effects.

Here's an example of a very simple middleware that logs some info about each request and response it handles.
```
let withLogging = next => {
  let newHandler = req => {
    let method = Hopper.methodToString(Hopper.method(req))
    let path = Hopper.path(req)
    Hopper.log(method ++ " " ++ path)
    // call either the request handler or the next middleware before the request handler
    let res = next(req)
    let status = Hopper.statusToCode(Hopper.status(res))
    Hopper.log("Responded with " ++ toString(status))
    res
  }
  newHandler
}
```
Here we see that we define the input request handler as "`next`"; since multiple middlewares may be composed on top of each other, the handler our middleware sits on top of can be thought of as the "next" handler in the entire chain of handlers defined for a certain route. The new handler we defined was given an explicit name to illustrate the point, but we can condense it down for brevity
```
let withLogging = next => req => {
  let method = ...
  // ...
}
```
Now that we have our middleware function defined, it is very simple to apply it to a request handler
```
let withLogging = // ...

Hopper.serve([
  Hopper.get("/logged", withLogging(req => {
    Hopper.text("Howdy")
  }))
])
```
Now if we launch our server and make a request to our endpoint, we'll get back a "Howdy" text response and in our WAGI log we will see
```
GET /logged
Responded with 200
```

## Middlewares On Scopes
Middlewares can also be added to `Hopper.scope`s, in which case the middleware will be applied to all requests in the scope (including to paths without handlers, in which case the middleware will process the `404 Not Found` or `405 Method Not Allowed` response)
```
Hopper.serve([
  Hopper.scopeWithMiddleware("/", withLogging, [
    // ...
  ]),
  // we can use multiple middlewares like this
  Hopper.scopeWithMiddleware("/a", req => withLogging(withOtherMiddleware(req)), [
    // ...
  ]),
  // or like this (equivalent to the above example)
  Hopper.scopeWithMiddleware("/b", Hopper.middlewares([withLogging, withOtherMiddleware]), [
    // ...
  ])
])

// middlewares can also be applied "globally"
Hopper.serveWithMiddleware(withLogging, [
  // ...
])
```

## Variables
Both requests and responses have the capability to contain "variables", primarily for use by middlewares to pass arbitrary data down to their child handlers or vice versa; this is very powerful mechanism for extending Hopper, as it can enable a great degree of abstraction for request handlers.

For example, let's say we have built a library for parsing strings into XML objects, and we want our request handlers to handle XML data. Rather than including all of the parsing logic in each request handler, we can have middleware pass down the XML-parsed data to our handlers.
```
type Xml = // ...
let parseXml = str => // ...

let withXmlParsing = next => req => {
  let xml = parseXml(Hopper.body(req))
  Hopper.setVariable("xmlBody", xml, req)
  next(req)
}

let getXml = req => {
  let xml: Hopper.Variable<Xml> = Hopper.variable("xmlBody", req)
  xml
}

Hopper.serve([
  Hopper.post("/submitXml", withXmlParsing(req => {
    let xml = getXml(req)
    // we can now work with the XML data directly
    // ...
  }))
])
```
Variables internally use Grain's `Marshal` standard library module to be serialized and deserialized, and thus may be of any type (meaning `Hopper.variable` does not guarantee type-safety). It is recommended to explicitly type variable accesses with `Hopper.Variable<a>`, ensuring that they are the same type as the values set.
