# frozen_string_literal: true

Token = Struct.new(:type, :value, :position)

# Interpreter implementation.
class Interpreter
  def initialize(text)
    @pos = 0
    @text = text
    @current_token = next_token
  end

  def next_token
    return Token.new :EOF, nil, @pos unless @pos < @text.length

    skip_ws

    case char = @text[@pos]
    when '-'
      token = Token.new :MINUS, char, @pos
      @pos += 1
      token
    when /\d/
      parse_int
    else
      raise "unexpected character #{char} in stdin:#{@pos}"
    end
  end

  def parse_int
    start = @pos
    char = @text[@pos]
    buff = ''

    while char =~ /\d/
      buff += char
      @pos += 1
      char = @text[@pos]
    end

    Token.new(:INT, buff.to_i, start)
  end

  def skip_ws
    @pos += 1 while @text[@pos] =~ /\s/
  end

  def eat(type)
    raise "unexpected token #{@current_token}, expected #{type}" unless @current_token.type == type

    @current_token = next_token
  end

  def expr
    left = @current_token
    eat :INT

    eat :MINUS

    right = @current_token
    eat :INT

    left.value - right.value
  end
end

puts Interpreter.new(ARGF.readline.chop).expr until ARGF.eof?
