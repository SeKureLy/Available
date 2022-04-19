# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:receipts].delete
  app.DB[:calendars].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:receipts] = YAML.safe_load File.read('app/db/seeds/receipt_seeds.yml')
DATA[:calendars] = YAML.safe_load File.read('app/db/seeds/calendar_seeds.yml')
