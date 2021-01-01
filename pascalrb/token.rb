# frozen_string_literal: true

require('set')
require_relative('dataclass')

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
  'NOT' => :NOT,
  'PROCEDURE' => :PROCEDURE,
  'PROGRAM' => :PROGRAM,
  'REAL' => :REAL,
  'VAR' => :VAR
}.freeze

# Token type.
Token = Dataclass.new(:category, :type, :value, :position) do
  def human_readable_str
    token_str = type.to_s
    token_str += " -> #{value.inspect}" unless value.nil?
    token_str += " at #{position}"
    "#{category.downcase} #{token_str}" unless category.nil?
  end
end
