# Tests
Some tests for Hopper functionality, using [grain-test](https://github.com/alex-snezhko/grain-test). Some of the functions tested in `unitTests.test.gr` are not exported in `hopper.gr` because they are not necessary to expose to the user; to run the tests make sure to temporarily export them. Here's a command to export them all at once (run from test directory):
```
sed -i '/\/\/ test-export/{ n; s/^let/export let/ }' ../hopper.gr
```
and to un-export them again
```
sed -i '/\/\/ test-export/{ n; s/^export let/let/ }' ../hopper.gr
```
`./run-tests` to run the tests.
