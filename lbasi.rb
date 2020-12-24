# frozen_string_literal: true

Token = Struct.new(:type, :value, :position)

# Interpreter implementation.
class Interpreter
  def initialize(text)
    @text = text
    @pos = 0
    @current_token = nil
  end

  def skip_ws
    @pos += 1 while @text[@pos] =~ /\s/
    nil
  end

  def consume_int
    buff = []
    while @text[@pos] =~ /\d/
      buff.append(@text[@pos])
      @pos += 1
    end
    buff.join.to_i
  end

  def read_token
    skip_ws
    value = @text[@pos]
    start_pos = @pos

    case value
    when nil
      type = :EOF
    when '+'
      type = :PLUS
      @pos += 1
    when '-'
      type = :MINUS
      @pos += 1
    when '*'
      type = :MULTIPLY
      @pos += 1
    when '/'
      type = :DIVIDE
      @pos += 1
    when /\d/
      type = :INT
      value = consume_int
    else raise "Unknown token '#{value} in input at position #{start_pos}"
    end

    Token.new(type, value, start_pos)
  end

  def eat(type)
    original_token = @current_token

    raise "Unexpected token #{original_token} in input - expected type :#{type}" if original_token.type != type

    @current_token = read_token
    original_token
  end

  def expr
    # expr  ::=   int  PLUS  int
    #         |   int  MINUS  int
    @current_token = read_token

    result = eat(:INT).value

    until @current_token.type == :EOF
      case @current_token.type
      when :PLUS
        eat(:PLUS)
        op = ->(l, r) { l + r }
      when :MINUS
        eat(:MINUS)
        op = ->(l, r) { l - r }
      when :MULTIPLY
        eat(:MULTIPLY)
        op = ->(l, r) { l * r }
      else
        eat(:DIVIDE)
        op = ->(l, r) { l / r }
      end

      right = eat(:INT)
      result = op.call(result, right.value)
    end

    result
  end
end

puts Interpreter.new(ARGF.readline.chop).expr until ARGF.eof?
