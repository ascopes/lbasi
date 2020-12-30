# frozen_string_literal: true

def short_inspect(member)
  raw = member.inspect
  return "\"#{raw[1..30]}...\"" if raw.length > 30 && (raw[0] == '"')

  raw
end

# An extension of Ruby's struct that is not as spammy for large numbers of items.
class Dataclass < Struct
  def inspect
    members = map { |m| short_inspect(m) }.join(' ')
    members = " #{members}" if members
    class_name = self.class.name
    "#<#{class_name}#{members}>"
  end

  def to_s
    inspect
  end
end
