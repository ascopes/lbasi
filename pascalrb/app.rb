# frozen_string_literal: true

require_relative('interpreter')
require_relative('lexer')
require_relative('parser')
require_relative('semantic')
require_relative('symbol')

def run_program(source_reader, debug)
  # Build the abstract syntax tree for the file.
  lexer = Lexer.new(source_reader, debug)
  parser = Parser.new(lexer)
  ast = parser.parse

  symbol_table = SymbolTable.new(debug)

  # Perform static semantic analysis next.
  # This ensures variables that are referred to are already defined, amongst other things.
  # This will also fill the symbol table for us.
  StaticSemanticAnalyser.new(symbol_table).visit(ast)

  # Finally, run the program.
  Interpreter.new(ast, symbol_table).interpret
end
