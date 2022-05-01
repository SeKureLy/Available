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

DATA = {
  events: YAML.load(File.read('app/db/seeds/events_seeds.yml')),
  calendars: YAML.load(File.read('app/db/seeds/calendars_seeds.yml')),
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml'))
}.freeze
