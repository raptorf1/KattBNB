# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_one :host_profile, dependent: :destroy
  has_many :message, dependent: :nullify
  has_many :booking, dependent: :destroy
  has_many :conversation1, :class_name => 'Conversation', :foreign_key => 'user1_id', dependent: :nullify
  has_many :conversation2, :class_name => 'Conversation', :foreign_key => 'user2_id', dependent: :nullify
  
  validates :nickname, uniqueness: { case_sensitive: false }, presence: true
  validates :location, presence: true

end
