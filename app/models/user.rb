class User < ApplicationRecord
  rolify
  devise :omniauthable, omniauth_providers: %i[dgfip france_connect]

  def self.from_dgfip_omniauth(data)
    where(
      provider: data['provider'],
      uid: data['uid'],
      email: data['email']
    ).first_or_create
  end

  def self.from_france_connect_omniauth(data)
    where(
      provider: data['provider'],
      uid: data['uid'],
      email: data.info['email']
    ).first_or_create
  end

  def france_connect?
    provider
  end

  def dgfip?
    provider == 'dgfip'
  end
end
