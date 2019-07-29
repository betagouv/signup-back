# frozen_string_literal: true

class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:api_gouv]

  has_many :enrollments
  has_many :events

  def self.reconcile(user_info_from_api_gouv)
    user = where(
      email: user_info_from_api_gouv[:info]['email'],
    ).first_or_create
    user.update(
      uid: user_info_from_api_gouv[:info]['sub'],
      email_verified: user_info_from_api_gouv[:info]['email_verified'],
      roles: user_info_from_api_gouv[:info]['roles']
    )
    user
  end

  def is_admin?(target_api)
    roles.include? target_api
  end
end
