namespace :conversations do
  desc 'Deletes all empty conversations'
  task delete_empty_conversations: :environment do
    conversations = Conversation.all
    deleted_conversations = []
    conversations.each do |conversation|
      next unless Message.where(conversation_id: conversation.id).exists? == false
      deleted_conversations.push(conversation)
      conversation.destroy
    end
    puts "#{deleted_conversations.length} empty conversation(s) succesfully deleted!"
  end

  desc 'Deletes all unassociated conversations'
  task delete_unassociated_conversations: :environment do
    conversations = Conversation.all
    unassociated_conversations = []
    conversations.each do |conversation|
      next unless (conversation.user1_id == nil && conversation.user2_id == nil) || (conversation.user1_id == conversation.hidden && conversation.user2_id == nil) || (conversation.user2_id == conversation.hidden && conversation.user1_id == nil)
      unassociated_conversations.push(conversation)
      conversation.destroy
    end
    puts "#{unassociated_conversations.length} unassociated conversation(s) succesfully deleted!"
  end
end
