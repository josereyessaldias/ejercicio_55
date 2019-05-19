class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  enum role: [:admin, :player]
  attribute :role, :integer, default: :player

  has_many :user_activity
  has_many :activities, through: :user_activity
  has_many :promote_activity
  has_many :billings

  has_many :ownactivity, class_name: 'Activity', foreign_key: :owner_id

  has_many :contacting, class_name: 'Contact', foreign_key: :user_id
  has_many :contacted, class_name: 'Contact', foreign_key: :followed_id

  mount_uploader :photo, ImageUploader

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.remote_photo_url = access_token.info.profile_pic.sub('http:','https:')
    end
  end
end
