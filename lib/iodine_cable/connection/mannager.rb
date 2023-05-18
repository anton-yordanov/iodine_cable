# frozen_string_literal: true

require "securerandom"
require "redis"
require "hiredis-client"
require "connection_pool"

module IodineCable
  module Connection
    module Mannager
      @connections = {}

      def add(identifier, client)
        mutex = Mutex.new

        Thread.new do
          mutex.synchronize do
            @connections[identifier] = client
          end
        end
        # REDIS_POOL.with { |conn| conn.set(connection_id, client.uuid) }
      end

      def remove(identifier)
        mutex = Mutex.new

        Thread.new do
          mutex.synchronize do
            @connections.delete(identifier)
          end
        end
        # REDIS_POOL.with { |conn| conn.del(connection_id) }
      end

      def clear
        mutex = Mutex.new

        Thread.new do
          mutex.synchronize do
            @connections = {}
          end
        end
      end
    end
  end
end
