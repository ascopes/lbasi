# frozen_string_literal: true

require 'set'

# Operators. These are non-alphanumeric tokens.
OPERATORS = {
  ':=' => :ASSIGN,
  ':' => :COLON,
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
  'INTEGER' => :INTEGER,
  'MOD' => :MOD,
  'PROGRAM' => :PROGRAM,
  'REAL' => :REAL,
  'VAR' => :VAR
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
