# frozen_string_literal: true

# Symbol type.
Symbol = Struct.new(:name, :type)

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
    @program_name = nil
    @global_scope = {}
  end

  def interpret
    visit @parser.parse
    puts "Resultant variables for program #{@program_name}"
    puts @global_scope
  end

  def visit_program_node(node)
    @program_name = node.name
    visit node.block
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
      raise "Expected integer oprands for DIV on #{node}" unless left.is_a?(Integer) && right.is_a?(Integer)

      left / right
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

  def visit_block_node(node)
    node.declarations.each do |declaration|
      visit(declaration)
    end

    visit(node.compound_statement)
  end

  def visit_variable_declaration_node(node)
    # For now, we don't implement anything useful here.
    # However, for the sake of context, lets put a dummy value in those variables.
    # We will have to do some typechecking magic here later probably.
    @global_scope[node.identifier.value] = :UNSET
  end

  def visit_type(node)
    node.name
  end

  def visit_compound_node(node)
    node.children.each do |child|
      visit child
    end
  end

  def visit_assignment_node(node)
    @global_scope[node.left.name] = visit node.right
  end

  def visit_variable_node(node)
    @global_scope.fetch node.name
  end

  def visit_no_op_node(node); end

  private def panic_about_operator(operator)
    raise "I don't know how to process operator #{operator}"
  end
end
