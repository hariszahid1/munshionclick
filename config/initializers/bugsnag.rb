if Rails.env.production?
  Bugsnag.configure do |config|
    config.api_key = "d5f51cf063f26e0745ce69461514fc85"
  end
end
