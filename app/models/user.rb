class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:api_gouv]
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "Vous devez renseigner un email valide"}

  has_many :enrollments
  has_many :dpo_enrollments, foreign_key: :dpo_id, class_name: :Enrollment
  has_many :responsable_traitement_enrollments, foreign_key: :responsable_traitement_id, class_name: :Enrollment
  has_many :events

  def self.reconcile(external_user_info)
    user = where(
      email: external_user_info["email"],
    ).first_or_create!

    # the following data must be used as a cache (do not modify them, use fresh data form api-auth whenever you can)
    user.update(uid: external_user_info["sub"]) if external_user_info.key?("sub")
    user.update(email_verified: external_user_info["email_verified"]) if external_user_info.key?("email_verified")
    user.update(organizations: external_user_info["organizations"]) if external_user_info.key?("organizations")

    user
  end

  def is_admin?(target_api)
    roles.include? target_api
  end
end
