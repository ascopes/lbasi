# frozen_string_literal: true

require('stringio')
require_relative('ex')
require_relative('position')
require_relative('token')

# Incremental tokenizer. This consumes an IO object.
class Lexer
  def initialize(reader, debug)
    reader = ARGF.file if reader == ARGF

    @debug = debug

    if reader == $stdin
      # We cannot use OS level buffering on STDIN properly,
      # once we hit the end of the file, STDIN closes abruptly
      # causing reverse seeking during peeking to fail.
      @reader = StringIO.new(reader.read)
      @filename = '<<stdin>>'
    else
      @reader = reader
      @filename = reader.path
    end

    @line = 1
    @col = 1
  end

  def position
    Position.new(@filename, @line, @col)
  end

  def next_token
    token = read_next_token
    p(token) if @debug
    token
  end

  def read_next_token
    # Always allow whitespace between individual tokens.
    skip_comment_or_ws

    curr_position = position
    next_chunk = get_raw(MAX_OPERATOR_LENGTH)

    case next_chunk
    when nil then return Token.new(nil, :EOF, nil, curr_position)
    when /^[a-z_]/i then return identifier_token(curr_position)
    when /^\d/ then return decimal_token(curr_position)
    when /^\$\d/ then return hex_token(curr_position)
    when /^&\d/ then return oct_token(curr_position)
    when /^%\d/ then return bin_token(curr_position)
    else
      # Look up the operator in the table. We start with the longest
      # possible operator and keep chopping down until we run out of
      # text or we find a match. This prevents "+=" being read as
      # "+" by accident if "+=" is also a valid operator.
      (next_chunk.length - 1).downto(0).each do |i|
        # x..y is a range of [x, y] inclusive.
        substr = next_chunk[0..i]
        operator = OPERATORS[substr]
        next if operator.nil?

        token = Token.new(:OPERATOR, operator, substr, curr_position)
        step(substr.length)
        return token
      end
    end

    raise(PascalSyntaxError.new(next_chunk[0], curr_position))
  end

  def step(steps = 1)
    (1..steps).each do
      char = @reader.read(1)
      if char == "\n"
        @col = 1
        @line += 1
      else
        @col += 1
      end
    end
  end

  def get_raw(chars = 1)
    result = @reader.read(chars)
    return nil if result.nil?

    @reader.seek(-result.length, IO::SEEK_CUR)
    result
  end

  def skip_comment_or_ws
    skip_ws

    raw = get_raw(2)

    case raw
    when /^\{/
      step
      step while get_raw != '}'
      step
    when /^\(\*/
      step(2)
      step while get_raw(2) != '*)'
      step(2)
    end

    skip_ws
  end

  def skip_ws
    step while get_raw =~ /\s/
  end

  def buffer_raw_while(pattern)
    buff = []

    while (char = get_raw) =~ pattern
      buff.append(char)
      step
    end

    buff.join
  end

  def bin_token(curr_position)
    step
    number = buffer_raw_while(/[01]/).to_i(2)
    Token.new(:BINARY_LITERAL, :INTEGER_CONST, number, curr_position)
  end

  def oct_token(curr_position)
    step
    number = buffer_raw_while(/[0-7]/).to_i(8)
    Token.new(:OCTAL_LITERAL, :INTEGER_CONST, number, curr_position)
  end

  def hex_token(curr_position)
    step
    number = buffer_raw_while(/[0-9a-f]/i).to_i(16)
    Token.new(:HEXADECIMAL_LITERAL, :INTEGER_CONST, number, curr_position)
  end

  def decimal_token(curr_position)
    # Reference: https://www.freepascal.org/docs-html/ref/refse6.html
    number = buffer_raw_while(/\d/)
    is_real = false

    if get_raw(2) =~ /^\.\d/
      is_real = true
      step
      number += '.'
      number += buffer_raw_while(/\d/)
    end

    if (symbol = get_raw).downcase == 'e'
      is_real = true
      step
      number += 'E'

      if (symbol = get_raw) =~ /[+-]/
        step
        number += symbol
      end

      unless get_raw =~ /\d/
        raise(PascalSyntaxError.new(number, curr_position, 'Unexpected character found while parsing number'))
      end

      number += buffer_raw_while(/\d/)
    end

    if is_real
      Token.new(:REAL_LITERAL, :REAL_CONST, number.to_f, curr_position)
    else
      Token.new(:INTEGER_LITERAL, :INTEGER_CONST, number.to_i, curr_position)
    end
  end

  def identifier_token(curr_position)
    # Technically the first character cannot be a number. Our
    # design avoids allowing this anyway though, so it isn't really
    # that important to put an edge case in for that here.
    identifier = buffer_raw_while(/[A-Z_0-9]/i)

    if KEYWORDS.keys.include?(identifier.upcase)
      Token.new(:KEYWORD, KEYWORDS[identifier], identifier, curr_position)
    else
      Token.new(:SYMBOL, :IDENTIFIER, identifier, curr_position)
    end
  end
end
