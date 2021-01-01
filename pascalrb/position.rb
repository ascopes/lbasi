# frozen_string_literal: true

require_relative('dataclass')

# File position type.
Position = Dataclass.new(:file, :line, :column) do
  def to_s
    "#{file}[line:#{line}, col:#{column}]"
  end
end
