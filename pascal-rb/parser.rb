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
    tree = expr
    eat(:EOF)
    tree
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

  private def prefix_unary
    if %i[PLUS MINUS INVERT].include?(@current_token.type)
      op_token = @current_token
      eat(op_token.type)
      UnaryOpNode.new(op_token, factor)
    else
      factor
    end
  end

  private def bitwise
    node = prefix_unary

    while %i[BAND BOR BXOR].include?(@current_token.type)
      op_token = @current_token
      eat(op_token.type)
      node = BinaryOpNode.new(node, op_token, prefix_unary)
    end

    node
  end

  private def term
    node = bitwise

    while %i[MUL DIV MOD].include?(@current_token.type)
      op_token = @current_token
      eat(op_token.type)
      node = BinaryOpNode.new(node, op_token, bitwise)
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
