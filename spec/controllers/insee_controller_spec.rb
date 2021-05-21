RSpec.describe InseeController, type: :controller do
  describe "#code_naf" do
    subject(:get_code_naf) do
      get :code_naf, params: {
        id: code_naf
      }
    end

    context "with valid naf code" do
      let(:code_naf) { "62.02A" }

      it { is_expected.to have_http_status(:ok) }

      it do
        expect(JSON.parse(get_code_naf.body)).to eq({
          "message" => "Conseil en systèmes et logiciels informatiques"
        })
      end
    end

    context "with invalid naf code" do
      let(:code_naf) { "62.02C" }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
