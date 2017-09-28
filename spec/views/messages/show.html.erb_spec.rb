require 'rails_helper'

RSpec.describe 'messages/show', type: :view do
  before(:each) do
    @message = assign(:message, Message.create!(
                                  enrollment_id: 2,
                                  content: 'MyText',
                                  user_id: 3
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/3/)
  end
end
