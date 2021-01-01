#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'pascalrb/interpreter'
require_relative 'pascalrb/lexer'
require_relative 'pascalrb/parser'
require_relative 'pascalrb/symbol'

DEBUG_MODE = ARGF.argv.delete('--debug') || false

lexer = Lexer.new(ARGF, DEBUG_MODE)
parser = Parser.new lexer
tree = parser.parse
symbol_table_builder = SymbolTableBuilder.new DEBUG_MODE
symbol_table = symbol_table_builder.build tree
interpreter = Interpreter.new tree
interpreter.interpret
