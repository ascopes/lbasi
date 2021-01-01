# frozen_string_literal: true

require_relative('visitor')

# Helper that performs static semantic analysis and populates a symbol table.
class StaticSemanticAnalyser < Visitor
  def initialize(symbol_table)
    super()
    @symbol_table = symbol_table
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
    @symbol_table.lookup(node.left.name, node.left.position)
  end

  def visit_variable_declaration_node(node)
    # Special stuff happens here.
    position = node.identifier.position
    type_symbol = @symbol_table.lookup(node.type.name, position)
    var_symbol = VariableSymbol.new(node.identifier.value, type_symbol, position)
    @symbol_table.define(var_symbol)
  end

  def visit_procedure_declaration_node(node)
    # We will handle nested procedures at a later time, for now this
    # does not do anything.
  end
end
