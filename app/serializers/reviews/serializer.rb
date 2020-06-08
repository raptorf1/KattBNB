class Reviews::Serializer < ActiveModel::Serializer
  ActiveModelSerializers.config.default_includes = '*.*'

  attributes :id, :score, :body, :host_reply, :host_nickname, :created_at, :updated_at

  belongs_to :user, serializer: Users::Serializer

end
