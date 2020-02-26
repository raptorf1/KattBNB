RSpec.describe MessageBroadcastJob, :type => :job do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:message) { FactoryBot.create(:message, user_id: user1.id, conversation_id: conversation.id, body: 'Batman, I love you!') }

  describe 'queue name' do
    it 'to be messages' do
      ActiveJob::Base.queue_adapter = :test
      expect(MessageBroadcastJob.queue_name).to eq 'messages'
    end
  end

  describe 'perform_later' do
    it 'adds a job to the queue' do
      ActiveJob::Base.queue_adapter = :test
      expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
    end

    it 'contains message id in the job arguments' do
      ActiveJob::Base.queue_adapter = :test
      expect(MessageBroadcastJob.perform_later(message.id).arguments).to eq [message.id]
    end
  end

  describe 'perform_now' do
    it 'displays error message if message id is invalid' do
      ActiveJob::Base.queue_adapter = :test
      expect(MessageBroadcastJob.perform_now(1000000)).to eq 'Message with id 1000000 not found'
    end

    it 'goes in the happy path flow of the job' do
      ActiveJob::Base.queue_adapter = :test
      expect(MessageBroadcastJob.perform_now(message.id).inspect).to include 'PGRES_COMMAND_OK'
      expect(MessageBroadcastJob.perform_now(message.id).result_status).to eq 1
    end
  end
  
end
