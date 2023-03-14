/*
eslint
no-multi-spaces: ["error", {exceptions: {"VariableDeclarator": true}}]
padded-blocks: ["error", {"classes": "always"}]
max-len: ["error", 80]
*/
'use strict'

module.exports = some

function some (arr, fn) {

  const len = arr.length
  let i = -1

  while (++i < len) {
    if (fn(arr[i], i, arr)) {
      return true
    }
  }

  return false
}
