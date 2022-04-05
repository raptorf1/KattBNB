RSpec.describe MessageBroadcastJob, type: :job do
  let(:message) { FactoryBot.create(:message) }

  describe 'queue name' do
    it 'to be messages' do
      expect(MessageBroadcastJob.queue_name).to eq 'messages'
    end
  end

  describe 'perform_later' do
    before { User.destroy_all }

    it 'adds a job to the queue' do
      ActiveJob::Base.queue_adapter = :test
      expect { MessageBroadcastJob.perform_later }.to have_enqueued_job
    end

    it 'contains message id in the job arguments' do
      expect(MessageBroadcastJob.perform_later(message.id).arguments).to eq [message.id]
    end
  end

  describe 'perform_now' do
    it 'displays error message if message id is invalid' do
      expect(MessageBroadcastJob.perform_now(1_000_000)).to eq 'Message with id 1000000 not found'
    end

    it 'goes in the happy path flow of the job' do
      expect(MessageBroadcastJob.perform_now(message.id).inspect).to include 'PGRES_COMMAND_OK'
      expect(MessageBroadcastJob.perform_now(message.id).result_status).to eq 1
    end
  end
end
