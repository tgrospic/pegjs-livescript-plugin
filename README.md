# PEG.js LiveScript plugin

[![build status][travis-image]][travis-url]
[![npm version][version-image]][version-url]

[PEG.js][peg-js] is a great tool for generating parsers in JavaScript with very concise grammar.  
For more in-depth entertainment on packrat parsers and PEGs;
here is the wild stuff [Packrat Parsing and Parsing Expression Grammars][peg-bford].

[LiveScript][livescript] is a glorious language which compiles to JavaScript.
The _everything-is-expression_ style and its sugary syntax makes me a smile every time. :smile:

This plugin, following the example of the existing CoffeeScript plugins
[[Dignifiedquire/pegjs-coffee-plugin][cp1], [ttilley/pegcoffee][cp2]],
allows writing PEG.js grammar with
[LiveScript][livescript] code in _initializer_, _actions_ and _predicates_.

_There is a little difference in comparison with Coffee plugins.
Context `this` or `@` remains unchanged._

## Installation

```sh
$ npm install pegjs-livescript-plugin
```

## Usage

#### Node.js

```ls
require! { PEG, 'pegjs-livescript-plugin' }

grammar = "Start = cs:.* { cs.join '' }"

# Build parser with LiveScript plugin
parser = PEG.buildParser grammar, plugins: [pegjs-livescript-plugin]

parser.parse 'PEG is fun!'
```

#### CLI

```sh
$ pegjs --plugin pegjs-livescript-plugin my-grammar.pegls
```

#### PEG.js LiveScript

```pegls
// .pegls - PEG.js LiveScript grammar
{
  my-var = 42

  join-chars = (chars) ->
    chars.join ''
}

Start
  = cs:.* {
    # my-var := 4711 # SyntaxError: assignment to undeclared "myVar"
    my-var = 4711 # initializer variable `my-var == 42` is shadowed
    join-chars cs
  }
```

compiles to JavaScript

```pegjs
{
  var myVar, joinChars;
  myVar = 42;
  joinChars = function(chars){
    return myVar + chars.join(''); // myVar === 42
  };
}

Start
  = ch:.* {
    var myVar;
    return myVar = 4711, joinChars(cs);
  }
```

__Note__: variables defined in one scope (between `{` `}`) can not be modified in a different scope
not even with `:=`. Each scope is compiled separately which causes re-declaration of variables.
It seems to me that this is actually a _smart_ restriction (consequence) but I'm open to suggestions.

## Tests

```sh
$ npm test
```

## Todo

- browser build/test
- better compile/runtime error report (sourcemap?!)
- accept compiler options (eg. `const: true`)

## License

[The MIT License (MIT)][license]

[peg-js]: https://github.com/pegjs/pegjs
[peg-bford]: http://bford.info/packrat
[livescript]: https://github.com/gkz/LiveScript
[cp1]: https://github.com/Dignifiedquire/pegjs-coffee-plugin
[cp2]: https://github.com/ttilley/pegcoffee

[travis-image]: https://api.travis-ci.org/tgrospic/pegjs-livescript-plugin.svg
[travis-url]: https://travis-ci.org/tgrospic/pegjs-livescript-plugin
[version-image]: https://img.shields.io/npm/v/pegjs-livescript-plugin.svg
[version-url]: https://www.npmjs.com/package/pegjs-livescript-plugin
[license]: https://github.com/tgrospic/pegjs-livescript-plugin/blob/master/LICENSE
