# frozen_string_literal: true

# Pascal interpreter definitions.
class NodeVisitor
  def visit(node)
    method("visit_#{node.class.name}").call(node)
  rescue NameError
    visit_unknown(node)
  end

  protected def visit_unknown(node)
    raise "No visit_#{node.class.name} method for node"
  end
end

# Application interpreter type.
class Interpreter < NodeVisitor
  def initialize(parser)
    super()
    @parser = parser
  end

  def visit_NumberNode(node)
    node.value
  end

  def visit_BinaryOpNode(node)
    case node.operator.type
    when :PLUS then visit(node.left) + visit(node.right)
    when :MINUS then visit(node.left) - visit(node.right)
    when :MUL then visit(node.left) * visit(node.right)
    when :DIV then visit(node.left) / visit(node.right)
    else raise "Unknown operator #{node.operator}"
    end
  end

  def interpret
    tree = @parser.parse
    visit(tree)
  end
end
