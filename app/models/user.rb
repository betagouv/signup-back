# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[service_provider france_connect]

  rolify

  def self.from_dgfip_omniauth(data)
    where(
      provider: data['provider'],
      uid: data['uid'] || data['id'],
      email: data.info['email']
    ).first_or_create.update(
      oauth_roles: data.info['roles']
    )
  end

  def self.from_france_connect_omniauth(data)
    where(
      provider: data['provider'],
      uid: data['uid'],
      email: data.info['email']
    ).first_or_create
  end

  def france_connect?
    provider == 'france_connect'
  end

  def dgfip?
    provider == 'dgfip'
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
