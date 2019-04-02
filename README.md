# Signup.api.gouv.fr Back

Installation instructions can be found [here](https://gitlab.incubateur.net/beta.gouv.fr/api-particulier-ansible).

## How to enroll a new API

Here are the files you need to update :
- app/controllers/enrollments_controller.rb
- app/mailers/enrollment_mailer.rb
- app/models/enrollment.rb
- app/policies/enrollment_policy.rb
- app/policies/message_policy.rb

Here are the files you need to create :
- app/models/enrollment/<name_of_api>.rb
- app/policies/enrollment/<name_of_api>_policy.rb
