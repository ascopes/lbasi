# frozen_string_literal: true

# Base logic for any visitor implementation. This handles dynamically
# dispatching the correct method for each type of AST node.
class Visitor
  def visit(node)
    # e.g. BinOpNode -> visit_bin_op_node
    name = "visit_#{node.class.name.gsub(/(?<=[^A-Z])(?=[A-Z])/, '_').downcase}"
    begin
      method(name).call(node)
    rescue NoMethodError
      raise NoMethodError, "No method while processing #{node}"
    end
  end
end

# Interpreter implementation.
class Interpreter < Visitor
  def initialize(parser)
    super()
    @parser = parser
    @global_scope = {}
  end

  def interpret
    visit @parser.parse
    puts(@global_scope)
  end

  def visit_bin_op_node(node)
    case node.op.type
    when :PLUS then visit(node.left) + visit(node.right)
    when :MINUS then visit(node.left) - visit(node.right)
    when :MUL then visit(node.left) * visit(node.right)
    # XXX: differentiate between division and integer division once we have REAL types.
    when :DIV, :INT_DIV then visit(node.left) / visit(node.right)
    else panic_about_operator node.op
    end
  end

  def visit_number_node(node)
    node.value
  end

  def visit_unary_op_node(node)
    case node.op.type
    when :PLUS then +node.expr
    when :MINUS then -node.expr
    else panic_about_operator node.op
    end
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

  private def panic_about_operator(operator)
    raise "I don't know how to process operator #{operator}"
  end
end
