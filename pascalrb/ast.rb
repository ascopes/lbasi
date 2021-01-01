# frozen_string_literal: true

require_relative 'dataclass'

# Program.
ProgramNode = Dataclass.new(:name, :block)

# Binary operation.
BinOpNode = Dataclass.new(:left, :op, :right)

# Unary operation.
UnaryOpNode = Dataclass.new(:op, :expr)

# A number node.
NumberNode = Dataclass.new(:token) do
  def value
    token.value
  end

  def value_int
    token.value.to_i
  end

  def value_float
    token.value.to_f
  end
end

# Code block. (VAR ... compound -- OR -- compound).
BlockNode = Dataclass.new(:declarations, :compound_statement)

# Variable definition.
VariableDeclarationNode = Dataclass.new(:identifier, :type)

# Procedure definition.
ProcedureDeclarationNode = Dataclass.new(:name, :block)

# Compound statement (BEGIN ... END block).
CompoundNode = Dataclass.new(:children)

# An assignment expression.
AssignmentNode = Dataclass.new(:left, :op, :right)

# Type definition.
TypeNode = Dataclass.new(:token) do
  def name
    token.value.upcase
  end
end

# A variable node.
VariableNode = Dataclass.new(:token) do
  def name
    token.value.upcase
  end
end

# A null operation. This does nothing useful. It is used
# in places where a statement has no content.
NoOpNode = Dataclass.new(:position)
