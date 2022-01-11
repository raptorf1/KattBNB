describe 'rake conversations:delete_unassociated_conversations', type: :task do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:user3) { FactoryBot.create(:user, email: 'cat@woman.com', nickname: 'Catwoman') }
  let!(:user4) { FactoryBot.create(:user, email: 'dead@pool.com', nickname: 'Deadpool') }

  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:hidden_conversation) do
    FactoryBot.create(:conversation, user1_id: user3.id, user2_id: user4.id, hidden: user3.id)
  end

  let!(:message1) do
    FactoryBot.create(:message, conversation_id: conversation1.id, user_id: user1.id, body: 'Sweet child of mine!!!!')
  end

  let!(:message2) do
    FactoryBot.create(
      :message,
      conversation_id: conversation2.id,
      user_id: user2.id,
      body: 'Who wants to live forever???'
    )
  end

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully deletes hidden conversation' do
    before do
      user4.destroy

      hidden_conversation.reload

      @subject = task.execute
    end

    it 'runs gracefully with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'deletes unassociated conversations that existing user has hidden' do
      expect { Conversation.find(hidden_conversation.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'logs to stdout' do
      expect(@std_output).to eq("1 unassociated conversation(s) succesfully deleted!\n")
    end
  end

  describe 'successfully deletes unassociated conversations' do
    before do
      user1.destroy
      user2.destroy

      conversation1.reload
      conversation2.reload

      @subject = task.execute
    end

    it 'runs gracefully with no errors' do
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
