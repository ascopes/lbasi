# frozen_string_literal: true

# A token representation.
Token = Struct.new(:type, :value, :position)

# Pascal tokenizer.
class Lexer
  def initialize(text)
    @text = text
    @position = 0
    @current_char = @text[0]
  end

  attr_reader :position

  def next_token
    skip_ws

    case @current_char
    when /\d/ then int_token
    when nil then Token.new(:EOF, nil, @position)
    when '+' then operator_token('+', :PLUS)
    when '-' then operator_token('-', :MINUS)
    when '*' then operator_token('*', :MUL)
    when '/' then operator_token('/', :DIV)
    when '%' then operator_token('%', :MOD)
    when '&' then operator_token('&', :BAND)
    when '|' then operator_token('|', :BOR)
    when '^' then operator_token('^', :BXOR)
    when '~' then operator_token('~', :INVERT)
    when '(' then operator_token('(', :LPAREN)
    when ')' then operator_token(')', :RPAREN)
    else raise "Unexpected symbol '#{@current_char}' in input at #{@position}"
    end
  end

  private def advance(steps = 1)
    @position += steps
    @current_char = @text[@position]
  end

  private def skip_ws
    advance while @current_char =~ /\s/
  end

  private def int_token
    buff = []

    start_position = @position

    while @current_char =~ /\d/
      buff.append(@current_char)
      advance
    end

    Token.new(:INT, buff.join, start_position)
  end

  private def operator_token(string, type)
    start_position = @position
    advance(string.length)
    Token.new(type, string, start_position)
  end
end
