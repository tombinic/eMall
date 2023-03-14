# array.some
tests whether some element in the array passes the test implemented by the provided function

----
<a href="https://nodei.co/npm/array.some/"><img src="https://nodei.co/npm/array.some.png?downloads=true"></a>

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg?style=flat-square)](https://travis-ci.org/joaquimserafim/array.some)![Code Coverage 100%](https://img.shields.io/badge/code%20coverage-100%25-green.svg?style=flat-square)[![ISC License](https://img.shields.io/badge/license-ISC-blue.svg?style=flat-square)](https://github.com/joaquimserafim/array.some/blob/master/LICENSE)[![NodeJS](https://img.shields.io/badge/node-6.1.x-brightgreen.svg?style=flat-square)](https://github.com/joaquimserafim/array.some/blob/master/package.json#L38)

[![JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)


### api
`const some = require('array.some')`

`some(array, callback)`

* **array** the array to be processed by the provided function
* **callback** function to test for each element, taking 3 arguments:
    - **currentValue** the current element being processed in the array
    - **index** the index of the current element being processed in the array
    - **array** the array some() was called upon

### example

```js
const some = require('array.some')

some([1, 2, 3, 4, 5, 6, 7, 8, 9], isBiggerThan5)// true

function isBiggerThan5 (ele) {
  return ele > 5
}

```

#### ISC License (ISC)
