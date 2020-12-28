# frozen_string_literal: true

# Pascal interpreter definitions.
class NodeVisitor
  def visit(node)
    name = visitor_method_name(node)
    begin
      method(name).call(node)
    rescue NameError
      visit_unknown(node, name)
    end
  end

  protected def visit_unknown(_node, name)
    raise "No #{name} method for node"
  end

  private def visitor_method_name(node)
    # XXX: optimise this eventually somehow.
    "visit_#{node.class.name.gsub(/(?<=[^A-Z])(?=[A-Z])/, '_').downcase}"
  end
end

# Application interpreter type.
class Interpreter < NodeVisitor
  def initialize(parser)
    super()
    @parser = parser
  end

  def visit_number_node(node)
    node.value
  end

  def visit_unary_op_node(node)
    case node.operator.type
    when :PLUS then visit(node.value)
    when :MINUS then -visit(node.value)
    when :INVERT then ~visit(node.value)
    else raise "Unknown unary operator #{node.operator}"
    end
  end

  def visit_binary_op_node(node)
    case node.operator.type
    when :PLUS then visit(node.left) + visit(node.right)
    when :MINUS then visit(node.left) - visit(node.right)
    when :MUL then visit(node.left) * visit(node.right)
    when :DIV then visit(node.left) / visit(node.right)
    when :MOD then visit(node.left) % visit(node.right)
    when :BAND then visit(node.left) & visit(node.right)
    when :BOR then visit(node.left) | visit(node.right)
    when :BXOR then visit(node.left) ^ visit(node.right)
    else raise "Unknown binary operator #{node.operator}"
    end
  end

  def interpret
    tree = @parser.parse
    visit(tree)
  end
end
