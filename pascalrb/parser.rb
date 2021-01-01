# frozen_string_literal: true

require_relative 'ast'

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
    # program = PROGRAM , variable , SEMICOLON, block , DOT ;
    eat :PROGRAM
    program_name = variable.name
    eat :SEMICOLON
    code_block = block
    eat :DOT

    ProgramNode.new(program_name, code_block)
  end

  private def block
    # block = declarations , compound_statement ;
    BlockNode.new(declarations, compound_statement)
  end

  private def declarations
    # declarations = [ VAR , variable_declaration , SEMICOLON , [ { variable_declaration , SEMICOLON } ] ] ,
    #                [ { PROCEDURE , IDENTIFIER , SEMICOLON , block , SEMICOLON } ] ;

    declarations = []

    # We don't havee to define any variables, but if we do, we must have AT LEAST ONE identifier there.
    if @current_token.type == :VAR
      # parse one or more identifier declarations.
      eat :VAR

      if @current_token.type != :IDENTIFIER
        raise "Expected at least one identifier in VAR section at #{@current_token.position}"
      end

      while @current_token.type == :IDENTIFIER
        # Each variable declaration may define more than one identifier at once
        # so we want to add all of them by extending the array.
        declarations += variable_declaration
        eat :SEMICOLON
      end
    end

    # We can then have zero or more procedures.
    while @current_token.type == :PROCEDURE
      eat :PROCEDURE
      procedure_name = (eat :IDENTIFIER).value
      eat :SEMICOLON
      declarations.append(ProcedureDeclarationNode.new(procedure_name, block))
      eat :SEMICOLON
    end

    declarations
  end

  private def variable_declaration
    # variable_declaration = IDENTIFIER , [ { COMMA , IDENTIFIER } ] , COLON , type_spec ;
    identifiers = [eat(:IDENTIFIER)]

    while @current_token.type == :COMMA
      eat :COMMA
      identifiers.append eat(:IDENTIFIER)
    end

    eat :COLON

    type = type_spec

    identifiers.map do |identifier|
      VariableDeclarationNode.new(identifier, type)
    end
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

  private def type_spec
    # type_spec = INTEGER | REAL | IDENTIFIER
    TypeNode.new eat @current_token.type
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
    #        | INTEGER_CONST
    #        | REAL_CONST
    #        | LPAREN , expr , RPAREN
    #        | variable
    #        ;
    if %i[PLUS MINUS NOT].include?(@current_token.type)
      token = eat @current_token.type
      UnaryOpNode.new(token, factor)
    elsif %i[INTEGER_CONST REAL_CONST].include? @current_token.type
      token = eat @current_token.type
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
