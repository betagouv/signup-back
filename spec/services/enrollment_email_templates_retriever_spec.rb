RSpec.describe EnrollmentEmailTemplatesRetriever, type: :service do
  describe '#perform' do
    subject { described_class.new(enrollment, instructor).perform }

    let(:instructor) { create(:user, given_name: 'Marc', family_name: 'Moulin') }
    let(:enrollment) { create(:enrollment, target_api: target_api) }

    context 'with a target_api which has no custom templates' do
      let(:target_api) { 'dinum_rockstars' }

      before do
        allow_any_instance_of(described_class).to receive(:target_api_data).and_return(
          {
            'target_api' => 'DINUM rockstars'
          }
        )
      end

      it 'renders 4 templates, one for each action' do
        expect(subject.count).to eq(4)

        expect(subject.map(&:action_name)).to include(
          *%w[
            notify
            refuse_application
            review_application
            validate_application
          ]
        )
      end

      describe 'review application default template' do
        subject do
          described_class.new(enrollment, instructor).perform.find do |template|
            template.action_name == 'review_application'
          end
        end

        let(:enrollment_mailer_layout_sample) do
          File.open(Rails.root.join('app/views/layouts/enrollment_mailer.text.erb')) { |f| f.readline }.chomp
        end

        let(:default_review_application_sample) do
          File.open(Rails.root.join('app/views/enrollment_mailer/review_application.text.erb')) { |f| f.readline }.chomp
        end

        it 'includes enrollment_mailer layout' do
          expect(subject.plain_text_content).to include(enrollment_mailer_layout_sample)
        end

        it 'includes review_application view' do
          expect(subject.plain_text_content).to include(default_review_application_sample)
        end

        it 'includes valid url to datapass' do
          expect(subject.plain_text_content).to include("#{ENV['FRONT_HOST']}/dinum-rockstars/#{enrollment.id}")
        end

        it 'includes target api humanized name' do
          expect(subject.plain_text_content).to include('DINUM rockstars')
        end
      end
    end

    context 'with a target api which has custom templates' do
      let(:target_api) { 'api_entreprise' }

      it 'renders 4 templates, one for each action' do
        expect(subject.count).to eq(4)

        expect(subject.map(&:action_name)).to include(
          *%w[
            notify
            refuse_application
            review_application
            validate_application
          ]
        )
      end

      describe 'a specific template : review application' do
        subject do
          described_class.new(enrollment, instructor).perform.find do |template|
            template.action_name == 'review_application'
          end
        end

        let(:enrollment_mailer_layout_sample) do
          File.open(Rails.root.join('app/views/layouts/enrollment_mailer.text.erb')) { |f| f.readline }.chomp
        end

        it 'does not include enrollment_mailer layout' do
          expect(subject.plain_text_content).not_to include(enrollment_mailer_layout_sample)
        end

        it 'includes default validate_application view' do
          expect(subject.plain_text_content).to include("#{instructor.given_name} pour API Entreprise")
        end
      end
    end
  end
end
