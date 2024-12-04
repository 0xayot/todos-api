class User < ApplicationRecord

  devise :database_authenticatable, :registerable, :recoverable, :validatable

  validates_presence_of :email
  validates_uniqueness_of :email, on: :create

  has_many :tasks

  def authenticate(password)
    valid_for_authentication? { valid_password?(password) }
  end

  def json_attributes
    {
      id: id,
      email: email,
      created_at: created_at
    }
  end

  def as_json(options = {})
    json_attributes
  end
end
