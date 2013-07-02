BestBoy.setup do |config|
  # if you want to use the asset-pipeline, set precompile_assets to true (default: false)
  config.precompile_assets = true

  # Define ORM. Could be :active_record (default). Actually no other mapper is supported
  config.orm = :active_record

  # Define base Controller (default ApplicationController)
  config.base_controller = "ApplicationController"

  # Define before_filter for using before_filters (default = nil)
  #config.before_filter = nil

  # Define skip_before_filter for skipping before_filters (default = nil)
  #config.skip_before_filter = nil

  # Define custom redirect path as string p.e. "/admin" (default = nil)
  #config.custom_redirect = nil
end