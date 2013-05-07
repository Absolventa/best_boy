BestBoy.setup do |config|
  # if you want to use the asset-pipeline, set precompile_assets to true (default: false)
  # config.precompile_assets = true

  # Define ORM. Could be :active_record (default). Actually no other mapper is supported
  #config.orm = :active_record

  # Define base Controller (default ApplicationController)
  #config.base_controller = "ApplicationController"

  # Define before_filter for using before_filters (default = nil)
  #config.before_filter = nil

  # Define skip_before_filter for skipping before_filters (default = nil)
  #config.skip_before_filter = nil

  # Define custom redirect path as string p.e. "/admin" (default = nil)
  #config.custom_redirect = nil
end

# if you are using will_paginate in your app project, you will need this uncommended
# this is a temporary fix that forces will_paginate to behave like kaminari

# module WillPaginate
#   # make will paginate behave like kaminari
#   module ActiveRecord
#     module RelationMethods
#       def per(value = nil)
#         per_page(value)
#       end
#     end
#   end

#   module ActionView
#     def paginate(collection = nil, options = {})
#       will_paginate(collection, options)
#     end
#   end
# end