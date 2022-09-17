---
title: Hopper
---

An HTTP microframework for the Grain programming language.

Version 0.1.0

## Types

Type declarations included in the Hopper module.

### Hopper.**Method**

```grain
enum Method {
  Get,
  Post,
  Put,
  Delete,
  Head,
  Patch,
  Options,
  Trace,
  Method(String),
}
```

Represents various HTTP request methods.

### Hopper.**OneOrMany**

```grain
enum OneOrMany<a> {
  Val(a),
  Vals(List<a>),
}
```

Represents either a single value or multiple values.

### Hopper.**RequestMsgData**

```grain
record RequestMsgData {
  _wagiEnv: Map.Map<String, String>,
  _params: Map.Map<String, String>,
  _query: Map.Map<String, OneOrMany<String>>,
}
```

Represents request-specific message data (this simply contains data
injected into `Message<a>` to make `Request` as `Message<RequestMsgData>`).
Typically you should not access the fields of this record directly.

### Hopper.**Status**

```grain
enum Status {
  Continue,
  SwitchingProtocols,
  HttpOk,
  Created,
  Accepted,
  NonAuthoritativeInformation,
  NoContent,
  ResetContent,
  ParialContent,
  MultipleChoices,
  MovedPermanently,
  Found,
  SeeOther,
  NotModified,
  TemporaryRedirect,
  PermanentRedirect,
  BadRequest,
  Unauthorized,
  PaymentRequired,
  Forbidden,
  NotFound,
  MethodNotAllowed,
  NotAcceptable,
  ProxyAuthenticationRequired,
  RequestTimeout,
  Conflict,
  Gone,
  LengthRequired,
  PreconditionFailed,
  PayloadTooLarge,
  UriTooLong,
  UnsupportedMediaType,
  RangeNotSatisfiable,
  ExpectationFailed,
  ImATeapot,
  MisdirectedRequest,
  TooEarly,
  UpgradeRequired,
  PrecoditionRequired,
  TooManyRequests,
  RequestHeaderFieldsTooLarge,
  UnavailableForLegalReasons,
  InternalServerError,
  NotImplemented,
  BadGateway,
  ServiceUnavailable,
  GatewayTimeout,
  HttpVersionNotSupported,
  VariantAlsoNegotiates,
  NotExtended,
  NetworkAuthenticationRequired,
  Status(Number),
}
```

Represents HTTP response statuses.

### Hopper.**ResponseMsgData**

```grain
record ResponseMsgData {
  _status: Status,
}
```

Represents response-specific message data (this simply contains data
injected into `Message<a>` to make `Response` as `Message<ResponseMsgData>`).
Typically you should not access the fields of this record directly.

### Hopper.**Message**

```grain
record Message<a> {
  _message: a,
  _headers: Map.Map<String, String>,
  _body: String,
  _variables: Map.Map<String, Bytes>,
}
```

Opaque polymorphic representation of an HTTP message (concretely instanced
by `Request` and `Response` types). Typically you should not access the
fields of this record directly.

### Hopper.**Request**

```grain
type Request = Message<RequestMsgData>
```

Represents an HTTP request.

### Hopper.**Response**

```grain
type Response = Message<ResponseMsgData>
```

Represents an HTTP response.

### Hopper.**RequestHandler**

```grain
type RequestHandler = Request -> Response
```

Represents an HTTP request handler which processes a request and returns a response.

### Hopper.**Middleware**

```grain
type Middleware = RequestHandler -> RequestHandler
```

Represents an HTTP middleware, which sits between the client and base request handler.

### Hopper.**RequestMethods**

```grain
enum RequestMethods {
  Methods(List<Method>),
  All,
}
```

### Hopper.**Route**

```grain
record Route {
  path: String,
  routeHandler: RouteHandler,
}
```

Represents a route on the server with a request handler attached to it.

### Hopper.**RouteHandler**

```grain
type RouteHandler
```

### Hopper.**GetVariableError**

```grain
enum GetVariableError {
  NotSet,
  DeserializationError(String),
}
```

Represents possible `Err` reasons for why a variable's value was not read.

`NotSet` indicates that a variable with the given name does not exist

`DeserializationError` indicates that the variable was unable to be
deserialized properly. The attached `String` gives the error reason

### Hopper.**Variable**

```grain
type Variable<a> = Result<a, GetVariableError>
```

Represents the result of fetching a message variable. A `Result` with an
`Ok` variant containing the value or `GetVariableError` `Err` variant.

### Hopper.**ServerOption**

```grain
enum ServerOption {
  NotFoundHandler(RequestHandler),
  MethodNotAllowedHandler(((List<Method>, Request) -> Response)),
}
```

Represents an option to apply globally to the server.

`NotFoundHandler` can be used to define a custom 404 Not Found handler
when a route is not matched.

`MethodNotAllowedHandler` can be used to defined a custom 405 method
Not Allowed handler for cases of method mismatches.

## Utilities

Miscellaneous utility functions.

### Hopper.**log**

```grain
log : a -> Void
```

Writes a message to the WAGI log file.

Parameters:

|param|type|description|
|-----|----|-----------|
|`val`|`a`|The value to write out to the log|

### Hopper.**middlewares**

```grain
middlewares : List<Middleware> -> Middleware
```

Utility function to combine multiple middlewares into one function.

Parameters:

|param|type|description|
|-----|----|-----------|
|`mws`|`List<Middleware>`|The middlewares to combine|

Returns:

|type|description|
|----|-----------|
|`Middleware`|A single middleware function, chaining the first middleware in the list down to the last|

### Hopper.**guessMimeType**

```grain
guessMimeType : String -> String
```

Guesses the MIME type of a media file by its filename extension.

Parameters:

|param|type|description|
|-----|----|-----------|
|`fileName`|`String`|The filename to guess the MIME type of|

Returns:

|type|description|
|----|-----------|
|`String`|A MIME type string for the filename|

### Hopper.**splitOneOrManyMap**

```grain
splitOneOrManyMap : Map.Map<a, OneOrMany<b>> -> List<(a, b)>
```

Splits a map containing `OneOrMany` values into a list of key-value pairs;
an element is added for each value of `Vals` for a key.

Parameters:

|param|type|description|
|-----|----|-----------|
|`map`|`Map.Map<a, OneOrMany<b>>`|The map with `OneOrMany` values to inspect|

Returns:

|type|description|
|----|-----------|
|`List<(a, b)>`|A list of key-value pairs representing the map|

### Hopper.**joinOneOrManyMap**

```grain
joinOneOrManyMap : List<(a, b)> -> Map.Map<a, OneOrMany<b>>
```

Joins a list of key-value pairs into a map of `OneOrMany` values, where
multiple values corresponding to the same key are collated into the same
`Vals` variant.

Parameters:

|param|type|description|
|-----|----|-----------|
|`map`|`List<(a, b)>`|The key-value pairs list to inspect|

Returns:

|type|description|
|----|-----------|
|`Map.Map<a, OneOrMany<b>>`|A map representing the list of pairs|

### Hopper.**percentEncode**

```grain
percentEncode : String -> String
```

Percent-encodes RFC 3986 reserved url characters (and space) in a string.

Parameters:

|param|type|description|
|-----|----|-----------|
|`str`|`String`|The string to encode|

Returns:

|type|description|
|----|-----------|
|`String`|A percent-encoding of the given string|

### Hopper.**percentDecode**

```grain
percentDecode : String -> String
```

Decodes any percent-encoded characters in a string.

Parameters:

|param|type|description|
|-----|----|-----------|
|`str`|`String`|The string to decode|

Returns:

|type|description|
|----|-----------|
|`String`|A decoding of the given percent-encoded string|

### Hopper.**urlEncode**

```grain
urlEncode : Map.Map<String, OneOrMany<String>> -> String
```

Url-encodes a map of OneOrMany values into a single string.

Parameters:

|param|type|description|
|-----|----|-----------|
|`urlVals`|`Map.Map<String, OneOrMany<String>>`|A map of OneOrMany values to url-encode|

Returns:

|type|description|
|----|-----------|
|`String`|A url-encoded string of the values|

### Hopper.**urlDecode**

```grain
urlDecode : String -> Map.Map<String, OneOrMany<String>>
```

Decodes a url-encoded string into a map of OneOrMany values.

Parameters:

|param|type|description|
|-----|----|-----------|
|`str`|`String`|A url-encoded string|

Returns:

|type|description|
|----|-----------|
|`Map.Map<String, OneOrMany<String>>`|A map of OneOrMany values containing the values of the encoded string|

### Hopper.**stringToMethod**

```grain
stringToMethod : String -> Method
```

Converts a string to an HTTP `Method`.

Parameters:

|param|type|description|
|-----|----|-----------|
|`str`|`String`|The string to convert to a `Method`|

Returns:

|type|description|
|----|-----------|
|`Method`|A `Method` representing the string|

Examples:

```grain
Hopper.stringToMethod("GET") // Method.Get
```

### Hopper.**methodToString**

```grain
methodToString : Method -> String
```

Converts a `Method` to a string describing the method.

Parameters:

|param|type|description|
|-----|----|-----------|
|`method`|`Method`|`Method` to stringify|

Returns:

|type|description|
|----|-----------|
|`String`|A string representing the `Method`|

### Hopper.**codeToStatus**

```grain
codeToStatus : Number -> Status
```

Converts a status code to its corresponding status.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Number`|A status code to convert to a `Status`|

Returns:

|type|description|
|----|-----------|
|`Status`|A status representing the given code|

### Hopper.**statusToCode**

```grain
statusToCode : Status -> Number
```

Converts a response status to its corresponding status code.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|A `Status` to get the status code of|

Returns:

|type|description|
|----|-----------|
|`Number`|A status code for the response status|

### Hopper.**isInformationalStatus**

```grain
isInformationalStatus : Status -> Bool
```

Determines if an HTTP status is informational i.e. has a 1XX code.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|The status to examine|

Returns:

|type|description|
|----|-----------|
|`Bool`|`true` if the status has a 1XX status code or `false` otherwise|

### Hopper.**isSuccessfulStatus**

```grain
isSuccessfulStatus : Status -> Bool
```

Determines if an HTTP status is successful i.e. has a 2XX code.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|The status to examine|

Returns:

|type|description|
|----|-----------|
|`Bool`|`true` if the status has a 2XX status code or `false` otherwise|

### Hopper.**isRedirectionStatus**

```grain
isRedirectionStatus : Status -> Bool
```

Determines if an HTTP status is a redirection i.e. has a 3XX code.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|The status to examine|

Returns:

|type|description|
|----|-----------|
|`Bool`|`true` if the status has a 3XX status code or `false` otherwise|

### Hopper.**isClientErrorStatus**

```grain
isClientErrorStatus : Status -> Bool
```

Determines if an HTTP status is a client error i.e. has a 4XX code.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|The status to examine|

Returns:

|type|description|
|----|-----------|
|`Bool`|`true` if the status has a 4XX status code or `false` otherwise|

### Hopper.**isServerErrorStatus**

```grain
isServerErrorStatus : Status -> Bool
```

Determines if an HTTP status is a server error i.e. has a 5XX code.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|The status to examine|

Returns:

|type|description|
|----|-----------|
|`Bool`|`true` if the status has a 5XX status code or `false` otherwise|

## Messages

Functions that can be used on both requests and responses

### Hopper.**header**

```grain
header : (String, Message<a>) -> Option<String>
```

Fetches a header from the message.

Parameters:

|param|type|description|
|-----|----|-----------|
|`key`|`String`|The header to request|
|`msg`|`Message<a>`|The request or response to examine|

Returns:

|type|description|
|----|-----------|
|`Option<String>`|The header value requested|

### Hopper.**headers**

```grain
headers : Message<a> -> Map.Map<String, String>
```

Fetches headers on a message.

Parameters:

|param|type|description|
|-----|----|-----------|
|`msg`|`Message<a>`|The request or response to examine|

Returns:

|type|description|
|----|-----------|
|`Map.Map<String, String>`|The headers on the request or response, with header names all in lowercase|

### Hopper.**body**

```grain
body : Message<a> -> String
```

Fetches the message body as a string.

Parameters:

|param|type|description|
|-----|----|-----------|
|`msg`|`Message<a>`|The request or response to examine|

Returns:

|type|description|
|----|-----------|
|`String`|The body as a string|

### Hopper.**setVariable**

```grain
setVariable : (String, a, Message<b>) -> Void
```

Sets a variable on a message to a new arbitrary value.

Parameters:

|param|type|description|
|-----|----|-----------|
|`key`|`String`|The variable to set|
|`value`|`a`|The new value to give the variable|
|`msg`|`Message<b>`|The message to attach the variable to|

### Hopper.**variable**

```grain
variable : (String, Message<b>) -> Variable<a>
```

Fetches the value of a variable set on a message. The result of this
function should be explicitly typed.

Parameters:

|param|type|description|
|-----|----|-----------|
|`key`|`String`|The variable to fetch|
|`msg`|`Message<b>`|The message to inspect|

Returns:

|type|description|
|----|-----------|
|`Variable<a>`|The value of the variable requested|

## Requests

Functions related to handling incoming requests.

### Hopper.**query**

```grain
query : (String, Request) -> Option<String>
```

Fetches a URL query parameter with the given name from a request.

Parameters:

|param|type|description|
|-----|----|-----------|
|`key`|`String`|The name of the parameter to fetch the value of|
|`req`|`Request`|The request to fetch the query parameter from|

Returns:

|type|description|
|----|-----------|
|`Option<String>`|The value of the query parameter with the given name|

### Hopper.**queryList**

```grain
queryList : (String, Request) -> List<String>
```

Fetches a list of values associated with the URL query parameter with the
given name.

Parameters:

|param|type|description|
|-----|----|-----------|
|`key`|`String`|The name of the parameter to fetch the value of|
|`req`|`Request`|The request to fetch the query parameters from|

Returns:

|type|description|
|----|-----------|
|`List<String>`|The list of values of the query parameter with the given name|

### Hopper.**queries**

```grain
queries : Request -> Map.Map<String, OneOrMany<String>>
```

Fetches all URL query parameters.

Parameters:

|param|type|description|
|-----|----|-----------|
|`req`|`Request`|The request to fetch the query parameters from|

Returns:

|type|description|
|----|-----------|
|`Map.Map<String, OneOrMany<String>>`|All query parameters given|

### Hopper.**path**

```grain
path : Request -> String
```

Fetches the full path from the requested URL.

Parameters:

|param|type|description|
|-----|----|-----------|
|`req`|`Request`|The request to examine|

Returns:

|type|description|
|----|-----------|
|`String`|The full path requested|

### Hopper.**param**

```grain
param : (String, Request) -> String
```

Fetches a path parameter from the request.

Parameters:

|param|type|description|
|-----|----|-----------|
|`key`|`String`|The path parameter to fetch|
|`req`|`Request`|The request to examine|

Returns:

|type|description|
|----|-----------|
|`String`|The path parameter requested|

### Hopper.**method**

```grain
method : Request -> Method
```

Fetches the HTTP method of the request.

Parameters:

|param|type|description|
|-----|----|-----------|
|`req`|`Request`|The request to examine|

Returns:

|type|description|
|----|-----------|
|`Method`|The HTTP method of the request.|

## Responses

Functions related to handling outgoing responses.

### Hopper.**response**

```grain
response : (Status, Map.Map<String, String>, String) -> Response
```

Creates a new `Response` with a status, headers, and body.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|The desired HTTP status|
|`headers`|`Map.Map<String, String>`|The desired HTTP headers|
|`body`|`String`|The body string to create the `Response` with|

Returns:

|type|description|
|----|-----------|
|`Response`|A new `Response` with the given values|

### Hopper.**text**

```grain
text : String -> Response
```

Creates a new OK `Response` with a text body and `"text/plain"` Content-Type.

Parameters:

|param|type|description|
|-----|----|-----------|
|`body`|`String`|The text body to create the `Response` with|

Returns:

|type|description|
|----|-----------|
|`Response`|A new text `Response`|

### Hopper.**json**

```grain
json : String -> Response
```

Creates a new OK `Response` with a JSON string body and `"application/json"` Content-Type.

Note: the argument type will likely be changed to a more friendly JSON
representation once https://github.com/grain-lang/grain/pull/1133 gets
merged.

Parameters:

|param|type|description|
|-----|----|-----------|
|`body`|`String`|The JSON body to create the `Response` with|

Returns:

|type|description|
|----|-----------|
|`Response`|A new JSON `Response`|

### Hopper.**contentType**

```grain
contentType : (String, String) -> Response
```

Creates a new OK `Response` with the specified content type.

Parameters:

|param|type|description|
|-----|----|-----------|
|`contentType`|`String`|The Content-Type to set for the `Response`|
|`body`|`String`|The body of the response|

Returns:

|type|description|
|----|-----------|
|`Response`|A new `Response` with the given content type|

### Hopper.**newStatus**

```grain
newStatus : (Status, Response) -> Response
```

Creates a new `Response` from an existing response, but with the response status code changed.

Parameters:

|param|type|description|
|-----|----|-----------|
|`status`|`Status`|The desired HTTP status|
|`res`|`Response`|The base response|

Returns:

|type|description|
|----|-----------|
|`Response`|A new `Response` with the desired HTTP status|

### Hopper.**newHeaders**

```grain
newHeaders : (Map.Map<String, String>, Response) -> Response
```

Creates a new `Response` from an existing response, but with the response headers changed.

Parameters:

|param|type|description|
|-----|----|-----------|
|`headers`|`Map.Map<String, String>`|The desired HTTP headers|
|`res`|`Response`|The base response|

Returns:

|type|description|
|----|-----------|
|`Response`|A new `Response` with the desired HTTP headers|

### Hopper.**newBody**

```grain
newBody : (String, Response) -> Response
```

Creates a new `Response` from an existing response, but with the response body changed.

Parameters:

|param|type|description|
|-----|----|-----------|
|`body`|`String`|The desired HTTP body|
|`res`|`Response`|The base response|

Returns:

|type|description|
|----|-----------|
|`Response`|A new `Response` with the desired HTTP body|

### Hopper.**file**

```grain
file : String -> Response
```

Creates a new `Response` from a static file on the server at the given path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`filePath`|`String`|The path of the file to search for on the server|

Returns:

|type|description|
|----|-----------|
|`Response`|A new "OK" `Response` if the file is found, or a "Not Found" reponse otherwise|

### Hopper.**redirectLocal**

```grain
redirectLocal : (String, Request) -> Response
```

Creates a new redirection `Response` to another route on the server.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The local path to redirect to|
|`req`|`Request`|The incoming `Request`|

Returns:

|type|description|
|----|-----------|
|`Response`|A new redirection `Response` with status code "302 Found"|

### Hopper.**redirectExternal**

```grain
redirectExternal : String -> Response
```

Creates a new redirection `Response` to an arbitrary URL.

Parameters:

|param|type|description|
|-----|----|-----------|
|`url`|`String`|The URL to redirect to|

Returns:

|type|description|
|----|-----------|
|`Response`|A new redirection `Response` with status code "302 Found"|

### Hopper.**status**

```grain
status : Response -> Status
```

Fetches the HTTP response status of a response.

Parameters:

|param|type|description|
|-----|----|-----------|
|`res`|`Response`|The response to examine|

Returns:

|type|description|
|----|-----------|
|`Status`|The status of the response|

## Routing

Functions related to routing.

### Hopper.**get**

```grain
get : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling GET requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling GET requests at a path|

### Hopper.**post**

```grain
post : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling POST requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling POST requests at a path|

### Hopper.**put**

```grain
put : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling PUT requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling PUT requests at a path|

### Hopper.**delete**

```grain
delete : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling DELETE requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling DELETE requests at a path|

### Hopper.**head**

```grain
head : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling HEAD requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling HEAD requests at a path|

### Hopper.**patch**

```grain
patch : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling PATCH requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling PATCH requests at a path|

### Hopper.**options**

```grain
options : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling OPTIONS requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling OPTIONS requests at a path|

### Hopper.**trace**

```grain
trace : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling TRACE requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling TRACE requests at a path|

### Hopper.**route**

```grain
route : (Method, String, RequestHandler) -> Route
```

Creates a new `Route` for handling requests at a path.

Parameters:

|param|type|description|
|-----|----|-----------|
|`method`|`Method`|The HTTP method the route will handle|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling requests at a path|

### Hopper.**methodsRoute**

```grain
methodsRoute : (List<Method>, String, RequestHandler) -> Route
```

Creates a new `Route` for handling requests at a path with multiple allowed HTTP methods.

Parameters:

|param|type|description|
|-----|----|-----------|
|`methods`|`List<Method>`|The HTTP methods the route will handle|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling requests at a path|

### Hopper.**all**

```grain
all : (String, RequestHandler) -> Route
```

Creates a new `Route` for handling requests at a path for all HTTP methods.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`handler`|`RequestHandler`|The `RequestHandler` responsible for handling the request|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling requests at a path|

### Hopper.**scopeWithMiddleware**

```grain
scopeWithMiddleware : (String, Middleware, List<Route>) -> Route
```

Creates a new `Route` composed of multiple sub-routes defined relative to
the path given. A middleware is also applied to all requests in the scope.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`middleware`|`Middleware`|The middleware to apply to the routes in the scope|
|`routes`|`List<Route>`|The `Route`s composing the scope|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling requests rooted from the path|

### Hopper.**scope**

```grain
scope : (String, List<Route>) -> Route
```

Creates a new `Route` composed of multiple sub-routes defined relative to the path given.

Parameters:

|param|type|description|
|-----|----|-----------|
|`path`|`String`|The relative path the request handler will reside on|
|`routes`|`List<Route>`|The `Route`s composing the scope|

Returns:

|type|description|
|----|-----------|
|`Route`|A new `Route` handling requests rooted from the path|

### Hopper.**RouteMatchStatus**

```grain
type RouteMatchStatus
```

## Serving

Functions for declaring servers, the starting points of Hopper applications.

### Hopper.**serveWithMiddlewareAndOptions**

```grain
serveWithMiddlewareAndOptions :
  (Middleware, List<ServerOption>, List<Route>) -> Void
```

Entry point for creating a server, taking a list of routes and options to
apply for the server.

Parameters:

|param|type|description|
|-----|----|-----------|
|`middleware`|`Middleware`|The middleware to apply to all routes in the application|
|`options`|`List<ServerOption>`|The options to use for the server|
|`routes`|`List<Route>`|The root routes for the server|

### Hopper.**serveWithMiddleware**

```grain
serveWithMiddleware : (Middleware, List<Route>) -> Void
```

Entry point for creating a server, taking a list of route handlers and using
a default set of options.

Parameters:

|param|type|description|
|-----|----|-----------|
|`middleware`|`Middleware`|The middleware to apply to all routes in the application|
|`routes`|`List<Route>`|The root routes for the server|

### Hopper.**serveWithOptions**

```grain
serveWithOptions : (List<ServerOption>, List<Route>) -> Void
```

Entry point for creating a server, taking a list of route handlers and using
a default set of options.

Parameters:

|param|type|description|
|-----|----|-----------|
|`options`|`List<ServerOption>`|The options to use for the server|
|`routes`|`List<Route>`|The root routes for the server|

### Hopper.**serve**

```grain
serve : List<Route> -> Void
```

Entry point for creating a server, taking a list of route handlers and using
a default set of options.

Parameters:

|param|type|description|
|-----|----|-----------|
|`routes`|`List<Route>`|The root routes for the server|

