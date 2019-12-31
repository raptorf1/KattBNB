RSpec.describe ConversationsChannel, type: :channel do
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
    subscribe(conversations_id: 42)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('conversations_42_channel')
  end

  it 'transmits relevant errors when message arguments are not within permitted params' do
    subscribe(conversations_id: 42)
    expect(subscription.send_message(conversation_id: 5)[1]['message']['type']).to eq 'errors'
    expect(subscription.send_message(conversation_id: 5)[1]['message']['data']).to eq ["User must exist", "Conversation must exist", "Body can't be blank"]
  end

end
