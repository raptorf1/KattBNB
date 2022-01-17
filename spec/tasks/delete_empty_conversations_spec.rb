describe 'rake conversations:delete_empty_conversations', type: :task do
  let(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let(:user3) { FactoryBot.create(:user, email: 'cat@woman.com', nickname: 'Catwoman') }

  let(:conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:empty_conversation) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }

  let!(:message1) do
    FactoryBot.create(:message, conversation_id: conversation.id, user_id: user1.id, body: 'Sweet child of mine!!!!')
  end

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully' do
    before { @subject = task.execute }

    it 'runs with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'removes the empty conversation' do
      expect(Conversation.all.length).to eq 1
    end

    it 'does not remove active conversation' do
      expect(Conversation.last.id).to eq conversation.id
    end

    it 'logs to stdout' do
      expect(@std_output).to eq("1 empty conversation(s) succesfully deleted!\n")
    end
  end
end
