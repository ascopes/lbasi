# frozen_string_literal: true

# Program.
ProgramNode = Struct.new(:name, :block)

# Binary operation.
BinOpNode = Struct.new(:left, :op, :right)

# Unary operation.
UnaryOpNode = Struct.new(:op, :expr)

# A number node.
NumberNode = Struct.new(:token) do
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
BlockNode = Struct.new(:declarations, :compound_statement)

# Variable definition.
VariableDeclarationNode = Struct.new(:identifier, :type)

# Compound statement (BEGIN ... END block).
CompoundNode = Struct.new(:children)

# An assignment expression.
AssignmentNode = Struct.new(:left, :op, :right)

# Type definition.
TypeNode = Struct.new(:token) do
  def name
    token.value.upcase
  end
end

# A variable node.
VariableNode = Struct.new(:token) do
  def name
    token.value.upcase
  end
end

# A null operation. This does nothing useful. It is used
# in places where a statement has no content.
NoOpNode = Struct.new(:position)
