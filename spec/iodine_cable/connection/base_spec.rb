# frozen_string_literal: true

require "iodine_cable"

RSpec.describe IodineCable::Connection::Base, with_app: :ws_app do
  describe "initialization" do
    subject { described_class.new }

    it "creates a new instance of Connection::Base" do
      expect(subject).to be_a(IodineCable::Connection::Base)
    end
  end

  describe "WebSocket methods" do
    let(:subscription_channel) { "/cable/test_channel" }
    let(:message) { "test_message" }

    it "calls on_open when a new WebSocket connection is established" do
      # expect_any_instance_of(described_class).to receive(:on_open).and_call_original

      pub_sub = IodineCable::PubSub.new

      pp Iodine.subscribe(subscription_channel, false).inspect
      pp pub_sub.subscribe(subscription_channel, "FCK")

      sleep(1)
    end

    # it "calls on_message when a WebSocket message is received" do
    #   run_iodine do
    #     expect_any_instance_of(IodineCable::ConnectionManager).to receive(:on_message).and_call_original

    #     Iodine.publish(subscription_channel, message)
    #     sleep(1)
    #   end
    # end

    # it "calls on_close when a WebSocket connection is closed" do
    #   run_iodine do
    #     expect_any_instance_of(IodineCable::ConnectionManager).to receive(:on_close).and_call_original

    #     Iodine.publish(subscription_channel, message)
    #     sleep(1)
    #     # Close the connection (you may need to add a helper method to do this)
    #   end
    # end
  end
end
