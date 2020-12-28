# frozen_string_literal: true

# Binary operation.
BinOpNode = Struct.new(:left, :op, :right)

# Unary operation.
UnaryOpNode = Struct.new(:op, :expr)

# A number node.
NumberNode = Struct.new(:token) do
  def value
    token.value.to_i
  end
end

# Compound statement (BEGIN ... END block).
CompoundNode = Struct.new(:children)

# An assignment expression.
AssignmentNode = Struct.new(:left, :op, :right)

# A variable node.
VariableNode = Struct.new(:token) do
  def name
    token.value.upcase
  end
end

# A null operation. This does nothing useful. It is used
# in places where a statement has no content.
NoOpNode = Struct.new(:position)

# Parser. Consumes an incremental lexer instance.
class Parser
  def initialize(lexer)
    @lexer = lexer
    @current_token = @lexer.next_token
  end

  def parse
    result = program
    eat :EOF
    result
  end

  private def program
    # program = compound_statement , DOT ;
    compound = compound_statement
    eat :DOT
    compound
  end

  private def compound_statement
    # compound_statement = BEGIN , statement_list , END ;
    eat :BEGIN
    compound = CompoundNode.new(statement_list)
    eat :END
    compound
  end

  private def statement_list
    # statement_list = statement , [ { SEMICOLON , statement } ] ;
    statements = [statement]

    while @current_token.type == :SEMICOLON
      eat :SEMICOLON
      statements.append statement
    end

    statements
  end

  private def statement
    # statement = compound_statement
    #           | assignment_statement
    #           | empty_statement
    #           ;
    case @current_token.type
    when :BEGIN then compound_statement
    when :IDENTIFIER then assignment_statement
    else empty_statement
    end
  end

  private def assignment_statement
    # assignment_statement = variable , ASSIGN , expr ;
    left = variable

    op = eat :ASSIGN

    right = expr

    AssignmentNode.new(left, op, right)
  end

  private def variable
    # variable = IDENTIFIER ;
    id = eat :IDENTIFIER
    VariableNode.new id
  end

  private def empty_statement
    # empty statement = ;
    NoOpNode.new(@lexer.position)
  end

  private def expr
    # expr = term , [ { ( PLUS | MINUS ) , term } ] ;
    node = term

    while %i[PLUS MINUS].include? @current_token.type
      op = eat @current_token.type
      node = BinOpNode.new(node, op, term)
    end

    node
  end

  private def term
    # term = factor , [ { ( DIV | INT_DIV | MOD | MUL ) , factor } ] ;
    node = factor

    while %i[DIV INT_DIV MOD MUL].include? @current_token.type
      op = eat @current_token.type
      node = BinOpNode.new(node, op, factor)
    end

    node
  end

  private def factor
    # factor = PLUS , factor
    #        | MINUS , factor
    #        | NOT , factor
    #        | INTEGER
    #        | LPAREN , expr , RPAREN
    #        | variable
    #        ;
    if %i[PLUS MINUS NOT].include?(@current_token.type)
      token = eat @current_token.type
      UnaryOpNode.new(token, factor)
    elsif @current_token.type == :INTEGER
      token = eat :INTEGER
      NumberNode.new token
    elsif @current_token.type == :LPAREN
      eat :LPAREN
      result = expr
      eat :RPAREN
      result
    else
      variable
    end
  end

  private def eat(type)
    unexpected_token type if type != @current_token.type

    old_token = @current_token
    @current_token = @lexer.next_token
    old_token
  end

  private def unexpected_token(type)
    raise "Expected token of type #{type} but received #{@current_token.type}\n" \
          "Position: #{@current_token.position}\n" \
          "Token: #{@current_token}"
  end
end
