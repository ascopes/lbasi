#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'pascal-rb/interpreter'
require_relative 'pascal-rb/lexer'
require_relative 'pascal-rb/parser'

until ARGF.eof?
  line = ARGF.readline.chop

  exit(true) if line == '/quit'

  lexer = Lexer.new(line)
  parser = Parser.new(lexer)
  interpreter = Interpreter.new(parser)

  puts(interpreter.interpret)
end
