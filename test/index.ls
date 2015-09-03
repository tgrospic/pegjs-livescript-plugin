/**
 * PEG.js LiveScript plugin test suite
 */
require! {
  tape: test
  fs, path, pegjs: PEG
  '../src/pegjs-livescript-plugin'
}

test 'should compile and generate parser with livescript plugin', (t) ->
  t.plan 1
  parser = build-parser 'valid-grammar'
  t.equal typeof parser.parse, 'function'

test 'should parse with generated parser', (t) ->
  t.plan 1
  parser = build-parser 'valid-grammar'
  ast = parser.parse '''
    query friendsOfFriends {
      alice: user(id: 4, active: true) {
        friends {
          friends(first: 10) {
            name
          }
        }
      }
    }'''
  t.deepEqual ast.0.body.0.args.1, name: 'active', value: 'true'

test 'should error with invalid livescript code', (t) ->
  t.plan 2
  f = -> build-parser 'livescript-error-grammar'
  t.throws f, SyntaxError
  t.throws f, /Parse error on line 2: Unexpected 'LITERAL'/

test 'should error if generated parser has invalid input (sync) - `semantic-and` predicate', (t) ->
  t.plan 2
  parser = build-parser 'valid-grammar'
  # Top definition must start with `query` or `type`
  parse = -> parser.parse '''
    sync friendsOfFriends {
      alice: user(id: 4, active: true) {
        friends {
          friends(first: 10) {
            name
          }
        }
      }
    }'''
  t.throws parse, parser.SyntaxError
  t.throws parse, /Expected end of input but "s" found/

test 'should error if generated parser has invalid input (__type) - `semantic-not` predicate', (t) ->
  t.plan 2
  parser = build-parser 'valid-grammar'
  # Field alias can't be `__type`
  parse = -> parser.parse '''
    query friendsOfFriends {
      alice: user(id: 4, active: true) {
        __type: name
        friends {
          friends(first: 10) {
            name
          }
        }
      }
    }'''
  t.throws parse, parser.SyntaxError
  t.throws parse, /Expected "}" but "_" found/

function load-grammar grammarPath
  filePath = path.join __dirname, 'fixtures', "#grammarPath.pegls"
  fs.readFileSync filePath, 'utf-8'

function build-parser grammar
  grammarSource = load-grammar grammar
  PEG.buildParser grammarSource, plugins: [pegjs-livescript-plugin], cache: true
