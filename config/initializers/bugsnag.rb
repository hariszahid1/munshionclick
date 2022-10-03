if Rails.env.production?
  Bugsnag.configure do |config|
    config.api_key = "66878042d3087edcf3482c7861556221"
  end
end
