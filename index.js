const R = require('ramda');
const shell = require('shelljs');

console.log(shell.exec('pwd'));
console.log(shell.exec("cd ../meishi-shoptag && git grep -n 'R.[a-zA-Z_]*' -- \'./server/*\' \'./src/*' | grep -o 'R\.[a-zA-Z_]*'"));

