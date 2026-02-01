class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :threats, dependent: :destroy
  has_many :workflows, dependent: :destroy

  validates :role, inclusion: { in: %w[admin analyst viewer], allow_nil: true }

  before_create :generate_api_token
  before_create :set_default_role

  def admin?
    role == "admin"
  end

  def analyst?
    role == "analyst"
  end

  def viewer?
    role == "viewer"
  end

  def regenerate_api_token!
    update(api_token: SecureRandom.hex(32))
  end

  private

  def generate_api_token
    self.api_token = SecureRandom.hex(32)
  end

  def set_default_role
    self.role ||= "viewer"
  end
end
