class WebhookMailer < ActionMailer::Base
  layout false

  def fail
    @webhook_url = ENV["#{params[:target_api].upcase}_WEBHOOK_URL"]
    @payload = JSON.pretty_generate(params[:payload])
    @webhook_response_body = params[:webhook_response_body]
    @webhook_response_status = params[:webhook_response_status]

    mail(
      subject: "[Datapass] Votre webhook endpoint est en défaut",
      to: target_api_instructor_emails,
      from: "datapass@api.gouv.fr",
      cc: "datapass@api.gouv.fr"
    )
  end

  private

  def target_api_instructor_emails
    User.where(
      roles: ["#{params[:target_api]}:instructor"]
    ).pluck(:email)
  end
end
