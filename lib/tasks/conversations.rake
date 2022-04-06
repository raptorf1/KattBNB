namespace :conversations do
  desc 'Deletes all empty conversations'
  task delete_empty_conversations: :environment do
    Conversation.all.each do |conversation|
      next unless !Message.where(conversation_id: conversation.id).exists?
      print "Empty conversation with id #{conversation.id} succesfully deleted!"
      conversation.destroy
    end
  end

  desc 'Deletes all unassociated conversations'
  task delete_unassociated_conversations: :environment do
    Conversation.all.each do |conversation|
      unless (conversation.user1_id == nil && conversation.user2_id == nil) ||
               (conversation.user1_id == conversation.hidden && conversation.user2_id == nil) ||
               (conversation.user2_id == conversation.hidden && conversation.user1_id == nil)
        next
      end
      print "Unassociated conversation with id #{conversation.id} succesfully deleted!"
      conversation.destroy
    end
  end
end
