# Hopper
```
import Hopper from "./hopper"

Hopper.serve([
  Hopper.get("/hello", req => {
    Hopper.text("Hello, world!")
  })
])
```
An HTTP microframework for the Grain programming language built on top of [WAGI](https://github.com/deislabs/wagi), a [CGI v1.1](https://datatracker.ietf.org/doc/html/rfc3875) server implementation for WebAssembly. Like its namesake, Hopper allows you to dispense your Grain (to users across the internet, that is _\*wink\*_).

Hopper allows you to quickly structure an HTTP server/API for use by your web app or otherwise. It is intentionally minimal; rather than aiming to be a complete, fully-featured web application framework, it aims to provide a foundation flexible enough to be used as a base for a wide array of use cases, while being easy to extend in order to fit specific scenarios.

Key features:
- Simple paradigm for handling HTTP requests and responses
- Routing system with regex-based matching and route nesting to make organizing HTTP routes easy
- Composable middleware system to enable code reuse and extensibility

**NOTE: Express caution if using Hopper in any serious application. Hopper is built on experimental technology and is currently in an early stage, having not been thoroughly vetted for robustness and/or security vulnerabilities. Furthermore, its API is likely to change in the future as new features get added to Grain and/or WAGI.**


## Documentation
Usage guides as well as API docs can be found in the [docs](/docs) directory of this repo.


## Contributing
If you find a bug or have a suggestion for improving Hopper, feel free to open a GitHub issue or fork the repo and open a PR!


## Acknowledgements
Hopper was heavily inspired by other HTTP server libraries, most prominently [Dream](https://github.com/aantron/dream) and [Express](https://expressjs.com/). Hopper would also not be possible without all of the foundation it stands upon, including the Grain programming language and WAGI ❤️
