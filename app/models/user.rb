# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User
  
  validates :nickname, uniqueness: { case_sensitive: false }, presence: true
  validates :location, presence: true
end
