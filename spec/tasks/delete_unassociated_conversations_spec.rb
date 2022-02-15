describe 'rake conversations:delete_unassociated_conversations', type: :task do
  let(:user_1) { FactoryBot.create(:user) }
  let(:user_2) { FactoryBot.create(:user) }
  let(:user_3) { FactoryBot.create(:user) }
  let(:user_4) { FactoryBot.create(:user) }

  let(:conversation_1) { FactoryBot.create(:conversation, user1_id: user_1.id, user2_id: user_2.id) }
  let(:conversation_2) { FactoryBot.create(:conversation, user1_id: user_1.id, user2_id: user_2.id) }
  let!(:hidden_conversation) do
    FactoryBot.create(:conversation, user1_id: user_3.id, user2_id: user_4.id, hidden: user_3.id)
  end

  let!(:message_1) { FactoryBot.create(:message, conversation_id: conversation_1.id, user_id: user_1.id) }

  let!(:message_2) { FactoryBot.create(:message, conversation_id: conversation_2.id, user_id: user_2.id) }

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully for hidden conversation' do
    before do
      user_4.destroy
      hidden_conversation.reload
      @subject = task.execute
    end

    it 'runs with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'deletes unassociated conversations that existing user has hidden' do
      expect { Conversation.find(hidden_conversation.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'logs to stdout' do
      expect(@std_output).to eq("1 unassociated conversation(s) succesfully deleted!\n")
    end
  end

  describe 'successfully for unassociated conversations' do
    before do
      user_1.destroy
      user_2.destroy
      conversation_1.reload
      conversation_2.reload
      @subject = task.execute
    end

    it 'runs with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'deletes only unassociated conversations' do
      expect(Conversation.all.length).to eq 1
    end

    it 'deletes all messages' do
      expect(Message.all.length).to eq 0
    end

    it 'logs to stdout' do
      expect(@std_output).to eq("2 unassociated conversation(s) succesfully deleted!\n")
    end
  end
end
