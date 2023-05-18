# frozen_string_literal: true

require "logger"
require "iodine"
require "rack"

require_relative "iodine_cable/version"
require_relative "iodine_cable/connection/base"
require_relative "iodine_cable/pub_sub"

module IodineCable
  class Error < StandardError; end

  module_function

  def logger
    @logger ||= Logger.new($stdout)
  end

  def logger= logger
    @logger = logger
  end
end
