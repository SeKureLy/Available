# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Available::Event.map(&:destroy)
  Available::Calendar.map(&:destroy)
  Available::Account.map(&:destroy)
end

def authenticate(account_data)
  Available::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)
  puts auth[:attributes][:auth_token]
  # token = AuthToken.new(auth[:attributes][:auth_token])
  # puts token.payload
  # account = token.payload['attributes']
  # { account: Available::Account.first(username: account['username']),
  #   scope: AuthScope.new(token.scope) }

  token = AuthToken.new(auth[:attributes][:auth_token])
  account_data = token.payload['data']['attributes']

  { account: Account.first(username: account_data['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {
  events: YAML.load(File.read('app/db/seeds/events_seed.yml')),
  calendars: YAML.load(File.read('app/db/seeds/calendars_seed.yml')),
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml'))
}.freeze
