# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, documents'
    create_accounts
    create_owned_calendars
    create_calendar_members
    create_events
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CAL_MEMBER_INFO = YAML.load_file("#{DIR}/calendars_members.yml")
CAL_INFO = YAML.load_file("#{DIR}/calendars_seed.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seed.yml")
OWNED_CAL_INFO = YAML.load_file("#{DIR}/owned_calendars.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Available::Account.create(account_info)
  end
end

def create_owned_calendars
  OWNED_CAL_INFO.each do |owner|
    owner['cal_name'].each do |cal_name|
      cal_data = CAL_INFO.find { |cal| cal['title'] == cal_name }
      Available::CreateCalendarForOwner.call(
        username: owner['username'], calendar_data: cal_data
      )
    end
  end
end

def create_calendar_members
  CAL_MEMBER_INFO.each do |calendar_info|
    calendar = Available::Calendar.first(title: calendar_info['cal_title'])
    calendar_info['member_email'].each do |member|
      Available::AddMemberToCalendar.call(
        email: member, title: calendar_info['cal_title']
      )
    end
  end
end

def create_events
  event_info_each = EVENT_INFO.each
  calendars_cycle = Available::Calendar.all.cycle
  loop do
    event_info = event_info_each.next
    calendar = calendars_cycle.next
    Available::CreateEventForCalendar.call(
      cal_id: calendar.id, event_data: event_info
    )
  end
end
