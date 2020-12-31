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
