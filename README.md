# Hopper
An HTTP microframework for the Grain programming language built on top of [WAGI](https://github.com/deislabs/wagi), a [CGI v1.1](https://datatracker.ietf.org/doc/html/rfc3875) implementation for WebAssembly. Like a real hopper, Hopper allows you to transport your Grain (across the internet, that is! _\*wink\*_)

Hopper allows you to easily set up an HTTP server/API for use by your web app or otherwise. It is intentionally minimal: it comes with a core set of features commonly needed from an HTTP server out-of-the-box, and it aims to be easy to extend for more specific use cases. 

Key features:
- Simple paradigm for handling HTTP requests and responses
- Nested routing system to make organizing HTTP routes easy
- Composable middleware system to avoid code duplication and add abstraction
- Out-of-the-box support for common use cases, including HTML form handling

**NOTE: Express great care if using Hopper in any serious application. Hopper is currently in a "Proof-of-Concept" stage and has not been thoroughly vetted for robustness and/or security vulnerabilities. It is also built on top of WAGI, a technology considered to be experimental by its authors.**


## Documentation
Guides with examples as well as API docs can be found in the [`docs`](/docs) directory of this repo.


## Contributing
If you find a bug or have a suggestion for improving Hopper, feel free to open an issue or fork the repo and open a PR.


## Acknowledgements
Hopper's API was inspired in no small part by [Dream](https://github.com/aantron/dream), [Flask](https://flask.palletsprojects.com/en/2.2.x/), and [Express](https://expressjs.com/). It would also not be possible without all of the foundation it stands upon, including the Grain programming language and WAGI ❤️
