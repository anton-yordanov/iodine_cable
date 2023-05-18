# frozen_string_literal: true

require_relative "mannager"
require "json"

module IodineCable
  module Connection
    class Base
      def initialize channel
        @channel = "AppearanceChannel"
      end

      attr_reader :channel

      # seng a message to new clients.
      def on_open(client)
        IodineCable.logger.info "Client #{client} connected."
        client.subscribe "AppearanceChannel"

        message = {identifier: {channel: "AppearanceChannel"}, type: "confirm_subscription"}.to_json
        client.write message
      end

      # send a message, letting the client know the server is suggunt down.
      def on_shutdown(client)
        client.write "Server shutting down. Goodbye."
      end

      # perform the echo
      def on_message(client, data)
        # IodineCable.logger.info "Client: #{client} sent a message: #{data}"
        # message = JSON.parse(data)

        # case message["command"]
        # when "subscribe"
        #   IodineCable.logger.info "Subscribing client #{client} to channel #{channel}"
        #   message = {identifier: {channel: "AppearanceChannel"}, type: "confirm_subscription"}.to_json
        #   client.publish(channel, message)
        # else
        #   client.publish(channel, data)
        # end
      rescue JSON::ParserError => e
        IodineCable.logger.error "Error parsing JSON message: #{e.message}"
      end

      def on_close(client)
        # let everyone know we left
        # IodineCable.logger.info "Disconnecting client: #{client}."
        # message = {command: "disconnected", identifier: {channel: "AppearanceChannel"}}.to_json
        # client.publish(channel, message)
        # we don't need to unsubscribe, subscriptions are cleared automatically once the connection is closed.
      end
    end
  end
end
