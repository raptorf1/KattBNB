# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  before_destroy :delete_conversations

  has_one :host_profile, dependent: :destroy
  has_many :message, dependent: :nullify
  has_many :booking, dependent: :destroy
  has_many :conversation, foreign_key: 'user1_id'
  has_many :conversation, foreign_key: 'user2_id'
  
  validates :nickname, uniqueness: { case_sensitive: false }, presence: true
  validates :location, presence: true


  def delete_conversations
 #  binding.pry
    Conversation.where('user1_id = :id OR user2_id = :id', id: id).map(&destroy)
    # :update(user1_id == self.id ? user1_id: nil : user2_id: nil))
    # user1.conversation.delete(conv)
  end
end
