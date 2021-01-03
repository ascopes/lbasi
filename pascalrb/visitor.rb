# frozen_string_literal: true

# Base logic for any visitor implementation. This handles dynamically
# dispatching the correct method for each type of AST node.
class Visitor
  def visit(node)
    # e.g. BinOpNode -> visit_bin_op_node
    name = "visit_#{node.class.name.gsub(/(?<=[^A-Z])(?=[A-Z])/, '_').downcase}"
    begin
      visitor_method = method(name)
    rescue NoMethodError
      raise NoMethodError.new("No method named #{name.inspect} found in #{self} while processing #{node}")
    end

    visitor_method.call(node)
  end
end
