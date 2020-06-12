REDIS_URL = Settings.redis.url

ENV['RGEOSERVER_CONFIG'] ||= File.expand_path(File.join(File.dirname(__FILE__), ENV['ROBOT_ENVIRONMENT'] + '_rgeoserver.yml'))
