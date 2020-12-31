# frozen_string_literal: true

def short_inspect(member)
  raw = member.inspect

  if raw.length > 30
    if raw[0] == '"'
      "\"#{raw[1..30]}...\"" 
    else 
      "#{raw[0..29]}..."
    end
  else
    raw
  end
end

# An extension of Ruby's struct that is not as spammy for large numbers of items when
# getting a string from a member.
# You can limit what is output by defining a method called to_s_members in your
# struct that returns a list.
class Dataclass < Struct
  def to_s
    begin
      included_members = to_s_members.map { |m| [m.to_s, send(m)] }
    rescue NameError
      included_members = each_pair
    end

    members_str = included_members.map { |k, v| " #{k}=#{short_inspect(v)}" }.join
    class_name = self.class.name

    "#<#{class_name}#{members_str}>"
  end
end
