# frozen_string_literal: true

module Available
    # Service object to create a new calendar for an owner
    class CreateGroupForOwner
      def self.call(owner_id:, group_name:)
        Account.first(id: owner_id)
               .add_owned_group(group_name)
      end
    end
  end