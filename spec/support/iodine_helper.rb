require "bundler"

module Support
  module IodineServer
    def spawn_with_test_log(cmd, verbose: ENV.key?("VERBOSE"))
      test_log = verbose ? $stderr : File.open("spec/log/test.log", "a+")

      Bundler.with_unbundled_env do
        Process.spawn(cmd, out: test_log, err: test_log)
      end
    end

    def server_port
      3001
    end

    def wait_until_iodine_ready
      tries = 0

      loop do
        sleep 0.1
        Socket.tcp("localhost", server_port, connect_timeout: 1) {}
        break
      rescue Errno::ETIMEDOUT
        raise "Could not start iodine, please check spec/log/test.log for more info" if tries > 10
        tries += 1
      rescue Errno::ECONNREFUSED
        raise "Could not start iodine, please check spec/log/test.log for more info" if tries > 10
        tries += 1
      end
    end

    def start_iodine_with_app(name, **opts)
      filename = "spec/support/apps/#{name}.ru"
      raise "test rack file (#{name}) does not exist" unless File.exist?(filename)
      cmd = if Gem.win_platform?
        +"bundle exec iodine -w 1 -t 1 -p #{server_port}"
      else
        +"bundle exec ruby bin/iodine -w 1 -t 1 -p #{server_port}"
      end
      cmd += " -V 5 -log" if opts[:verbose]
      pid = spawn_with_test_log("#{cmd} #{filename}", **opts)
      wait_until_iodine_ready
      pid
    end

    def with_app(name, **opts)
      pid = start_iodine_with_app(name, **opts)

      begin
        yield if block_given?
      ensure
        if !pid.nil?
          if Gem.win_platform?
            # SIGINT or SIGILL are unreliable on Windows, try native taskkill first
            Process.kill("KILL", pid) unless system("taskkill /f /t /pid #{pid} >NUL 2>NUL")
          else
            Process.kill "SIGINT", pid
          end
          Process.wait pid
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/integration/}) do |metadata|
    metadata[:type] = :integration
  end

  when_tagged_with_app = {with_app: ->(v) { !!v }}

  config.around(:each, when_tagged_with_app) do |ex|
    with_app(ex.metadata[:with_app], verbose: ex.metadata[:verbose]) { ex.run }
  end

  config.include(::Support::IodineServer, type: :integration)
end
