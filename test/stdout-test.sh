#!/usr/bin/env bash

assertCorrect() {
    expected=$1
    actual=$2
    if [ "$expected" = "$actual" ]; then
        printf 'Test passed\n'
    else
        printf "Test failed;\nExpected:\n$expected\nActual:\n$actual\n"
    fi
}

cat > outTest.gr <<EOF
import Map from "map"
import Option from "option"
import Hopper from "../hopper"

Hopper.serve([
  Hopper.get("/route", req => {
    Hopper.text("Response")
  }),
  Hopper.post("/route", req => {
    Hopper.text("Post Response")
  }),
  Hopper.get("/asdf", req => {
    Hopper.response(Hopper.HttpOk, Map.make(), "")
  }),
  Hopper.get("/funky", req => {
    Hopper.response(Hopper.HttpOk, Map.fromList([("Content\n-Type\n", "\n\ntext/plain\n")]), "Funky")
  }),
  Hopper.get("/redirect", req => {
    Hopper.redirectLocal("/asdf", req)
  }),
  Hopper.scope("/info", [
    Hopper.get("/<param>", req => {
      let fp = Hopper.path(req)
      let p = Hopper.param("param", req)
      let q = Option.unwrap(Hopper.query("qp", req))
      let l = Hopper.queryList("qpl", req)
      let h = Option.unwrap(Hopper.header("Content-Type", req))
      let b = Hopper.body(req)
      Hopper.text(fp ++ " " ++ p ++ " " ++ q ++ " " ++ toString(l) ++ " " ++ h ++ " " ++ b)
    })
  ])
])
EOF

grain compile outTest.gr

out=$(REQUEST_METHOD=GET PATH_INFO=/route CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: text/plain
status: 200

Response
END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=GET PATH_INFO=/not-found CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: text/plain
status: 404

Requested URL not found
END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=PUT PATH_INFO=/route CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
allow: GET, POST
content-type: text/plain
status: 405

Method not allowed for this URL
END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=GET PATH_INFO=/asdf CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: application/octet-stream
status: 200


END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=GET PATH_INFO=/funky CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: text/plain
content-type: application/octet-stream
status: 200

Funky
END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=GET PATH_INFO=/redirect CONTENT_LENGTH=0 SERVER_NAME=localhost SERVER_PORT=3000 X_FULL_URL=http://... grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: application/octet-stream
location: http://localhost:3000/asdf
status: 302


END
assertCorrect "$expected" "$out"


out=$(echo 'asdfghjkl;' | REQUEST_METHOD=GET PATH_INFO=/info/paramVal CONTENT_LENGTH=10 HTTP_CONTENT_TYPE=text/plain grain run outTest.gr.wasm / qpl=f qp=qpVal qpl=s)
read -r -d '' expected << END
content-type: text/plain
status: 200

/info/paramVal paramVal qpVal ["f", "s"] text/plain asdfghjkl;
END
assertCorrect "$expected" "$out"


cat > outTest.gr <<EOF
import Map from "map"
import Option from "option"
import Hopper from "../hopper"

let makeMw = suffix => next => req => {
  let res = next(req)
  let b = Hopper.body(res) ++ " - " ++ suffix
  Hopper.response(Hopper.status(res), Hopper.headers(res), b)
}

Hopper.serveWithSettings([
  Hopper.NotFoundHandler(req => {
    Hopper.newStatus(Hopper.NotFound, Hopper.text("CUSTOM - Route not found"))
  }),
  Hopper.MethodNotAllowedHandler((allowed, req) => {
    Hopper.newStatus(Hopper.NotFound, Hopper.text("CUSTOM - Route with method not found"))
  }),
  Hopper.GlobalMiddleware(makeMw("glob"))
], [
  Hopper.scopeWithMiddleware("/info/.*", makeMw("scope"), [
    Hopper.get("/<caught(.*)>/end", req => {
      let v = Hopper.param("caught", req)
      Hopper.text(v)
    })
  ])
])
EOF

grain compile outTest.gr

out=$(REQUEST_METHOD=GET PATH_INFO=/not-found CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: text/plain
status: 404

CUSTOM - Route not found - glob
END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=GET PATH_INFO=/info/uncaught/what CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: text/plain
status: 404

CUSTOM - Route not found - scope - glob
END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=POST PATH_INFO=/info/uncaught/caught-thing.stuff/end CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: text/plain
status: 404

CUSTOM - Route with method not found - scope - glob
END
assertCorrect "$expected" "$out"


out=$(REQUEST_METHOD=GET PATH_INFO=/info/uncaught/caught-thing.stuff/end CONTENT_LENGTH=0 grain run outTest.gr.wasm)
read -r -d '' expected << END
content-type: text/plain
status: 200

caught-thing.stuff - scope - glob
END
assertCorrect "$expected" "$out"

rm outTest.gr outTest.gr.wasm