# frozen_string_literal: true

require "rack"
require "rack/cors"
require "iodine_cable"
require "json"

# creates an example Pub/Sub Engine that merely reports any pub/sub events to the system's terminal
class PubSubReporter < Iodine::PubSub::Engine
  def initialize
    # make sure engine setup is complete
    super
    # register engine and make it into the new default
    @target = Iodine::PubSub.default
    Iodine::PubSub.default = self
    Iodine::PubSub.attach self
  end

  def subscribe to, as = nil
    puts "* Subscribing to \"#{to}\" (#{as || "exact match"})"
  end

  def unsubscribe to, as = nil
    puts "* Unsubscribing to \"#{to}\" (#{as || "exact match"})"
  end

  def publish to, msg
    puts "* Publishing to \"#{to}\": #{msg}"
    # we need to forward the message to the actual engine (the previous default engine),
    # or it will never be received by any Pub/Sub client.
    @target.publish to, msg
  end
end

PubSubReporter.new

# A simple Websocket Callback Object.
class PubSubClient
  def initialize name
    @name = name
  end

  def on_open(client)
    client.subscribe "AppearanceChannel"
    message = {identifier: {channel: "AppearanceChannel"}, type: "confirm_subscription"}.to_json
    client.publish "", message
  end

  def on_shutdown(client)
    client.write "Server shutting down. Goodbye."
  end

  def on_message(client, data)
    message = {identifier: {channel: "AppearanceChannel"}, message: data}.to_json
    client.publish "AppearanceChannel", message
  end

  def on_close(client)
    message = {command: "disconnected", identifier: {channel: "AppearanceChannel"}}.to_json
    client.publish "AppearanceChannel", message
    # we don't need to unsubscribe, subscriptions are cleared automatically once the connection is closed.
  end
end

# A simple router - Checks for Websocket Upgrade and answers HTTP.
module MyHTTPRouter
  # This is the HTTP response object according to the Rack specification.
  HTTP_RESPONSE = [200, {"Content-Type" => "text/html",
                         "Content-Length" => "32"},
    ["Please connect using websockets."]]

  WS_RESPONSE = [0, {}, []]

  # this is function will be called by the Rack server (iodine) for every request.
  def self.call env
    return HTTP_RESPONSE unless env["rack.upgrade?"]

    protocol = env["HTTP_SEC_WEBSOCKET_PROTOCOL"]
    env["rack.upgrade"] = PubSubClient.new(env["PATH_INFO"])
    [101, {"Sec-Websocket-Protocol" => protocol}, []]
  end
end

# this function call links our HelloWorld application with Rack
run MyHTTPRouter
