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
end
