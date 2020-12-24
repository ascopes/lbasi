#!/usr/bin/env ruby
# frozen_string_literal: true

Token = Struct.new(:type, :position)
ValueToken = Struct.new(:type, :position, :value)

# Interpreter implementation.
class Interpreter
  def initialize(text)
    @text = text
    @pos = 0
    @current_token = nil
  end

  #################
  ### TOKENIZER ###
  #################

  def skip_ws
    @pos += 1 while @text[@pos] =~ /\s/
    nil
  end

  def number
    buff = []
    while @text[@pos] =~ /\d/
      buff.append @text[@pos]
      @pos += 1
    end
    buff.join.to_i
  end

  def make_token_advance(type, pos, offset = 1)
    @pos += offset
    Token.new type, pos
  end

  def next_token
    skip_ws

    start_pos = @pos
    char = @text[@pos]

    case char
    when nil then Token.new :EOF, start_pos
    when /\d/ then ValueToken.new :NUMBER, start_pos, number
    when '*' then make_token_advance :MUL, start_pos
    when '/' then make_token_advance :DIV, start_pos
    else raise "Unexpected character '#{char}' found during lexical analysis at ##{start_pos}"
    end
  end

  ##############
  ### PARSER ###
  ##############

  def eat(token_type)
    raise "Unexpected token #{@current_token}, expected :#{token_type}" if @current_token.type != token_type

    @current_token = next_token
  end

  ###################
  ### INTERPRETER ###
  ###################

  def term
    token = @current_token
    eat(:NUMBER)
    token.value
  end

  def expr
    @current_token = next_token

    result = term

    while %i[MUL DIV].include? @current_token.type
      case @current_token.type
      when :MUL
        eat(:MUL)
        result *= term
      when :DIV
        eat(:DIV)
        result /= term
      else
        raise "Unexpected token #{@current_token}, expected an operator"
      end
    end

    result
  end
end

puts Interpreter.new(ARGF.readline).expr until ARGF.eof?
