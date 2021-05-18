RSpec.describe "Providers config", type: :acceptance do
  let(:config_file) do
    Rails.root.join("config/providers.yml")
  end

  it "is a valid YAML file" do
    expect {
      YAML.load_file(config_file)
    }.not_to raise_error
  end

  it "has valid fields" do
    YAML.load_file(config_file).each do |provider, config|
      %w[
        support_email
        label
      ].each do |key|
        expect(config[key]).to be_present, "Provider '#{provider}': missing key '#{key}'"
      end

      expect(config["support_email"]).to match(URI::MailTo::EMAIL_REGEXP), "Provider '#{provider}' has an invalid 'support_email' email format"
    end
  end
end
