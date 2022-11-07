module StripeService
  def self.get_api_key()
    if ENV["OFFICIAL"] == "yes"
      Rails.application.credentials.STRIPE_API_KEY_PROD
    else
      Rails.application.credentials.STRIPE_API_KEY_DEV
    end
  end

  def self.get_webhook_endpoint_secret()
    if ENV["OFFICIAL"] == "yes"
      Rails.application.credentials.STRIPE_WEBHOOK_SIGN_PROD
    else
      Rails.application.credentials.STRIPE_WEBHOOK_SIGN_TEST
    end
  end
end
