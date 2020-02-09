RSpec.describe ConversationsChannel, type: :channel do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:user3) { FactoryBot.create(:user, email: 'nothing@thestreets.com', nickname: 'Deadpool') }
  let!(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }

  before do
    stub_connection
  end

  it 'rejects when no conversation id is passed as a param' do
    subscribe
    expect(subscription).to be_rejected
    expect(subscription.streams.length).to eq 0
  end

  it 'rejects when a non existing conversation id is passed as a param' do
    subscribe(conversations_id: 5000000)
    expect(subscription).to be_rejected
    expect(subscription.streams.length).to eq 0
  end

  it 'transmits relevant error' do
    subscribe
    expect(subscription.connection.transmissions[0]['error']).to eq 'No conversation specified or conversation does not exist. Connection rejected!'
  end

  it 'subscribes to a stream when a valid conversation id is provided' do
    subscribe(conversations_id: conversation.id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("conversations_#{conversation.id}_channel")
  end

  it 'transmits relevant errors when message arguments are not within permitted params' do
    subscribe(conversations_id: conversation.id)
    expect(subscription.send_message({'conversation_id' => conversation.id})[1]['message']['type']).to eq 'errors'
    expect(subscription.send_message({'conversation_id' => conversation.id})[1]['message']['data']).to eq ["User must exist", "Body can't be blank"]
  end

  it 'transmits relevant error when unassociated with a conversation user tries to send a message and then it deletes the message' do
    subscribe(conversations_id: conversation.id)
    expect(subscription.send_message({'conversation_id' => conversation.id, 'body' => 'Happy New Year!', 'user_id' => user3.id})[1]['message']['type']).to eq 'errors'
    expect(subscription.send_message({'conversation_id' => conversation.id, 'body' => 'Happy New Year!', 'user_id' => user3.id})[1]['message']['data']).to eq 'You cannot send message to a conversation you are not part of!'
    expect(Message.all.length).to eq 0
  end

  it 'broadcasts message and sends an email to receiver when message arguments are within permitted params' do
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation.id)
    subscription.send_message({'conversation_id' => conversation.id, 'user_id' => user1.id, 'body' => 'Batman, I love you!'})
    expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end

end
