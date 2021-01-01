# frozen_string_literal: true

require_relative('dataclass')
require_relative('ex')
require_relative('token')

# Builtin-type.
BuiltinTypeSymbol = Dataclass.new(:name) do
  def defined_at
    Position.new(-1, -1, -1)
  end
end

# Symbol for a variable.
VariableSymbol = Dataclass.new(:raw_name, :type, :defined_at) do
  def name
    raw_name.upcase
  end
end

# Integer type.
IntegerType = BuiltinTypeSymbol.new('INTEGER').freeze

# Real type.
RealType = BuiltinTypeSymbol.new('REAL').freeze

# Symbol table representation, preloaded with builtins.
class SymbolTable
  def initialize(debug)
    @debug = debug
    @symbols = {
      IntegerType.name => IntegerType,
      RealType.name => RealType
    }
  end

  def define(symbol)
    p("Define #{symbol.name} as type #{symbol.type}") if @debug

    existing_symbol = @symbols[symbol.name]

    unless existing_symbol.nil?
      raise(PascalDuplicateNameError.new(symbol.name, existing_symbol.defined_at, symbol.defined_at))
    end

    @symbols[symbol.name] = symbol
  end

  def lookup(name, position)
    p("Look up #{name}") if @debug
    symbol = @symbols[name]
    raise(PascalMissingNameError.new(name, position)) if symbol.nil?

    symbol
  end
end
