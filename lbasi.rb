#!/usr/bin/env ruby
# frozen_string_literal: true

Token = Struct.new(:type, :position, :value)

# Tokenizer implementation.
class Lexer
  def initialize(text)
    @text = text
    @pos = 0
  end

  def read_token
    skip_ws

    char = @text[@pos]

    case char
    when nil then read_eof
    when /\d/ then read_number
    when '+' then read_char(char, :PLUS)
    when '-' then read_char(char, :MINUS)
    when '*' then read_char(char, :MUL)
    when '/' then read_char(char, :DIV)
    when '%' then read_char(char, :MOD)
    when '(' then read_char(char, :LPAREN)
    when ')' then read_char(char, :RPAREN)
    else raise "No suitable token matches character '#{char}' at index #{@pos}"
    end
  end

  def skip_ws
    @pos += 1 while @text[@pos] =~ /\s/
  end

  private :skip_ws

  def read_number
    buff = []
    index = @pos

    while @text[@pos] =~ /\d/
      buff.append(@text[@pos])
      @pos += 1
    end

    if @text[@pos] == '.'
      buff.append('.')
      @pos += 1
      while @text[@pos] =~ /\d/
        buff.append(@text[@pos])
        @pos += 1
      end
    end

    value = buff.join.to_f
    Token.new(:NUMBER, index, value)
  end

  private :read_number

  def read_char(characters, constant)
    token = Token.new(constant, @pos, characters)
    @pos += characters.length
    token
  end

  private :read_char

  def read_eof
    Token.new(:EOF, @pos, nil)
  end

  private :read_eof
end

# Interpreter for a token stream.
#
#   expr        = term (('+'|'-') term)*
#
#   term        = unary (('*'|'/'|'%') unary)*
#
#   unary       = '+' expr | '-' expr | factor
#
#   factor      = parenthesis | number
#
#   parenthesis = '(' expr ')'
#
#   number      = [0-9]+ ('.' [0-9]+)?
#
class Interpreter
  def initialize(lexer)
    @lexer = lexer
    @current_token = @lexer.read_token
  end

  def interpret
    result = expr
    eat(:EOF)
    result
  end

  def number
    token = @current_token
    eat(:NUMBER)
    token.value
  end

  private :number

  def parenthesis
    eat(:LPAREN)
    result = expr
    eat(:RPAREN)
    result
  end

  private :parenthesis

  def factor
    if @current_token.type == :LPAREN
      parenthesis
    else
      number
    end
  end

  private :factor

  def unary
    token = @current_token

    case token.type
    when :MINUS
      eat(:MINUS)
      -expr
    when :PLUS
      eat(:PLUS)
      expr
    else
      factor
    end
  end

  private :unary

  def term
    result = unary

    while %i[MUL DIV MOD].include?(@current_token.type)
      token = @current_token
      eat(token.type)

      case token.type
      when :MUL then result *= unary
      when :DIV then result /= unary
      when :MOD then result %= unary
      end
    end

    result
  end

  private :term

  def expr
    result = term

    while %i[PLUS MINUS].include?(@current_token.type)
      token = @current_token
      eat(token.type)

      case token.type
      when :PLUS then result += term
      when :MINUS then result -= term
      end
    end

    result
  end

  private :expr

  def eat(type)
    if @current_token.type == type
      @current_token = @lexer.read_token
    elsif @current_token.value.nil?
      raise <<-END_OF_MESSAGE
        unexpected token #{@current_token.type} at index #{@pos}:
        expected token of type #{type}
      END_OF_MESSAGE
    else
      raise <<-END_OF_MESSAGE
        unexpected token #{@current_token.type}
        (value = #{@current_token.value}) at index #{@pos}:
        expected token of type #{type}
      END_OF_MESSAGE
    end
  end

  private :eat
end

ARGF.each_line do |line|
  exit(true) if line.start_with?('/quit')

  lexer = Lexer.new(line)
  interpreter = Interpreter.new(lexer)
  puts interpreter.interpret
end
