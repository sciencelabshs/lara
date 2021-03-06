LightweightStandalone::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = false
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.growl = false
    Bullet.xmpp = false
    Bullet.rails_logger = true
    Bullet.airbrake = false
    # Bullet.add_footer = true
  end

  # include per developer environment files if found (the default is excluded by .gitignore)
  #
  # Here is a sample local-development.rb file to speed up requests
  #
  # LightweightStandalone::Application.configure do
  #   config.assets.debug = false
  #   config.after_initialize do
  #     Bullet.enable = false
  #     Bullet.bullet_logger = false
  #     Bullet.rails_logger = false
  #     Bullet.add_footer = false
  #   end
  # end
  localDevPath = File.expand_path((ENV['LOCAL_DEV_ENVIRONMENT_FILE'] || 'local-development.rb'), File.dirname(__FILE__))
  require(localDevPath) if File.file?(localDevPath)
end

# Open file links in BetterErrors in sublime text.
# On a mac, you will need to use this tool, or something similar:
# https://github.com/dhoulb/subl
BetterErrors.editor = :subl

# Flush stdout which is used for logging, in some cases docker was not seeing the
# output. There might be a better way to handle this.
$stdout.sync = true
