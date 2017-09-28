require 'rails_helper'

RSpec.describe 'messages/new', type: :view do
  before(:each) do
    assign(:message, Message.new(
                       enrollment_id: 1,
                       content: 'MyText',
                       user_id: 1
    ))
  end

  it 'renders new message form' do
    render

    assert_select 'form[action=?][method=?]', messages_path, 'post' do
      assert_select 'input[name=?]', 'message[enrollment_id]'

      assert_select 'textarea[name=?]', 'message[content]'

      assert_select 'input[name=?]', 'message[user_id]'
    end
  end
end
