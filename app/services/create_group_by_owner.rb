# frozen_string_literal: true

module Available
  # Service object to create a new group for an owner
  class CreateGroupForOwner
    def self.call(owner_id:, group_name:)
      owner = Account.first(id: owner_id)
      owner.add_owned_group(group_name:)
      Group.first(group_name:).add_member(owner)
    end
  end
end
