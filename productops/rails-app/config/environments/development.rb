Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.assets.debug = true
  config.active_record.migration_error = :page_load
end
