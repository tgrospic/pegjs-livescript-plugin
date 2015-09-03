/**
 * PEG.js LiveScript plugin
 */
require! livescript

export use: (config, options) -> config.passes.transform.unshift peg-pass-ls!

function peg-pass-ls
  compile = (code) ->
    options = bare: true, header: false
    try
      livescript.compile code, options
    catch {message}
      throw new SyntaxError "#message\n#code"

  wrapCode = (expr) ->
    if expr.type == 'initializer'
      then "(\n#{expr.code}\n)"
      else "return(\n#{expr.code}\n)"

  compileExpression = (expr) ->
    # initializer, action, semantic_and, semantic_not
    expr
      ..code = compile wrapCode expr if expr and expr.code and /\S/.test expr.code

  # Subexpressions by expression type (and also by various field names)
  # - PEG.js version: v0.9.0 (v0.8.0)
  subExpressions = (expr) ->
    switch expr.type
    | 'grammar'  => [expr.initializer] ++ expr.rules
    | 'choice'   => expr.alternatives
    | 'sequence' => expr.elements
    | 'rule'     , 'named'
    , 'action'   , 'labeled'
    , 'text'     , 'simple_and'  , 'simple_not'
    , 'optional' , 'zero_or_more', 'one_or_more'
                 => [expr.expression]

  # Traverse PEG.js AST and compile expression code
  traverse = (expr) !->
    [traverse .. for subexps] if expr and subexps = subExpressions . compileExpression <| expr
