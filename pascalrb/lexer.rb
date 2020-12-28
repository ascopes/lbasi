# frozen_string_literal: true

require 'set'
require 'stringio'

# Operators. These are non-alphanumeric tokens.
OPERATORS = {
  ':=' => :ASSIGN,
  ',' => :COMMA,
  '/' => :DIV,
  '.' => :DOT,
  '=' => :EQUAL,
  '(' => :LPAREN,
  '-' => :MINUS,
  '*' => :MUL,
  '+' => :PLUS,
  ')' => :RPAREN,
  ';' => :SEMICOLON
}.freeze

# Max operator size. This describes the max number of characters
# we need to incrementally look ahead by.
MAX_OPERATOR_LENGTH = OPERATORS.keys.map(&:length).max

# Keywords. These are word-like tokens that would otherwise be confused
# with generic identifiers.
KEYWORDS = {
  'BEGIN' => :BEGIN,
  'DIV' => :INT_DIV,
  'END' => :END,
  'MOD' => :MOD
}.freeze

# Literal value types and identifiers.
LITERAL_TYPES = Set[
  :INTEGER,
  :IDENTIFIER,
].freeze

# Token type.
Token = Struct.new(:type, :value, :position)

# File position type.
Position = Struct.new(:offset, :line, :column)

# Incremental tokenizer. This consumes an IO object.
class Lexer
  def initialize(reader)
    if [ARGF, $stdin].include?(reader)
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
    # Always allow whitespace between individual tokens.
    skip_ws

    position = Position.new(@reader.tell, @line, @col)
    next_chunk = get_raw MAX_OPERATOR_LENGTH

    case next_chunk
    when nil then return Token.new(:EOF, nil, position)
    when /^[A-Za-z_]/ then return identifier_token(position)
    when /^\d/ then return integer_token(position)
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

  private def skip_ws
    step while get_raw =~ /\s/
  end

  private def integer_token(position)
    buff = []

    while (current_char = get_raw) =~ /\d/
      buff.append current_char
      step
    end

    Token.new(:INTEGER, buff.join, position)
  end

  private def identifier_token(position)
    buff = []

    # Technically the first character cannot be a number. Our
    # design avoids allowing this anyway though, so it isn't really
    # that important to put an edge case in for that here.
    while (current_char = get_raw) =~ /[A-Za-z_0-9]/
      buff.append current_char
      step
    end

    identifier = buff.join.upcase

    if KEYWORDS.keys.include? identifier
      Token.new(KEYWORDS[identifier], identifier, position)
    else
      Token.new(:IDENTIFIER, identifier, position)
    end
  end
end
