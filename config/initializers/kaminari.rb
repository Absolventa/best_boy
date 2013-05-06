# if you are using will_paginate in your project, you will need this uncommended

Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end