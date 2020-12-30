# frozen_string_literal: true

require 'stringio'
require_relative 'token'

# Incremental tokenizer. This consumes an IO object.
class Lexer
  def initialize(reader, **kwargs)
    reader = ARGF.file if reader == ARGF

    @debug = kwargs['debug'] || false

    if reader == $stdin
      puts 'WARNING: reading from stdin, incremental reading will be disabled'
      # We cannot use OS level buffering on STDIN properly,
      # once we hit the end of the file, STDIN closes abruptly
      # causing reverse seeking during peeking to fail.
      reader = StringIO.new(reader.read)
    end

    @line = 1
    @col = 1
    @reader = reader
  end

  def position
    @reader.tell
  end

  def next_token
    token = read_next_token
    p token if @debug
    token
  end

  private def read_next_token
    # Always allow whitespace between individual tokens.
    skip_comment_or_ws

    position = Position.new(@reader.tell, @line, @col)
    next_chunk = get_raw MAX_OPERATOR_LENGTH

    case next_chunk
    when nil then return Token.new(:EOF, nil, position)
    when /^[a-z_]/i then return identifier_token(position)
    when /^\d/ then return decimal_token(position)
    when /^\$\d/ then return hex_token(position)
    when /^&\d/ then return oct_token(position)
    when /^%\d/ then return bin_token(position)
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

        token = Token.new(operator, substr, position)
        step substr.length
        return token
      end
    end

    raise "Unexpected character #{next_chunk[0]} in input at #{@reader.tell} (#{@line}:#{@col})"
  end

  private def step(steps = 1)
    (1..steps).each do
      char = @reader.read 1
      if char == "\n"
        @col = 1
        @line += 1
      else
        @col += 1
      end
    end
  end

  private def get_raw(chars = 1)
    result = @reader.read chars
    return nil if result.nil?

    @reader.seek(-result.length, IO::SEEK_CUR)
    result
  end

  private def skip_comment_or_ws
    skip_ws

    raw = get_raw(2)

    case raw
    when /^\{/
      step
      step while get_raw != '}'
      step
    when /^\(\*/
      step 2
      step while get_raw(2) != '*)'
      step 2
    end

    skip_ws
  end

  private def skip_ws
    step while get_raw =~ /\s/
  end

  private def buffer_raw_while(pattern)
    buff = []

    while (char = get_raw) =~ pattern
      buff.append char
      step
    end

    buff.join
  end

  private def bin_token(position)
    step
    number = buffer_raw_while(/[01]/).to_i(2)
    Token.new(:INTEGER_CONST, number, position)
  end

  private def oct_token(position)
    step
    number = buffer_raw_while(/[0-7]/).to_i(8)
    Token.new(:INTEGER_CONST, number, position)
  end

  private def hex_token(position)
    step
    number = buffer_raw_while(/[0-9a-f]/i).to_i(16)
    Token.new(:INTEGER_CONST, number, position)
  end

  private def decimal_token(position)
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
        raise "Unexpected literal '#{number}' in input at #{position.offset} (#{position.line}:#{position.column})"
      end

      number += buffer_raw_while(/\d/)
    end

    if is_real
      Token.new(:REAL_CONST, number.to_f, position)
    else
      Token.new(:INTEGER_CONST, number.to_i, position)
    end
  end

  private def identifier_token(position)
    # Technically the first character cannot be a number. Our
    # design avoids allowing this anyway though, so it isn't really
    # that important to put an edge case in for that here.
    identifier = buffer_raw_while(/[A-Z_0-9]/i).upcase

    if KEYWORDS.keys.include? identifier
      Token.new(KEYWORDS[identifier], identifier, position)
    else
      Token.new(:IDENTIFIER, identifier, position)
    end
  end
end
