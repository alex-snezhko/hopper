# Getting Started
Firstly, [WAGI](https://github.com/deislabs/wagi) is required to be installed to be used as a runtime environment (the current version of Hopper is confirmed to work with WAGI v0.8.1). Currently, the core Hopper library is distributed as a single Grain file. For example, if you are on UNIX-based system with `curl` installed, you can get the core library with
```
curl https://raw.githubusercontent.com/alexsnezhko3/hopper/main/hopper.gr -o hopper.gr
```

## WAGI Configuration
You'll need a WAGI module configuration file to get WAGI running. Assuming you want to run your server on port 3000, be able to serve static files in your project directory, and have a single Grain file `app.gr` responsible for all of the endpoints on your server, here's a sample config which can be pasted into a `modules.toml` file in your project directory:
```
default_host = "localhost:3000"

[[module]]
route = "/..."
module = "./app.gr.wasm"
volumes = {"/" = "."}
```

## Hello, world!
Now that we have what we need, let's write a simple HTTP server that has a single `GET` endpoint at the path `/hello` which always responds with the text response "Hello, world!". In `app.gr`:
```
import Hopper from "./hopper"

Hopper.serve(
  Hopper.get("/hello", req => {
    Hopper.text("Hello, world!")
  })
)
```
Note that we'll go over each of these features in more depth in following guides.

In order to run our new program, first let's compile it;
```
grain compile app.gr --release
```
**Please note that the `--release` flag is currently required in order for the generated WASM binary to be compatible with WAGI**. If you don't include this flag, you'll be met with a nasty error upon running your code against WAGI.

Now we can run it with WAGI with the config file we created earlier:
```
wagi -c modules.toml
```

Now if we try to access `http://localhost:3000/hello` with a GET request, we should be met with our "Hello, world!" message!
```
$ curl http://localhost:3000/hello
Hello, world!
```
