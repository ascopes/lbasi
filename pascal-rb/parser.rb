# frozen_string_literal: true

# Node containing a number.
NumberNode = Struct.new(:token, :value)

# Node containing a unary operation.
UnaryOpNode = Struct.new(:operator, :value)

# Node containing a binary operation.
BinaryOpNode = Struct.new(:left, :operator, :right)

# Pascal parser.
class Parser
  def initialize(lexer)
    @current_token = lexer.next_token
    @lexer = lexer
  end

  def parse
    expr
  end

  private def eat(type)
    raise "Unexpected token #{@current_token}, expected type to be #{type}" unless @current_token.type == type

    @current_token = @lexer.next_token
  end

  private def factor
    token = @current_token

    case token.type
    when :INT
      eat(:INT)
      NumberNode.new(token, token.value.to_i)
    when :LPAREN
      eat(:LPAREN)
      node = expr
      eat(:RPAREN)
      node
    end
  end

  private def term
    node = factor

    while %i[MUL DIV].include?(@current_token.type)
      op_token = @current_token
      eat(op_token.type)
      node = BinaryOpNode.new(node, op_token, factor)
    end

    node
  end

  private def expr
    node = term

    while %i[PLUS MINUS].include?(@current_token.type)
      op_token = @current_token
      eat(op_token.type)
      node = BinaryOpNode.new(node, op_token, term)
    end

    node
  end
end
