# Hopper
An HTTP microframework for the Grain programming language built on top of [WAGI](https://github.com/deislabs/wagi), a [CGI v1.1](https://datatracker.ietf.org/doc/html/rfc3875) server implementation for WebAssembly. Like its namesake, Hopper allows you to dispense your Grain (across the internet, that is _\*wink\*_).

Hopper allows you to easily set up an HTTP server/API for use by your web app or otherwise. It is intentionally minimal, shipping with a core set of common HTTP server features out-of-the-box, while aiming to be easy to extend for more specific use cases. 

Key features:
- Simple paradigm for handling HTTP requests and responses
- Nested routing system to make organizing HTTP routes easy
- Out-of-the-box support for common use cases, including HTML form handling
- Composable middleware system to enable code reuse and extensibility

**NOTE: Express caution if using Hopper in any serious application. Hopper is built on experimental technology and is currently in a "Proof-of-Concept" stage, having not been thoroughly vetted for robustness and/or security vulnerabilities. Furthermore, its API may significantly change in the future.**


## Documentation
Guides with examples as well as API docs can be found in the [`docs`](/docs) directory of this repo.


## Contributing
If you find a bug or have a suggestion for improving Hopper, feel free to open an issue or fork the repo and open a PR.


## Acknowledgements
Hopper's API was inspired by other HTTP server libraries, namely [Dream](https://github.com/aantron/dream), [Express](https://expressjs.com/), and [Flask](https://flask.palletsprojects.com/en/2.2.x/) (roughly in that order of influence). It would also not be possible without all of the foundation it stands upon, including the Grain programming language and WAGI ❤️
