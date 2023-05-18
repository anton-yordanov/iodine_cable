# frozen_string_literal: true

module IodineCable
  class PubSub < Iodine::PubSub::Engine
    def initialize
      # make sure engine setup is complete
      super

      # register engine and make it into the new default
      @target = Iodine::PubSub.default
      Iodine::PubSub.default = self
      Iodine::PubSub.attach self
    end

    def subscribe to, as = nil
      IodineCable.logger.info("* Subscribing to \"#{to}\" (#{as || "exact match"})")
      # message = {identifier: {channel: "AppearanceChannel"}, type: "confirm_subscription"}.to_json
      # Iodine.write(message)
    end

    def unsubscribe to, as = nil
      IodineCable.logger.info("* Unsubscribing from \"#{to}\" (#{as || "exact match"})")
      puts
    end

    def publish to, msg
      IodineCable.logger.info("* Publishing to \"#{to}\": #{msg.inspect}")
      # we need to forward the message to the actual engine (the previous default engine),
      # or it will never be received by any Pub/Sub client.
      @target.publish to, msg
    end
  end
end
