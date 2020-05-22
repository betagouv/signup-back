class RgpdMailer < ActionMailer::Base
  self.delivery_method = :mailjet_api

  def rgpd_contact_email
    mail(
      # The list of emails can be an array of email addresses or a single string with the addresses separated by commas.
      to: params[:to],
      subject: "Vous avez été désigné #{params[:rgpd_role]} pour l’organisation #{params[:nom_raison_sociale]}",
      from: "contact@api.gouv.fr",
      body: "", # skip template rendering
      delivery_method_options: {
        "version": "v3.1",
        "TemplateID": 1377498,
        "TemplateLanguage": true,
        "Variables": {
          target_api_label: EnrollmentMailer::MAIL_PARAMS[params[:target_api]]["target_api"],
          rgpd_role: params[:rgpd_role],
          contact_label: params[:contact_label],
          owner_email: params[:owner_email],
          nom_raison_sociale: params[:nom_raison_sociale],
          intitule: params[:intitule],
          url: "#{ENV.fetch("FRONT_HOST")}/#{params[:target_api].tr("_", "-")}/#{params[:enrollment_id]}"
        },
        "TemplateErrorReporting": {
          "Email": "contact@api.gouv.fr"
        },
        "TemplateErrorDeliver": true
      }
    )
  end
end
