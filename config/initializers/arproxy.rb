if Rails.env.development? || Rails.env.test?
  require 'multiple_database_connection_logger'
  Arproxy.configure do |config|
    config.adapter = 'mysql2'
    config.use MultipleDatabaseConnectionLogger
  end
  Arproxy.enable!
 end
