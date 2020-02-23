describe 'rake conversations:delete_unassociated_conversations', type: :task do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:user3) { FactoryBot.create(:user, email: 'cat@woman.com', nickname: 'Catwoman') }
  let!(:user4) { FactoryBot.create(:user, email: 'dead@pool.com', nickname: 'Deadpool') }
  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation3) { FactoryBot.create(:conversation, user1_id: user3.id, user2_id: user4.id, hidden: user3.id) }
  let!(:message1) { FactoryBot.create(:message, conversation_id:conversation1.id, user_id: user1.id, body: 'Sweet child of mine!!!!') }
  let!(:message2) { FactoryBot.create(:message, conversation_id:conversation2.id, user_id: user2.id, body: 'Who wants to live forever???') }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'deletes only unassociated conversations and their messages' do
    expect(Conversation.all.length).to eq 3
    expect(Message.all.length).to eq 2
    user1.destroy
    user2.destroy
    conversation1.reload
    conversation2.reload
    conversation3.reload
    task.execute
    expect(Conversation.all.length).to eq 1
    expect(Conversation.last.id).to eq conversation3.id
    expect(Message.all.length).to eq 0
  end

  it 'deletes unassociated conversations that existing user has hidden' do
    expect(Conversation.all.length).to eq 3
    user4.destroy
    conversation3.reload
    task.execute
    expect(Conversation.all.length).to eq 2
    expect(Conversation.first.id).to eq conversation1.id
    expect(Conversation.last.id).to eq conversation2.id
  end

  it 'logs to stdout' do
    user1.destroy
    user2.destroy
    conversation1.reload
    conversation2.reload
    conversation3.reload
    expect { task.execute }.to output("2 unassociated conversation(s) succesfully deleted!\n").to_stdout
  end

end
