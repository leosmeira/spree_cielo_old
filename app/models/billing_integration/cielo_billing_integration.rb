module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module CieloIntegration 

        mattr_accessor :service_url
        self.service_url = '#'

      end
    end
  end
end


class BillingIntegration::CieloBillingIntegration < BillingIntegration
  # preference :login, :string
  # preference :password, :string

  def provider_class
    ActiveMerchant::Billing::Integrations::CieloIntegration
  end
end