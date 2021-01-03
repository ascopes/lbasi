# frozen_string_literal: true

require_relative('dataclass')
require_relative('ex')
require_relative('visitor')

# Builtin-type.
BuiltinTypeSymbol = Dataclass.new(:name) do
  def defined_at
    Position.new(-1, -1, -1)
  end
end

# Symbol for a variable.
VariableSymbol = Dataclass.new(:name, :type)

# Symbols for a procedure.
ProcedureSymbol = Dataclass.new(:name, :params, :defined_at) do
  def type
    :PROCEDURE
  end
end

# Integer type.
IntegerType = BuiltinTypeSymbol.new('INTEGER').freeze

# Real type.
RealType = BuiltinTypeSymbol.new('REAL').freeze

# Symbol table representation, preloaded with builtins.
class ScopeSymbolTable
  def initialize(scope_name, scope_level, debug, enclosing_scope)
    @debug = debug
    @scope_level = scope_level
    @scope_name = scope_name
    @symbols = {
      IntegerType.name => IntegerType,
      RealType.name => RealType
    }
    @enclosing_scope = enclosing_scope
  end

  attr_reader :scope_level, :scope_name, :enclosing_scope

  def define(symbol)
    puts("+++ Define #{symbol.name} as type #{symbol.type} in scope #{self}") if @debug

    # Do not look in the enclosing scope; we allow shadowing of names.
    existing_symbol = @symbols[symbol.name]

    unless existing_symbol.nil?
      raise PascalDuplicateNameError.new(symbol.name, existing_symbol.defined_at, symbol.defined_at)
    end

    @symbols[symbol.name] = symbol
  end

  def lookup(name, position)
    puts("??? Look up #{name} in #{self}") if @debug
    symbol = @symbols[name]

    if symbol.nil?
      # No match in this scope.
      raise PascalMissingNameError.new(name, position) if @enclosing_scope.nil?

      # If we have an enclosing scope, try to look the symbol up in there.
      @enclosing_scope.lookup(name, position)
    else
      symbol
    end
  end

  def to_s
    "scope #{@scope_name.inspect} with level #{@scope_level}"
  end
end

# Helper that performs static semantic analysis and populates a symbol table.
class StaticSemanticAnalyser < Visitor
  def initialize(debug)
    super()
    @current_scope = nil
    @debug = debug
  end

  attr_reader :symbol_table

  def visit_program_node(node)
    # Parse the global scope.
    puts('>>> Entering global scope') if @debug
    # @current_scope will always be null at this point if semantic analysis has not already been run.
    @current_scope = ScopeSymbolTable.new('global', 0, @debug, @current_scope)

    visit(node.block)
    puts('<<< Exiting global scope') if @debug
  end

  def visit_bin_op_node(node)
    visit(node.left)
    visit(node.right)
  end

  def visit_unary_op_node(node)
    visit(node.expr)
  end

  # Do nothing.
  def visit_number_node(_node); end

  # Do nothing.
  def visit_no_op_node(_node); end

  def visit_block_node(node)
    node.declarations.each do |declaration|
      visit(declaration)
    end

    visit(node.compound_statement)
  end

  def visit_compound_node(node)
    node.children.each do |child|
      visit(child)
    end
  end

  def visit_assignment_node(node)
    @current_scope.lookup(node.left.name, node.left.position)
    visit(node.right)
  end

  def visit_variable_node(node)
    @current_scope.lookup(node.name, node.position)
  end

  def visit_variable_declaration_node(node)
    # Special stuff happens here.
    position = node.identifier.position
    type_symbol = @current_scope.lookup(node.type.name, position)
    var_symbol = VariableSymbol.new(node.name, type_symbol)
    @current_scope.define(var_symbol)
  end

  def visit_procedure_declaration_node(node)
    puts(">>> Entering procedure scope for #{node}") if @debug

    procedure_name = node.name

    enclosing_scope = @current_scope
    procedure_scope = ScopeSymbolTable.new(procedure_name, enclosing_scope.scope_level + 1, @debug, enclosing_scope)
    @current_scope = procedure_scope

    parameter_symbols = []

    node.params.each do |param|
      param_type = procedure_scope.lookup(param.type.name, param.type.position)
      variable_symbol = VariableSymbol.new(param.name, param_type)
      procedure_scope.define(variable_symbol)
      parameter_symbols.append(variable_symbol)
    end

    procedure_symbol = ProcedureSymbol.new(node.name, node.position, parameter_symbols)

    enclosing_scope.define(procedure_symbol)

    # XXX: if this fails the scope will be left in an inconsistent state. Do I really care though?
    # Probably not.
    visit(node.block)

    puts("<<< Exiting procedure scope for #{node}") if @debug

    @current_scope = enclosing_scope
  end
end
