# frozen_string_literal: true

module Available
  # Service object to create a new group for an owner
  class GetOwnGroup
    def self.call(username:)
      account = Account.first(username:)
      account.owned_groups
    end
  end
end
