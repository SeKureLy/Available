# frozen_string_literal: true

require 'http'

module Available
  # Find or create an SsoAccount based on google code
  class AuthorizeSso
    def call(access_token)
      google_account = get_google_account(access_token)
      sso_account = find_or_create_sso_account(google_account)

      account_and_token(sso_account)
    end

    def get_google_account(access_token)
      g_response = HTTP.headers(
        user_agent: 'Credence',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV['GOOGLE_ACCOUNT_URL'])

      raise unless g_response.status == 200

      account = GoogleAccount.new(JSON.parse(g_response))
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_google_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
