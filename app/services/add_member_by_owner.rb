# frozen_string_literal: true

module Available
  # Service object to create a new group for an owner
  class AddMemberByOwner
    def self.call(owner_id:, member_name:, group_name:)
      group = Group.first(group_name:)
      raise StandardError unless group.owner_id == owner_id
      member = Account.first(username: member_name)
      group.add_member(member)
    end
  end
end
