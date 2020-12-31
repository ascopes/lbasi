#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'pascalrb/interpreter'
require_relative 'pascalrb/lexer'
require_relative 'pascalrb/parser'
require_relative 'pascalrb/symbol'

lexer = Lexer.new(ARGF, debug: true)
parser = Parser.new lexer
tree = parser.parse
symbol_table = SymbolTableBuilder.new.build tree
interpreter = Interpreter.new tree
interpreter.interpret
