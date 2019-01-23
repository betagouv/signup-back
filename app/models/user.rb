# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_token_authenticatable
  devise :omniauthable, omniauth_providers: [:resource_provider]

  rolify

  def self.from_service_provider_omniauth(data)
    user = where(
      uid: data[:info]['sub']
    ).first_or_create
    user.update(
      oauth_roles: data[:info]['roles'],
      email: data[:info]['email'],
      provider: data[:info]['legacy_account_type']
    )
    user
  end

  def provided_by?(provider)
    send("#{provider}?")
  end

  def service_provider?
    provider == 'service_provider'
  end

  def dgfip?
    provider == 'dgfip'
  end

  def api_particulier?
    provider == 'api_particulier'
  end

  def franceconnect?
    provider == 'franceconnect'
  end

  def api_droits_cnam?
    provider == 'api_droits_cnam'
  end

  def sent_messages
    Message.with_role(:sender, self)
  end

  # def send_message(enrollment, params)
  #   message = enrollment.messages.create(params)
  #   add_role(:sender, message)
  #   message
  # end
end
