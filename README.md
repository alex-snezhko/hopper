# Hopper
An HTTP microframework for the Grain programming language, built on top of [WAGI](https://github.com/deislabs/wagi). Like a real hopper, Hopper allows you to transport your Grain (across the internet, that is! _\*wink\*_)

Hopper allows you to easily set up an HTTP server/API for use by your web app or otherwise. It is intentionally minimal: it comes with a core set of features commonly needed from an HTTP server out-of-the-box, and it aims to be easy to extend for more specific use cases. 

Key features:
- Simple paradigm for handling HTTP requests
- Nested routing system to make organizing HTTP routes easy
- Composable middleware system to avoid code duplication and add abstraction
- Out-of-the-box support for common use cases, including HTML form handling

**NOTE: Express great care if using Hopper in a production environment. Hopper includes some basic security features, but was not thoroughly vetted for security vulnerabilities. It is also built on top of WAGI, a technology considered to be experimental by its authors.**


## Documentation
Guides with examples as well as API docs can be found in the [`docs`](/docs) directory of this repo.


## Contributing
If you find a bug or feel that Hopper is missing some feature, feel free to open an issue or fork the repo and open a PR.


## Acknowledgements
Hopper was inspired in no small part by [Dream](https://github.com/aantron/dream) and [Express](https://expressjs.com/), and of course it would not be possible without all of the foundation it stands upon, including the Grain programming language and WAGI ❤️
