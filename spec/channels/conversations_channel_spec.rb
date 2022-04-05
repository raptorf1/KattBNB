RSpec.describe ConversationsChannel, type: :channel do
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:user3) { FactoryBot.create(:user, message_notification: false) }
  let(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }
  let(:conversation3) { FactoryBot.create(:conversation, user1_id: user2.id, user2_id: user3.id, hidden: user2.id) }

  describe 'unsuccessfully' do
    before do
      User.destroy_all
      stub_connection
    end

    it 'rejects when no conversation id is passed' do
      subscribe
      expect(subscription).to be_rejected
    end

    it 'with zero stream length' do
      subscribe
      expect(subscription.streams.length).to eq 0
    end

    it 'by transmitting relevant error' do
      subscribe
      expect(
        subscription.connection.transmissions[0]['error']
      ).to eq 'No conversation specified or conversation does not exist. Connection rejected!'
    end

    it 'rejects when a non existing conversation id is passed as a param' do
      subscribe(conversations_id: 5_000_000)
      expect(subscription).to be_rejected
    end

    it 'by transmitting relevant error when message arguments are not within permitted params' do
      subscribe(conversations_id: conversation.id)
      expect(subscription.receive({ 'conversation_id' => conversation.id })[1]['message']['data']).to eq [
           'User must exist'
         ]
    end

    it 'by transmitting relevant error when unassociated with a conversation user tries to send a message' do
      subscribe(conversations_id: conversation.id)
      expect(
        subscription.receive(
          { 'conversation_id' => conversation.id, 'body' => 'Happy New Year!', 'user_id' => user3.id }
        )[
          1
        ][
          'message'
        ][
          'data'
        ]
      ).to eq 'You cannot send message to a conversation you are not part of!'
    end
  end

  describe 'successfully' do
    before do
      User.destroy_all
      stub_connection
    end

    it 'subscribes to a stream when a valid conversation id is provided' do
      subscribe(conversations_id: conversation.id)
      expect(subscription).to be_confirmed
    end

    it 'streams from correct channel' do
      subscribe(conversations_id: conversation.id)
      expect(subscription).to have_stream_from("conversations_#{conversation.id}_channel")
    end

    it 'broadcasts message when arguments are within permitted params' do
      ActiveJob::Base.queue_adapter = :test
      subscribe(conversations_id: conversation.id)
      subscription.receive(
        { 'conversation_id' => conversation.id, 'user_id' => user1.id, 'body' => 'Batman, I love you!' }
      )
      expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
    end

    it 'sends an email to receiver' do
      subscribe(conversations_id: conversation.id)
      subscription.receive(
        { 'conversation_id' => conversation.id, 'user_id' => user1.id, 'body' => 'Batman, I love you!' }
      )
      expect(Delayed::Job.all.count).to eq 1
    end

    it 'broadcasts message and does not send an email to receiver if they opt out of that notification' do
      subscribe(conversations_id: conversation2.id)
      subscription.receive(
        { 'conversation_id' => conversation2.id, 'user_id' => user1.id, 'body' => 'Batman, I hate you!' }
      )
      expect(Delayed::Job.all.count).to eq 0
    end

    it 'updates conversation hidden field to nil' do
      subscribe(conversations_id: conversation3.id)
      subscription.receive(
        { 'conversation_id' => conversation3.id, 'user_id' => user3.id, 'body' => 'Batman, I love you!' }
      )
      conversation3.reload
      expect(conversation3.hidden).to eq nil
    end

    it 'broadcasts message with image attached' do
      image = {
        type: 'image/png',
        encoder: 'name=carbon (5).png;base64',
        data:
          'iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf',
        extension: 'png'
      }
      subscribe(conversations_id: conversation.id)
      subscription.receive(
        {
          'conversation_id' => conversation.id,
          'user_id' => user1.id,
          'body' => 'Batman, I love you!',
          'image' => image
        }
      )
      expect(Message.last.image).to be_attached
    end
  end
end
