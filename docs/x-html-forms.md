
TODO this is no longer accurate

`Hopper.parseUrlencodedFormBody` reads form data from requests. On `GET` requests, the URL query params will be parsed for the form data. For all other request methods, the form data will be parsed from the request body as `&`-separated key-value pairs. Note that for non-`GET` requests, the `Content-Type` is expected to be `application/x-www-form-urlencoded`. If it is not, an `Err` `Result` variant will be returned containing a `415 Unsupported Media Type` response
