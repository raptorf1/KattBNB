describe 'rake conversations:delete_empty_conversation', type: :task do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let!(:user2) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:user3) { FactoryBot.create(:user, email: 'cat@woman.com', nickname: 'Catwoman') }
  let!(:conversation1) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user2.id) }
  let!(:conversation2) { FactoryBot.create(:conversation, user1_id: user1.id, user2_id: user3.id) }
  let!(:message1) { FactoryBot.create(:message, conversation_id:conversation1.id, user_id: user1.id, body: 'Sweet child of mine!!!!') }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no errors' do
    expect { task.execute }.not_to raise_error
  end

  it 'deletes only empty conversations' do
    expect(Conversation.all.length).to eq 2
    task.execute
    expect(Conversation.all.length).to eq 1
    expect(Conversation.last.id).to eq conversation1.id
  end

  it 'logs to stdout' do
    expect { task.execute }.to output("1 conversation(s) succesfully deleted!\n").to_stdout
  end
end
