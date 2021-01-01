# frozen_string_literal: true

# Base error type for application exceptions.
class PascalError < RuntimeError; end

# Error raised if a syntax error occurs.
class PascalSyntaxError < PascalError; end

# Syntax error discovered in the lexer.
class PascalLexerSyntaxError < PascalSyntaxError
  def initialize(string, where, reason = 'Unexpected string')
    @reason = reason
    @string = string
    @where = where
    super("Syntax Error!\n    #{reason} #{string.inspect} at #{where}")
  end

  attr_reader :reason, :string, :where
end

# Error raised if we encounter an unexpected token. This can then advise the correct
# token types to allow. This may be one type or an array of types.
class PascalParserSyntaxError < PascalSyntaxError
  def initialize(actual_token, *expected_types)
    @expected_types = expected_types
    @actual_token = actual_token

    expected_types = expected_types.join(' or ')
    message = "Expected token of type #{expected_types} but got #{actual_token.human_readable_str}"

    is_missing_semi = @expected_types.include?(:SEMICOLON) && actual_token.type == :END \
                      || @expected_types.include?(:END) && %i[BEGIN IDENTIFIER PROCEDURE].include?(actual_token.type)

    if is_missing_semi
      message += "\n    ... perhaps you forgot a SEMICOLON on a previous line?"
    elsif @expected_types.include?(:DOT) && actual_token.type == :EOF
      message += "\n    ... you probably forgot to put a DOT at the end of your file!"
    end

    super("Syntax Error!\n    #{message}")
  end

  attr_reader :expected_types, :actual_token
end

# Error raised if a symbol name is accessed before being defined.
class PascalMissingNameError < PascalError
  def initialize(name, where)
    @name = name
    @where = where
    super("Name Error!\n    No symbol named #{name.inspect} is defined at #{where}")
  end

  attr_reader :name, :where
end

# Raised if a variable is declared more than once.
class PascalDuplicateNameError < PascalError
  def initialize(name, previous_definition_position, current_definition_position)
    @name = name
    @previous_definition_position = previous_definition_position
    @current_definition_position = current_definition_position
    super(
      "Name Error!\n    Symbol #{name.inspect} at " \
      "#{current_definition_position} has already been defined " \
      "at #{previous_definition_position}"
    )
  end

  attr_reader :name, :where
end

# A type-error raised by the interpreter.
class PascalTypeError < PascalError
  def initialize(message)
    super("Type Error!\n    #{message}")
  end
end
