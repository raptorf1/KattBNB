class Conversations::IndexSerializer < ActiveModel::Serializer
  attributes :id, :msg_body, :msg_created, :hidden
  belongs_to :user1, serializer: Users::Serializer
  belongs_to :user2, serializer: Users::Serializer

  def msg_body
    unless object.message.last == nil
      if object.message.last.body == ''
        (return I18n.t('serializers.conversations.index.image_attachment'))
      else
        (return object.message.last.body)
      end
    end
  end

  def msg_created
    return object.message.last.created_at unless object.message.last == nil
  end
end
