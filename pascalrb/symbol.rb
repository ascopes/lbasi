# frozen_string_literal: true

require_relative 'dataclass'
require_relative 'visitor'

# Builtin-type.
BuiltinTypeSymbol = Dataclass.new(:name)

# Symbol for a variable.
VariableSymbol = Dataclass.new(:name, :type)

# Integer type.
IntegerType = BuiltinTypeSymbol.new('INTEGER').freeze

# Real type.
RealType = BuiltinTypeSymbol.new('REAL').freeze

# Symbol table representation, preloaded with builtins.
class SymbolTable
  def initialize
    @symbols = {
      IntegerType.name => IntegerType,
      RealType.name => RealType
    }
  end

  def define(symbol)
    p "Define #{symbol.name} as type #{symbol.type}"
    @symbols[symbol.name] = symbol
  end

  def lookup(name)
    p "Look up #{name}"
    symbol = @symbols[name]
    raise "NameError: no symbol called #{name} is defined" if symbol.nil?

    symbol
  end
end

# Visits an AST to generate a symbol table.
class SymbolTableBuilder < Visitor
  def initialize
    super()
    @symbol_table = SymbolTable.new
  end

  def visit_program_node(node)
    visit(node.block)
  end

  def visit_bin_op_node(node)
    visit(node.left)
    visit(node.right)
  end

  def visit_unary_op_node(node)
    visit(node.expr)
  end

  # Do nothing.
  def visit_number_node(_node); end

  # Do nothing.
  def visit_no_op_node(_node); end

  def visit_block_node(node)
    node.declarations.each do |declaration|
      visit(declaration)
    end

    visit(node.compound_statement)
  end

  def visit_compound_node(node)
    node.children.each do |child|
      visit(child)
    end
  end

  def visit_assignment_node(node)
    @symbol_table.lookup(node.left.name)
  end

  def visit_variable_declaration_node(node)
    # Special stuff happens here.
    type_symbol = @symbol_table.lookup(node.type.name)
    var_symbol = VariableSymbol.new(node.identifier.value, type_symbol)
    @symbol_table.define(var_symbol)
  end

  def build(ast)
    visit ast
    @symbol_table
  end
end
