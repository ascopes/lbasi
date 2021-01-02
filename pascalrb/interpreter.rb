# frozen_string_literal: true

require_relative('ex')
require_relative('visitor')

# Interpreter implementation.
class Interpreter < Visitor
  def initialize(tree)
    super()
    @tree = tree
    @program_name = nil
    @global_scope = {}
  end

  def interpret
    visit(@tree)
    puts("Resultant variables for program #{@program_name}")
    puts(@global_scope)
  end

  def visit_program_node(node)
    @program_name = node.name
    visit(node.block)
  end

  def visit_bin_op_node(node)
    case node.op.type
    when :PLUS then visit(node.left) + visit(node.right)
    when :MINUS then visit(node.left) - visit(node.right)
    when :MUL then visit(node.left) * visit(node.right)
    when :DIV then visit(node.left).to_f / visit(node.right)
    when :INT_DIV
      left = visit(node.left)
      right = visit(node.right)

      unless left.is_a?(Integer) && right.is_a?(Integer)
        raise(PascalTypeError,
              "Expected integer oprands when performing DIV operation at #{node.op.human_readable_str}",)
      end

      left / right
    else panic_about_operator(node.op)
    end
  end

  def visit_unary_op_node(node)
    case node.op.type
    when :PLUS then +node.expr
    when :MINUS then -node.expr
    else panic_about_operator(node.op)
    end
  end

  def visit_number_node(node)
    node.value
  end

  def visit_block_node(node)
    node.declarations.each do |declaration|
      visit(declaration)
    end

    visit(node.compound_statement)
  end

  def visit_variable_declaration_node(node)
    # For now, we don't implement anything useful here.
  end

  def visit_procedure_declaration_node(node)
    # We will handle nested procedures at a later time, for now this
    # does not do anything.
  end

  def visit_type(node)
    node.name
  end

  def visit_compound_node(node)
    node.children.each do |child|
      visit(child)
    end
  end

  def visit_assignment_node(node)
    @global_scope[node.left.name] = visit(node.right)
  end

  def visit_variable_node(node)
    @global_scope.fetch(node.name)
  end

  def visit_no_op_node(node); end

  def panic_about_operator(operator)
    raise(PascalTypeError, "I don't know how to process operator #{operator}")
  end
end
