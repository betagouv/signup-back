module SpecPolicyHelper
  def permissions_by_records_and_users(action, record_factories, user_factories)
    permissions action do
      record_factories.each do |record_factory|
        user_factories.each do |user_factory, allowed|
          describe "with a #{user_factory} user and a #{record_factory} record" do

            #XXX temporary hack
            # legacy of dependency on factory names that were like factory_#{provider} and
            # do nothing but add set provider value to the suffix

            provider = (user_factory.to_s.split('_') - ['user']).join('_')
            provider = (provider.empty?) ? nil : provider

            let(:user)    { create(:user, provider: provider) }
            let(:record)  { create(record_factory) }

            if allowed
              it 'allow access' do
                expect(subject).to permit(user, record)
              end
            else
              it 'deny access' do
                expect(subject).not_to permit(user, record)
              end
            end
          end
        end
      end
    end
  end
end
