# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module AIS
  STORE_DIR = 'app/db/store'

  # Holds a full secret receipt
  class Receipt
    # Create a new receipt by passing in hash of attributes
    def initialize(new_receipt)
      @id           = new_receipt['id'] || new_id
      @sender       = new_receipt['sender'] || new_id
      @receiver     = new_receipt['receiver'] || new_id
      @sender_sig   = new_receipt['sender_sig'] || new_id
      @receiver_sig = new_receipt['receiver_sig'] || new_id
      @content      = new_receipt['content']
    end

    attr_reader :id, :sender, :receiver, :sender_sig, :receiver_sig, :content

    def to_json(options = {})
      JSON(
        { type: 'receipt',
          id: id,
          sender: sender,
          receiver: receiver,
          sender_sig: sender_sig,
          receiver_sig: receiver_sig,
          content: content }, options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(AIS::STORE_DIR) unless Dir.exist? AIS::STORE_DIR
    end

    # Stores receipt in file store
    def save
      File.write("#{AIS::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one receipt
    def self.find(find_id)
      receipt_file = File.read("#{AIS::STORE_DIR}/#{find_id}.txt")
      Receipt.new JSON.parse(receipt_file)
    end

    # Query method to retrieve index of all receipts
    def self.all
      Dir.glob("#{AIS::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(AIS::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
