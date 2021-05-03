RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe ConversationsChannel, type: :channel do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:user3) do
    FactoryBot.create(:user, email: 'nothing@thestreets.com', nickname: 'Deadpool', message_notification: false)
  end
  let!(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }
  let!(:conversation3) { FactoryBot.create(:conversation, user1_id: user2.id, user2_id: user3.id, hidden: user2.id) }

  before { stub_connection }

  it 'rejects when no conversation id is passed as a param' do
    subscribe
    expect(subscription).to be_rejected
    expect(subscription.streams.length).to eq 0
  end

  it 'rejects when a non existing conversation id is passed as a param' do
    subscribe(conversations_id: 5_000_000)
    expect(subscription).to be_rejected
    expect(subscription.streams.length).to eq 0
  end

  it 'transmits relevant error' do
    subscribe
    expect(
      subscription.connection.transmissions[0]['error']
    ).to eq 'No conversation specified or conversation does not exist. Connection rejected!'
  end

  it 'subscribes to a stream when a valid conversation id is provided' do
    subscribe(conversations_id: conversation.id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("conversations_#{conversation.id}_channel")
  end

  it 'subscribes to a stream in under 1 ms' do
    subscription_request = subscribe(conversations_id: conversation.id)
    expect { subscription_request }.to perform_under(1).ms.sample(20).times
  end

  it 'subscribes to a stream with iteration of at least 3000000 per second' do
    subscription_request = subscribe(conversations_id: conversation.id)
    expect { subscription_request }.to perform_at_least(3_000_000).ips
  end

  it 'transmits relevant errors when message arguments are not within permitted params' do
    subscribe(conversations_id: conversation.id)
    expect(subscription.receive({ 'conversation_id' => conversation.id })[1]['message']['type']).to eq 'errors'
    expect(subscription.receive({ 'conversation_id' => conversation.id })[1]['message']['data']).to eq [
         'User must exist'
       ]
  end

  it 'transmits relevant error when unassociated with a conversation user tries to send a message and then it deletes the message' do
    subscribe(conversations_id: conversation.id)
    expect(
      subscription.receive(
        { 'conversation_id' => conversation.id, 'body' => 'Happy New Year!', 'user_id' => user3.id }
      )[
        1
      ][
        'message'
      ][
        'type'
      ]
    ).to eq 'errors'
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
    expect(Message.all.length).to eq 0
  end

  it 'broadcasts message and does not send an email to receiver if she opts out of that notification' do
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation2.id)
    subscription.receive(
      { 'conversation_id' => conversation2.id, 'user_id' => user1.id, 'body' => 'Batman, I hate you!' }
    )
    expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
    expect(Delayed::Job.all.count).to eq 0
  end

  it 'broadcasts message and sends an email to receiver when message arguments are within permitted params' do
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation.id)
    subscription.receive(
      { 'conversation_id' => conversation.id, 'user_id' => user1.id, 'body' => 'Batman, I love you!' }
    )
    expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
    expect(Delayed::Job.all.count).to eq 1
  end

  it 'updates conversation hidden field to nil and broadcasts message when message arguments are within permitted params' do
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation3.id)
    expect(conversation3.hidden).to eq user2.id
    subscription.receive(
      { 'conversation_id' => conversation3.id, 'user_id' => user3.id, 'body' => 'Batman, I love you!' }
    )
    conversation3.reload
    expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
    expect(conversation3.hidden).to eq nil
  end

  it 'updates conversation hidden field to nil and broadcasts message in under 1 ms and with iteration rate of 3000000 per second' do
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation3.id)
    send_message =
      subscription.receive(
        { 'conversation_id' => conversation3.id, 'user_id' => user3.id, 'body' => 'Batman, I love you!' }
      )
    expect { send_message }.to perform_under(1).ms.sample(20).times
    expect { send_message }.to perform_at_least(3_000_000).ips
  end

  it 'broadcasts message with image attached' do
    image = {
      type: 'image/png',
      encoder: 'name=carbon (5).png;base64',
      data:
        'iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf',
      extension: 'png'
    }
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation.id)
    subscription.receive(
      { 'conversation_id' => conversation.id, 'user_id' => user1.id, 'body' => 'Batman, I love you!', 'image' => image }
    )
    expect(Message.last.image).to be_attached
    expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
  end

  it 'broadcasts message with image attached in under 1 ms and with iteration rate of 2000000 per second' do
    image = {
      type: 'image/png',
      encoder: 'name=carbon (5).png;base64',
      data:
        'iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf',
      extension: 'png'
    }
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation.id)
    send_message =
      subscription.receive(
        {
          'conversation_id' => conversation.id,
          'user_id' => user1.id,
          'body' => 'Batman, I love you!',
          'image' => image
        }
      )
    expect { send_message }.to perform_under(1).ms.sample(20).times
    expect { send_message }.to perform_at_least(2_000_000).ips
  end

  it 'broadcasts message with only image attached, without body' do
    image = {
      type: 'image/png',
      encoder: 'name=carbon (5).png;base64',
      data:
        'iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm+58y6yW4a2SS7O4n/eZ7vuWR35pwzvzO76zf',
      extension: 'png'
    }
    ActiveJob::Base.queue_adapter = :test
    subscribe(conversations_id: conversation.id)
    subscription.receive(
      { 'conversation_id' => conversation.id, 'user_id' => user1.id, 'body' => '', 'image' => image }
    )
    expect(Message.last.image).to be_attached
    expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
  end
end
