# frozen_string_literal: true

class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:api_gouv]

  has_many :enrollments
  has_many :events

  def self.reconcile(user_info_from_api_gouv)
    user = where(
      uid: user_info_from_api_gouv[:info]['sub']
    ).first_or_create
    user.update(
      email: user_info_from_api_gouv[:info]['email'],
      email_verified: user_info_from_api_gouv[:info]['email_verified'],
      role: user_info_from_api_gouv[:info]['legacy_account_type']
    )
    user
  end

  def is_admin?(target_api)
    role == target_api
  end
end
