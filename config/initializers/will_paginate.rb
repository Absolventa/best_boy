if defined?(WillPaginate)
  ActiveSupport.on_load :active_record do
    module WillPaginate
      module ActiveRecord
        module RelationMethods
          alias_method :per, :per_page
        end
      end
      module ActionView
        alias_method :paginate, :will_paginate
      end
    end
  end
end