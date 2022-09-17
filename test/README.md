# Tests
Some tests for Hopper functionality; unit tests using [grain-test](https://github.com/alex-snezhko/grain-test) and functional shell script tests mocking input. Some of the functions tested in the unit tests are not exported in `hopper.gr` because they are not necessary to expose to the user in normal usage scenarios; to run the tests make sure to temporarily export them. Here's a command to export them all at once (run from test directory):
```
sed -i '/\/\/ test-export/{ n; s/^let/export let/ }' ../hopper.gr
```
and to un-export them again
```
sed -i '/\/\/ test-export/{ n; s/^export let/let/ }' ../hopper.gr
```
`./run-tests` to run the unit tests and `./stdout-test.sh` to run the functional tests.
