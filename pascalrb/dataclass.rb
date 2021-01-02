# frozen_string_literal: true

def short_inspect(member)
  raw = member.inspect

  if raw.length >= 45
    if raw[0] == '"'
      "\"#{raw[1..46]}...\""
    else
      "#{raw[0..45]}..."
    end
  else
    raw
  end
end

# An extension of Ruby's struct that is not as spammy for large numbers of items when
# getting a string from a member.
class Dataclass < Struct
  def to_s
    included_members = each_pair
    members_str = included_members.map { |k, v| " #{k}=(#{short_inspect(v)})" }.join(',')
    class_name = self.class.name

    "#<#{class_name}#{members_str}>"
  end
end
