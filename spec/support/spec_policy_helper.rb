module SpecPolicyHelper
  def permissions_by_records_and_users(action, record_factories, user_factories)
    permissions action do
      record_factories.each do |record_factory|
        user_factories.each do |user_factory, allowed|
          describe "with a #{user_factory} user and a #{record_factory} record" do
            let(:record) { FactoryGirl.create(record_factory) }
            let(:user) { FactoryGirl.create(user_factory) }

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
