RSpec.describe ConversationsChannel, type: :channel do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:message) { FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation.id, body: 'Batman, I love you!') }

  before do
    stub_connection
  end

  it 'rejects when no conversation id is passed as a param' do
    subscribe
    expect(subscription).to be_rejected
    expect(subscription.streams.length).to eq 0
  end

  it 'transmits relevant error' do
    subscribe
    expect(subscription.connection.transmissions[0]['error']).to eq 'No conversation specified. Connection rejected!'
  end

  it 'subscribes to a stream when conversation id is provided' do
    subscribe(conversations_id: conversation.id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("conversations_#{conversation.id}_channel")
  end

  it 'transmits relevant errors when message arguments are not within permitted params' do
    subscribe(conversations_id: conversation.id)
    expect(subscription.send_message({'conversation_id' => 5000000})[1]['message']['type']).to eq 'errors'
    expect(subscription.send_message({'conversation_id' => 5000000})[1]['message']['data']).to eq ["User must exist", "Conversation must exist", "Body can't be blank"]
  end

  it 'broadcast message when message arguments are within permitted params' do
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation.id)
    subscription.send_message({'conversation_id' => conversation.id, 'user_id' => user1.id, 'body' => message.body})
    expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
  end

end
