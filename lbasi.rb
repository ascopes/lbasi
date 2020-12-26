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

    index = @pos
    char = @text[index]

    case char
    when nil
      Token.new(:EOF, index, nil)
    when /\d/
      Token.new(:NUMBER, index, read_number)
    when '+'
      @pos += 1
      Token.new(:PLUS, index, nil)
    when '-'
      @pos += 1
      Token.new(:MINUS, index, nil)
    else
      raise "No suitable token matches character '#{char}' at index #{index}"
    end
  end

  def skip_ws
    @pos += 1 while @text[@pos] =~ /\s/
  end

  private :skip_ws

  def read_number
    buff = []

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

    buff.join.to_f
  end

  private :read_number
end

# Interpreter for a token stream.
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

  def factor
    token = @current_token
    eat(:NUMBER)
    token.value
  end

  def expr
    result = factor

    while %i[PLUS MINUS].include?(@current_token.type)
      token = @current_token
      eat(token.type)

      case token.type
      when :PLUS then result += factor
      when :MINUS then result -= factor
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
