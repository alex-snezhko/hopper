# Getting Started
First, make sure to install [WAGI](https://github.com/deislabs/wagi) as it is currently the only runtime environment Hopper supports. Hopper is distributed as a single Grain file, which you can install into your project directory. For example, if you are on UNIX-based system with `curl` installed, from your project directory you can run
```
curl https://raw.githubusercontent.com/alex-snezhko/hopper/main/hopper.gr -o hopper.gr
```

## WAGI Configuration
You'll need a WAGI module configuration file to get WAGI to run your code properly. Below is a sample configuration you can paste into `modules.toml`, assuming you want to run your server on port 3000, be able to serve static files from your project directory, and have a single Grain file `app.gr` responsible for all of the endpoints on your server:
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

Hopper.serve([
  Hopper.get("/hello", req => {
    Hopper.text("Hello, world!")
  })
])
```

In order to run our new program, first let's compile it;
```
grain compile app.gr --release
```
**Please note that the `--release` flag is currently required in order for the generated WASM binary to be compatible with WAGI**. If you don't include this compilation flag, you'll be met with a nasty error upon running the compiled WASM against WAGI.

Now we can run our compiled WASM with WAGI using the config file we created earlier; assuming you have `wagi` in your `PATH`:
```
wagi -c modules.toml
```

Now if we try to access `http://localhost:3000/hello` with a GET request, we should see our "Hello, world!" message
```
$ curl http://localhost:3000/hello
Hello, world!
```

## ⚠️ An foreword about logging
Often times it is desirable to have an HTTP server write log messages for debugging or logging significant application events. **Please note that you should NOT write to `stdout` for logging e.g. through Grain's built-in `print` function. WAGI reserves `stdout` for writing HTTP responses!** Instead, the solution is to write to `stderr`, reserved by WAGI for writing to the configured log file. By default, this file is in a temporary directory, but the CLI flag `--log-dir <desired_directory>` can be used when running WAGI to specify a directory to write logs to. `Hopper.log` is a simple built-in function that writes to `stderr`, and it can be viewed as a replacement of Grain's `print` function for writing logs.

Next guide: [Request handling](1-request-handling.md)
