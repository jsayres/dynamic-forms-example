class Session < ActiveRecord::Base
  after_initialize :create_key
  before_save :set_expiration

  belongs_to :user

  validates :user, presence: true
  validates :key, presence: true

  private

  def create_key
    self.key = SecureRandom.urlsafe_base64 unless key
  end

  def set_expiration
    self.expires = DateTime.current + 1.week
  end
end
