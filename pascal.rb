#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'pascalrb/interpreter'
require_relative 'pascalrb/lexer'
require_relative 'pascalrb/parser'

lexer = Lexer.new(ARGF, debug: true)
parser = Parser.new lexer
interpreter = Interpreter.new parser
interpreter.interpret
