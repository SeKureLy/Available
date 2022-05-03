# frozen_string_literal: true

Sequel.seed(:development) do
    def run
      puts 'Seeding accounts, projects, documents'
      create_accounts
      create_owned_calendars
    #   create_documents
    #   add_collaborators
    end
  end
  
  require 'yaml'
  DIR = File.dirname(__FILE__)
  ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
  OWNER_INFO = YAML.load_file("#{DIR}/owned_calendar.yml")
  CAL_INFO = YAML.load_file("#{DIR}/calendars_seeds.yml")
  EVENT_INFO = YAML.load_file("#{DIR}/events_seeds.yml")
  GROUP_INFO = YAML.load_file("#{DIR}/owned_group.yml")
  
  def create_accounts
    ACCOUNTS_INFO.each do |account_info|
      Available::Account.create(account_info)
    end
  end
  
  def create_owned_calendars
    OWNER_INFO.each do |owner|
      account = Available::Account.first(username: owner['username'])
      owner['cal_name'].each do |cal_name|
        cal_data = CAL_INFO.find { |cal| cal['title'] == cal_name }
        Available::CreateCalendarForOwner.call(
            title: account.id, calendar_data: cal_data
        )
      end
    end
  end

#   def create_owned_groups
#     OWNER_INFO.each do |owner|
#       account = Available::Account.first(username: owner['username'])
#       owner['group_name'].each do |cal_name|
#         cal_data = CAL_INFO.find { |cal| cal['title'] == cal_name }
#         Available::CreateGroupForOwner.call( group_name: cal_data )
#       end
#     end
#   end
  
#   def create_documents
#     doc_info_each = DOCUMENT_INFO.each
#     projects_cycle = Available::Project.all.cycle
#     loop do
#       doc_info = doc_info_each.next
#       project = projects_cycle.next
#       Available::CreateDocumentForProject.call(
#         project_id: project.id, document_data: doc_info
#       )
#     end
#   end
  