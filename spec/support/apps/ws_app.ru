require "rack"
require "rack/cors"
require "iodine_cable"

Iodine.patch_rack
MyEngine = IodineCable::PubSub.new

module MyHTTPRouter
  # This is the HTTP response object according to the Rack specification.
  HTTP_RESPONSE = [200, {"Content-Type" => "text/html","Content-Length" => "32"},["Please connect using websockets."]]

  # this is function will be called by the Rack server (iodine) for every request.
  def self.call env
    protocol = env["HTTP_SEC_WEBSOCKET_PROTOCOL"]

    # check if this is an upgrade request.
    if env["rack.upgrade?"]
      IodineCable.logger.debug "Upgrade request received."
      env["rack.upgrade"] = IodineCable::Connection::Base.new(env["PATH_INFO"])
      return [101, {"Sec-Websocket-Protocol" => protocol}, []]
    end
    # simply return the RESPONSE object, no matter what request was received.
    HTTP_RESPONSE
  end

  extend self
end

use Rack::Cors do
  allow do
    origins "localhost:3001", "https://cdn.jsdelivr.net"
    resource(
      "*",
      headers: :any,
      expose: ["*", "ETag", "Authorization", "X-Channel"],
      methods: [:get, :post, :delete, :put, :patch, :options, :head],
      max_age: 86_400,
      credentials: true
    )
  end
end

map "/" do
  run MyHTTPRouter
end
