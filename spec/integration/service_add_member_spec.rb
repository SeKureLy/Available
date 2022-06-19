# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Add Member service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Available::Account.create(account_data)
    end

    calendar_data = DATA[:calendars].first

    @owner_data = DATA[:accounts][0]
    @owner = Available::Account.all[0]
    @member = Available::Account.all[1]
    @calendar = @owner.add_owned_calendar(calendar_data)
  end

  it 'HAPPY: should be able to add a member to a calendar' do
    auth = authorization(@owner_data)

    Available::AddMemberToCalendar.call(
      auth:,
      email: @member.email,
      calendar: @calendar
    )

    _(@member.calendars.count).must_equal 1
    _(@member.calendars.first).must_equal @calendar
  end

  it 'BAD: should not add owner as a member' do
    auth = Available::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )

    _(proc {
      Available::AddMemberToCalendar.call(
        auth:,
        email: @member.email,
        calendar: @calendar
      )
    }).must_raise Available::AddMemberToCalendar::ForbiddenError
  end
end
