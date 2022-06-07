# frozen_string_literal: true

module Available
    # Maps Google account details to attributes
    class GoogleAccount
      def initialize(g_account)
        @g_account = g_account
      end
  
      def username
        @g_account['login'] + '@google'
      end
  
      def email
        @g_account['email']
      end
    end
  end