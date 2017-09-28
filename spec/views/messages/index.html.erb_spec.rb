require 'rails_helper'

RSpec.describe 'messages/index', type: :view do
  before(:each) do
    assign(:messages, [
             Message.create!(
               enrollment_id: 2,
               content: 'MyText',
               user_id: 3
             ),
             Message.create!(
               enrollment_id: 2,
               content: 'MyText',
               user_id: 3
             )
           ])
  end

  it 'renders a list of messages' do
    render
    assert_select 'tr>td', text: 2.to_s, count: 2
    assert_select 'tr>td', text: 'MyText'.to_s, count: 2
    assert_select 'tr>td', text: 3.to_s, count: 2
  end
end
