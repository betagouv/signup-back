class TeamMember < ActiveRecord::Base
  # enable Single Table Inheritance with a snake_case value as discriminatory field
  class << self
    # ex: 'contact_technique' => TeamMember::ContactTechnique
    def find_sti_class(type)
      "TeamMember::#{type.underscore.classify}".constantize
    end

    # ex: > TeamMember::ContactTechnique => 'contact_technique'
    def sti_name
      name.demodulize.underscore
    end
  end

  belongs_to :enrollment
  belongs_to :user, optional: true
  before_save :set_user, if: :will_save_change_to_email?
  before_save :set_to_current_user

  validates :email,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "Vous devez renseigner un email valide"
    }, allow_blank: true

  def has_linked_user
    true
  end

  def disable_edition
    false
  end

  protected

  def set_to_current_user
    if disable_edition
      self.family_name = Current.user.family_name
      self.given_name = Current.user.given_name
      self.email = Current.user.email
      self.phone_number = Current.user.phone_number
      self.job = Current.user.job
      self.user = Current.user
    end
  end

  def set_user
    self.user = if has_linked_user && email.present?
      User.reconcile({"email" => email.strip})
    end
  end
end
