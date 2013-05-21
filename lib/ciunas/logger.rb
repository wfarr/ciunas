module Ciunas
  class Logger < Rails::Rack::Logger
    def initialize(app, opts = {})
      @app = app
      @opts = opts
      @opts[:silenced] ||= []
    end

    def call(env)
      if env['X-SILENCE-LOGGER'] || @opts[:silenced].any? {|m| m === env['PATH_INFO'] }
        begin
          # temporarily set the rails log level to error
          old_logger_level, Rails.logger.level = Rails.logger.level, tmp_log_level
          @app.call(env)
        ensure
          Rails.logger.level = old_logger_level
        end
      else
        super(env)
      end
    end
    
    def tmp_log_level
      if defined?(ActiveSupport::BufferedLogger::Severity::ERROR)
        ActiveSupport::BufferedLogger::Severity::ERROR
      else
        ActiveSupport::Logger::Severity::ERROR
      end
    end
  end
end  
